#!/usr/bin/env bash
#
# Copyright 2026 Hunan Yijing Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📝 模块描述 : Docker 容器环境与代理配置模块
#  📁 文件路径 : modules/docker.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ═══════════════════════════════════════════════════════════════
# 辅助函数
# ═══════════════════════════════════════════════════════════════

is_docker_installed() {
    command_exists docker
}

# ═══════════════════════════════════════════════════════════════
# Docker 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_docker() {
    while true; do
        show_submenu "Docker管理" \
            "安装Docker系统" \
            "卸载Docker系统" \
            "配置[镜像加速]源" \
            "查看[镜像加速]配置" \
            "移除[镜像加速]配置" \
            "配置[网络代理]服务" \
            "查看[网络代理]配置" \
            "移除[网络代理]配置" \
            "智能高速拉取镜像" \
            "查看系统运行状态" \
            "安装DockerCompose" \
            "卸载DockerCompose"

        msg_prompt "请选择操作 [0-12, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_docker ;;
            2) remove_docker ;;
            3) push_path "配置镜像加速"; config_docker_mirror; pop_path; continue ;;
            4) get_docker_mirror_config ;;
            5) unconfigure_docker_mirror ;;
            6) push_path "配置网络代理"; config_docker_proxy; pop_path; continue ;;
            7) get_docker_proxy_config ;;
            8) unconfigure_docker_proxy ;;
            9) pull_docker_image_smart ;;
            10) show_docker_status ;;
            11) install_docker_compose_standalone ;;
            12) remove_docker_compose_standalone ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装 Docker
# ═══════════════════════════════════════════════════════════════

install_docker() {
    show_section "安装Docker"

    if is_docker_installed; then
        msg_info "Docker已安装"
        docker --version | sed 's/^/  /'
        return 0
    fi

    show_submenu "Docker-CE安装源选择" \
        "清华大学镜像源(推荐)" \
        "北京大学镜像源" \
        "阿里云镜像源" \
        "华为云镜像源" \
        "腾讯云镜像源" \
        "Docker官方源"

    local choice
    msg_prompt "请选择安装源 [0-6, q退出]"
    [[ $choice == "0" ]] && return 0
    [[ $choice == "q" || $choice == "Q" ]] && exit 0

    local mirror_url
    case $choice in
        1) mirror_url="https://mirrors.tuna.tsinghua.edu.cn"; msg_info "已选择清华大学镜像源" ;;
        2) mirror_url="https://mirrors.pku.edu.cn"; msg_info "已选择北京大学镜像源" ;;
        3) mirror_url="https://mirrors.aliyun.com"; msg_info "已选择阿里云镜像源" ;;
        4) mirror_url="https://mirrors.huaweicloud.com"; msg_info "已选择华为云镜像源" ;;
        5) mirror_url="https://mirrors.cloud.tencent.com"; msg_info "已选择腾讯云镜像源" ;;
        6) mirror_url="https://download.docker.com"; msg_info "已选择官方镜像源" ;;
        *) msg_error "无效选择，退出安装"; return 1 ;;
    esac

    msg_info "正在安装Docker..."

    apt_update_with_progress
    install_packages ca-certificates curl gnupg lsb-release

    local arch distro codename
    arch=$(get_arch)
    distro=$(get_distro_id)
    codename=$(get_distro_codename)

    if [[ "$codename" == "kali-rolling" ]]; then
        distro="debian"
        codename="bookworm"
        msg_info "检测到Kali Linux，将使用Debian($codename)存储库"
    fi

    install -m 0755 -d /etc/apt/keyrings
    local gpg_path="/etc/apt/keyrings/docker.asc"
    
    if [[ $choice == "6" ]]; then
        curl -fsSL "${mirror_url}/linux/${distro}/gpg" -o "$gpg_path" 2>/dev/null || \
        curl -fsSL "${mirror_url}/docker-ce/linux/${distro}/gpg" -o "$gpg_path" 2>/dev/null
    else
        curl -fsSL "${mirror_url}/docker-ce/linux/${distro}/gpg" -o "$gpg_path" 2>/dev/null || \
        curl -fsSL "${mirror_url}/linux/${distro}/gpg" -o "$gpg_path" 2>/dev/null
    fi

    if [[ ! -f "$gpg_path" ]]; then
        msg_error "无法获取 Docker GPG 密钥"
        return 1
    fi
    chmod a+r "$gpg_path"

    echo "deb [arch=$arch signed-by=$gpg_path] ${mirror_url}/docker-ce/linux/${distro} ${codename} stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt_update_with_progress
    if apt_install_with_progress docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
        enable_service docker
        start_service docker

        if action "Docker安装完成" "Docker安装失败"; then
            local current_user
            current_user=${SUDO_USER:-$USER}
            usermod -aG docker "$current_user" 2>/dev/null || true
            docker --version | sed 's/^/  /'
        else
            return 1
        fi
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载Docker
# ═══════════════════════════════════════════════════════════════

