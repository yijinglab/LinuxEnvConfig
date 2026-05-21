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
#  📝 模块描述 : CTFd 竞赛框架配置模块
#  📁 文件路径 : modules/ctfd.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly CTFD_IMAGE="ctfd/ctfd:latest"
readonly CTFD_CONTAINER="ctfd"
readonly CTFD_DEFAULT_PORT="8000"

# ═══════════════════════════════════════════════════════════════
# CTFd 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_ctfd() {
    while true; do
        show_submenu "CTFd框架配置" \
            "安装CTFd" \
            "停止CTFd" \
            "启动CTFd" \
            "卸载CTFd"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_ctfd ;;
            2) stop_ctfd ;;
            3) start_ctfd ;;
            4) remove_ctfd ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装CTFd
# ═══════════════════════════════════════════════════════════════

install_ctfd() {
    check_docker || return 1
    show_section "安装CTFd框架"

    local host_ip host_port
    prompt_host_ip "CTFd" || return 1
    prompt_host_port "CTFd" "${CTFD_DEFAULT_PORT}" || return 1

    if ! docker_pull_image "${CTFD_IMAGE}"; then
        return 1
    fi

    msg_info "正在启动容器服务..."
    docker rm -f "${CTFD_CONTAINER}" >/dev/null 2>&1
    
    docker run -dit \
        -p "${host_port}:8000" \
        --name "${CTFD_CONTAINER}" \
        --restart always \
        "${CTFD_IMAGE}" >/dev/null 2>&1
        
    if action "CTFd容器创建成功" "启动服务失败, 请检查端口 ${host_port} 是否被占用"; then
        docker_wait_healthy "${CTFD_CONTAINER}" "CTFd"
        msg_success "CTFd部署完成"
        show_access_info \
            "访问地址: http://${host_ip}:${host_port}" \
            "提示: 首次运行需通过页面引导完成初始化设置"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 生命周期管理
# ═══════════════════════════════════════════════════════════════

stop_ctfd() {
    show_section "停止CTFd框架"
    docker_stop_container "${CTFD_CONTAINER}" "CTFd"
}

start_ctfd() {
    show_section "启动CTFd框架"

    local host_ip
    prompt_host_ip "CTFd" "host_ip" "false"

    if docker_start_container "${CTFD_CONTAINER}" "CTFd"; then
        show_access_info \
            "访问地址: http://${host_ip}:${CTFD_DEFAULT_PORT}" \
            "提示: 首次运行需通过页面引导完成初始化设置"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载CTFd
# ═══════════════════════════════════════════════════════════════

remove_ctfd() {
    show_section "卸载CTFd框架"
    docker_remove_container_and_image "${CTFD_CONTAINER}" "${CTFD_IMAGE}" "CTFd"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置CTFd" "config_ctfd"