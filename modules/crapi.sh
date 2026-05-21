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
#  📝 模块描述 : crAPI (Completely Ridiculous API) 靶场配置模块
#  📁 文件路径 : modules/crapi.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly CRAPI_DIR="/opt/crapi"
readonly CRAPI_COMPOSE_URL="https://gitee.com/yijingsec/crAPI/releases/download/v1.1.5/docker-compose.yml"

# ═══════════════════════════════════════════════════════════════
# crAPI 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_crAPI() {
    while true; do
        show_submenu "crAPI靶场配置" \
            "安装crAPI靶场" "停止crAPI靶场" \
            "启动crAPI靶场" "卸载crAPI靶场"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_crapi ;; 2) stop_crapi ;;
            3) start_crapi ;;   4) uninstall_crapi ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装 crAPI 靶场
# ═══════════════════════════════════════════════════════════════

install_crapi() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装crAPI靶场"

    msg_info "正在准备安装目录..."
    sudo mkdir -p "${CRAPI_DIR}"
    
    msg_info "正在下载docker-compose.yml..."
    if ! download_file "${CRAPI_COMPOSE_URL}" "${CRAPI_DIR}/docker-compose.yml"; then
        msg_error "下载配置文件失败, 请检查网络"
        return 1
    fi

    cd "${CRAPI_DIR}" || return 1
    
    msg_info "正在预拉取镜像资源(涉及10+镜像, 请耐心等待)..."
    if ! sudo "${COMPOSE_CMD[@]}" pull -q 2>&1 | sed 's/^/  /'; then
        msg_error "拉取镜像失败, 请检查网络"
        return 1
    fi

    msg_info "正在启动crAPI容器服务..."
    if ! sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'; then
        msg_error "启动容器失败"
        return 1
    fi

    msg_info "正在检测容器状态..."
    sleep 5
    
    local containers_status
    containers_status=$(sudo "${COMPOSE_CMD[@]}" ps --format "{{.Name}}:{{.State}}")
    local all_up=true
    local exited_list=""

    while IFS=: read -r name status; do
        [[ -z "$name" ]] && continue
        if [[ "$status" != "running" && "$status" != "Up" ]]; then
            all_up=false
            exited_list="${exited_list}  - ${name} (${status})\n"
        fi
    done <<< "$containers_status"

    if [[ "$all_up" == "true" ]]; then
        local host_ip
        host_ip=$(get_best_ip)
        msg_success "crAPI靶场安装成功, 所有容器均已就绪"
        show_access_info \
            "Web 访问: http://${host_ip}:8888" \
            "邮件管理: http://${host_ip}:8025"
    else
        msg_warning "部分容器启动异常:"
        printf '%b' "${exited_list}"
        msg_info "请执行 'docker ps' 或查看容器日志进行排查"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 停止 crAPI 靶场
# ═══════════════════════════════════════════════════════════════

stop_crapi() {
    show_section "停止crAPI靶场"
    docker_compose_stop "${CRAPI_DIR}" "crAPI"
}

# ═══════════════════════════════════════════════════════════════
# 启动 crAPI 靶场
# ═══════════════════════════════════════════════════════════════

start_crapi() {
    show_section "启动crAPI靶场"
    
    if [[ ! -d "${CRAPI_DIR}" ]]; then
        msg_error "未找到crAPI安装目录, 请先执行安装"
        return 1
    fi

    check_docker_compose || return 1
    cd "${CRAPI_DIR}" || return 1
    
    msg_info "正在检查并预拉取镜像资源..."
    sudo "${COMPOSE_CMD[@]}" pull -q 2>&1 | sed 's/^/  /'

    msg_info "正在启动容器服务..."
    if sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'; then
        local host_ip
        host_ip=$(get_best_ip)
        msg_success "crAPI服务已启动"
        show_access_info \
            "访问地址: http://${host_ip}:8888" \
            "邮件管理: http://${host_ip}:8025 (Mailhog)"
    else
        msg_error "启动操作失败"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载 crAPI 靶场
# ═══════════════════════════════════════════════════════════════

uninstall_crapi() {
    show_section "卸载crAPI靶场"
    local found=false

    if [[ -d "${CRAPI_DIR}" ]]; then
        found=true
        if confirm "检测到crAPI安装目录, 确定要卸载吗? 这将删除所有环境数据!"; then
            check_docker_compose || return 1
            msg_info "正在清理容器资源..."
            cd "${CRAPI_DIR}" || return 1
            sudo "${COMPOSE_CMD[@]}" down >/dev/null 2>&1
            
            msg_info "正在清理物理文件..."
            cd ~ || return 1
            sudo rm -rf "${CRAPI_DIR}"
            msg_success "物理环境清理完成"
        fi
    fi

    if docker images --format '{{.Repository}}' | grep -q "crapi/"; then
        found=true
        if confirm "检测到crAPI相关Docker镜像, 是否执行清理以释放磁盘空间?"; then
            msg_info "正在清理本地镜像..."
            docker images --format '{{.Repository}}:{{.Tag}}' | grep "crapi/" | xargs -r sudo docker rmi >/dev/null 2>&1 || true
            msg_success "镜像清理完成"
        fi
    fi

    if [[ "$found" == "false" ]]; then
        msg_info "未检测到crAPI相关的环境资源, 可能已卸载"
    else
        msg_success "crAPI靶场卸载操作完成"
    fi
}

register_main_menu "配置crAPI" "config_crAPI"