remove_docker() {
    show_section "卸载Docker"

    if ! is_docker_installed; then
        msg_info "Docker未安装"
        return 0
    fi

    if ! confirm "确定要卸载Docker吗? 所有容器和数据将被删除!"; then
        msg_info "取消卸载"
        return 0
    fi

    stop_service docker || true

    apt-get remove -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
    apt-get purge -y -qq docker-ce docker-ce-cli containerd.io 2>/dev/null || true

    rm -rf /var/lib/docker
    rm -rf /etc/docker

    msg_success "Docker已卸载"
}

# ═══════════════════════════════════════════════════════════════
# 配置国内镜像
# ═══════════════════════════════════════════════════════════════

config_docker_mirror() {
    show_section "配置Docker国内镜像"

    if ! is_docker_installed; then
        msg_error "Docker未安装"
        return 1
    fi

    local mirrors=(
        "https://docker.m.daocloud.io"
        "https://docker.1ms.run"
        "https://docker.gh-proxy.org"
        "https://docker.xuanyuan.me"
        "https://dockerproxy.net"
        "https://hub.rat.dev"
        "https://docker.m.ixdev.cn"
    )

    msg_info "正在检测镜像源可用性(请稍候)..."
    local available_mirrors=()
    
    for mirror in "${mirrors[@]}"; do
        local mirror_host=${mirror#https://}
        if timeout 10 docker pull "${mirror_host}/library/hello-world:latest" &> /dev/null; then
            msg_success "可用: $mirror"
            available_mirrors+=("$mirror")
            docker rmi "${mirror_host}/library/hello-world:latest" &> /dev/null
        else
            msg_warning "不可用: $mirror"
        fi
    done

    if [[ ${#available_mirrors[@]} -eq 0 ]]; then
        msg_error "没有检测到可用的国内镜像源"
        return 1
    fi

    mkdir -p /etc/docker
    local daemon_config="/etc/docker/daemon.json"
    
    local json="{\n  \"registry-mirrors\": [\n"
    for i in "${!available_mirrors[@]}"; do
        json+="    \"${available_mirrors[i]}\""
        [[ $((i + 1)) -lt ${#available_mirrors[@]} ]] && json+=","
        json+="\n"
    done
    json+="  ],\n  \"log-driver\": \"json-file\",\n  \"log-opts\": {\n    \"max-size\": \"100m\",\n    \"max-file\": \"3\"\n  }\n}"

    echo -e "$json" > "$daemon_config"

    restart_service docker
    if action "镜像配置已生效(共配置${#available_mirrors[@]}个源)" "Docker重启失败，请检查配置"; then
        get_docker_mirror_config
        pause
    fi
}

get_docker_mirror_config() {
    show_section "当前Docker镜像配置"
    if [[ -f "/etc/docker/daemon.json" ]]; then
        cat "/etc/docker/daemon.json" | sed 's/^/  /'
    else
        msg_warning "未找到镜像配置文件 (/etc/docker/daemon.json)"
    fi
}

unconfigure_docker_mirror() {
    show_section "取消Docker镜像加速"
    if [[ -f "/etc/docker/daemon.json" ]]; then
        rm -f "/etc/docker/daemon.json"
        restart_service docker
        msg_success "镜像配置已清除"
    else
        msg_info "当前未配置镜像加速"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 代理配置管理
# ═══════════════════════════════════════════════════════════════

config_docker_proxy() {
    show_section "配置Docker网络代理"

    if ! is_docker_installed; then
        msg_error "Docker未安装"
        return 1
    fi

    show_submenu "代理协议选择" \
        "HTTP / HTTPS" \
        "SOCKS5"

    local type
    msg_prompt "请选择协议 [0-2]" "type"
    [[ $type == "0" ]] && return 0

    local proxy_proto="http"
    [[ $type == "2" ]] && proxy_proto="socks5"

    local proxy_addr
    msg_prompt "请输入代理地址(如127.0.0.1:7890)" "proxy_addr"

    if [[ -z $proxy_addr ]]; then
        msg_error "代理地址不能为空"
        pause
        return 1
    fi

    local proxy_url="${proxy_proto}://${proxy_addr}"
    local proxy_dir="/etc/systemd/system/docker.service.d"
    mkdir -p "$proxy_dir"

    cat > "$proxy_dir/proxy.conf" << EOF
[Service]
Environment="HTTP_PROXY=$proxy_url"
Environment="HTTPS_PROXY=$proxy_url"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

    systemctl daemon-reload
    restart_service docker
    if action "代理配置已生效: $proxy_url" "Docker重启失败"; then
        get_docker_proxy_config
        pause
    fi
}

get_docker_proxy_config() {
    show_section "当前Docker代理配置"
    local config="/etc/systemd/system/docker.service.d/proxy.conf"
    if [[ -f "$config" ]]; then
        cat "$config" | sed 's/^/  /'
    else
        msg_warning "未找到代理配置文件 ($config)"
    fi
}

unconfigure_docker_proxy() {
    show_section "取消Docker网络代理"
    local config="/etc/systemd/system/docker.service.d/proxy.conf"
    if [[ -f "$config" ]]; then
        rm -f "$config"
        systemctl daemon-reload
        restart_service docker
        msg_success "代理配置已清除"
    else
        msg_info "当前未配置网络代理"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 镜像与容器辅助工具
# ═══════════════════════════════════════════════════════════════

pull_docker_image_smart() {
    show_section "智能拉取Docker镜像"
    
    if ! is_docker_installed; then
        msg_error "Docker未安装"
        return 1
    fi

    local image_name
    msg_prompt "请输入要拉取的镜像名称(如nginx:latest)" "image_name"
    [[ -z $image_name ]] && { msg_error "镜像名称不能为空"; return 1; }

    local mirrors=(
        "docker.io"
        "docker.1ms.run"
        "docker.gh-proxy.org"
        "docker.xuanyuan.me"
        "docker.m.daocloud.io"
        "dockerproxy.net"
        "hub.rat.dev"
        "docker.m.ixdev.cn"
    )

    msg_info "开始尝试从多个源拉取:$image_name"
    
    for mirror in "${mirrors[@]}"; do
        local mirror_host=${mirror#https://}
        msg_info "尝试源: $mirror_host"
        
        if timeout 10 docker pull "${mirror_host}/library/hello-world:latest" &> /dev/null; then
            msg_success "源 $mirror_host 可用，正在拉取目标镜像..."
            docker rmi "${mirror_host}/library/hello-world:latest" &> /dev/null
            
            local target_pull_name="${mirror_host}/${image_name}"
            if [[ "$mirror_host" == "docker.io" ]]; then
                target_pull_name="$image_name"
            fi

            if timeout 300 docker pull "$target_pull_name" 2>&1 | sed 's/^/  /'; then
                if [[ "$target_pull_name" != "$image_name" ]]; then
                    local img_id
                    img_id=$(docker images -q "$target_pull_name" | head -n1)
                    if [[ -n $img_id ]]; then
                        docker tag "$img_id" "$image_name" >/dev/null 2>&1
                        docker rmi "$target_pull_name" &> /dev/null
                    fi
                fi
                msg_success "镜像拉取成功:$image_name"
                return 0
            else
                msg_warning "源 $mirror_host 拉取失败，尝试下一个源..."
            fi
        else
            msg_warning "源 $mirror_host 连通性测试失败"
        fi
    done

    msg_error "所有源均尝试失败！"
    msg_info "可能的排查方向："
    echo "  1. 请检查镜像名称是否正确: ${BRIGHT_YELLOW}$image_name${NC}"
    echo "  2. 请确认该 Tag 是否存在于 Docker Hub"
    echo "  3. 如果是私有镜像，请先执行 ${BRIGHT_WHITE}docker login${NC}"
    echo "  4. 当前网络可能完全无法访问已配置的所有加速源"
    return 1
}

# ═══════════════════════════════════════════════════════════════
# Docker Compose 管理 (Standalone)
# ═══════════════════════════════════════════════════════════════

install_docker_compose_standalone() {
    show_section "安装Docker Compose (Standalone)"
    
    if command_exists docker-compose; then
        msg_info "检测到已安装DockerCompose"
        docker-compose --version | sed 's/^/  /'
        if ! confirm "是否重新安装?"; then return 0; fi
    fi

    show_submenu "Compose安装源选择" \
        "Gitee镜像源(国内推荐)" \
        "Github官方源"

    local choice
    msg_prompt "请选择安装源 [0-2]"
    [[ $choice == "0" ]] && return 0

    local url
    if [[ $choice == "1" ]]; then
        msg_info "获取Gitee最新版本..."
        local tag
        tag=$(curl -s https://gitee.com/api/v5/repos/yijingsec/compose/releases/latest | grep -E -o '"tag_name":"([^"]+)"' | awk -F\" '{print $4}')
        url="https://gitee.com/yijingsec/compose/releases/download/${tag}/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
    else
        msg_info "获取Github最新版本..."
        local tag
        tag=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        url="https://github.com/docker/compose/releases/download/${tag}/docker-compose-$(uname -s)-$(uname -m)"
    fi

    msg_info "正在下载: $url"
    local dest="/usr/local/bin/docker-compose"
    download_file "$url" "$dest"
    if action "DockerCompose安装成功" "下载失败"; then
        chmod +x "$dest"
        docker-compose --version | sed 's/^/  /'
    else
        return 1
    fi
}

remove_docker_compose_standalone() {
    show_section "卸载DockerCompose(Standalone)"
    if [[ -f "/usr/local/bin/docker-compose" ]]; then
        rm -f "/usr/local/bin/docker-compose"
        msg_success "已删除/usr/local/bin/docker-compose"
    else
        msg_info "未检测到独立版DockerCompose"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 查看Docker状态
# ═══════════════════════════════════════════════════════════════

show_docker_status() {
    show_section "Docker运行状态"

    if ! is_docker_installed; then
        msg_warning "Docker未安装"
        return 1
    fi

    local docker_ver compose_ver service_status storage_driver root_dir containers_running containers_total images_count disk_usage
    docker_ver=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
    compose_ver=$(docker compose version 2>/dev/null | awk '{print $4}')
    [[ -z $compose_ver ]] && compose_ver="未安装"
    
    if is_service_active docker; then
        service_status="${GREEN}● 正在运行${NC}"
    else
        service_status="${RED}● 已停止${NC}"
    fi

    storage_driver=$(docker info 2>/dev/null | grep "Storage Driver" | cut -d: -f2 | xargs)
    root_dir=$(docker info 2>/dev/null | grep "Docker Root Dir" | cut -d: -f2 | xargs)
    containers_running=$(docker ps -q 2>/dev/null | wc -l)
    containers_total=$(docker ps -aq 2>/dev/null | wc -l)
    images_count=$(docker images -q 2>/dev/null | wc -l)
    disk_usage=$(docker system df 2>/dev/null | grep "Total" -A 1 | tail -n 1 | awk '{print $4}')

    echo ""
    echo -e "  ${BRIGHT_CYAN}📦 版本信息${NC}"
    draw_line "-" "${BRIGHT_CYAN}"
    echo -e "  ${CYAN}Docker${NC}      : ${WHITE}${BOLD}${docker_ver}${NC}"
    echo -e "  ${CYAN}Compose${NC}     : ${WHITE}${BOLD}${compose_ver}${NC}"
    
    echo ""
    echo -e "  ${BRIGHT_CYAN}⚙️ 服务运行${NC}"
    draw_line "-" "${BRIGHT_CYAN}"
    echo -e "  ${CYAN}核心服务${NC}    : ${service_status}"
    echo -e "  ${CYAN}存储驱动${NC}    : ${WHITE}${storage_driver:-未知}${NC}"
    echo -e "  ${CYAN}根目录${NC}      : ${WHITE}${root_dir:-未知}${NC}"

    echo ""
    echo -e "  ${BRIGHT_CYAN}📊 资源统计${NC}"
    draw_line "-" "${BRIGHT_CYAN}"
    echo -e "  ${CYAN}运行中容器${NC}  : ${BRIGHT_GREEN}${containers_running}${NC}"
    echo -e "  ${CYAN}已停止容器${NC}  : ${YELLOW}$((containers_total - containers_running))${NC}"
    echo -e "  ${CYAN}本地镜像数${NC}  : ${BRIGHT_WHITE}${images_count}${NC}"
    echo -e "  ${CYAN}磁盘总占用${NC}  : ${BRIGHT_MAGENTA}${disk_usage:-0B}${NC}"
    echo ""
}

register_main_menu "配置Docker" "config_docker"
