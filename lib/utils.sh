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
#  📝 模块描述 : 系统实用工具与包/服务管理
#  📁 文件路径 : lib/utils.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 文件备份工具
# ═══════════════════════════════════════════════════════════════

backup_file() {
    local file="$1"
    local backup_suffix="${2:-.bak}"
    local desc="${3:-}"

    if [[ -f $file ]]; then
        local backup
        if [[ -n $desc ]]; then
            backup="${file}${backup_suffix}.${desc}.$(date +%Y%m%d_%H%M%S)"
        else
            backup="${file}${backup_suffix}.$(date +%Y%m%d_%H%M%S)"
        fi
        cp "$file" "$backup"
        msg_info "已备份: $file → $backup"
        return 0
    else
        msg_warning "文件不存在: $file"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 系统信息查询
# ═══════════════════════════════════════════════════════════════

get_arch() { dpkg --print-architecture 2>/dev/null || uname -m; }
get_memory_info() { free -h 2>/dev/null | grep "^Mem:" | awk '{print $2}'; }
get_disk_usage() { df -h / 2>/dev/null | tail -1 | awk '{print $5}'; }

# ═══════════════════════════════════════════════════════════════
# APT软件包管理
# ═══════════════════════════════════════════════════════════════

is_package_installed() { dpkg -l "$1" 2>/dev/null | grep -q "^ii"; }
is_package_available() { apt-cache show "$1" >/dev/null 2>&1; }

apt_update_with_progress() {
    msg_info "正在从软件源同步软件包索引 (请稍候)..."
    show_progress 5 100
    local status=0
    DEBIAN_FRONTEND=noninteractive apt-get update -o APT::Status-Fd=3 3>&1 1>/dev/null 2>/dev/null | while read -r line; do
        if [[ "$line" =~ ^(progress|dlstatus): ]]; then
            local percent
            percent=$(echo "$line" | cut -d: -f3 | tr -d ' ' | cut -d. -f1)
            if [[ "$percent" =~ ^[0-9]+$ ]]; then
                show_progress "$percent" 100
            fi
        fi
    done
    status=${PIPESTATUS[0]}
    show_progress 100 100
    echo "" >&2
    return "$status"
}

apt_install_with_progress() {
    msg_info "正在下载并安装软件包..."
    show_progress 5 100
    local status=0
    DEBIAN_FRONTEND=noninteractive apt-get install -y -o APT::Status-Fd=3 "$@" 3>&1 1>/dev/null 2>/dev/null | while read -r line; do
        if [[ "$line" =~ ^(progress|status): ]]; then
            local percent
            percent=$(echo "$line" | cut -d: -f3 | tr -d ' ' | cut -d. -f1)
            if [[ "$percent" =~ ^[0-9]+$ ]]; then
                show_progress "$percent" 100
            fi
        fi
    done
    status=${PIPESTATUS[0]}
    show_progress 100 100
    echo "" >&2
    return "$status"
}

install_packages() {
    local missing=()
    for pkg in "$@"; do if ! is_package_installed "$pkg"; then missing+=("$pkg"); fi; done
    if [[ ${#missing[@]} -eq 0 ]]; then msg_info "所有包已安装"; return 0; fi
    msg_info "准备安装缺失组件: ${missing[*]}"
    apt_update_with_progress
    if apt_install_with_progress "${missing[@]}"; then
        msg_success "软件包安装成功"
        return 0
    fi
    msg_error "软件包安装失败"
    return 1
}

install_package() { install_packages "$1"; }

remove_package() {
    if ! is_package_installed "$1"; then msg_info "$1未安装"; return 0; fi
    msg_info "正在卸载$1..."
    if DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq "$1" >/dev/null 2>&1; then
        msg_success "$1卸载成功"
        return 0
    fi
    msg_error "$1卸载失败"
    return 1
}

# ═══════════════════════════════════════════════════════════════
# Systemd服务管理
# ═══════════════════════════════════════════════════════════════

is_service_active() { systemctl is-active --quiet "$1" 2>/dev/null; }

start_service() {
    msg_info "正在启动$1服务..."
    if systemctl start "$1" 2>/dev/null; then
        msg_success "已启动$1服务"; return 0
    fi
    msg_error "$1启动失败"; return 1
}

stop_service() {
    msg_info "正在停止$1服务..."
    if systemctl stop "$1" 2>/dev/null; then
        msg_success "已停止$1服务"; return 0
    fi
    msg_error "停止$1服务失败"; return 1
}

restart_service() {
    msg_info "正在重启$1服务..."
    if systemctl restart "$1" 2>/dev/null; then
        msg_success "已重启$1服务"; return 0
    fi
    msg_error "重启$1服务失败"; return 1
}

enable_service() { systemctl enable "$1" 2>/dev/null && msg_success "已启用 $1 开机自启"; }
disable_service() { systemctl disable "$1" 2>/dev/null && msg_success "已取消 $1 开机自启"; }

# ═══════════════════════════════════════════════════════════════
# Docker环境检测与初始化
# ═══════════════════════════════════════════════════════════════

check_docker() {
    if ! command_exists docker; then
        msg_info "Docker未安装, 开始尝试安装..."
        if declare -f install_docker >/dev/null; then
            install_docker
        else
            msg_error "无法找到安装Docker的函数, 请先手动安装Docker"
            return 1
        fi
    fi

    if ! is_service_active docker; then
        msg_info "正在启动Docker服务..."
        start_service docker
    fi
    return 0
}

check_docker_compose() {
    if declare -p COMPOSE_CMD >/dev/null 2>&1 && [[ "$(declare -p COMPOSE_CMD)" == *"="* ]] && [[ "${COMPOSE_CMD[0]-}" =~ ^docker ]]; then
        return 0
    fi
    # shellcheck disable=SC2034
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(docker compose)
        return 0
    elif command_exists docker-compose; then
        COMPOSE_CMD=(docker-compose)
        return 0
    else
        msg_info "Docker Compose未安装, 开始尝试安装..."
        if declare -f install_docker_compose_standalone >/dev/null; then
            install_docker_compose_standalone
            COMPOSE_CMD=(docker-compose)
            return 0
        else
            msg_error "无法找到安装Docker Compose的函数, 请先手动安装"
            return 1
        fi
    fi
}

docker_pull_image() {
    local image="$1"
    msg_info "正在拉取镜像:${image}..."
    
    local prev_msg=""
    local lines_printed=0
    
    docker pull "$image" 2>&1 | stdbuf -oL grep -E "^[a-f0-9]{12}:|Digest:|Status:" | while read -r line; do
        local clean_line
        clean_line=$(echo "$line" | xargs | cut -c 1-80)
        [[ -z "$clean_line" ]] && continue
        
        while [[ $lines_printed -gt 0 ]]; do
            printf "\033[A\r\033[K"
            ((lines_printed--))
        done
        
        if [[ -n "$prev_msg" ]]; then
            printf "  ${GRAY}➜ %s${NC}\n" "$prev_msg"
            printf "  ${BRIGHT_BLUE}➜${NC} ${CYAN}%s${NC}\n" "$clean_line"
            lines_printed=2
        else
            printf "  ${BRIGHT_BLUE}➜${NC} ${CYAN}%s${NC}\n" "$clean_line"
            lines_printed=1
        fi
        prev_msg="$clean_line"
    done

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${image}"; then
        return 0
    else
        msg_error "镜像${image}拉取失败"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# Docker容器生命周期管理
# ═══════════════════════════════════════════════════════════════

container_exists() { docker inspect "$1" >/dev/null 2>&1; }
container_running() { [[ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" == "true" ]]; }
docker_image_exists() { docker image inspect "$1" >/dev/null 2>&1; }

docker_stop_container() {
    local container="$1" label="${2:-$1}"
    if ! container_running "$container"; then
        msg_info "${label}容器当前未处于运行状态"
        return 0
    fi
    msg_info "正在停止容器..."
    docker stop "$container" >/dev/null 2>&1
    action "${label}服务已停止" "停止服务失败"
}

docker_start_container() {
    local container="$1" label="${2:-$1}"
    if ! container_exists "$container"; then
        msg_error "未找到${label}容器, 请先执行安装"
        return 1
    fi
    msg_info "正在启动容器服务..."
    docker start "$container" >/dev/null 2>&1
    if action "${label}服务启动成功" "启动服务失败"; then
        return 0
    else
        return 1
    fi
}

docker_remove_container_and_image() {
    local container="$1" image="$2" label="${3:-$1}"
    local found=false

    if container_exists "$container"; then
        found=true
        if confirm "检测到${label}容器, 确定要移除吗?"; then
            msg_info "正在移除容器..."
            docker rm -f "$container" >/dev/null 2>&1
            msg_success "${label}容器移除成功"
        fi
    fi

    if docker_image_exists "$image"; then
        found=true
        if confirm "检测到${label}相关Docker镜像, 是否执行清理?"; then
            msg_info "正在清理本地镜像..."
            docker rmi "$image" >/dev/null 2>&1 || true
            msg_success "镜像清理完成"
        fi
    fi

    if [[ "$found" == "false" ]]; then
        msg_info "未检测到${label}相关的容器或镜像, 可能已卸载"
    else
        msg_success "${label}卸载操作完成"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 文件下载工具
# ═══════════════════════════════════════════════════════════════

download_file() {
    local url="$1"
    local output="$2"
    local ua="${3:-Wget/1.21.1}"
    
    local success=false
    local filename; filename=$(basename "$output")
    if command_exists wget; then
        # 使用 PIPESTATUS 准确获取 wget 的退出状态
        sudo wget -q --user-agent="$ua" --show-progress --progress=bar:force "$url" -O "$output" 2>&1 | while read -r -d $'\r' line; do
            local percent
            percent=$(echo "$line" | grep -oE "[0-9]+%" | tail -n 1)
            [[ -n "$percent" ]] && printf "\r  ${BRIGHT_BLUE}➜${NC} ${CYAN}正在下载 [%s]: %-4s${NC}\033[K" "$filename" "$percent"
        done
        
        if [[ ${PIPESTATUS[0]} -eq 0 && -f "$output" ]]; then
            printf "\r  ${BRIGHT_BLUE}➜${NC} ${CYAN}正在下载 [%s]: 100%%${NC}\033[K\n" "$filename"
            success=true
        fi
    fi
    
    if [[ "$success" == "false" ]] && command_exists curl; then
        msg_info "尝试使用 curl 备用下载..."
        sudo curl -# -L -A "$ua" -o "$output" "$url" 2>&1 | while read -r -d $'\r' line; do
            local percent
            percent=$(echo "$line" | grep -oE "[0-9.]+(%)?" | tail -n 1)
            [[ -n "$percent" ]] && printf "\r  ${BRIGHT_BLUE}➜${NC} ${CYAN}正在下载 [%s]: %-6s${NC}\033[K" "$filename" "$percent"
        done
        
        if [[ ${PIPESTATUS[0]} -eq 0 && -f "$output" ]]; then
            printf "\r  ${BRIGHT_BLUE}➜${NC} ${CYAN}正在下载 [%s]: 100%%${NC}\033[K\n" "$filename"
            success=true
        fi
    fi
    
    if [[ "$success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# Docker部署交互
# ═══════════════════════════════════════════════════════════════

docker_wait_healthy() {
    local container="$1" label="${2:-$1}" timeout="${3:-30}"
    msg_info "正在等待服务初始化..."
    local count=0
    while [[ $count -lt $timeout ]]; do
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            msg_success "容器处于运行状态"
            return 0
        fi
        sleep 1
        ((count++))
    done
    msg_warning "${label}容器启动超时, 请稍后通过 docker ps 检查"
    return 1
}

prompt_host_ip() {
    local label="${1:-服务}" var_name="${2:-host_ip}" do_validate="${3:-true}"
    local default_ip
    default_ip=$(get_best_ip)
    local input_val
    read -r -p "  ${CYAN}请输入启动${label}的主机地址 [${default_ip}]: ${NC}" input_val
    input_val="${input_val:-$default_ip}"
    if [[ "$do_validate" == "true" ]]; then
        validate_ip "$input_val" || return 1
    fi
    printf -v "$var_name" "%s" "$input_val"
}

prompt_host_port() {
    local label="${1:-服务}" default_port="$2" var_name="${3:-host_port}"
    local input_val
    read -r -p "  ${CYAN}请输入${label}映射端口 [${default_port}]: ${NC}" input_val
    input_val="${input_val:-$default_port}"
    validate_port "$input_val" || return 1
    printf -v "$var_name" "%s" "$input_val"
}

show_access_info() {
    draw_line "-"
    local line
    for line in "$@"; do
        msg_star "$line"
    done
    draw_line "-"
}

# ═══════════════════════════════════════════════════════════════
# DockerCompose生命周期管理
# ═══════════════════════════════════════════════════════════════

# 内部函数：实现双行静默刷新渲染
_docker_compose_render_premium() {
    local label="$1"
    local action="$2"
    shift 2
    local compose_args=("$action")
    [[ "$action" == "up" ]] && compose_args=("up" "-d")
    
    local prev_msg=""
    # 忽略 Waiting 状态，捕获核心变更
    sudo "${COMPOSE_CMD[@]}" "${compose_args[@]}" "$@" 2>&1 | while read -r line; do
        if [[ "$line" =~ (Created|Started|Healthy|Running|Stopped|Removing|Removed|Pulled|Up-to-date) ]] && [[ ! "$line" =~ "Waiting" ]]; then
            local clean_line; clean_line=$(echo "$line" | grep -oE "(Container|Network|Volume|Service|Image) [^ ]+ (Created|Started|Healthy|Running|Stopped|Removing|Removed|Pulled|Up-to-date)" | head -n 1)
            [[ -z "$clean_line" ]] && clean_line=$(echo "$line" | xargs | cut -c 1-60)
            
            # 双行渲染逻辑
            if [[ -n "$prev_msg" ]]; then
                printf "\033[A\r\033[K" # 回退一行并清除
                printf "\033[A\r\033[K" # 再回退一行并清除
                printf "  ${GRAY}➜ %s${NC}\n" "$prev_msg"
            fi
            printf "  ${BRIGHT_BLUE}➜${NC} ${CYAN}%s${NC}\n" "$clean_line"
            prev_msg="$clean_line"
        fi
    done
}

docker_compose_stop() {
    local dir="$1" label="${2:-服务}"
    if [[ ! -d "$dir" ]]; then
        msg_error "未找到${label}安装目录: $dir"
        return 1
    fi
    check_docker_compose || return 1
    cd "$dir" || return 1
    msg_info "正在停止${label}容器服务..."
    _docker_compose_render_premium "${label}" "stop"
    action "${label}服务已停止" "${label}服务停止失败"
}

docker_compose_start() {
    local dir="$1" label="${2:-服务}" mode="${3:-start}"
    if [[ ! -d "$dir" ]]; then
        msg_error "未找到${label}安装目录, 请先执行安装"
        return 1
    fi
    check_docker_compose || return 1
    cd "$dir" || return 1
    msg_info "正在启动${label}容器服务..."
    local action="start"
    [[ "$mode" == "up" ]] && action="up"
    _docker_compose_render_premium "${label}" "$action"
    action "${label}服务启动成功" "${label}服务启动失败"
}

docker_compose_remove() {
    local dir="$1" label="$2"
    shift 2
    local images=("$@")
    local found=false

    if [[ -d "$dir" ]]; then
        found=true
        if confirm "检测到${label}安装目录, 确定要卸载吗?"; then
            check_docker_compose || return 1
            msg_info "正在清理容器资源..."
            cd "$dir" || return 1
            sudo "${COMPOSE_CMD[@]}" down >/dev/null 2>&1

            msg_info "正在清理物理文件..."
            cd ~ || return 1
            sudo rm -rf "$dir"
            msg_success "物理环境清理完成"
        fi
    fi

    if [[ ${#images[@]} -gt 0 ]]; then
        local image_exists=false
        for img in "${images[@]}"; do
            if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${img}"; then
                image_exists=true
                break
            fi
        done

        if [[ "$image_exists" == "true" ]]; then
            found=true
            if confirm "检测到${label}相关Docker镜像, 是否执行清理?"; then
                msg_info "正在清理本地镜像..."
                for img in "${images[@]}"; do
                    docker rmi "${img}" >/dev/null 2>&1 || true
                done
                msg_success "镜像清理完成"
            fi
        fi
    fi

    if [[ "$found" == "false" ]]; then
        msg_info "未检测到${label}相关的环境资源, 可能已卸载"
    else
        msg_success "${label}卸载操作完成"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 通用备份管理
# ═══════════════════════════════════════════════════════════════

backup_list() {
    ls -t "${1}".bak* 2>/dev/null
}

backup_display() {
    local label="$1"
    shift
    local backups=("$@")
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        msg_warning "目前没有任何${label}备份文件"
        return 1
    fi

    echo ""
    local widths="6 32 12 18"
    msg_table_row "$widths" "${BOLD}编号" "备份文件名" "标签" "修改时间${NC}"
    draw_line "-"

    local i
    for i in "${!backups[@]}"; do
        local file="${backups[$i]}"
        local filename
        filename=$(basename "$file")
        
        local tag="legacy"
        if [[ $filename =~ \.bak\.([^.]+)\. ]]; then
            tag="${BASH_REMATCH[1]}"
        fi
        
        local mtime
        mtime=$(date -r "$file" "+%Y-%m-%d %H:%M")
        
        msg_table_row "$widths" "$((i+1))" "$filename" "$tag" "$mtime"
    done
    echo ""
    return 0
}

backup_preview() {
    local file="$1" pattern="${2:-.*}"
    local total
    total=$(grep -c "$pattern" "$file" 2>/dev/null || echo 0)

    msg_info "备份内容预览($file):"
    draw_line "-" "${GRAY}"
    grep "$pattern" "$file" | head -n 5 | sed 's/^/    /'
    if [[ $total -gt 5 ]]; then
        echo "    ... (共${total}条记录)"
    fi
    draw_line "-" "${GRAY}"
}

backup_select() {
    local title="$1" target_file="$2" label="$3"
    show_section "$title"

    local backups=()
    mapfile -t backups < <(backup_list "$target_file")

    if ! backup_display "$label" "${backups[@]}"; then return 1; fi

    local choice
    msg_prompt "请输入备份编号 [1-${#backups[@]}, 0取消]"

    if [[ $choice == "0" ]]; then
        return 1
    fi

    if ! [[ $choice =~ ^[0-9]+$ ]] || [[ $choice -lt 1 || $choice -gt ${#backups[@]} ]]; then
        msg_error "无效编号"
        return 1
    fi

    _SELECTED_BACKUP="${backups[$((choice-1))]}"
    return 0
}

backup_clear_all() {
    local label="$1" target_file="$2"
    show_section "清空全部${label}备份"
    
    local backups=()
    mapfile -t backups < <(backup_list "$target_file")
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        msg_warning "没有备份文件可清理"
        return 0
    fi
    
    msg_warning "即将删除 ${#backups[@]} 个备份文件"
    if confirm "你确定要清空所有的${label}历史备份吗?"; then
        if confirm "请再次确认(操作不可恢复):"; then
            rm -f "${target_file}".bak*
            msg_success "所有备份清理完毕"
        fi
    fi
}
