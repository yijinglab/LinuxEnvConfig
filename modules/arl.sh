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
#  📝 模块描述 : 灯塔 ARL 资产侦察系统配置模块
#  📁 文件路径 : modules/arl.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# ARL配置主菜单
# ═══════════════════════════════════════════════════════════════

config_arl() {
    while true; do
        show_submenu "ARL灯塔配置" \
            "安装ARL" \
            "停止ARL" \
            "启动ARL" \
            "卸载ARL" \
            "添加指纹"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_arl ;;
            2) stop_arl ;;
            3) start_arl ;;
            4) remove_arl ;;
            5) add_fingerprint_to_arl ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装灯塔ARL
# ═══════════════════════════════════════════════════════════════

install_arl() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装灯塔ARL"
    
    local default_ip
    default_ip=$(get_best_ip)
    local host_ip
    read -r -p "  ${CYAN}输入启动灯塔ARL的主机地址 [${default_ip}]: ${NC}" host_ip
    host_ip="${host_ip:-$default_ip}"

    msg_info "正在预拉取核心镜像..."
    docker_pull_image "registry.cn-hangzhou.aliyuncs.com/mingy123/rabbitmq:3.8.19-management-alpine"
    docker_pull_image "registry.cn-hangzhou.aliyuncs.com/mingy123/mongo:4.0.27"

    sudo mkdir -p /opt/docker_arl
    msg_info "开始下载ARL压缩包..."
    download_file "https://gitee.com/yijingsec/ARL-docker/raw/master/docker.zip" "/opt/docker_arl/docker.zip"
    if ! action "下载ARL压缩包成功" "下载ARL压缩包失败"; then
        return 1
    fi

    msg_info "开始解压ARL压缩包..."
    cd /opt/docker_arl || return 1
    sudo unzip -o docker.zip > /dev/null 2>&1

    msg_info "启动灯塔ARL服务..."
    sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'
    if action "安装灯塔ARL成功" "安装灯塔ARL失败"; then
        draw_line "-"
        msg_star "访问地址: https://${host_ip}:5003"
        msg_star "用户名  : admin"
        msg_star "密    码: arlpass"
        draw_line "-"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 停止灯塔ARL
# ═══════════════════════════════════════════════════════════════

stop_arl() {
    show_section "停止灯塔ARL"
    check_docker_compose || return 1
    
    if [[ ! -d "/opt/docker_arl" ]]; then
        msg_error "未找到ARL安装目录: /opt/docker_arl"
        return 1
    fi

    cd /opt/docker_arl || return 1
    
    msg_info "检测服务状态..."
    if sudo "${COMPOSE_CMD[@]}" ps | grep -E "arl_|Up" >/dev/null 2>&1; then
        msg_info "正在停止服务..."
        sudo "${COMPOSE_CMD[@]}" stop 2>&1 | sed 's/^/  /'
        if ! action "停止灯塔ARL完成" "停止服务失败"; then
            return 1
        fi
    else
        msg_info "灯塔ARL服务当前未处于运行状态"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 启动灯塔ARL
# ═══════════════════════════════════════════════════════════════

start_arl() {
    show_section "启动灯塔ARL"
    check_docker_compose || return 1

    if [[ ! -d "/opt/docker_arl" ]]; then
        msg_error "未找到ARL安装目录, 请先安装"
        return 1
    fi

    local default_ip
    default_ip=$(get_best_ip)
    local host_ip
    read -r -p "  ${CYAN}输入启动灯塔ARL的主机地址 [${default_ip}]: ${NC}" host_ip
    host_ip="${host_ip:-$default_ip}"

    cd /opt/docker_arl || return 1

    msg_info "尝试启动服务..."
    if sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'; then
        msg_success "启动灯塔ARL完成"
        draw_line "-"
        msg_star "访问地址: https://${host_ip}:5003"
        msg_star "用户名  : admin"
        msg_star "密    码: arlpass"
        draw_line "-"
    else
        msg_error "启动灯塔ARL失败"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载灯塔ARL
# ═══════════════════════════════════════════════════════════════

remove_arl() {
    show_section "卸载灯塔ARL"
    check_docker_compose || return 1

    if [[ -d "/opt/docker_arl" ]]; then
        if confirm "检测到ARL安装目录, 确定要删除吗?"; then
            msg_info "停止并清理ARL容器..."
            cd /opt/docker_arl || return 1
            sudo "${COMPOSE_CMD[@]}" down -v >/dev/null 2>&1
            
            msg_info "删除ARL相关数据卷..."
            sudo docker volume rm arl_db >/dev/null 2>&1
            
            msg_info "清理安装目录..."
            cd ~ || return 1
            sudo rm -rf /opt/docker_arl
            msg_success "物理环境清理完成"
        fi
    else
        msg_info "未检测到ARL安装目录, 跳过物理清理"
    fi

    local images
    images=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "arl|rabbitmq:3.8.19|mongo:4.0.27" | grep -v "TAG" || true)
    
    if [[ -n "$images" ]]; then
        echo -e "  ${YELLOW}发现相关镜像:${NC}"
        echo "    - ${images//$'\n'/$'\n'    - }"
        if confirm "是否删除上述ARL相关Docker镜像?"; then
            msg_info "正在清理镜像..."
            echo "$images" | while read -r img; do
                sudo docker rmi "$img" >/dev/null 2>&1 && msg_info "已删除: $img" | sed 's/^/  /'
            done
            msg_success "镜像清理操作完成"
        fi
    fi

    msg_success "灯塔ARL卸载流程执行完毕"
}

# ═══════════════════════════════════════════════════════════════
# 给ARL添加指纹
# ═══════════════════════════════════════════════════════════════

add_fingerprint_to_arl() {
    show_section "给ARL添加指纹"
    
    if [[ ! -d "/opt/docker_arl" ]]; then
        msg_error "未找到ARL安装目录, 无法添加指纹"
        return 1
    fi

    local default_ip
    default_ip=$(get_best_ip)
    local arl_ip
    read -r -p "  ${CYAN}请输入ARL的IP地址 [${default_ip}]: ${NC}" arl_ip
    arl_ip="${arl_ip:-$default_ip}"
    
    local arl_pass
    read -r -p "  ${CYAN}请输入ARL的密码 [arlpass]: ${NC}" arl_pass
    arl_pass="${arl_pass:-arlpass}"

    msg_info "准备指纹更新脚本..."
    sudo rm -rf /opt/docker_arl/ARL-Finger-ADD
    if sudo git clone https://gitee.com/yijingsec/ARL-Finger-ADD.git /opt/docker_arl/ARL-Finger-ADD 2>&1 | sed 's/^/  /'; then
        cd /opt/docker_arl/ARL-Finger-ADD || return 1
        
        local py_cmd=""
        if command -v python3 &>/dev/null; then
            py_cmd="python3"
        elif command -v python &>/dev/null; then
            py_cmd="python"
        fi

        if [[ -n "$py_cmd" ]]; then
            msg_info "正在执行指纹添加 (这可能需要一些时间)..."
            sudo "$py_cmd" ARL-Finger-ADD.py "https://${arl_ip}:5003/" admin "${arl_pass}" 2>&1 | sed 's/^/  /'
            msg_success "指纹添加任务已提交"
        else
            msg_error "未检测到Python环境, 请先安装python3"
            return 1
        fi
    else
        msg_error "克隆指纹项目失败"
        return 1
    fi
}

register_main_menu "配置ARL灯塔" "config_arl"
