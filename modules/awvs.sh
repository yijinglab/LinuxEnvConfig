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
#  📝 模块描述 : AWVS 扫描器配置模块
#  📁 文件路径 : modules/awvs.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly AWVS_IMAGE="registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest"
readonly AWVS_CONTAINER="yijingsec-awvs"
readonly AWVS_DEFAULT_PORT="3443"

# ═══════════════════════════════════════════════════════════════
# AWVS配置主菜单
# ═══════════════════════════════════════════════════════════════

config_awvs() {
    while true; do
        show_submenu "AWVS扫描器配置" \
            "安装AWVS" "停止AWVS" "启动AWVS" "卸载AWVS"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_awvs ;; 2) stop_awvs ;;
            3) start_awvs ;;  4) remove_awvs ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 生命周期管理
# ═══════════════════════════════════════════════════════════════

stop_awvs() {
    show_section "停止AWVS服务"
    docker_stop_container "${AWVS_CONTAINER}" "AWVS"
}

start_awvs() {
    show_section "启动AWVS服务"
    local host_ip
    host_ip=$(get_best_ip)
    local host_port
    host_port=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "3443/tcp") 0).HostPort}}' "${AWVS_CONTAINER}" 2>/dev/null || echo "${AWVS_DEFAULT_PORT}")

    if docker_start_container "${AWVS_CONTAINER}" "AWVS"; then
        show_access_info \
            "访问地址: https://${host_ip}:${host_port}" \
            "默认用户: admin@admin.com" \
            "默认密码: Admin123"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 安装AWVS
# ═══════════════════════════════════════════════════════════════

install_awvs() {
    check_docker || return 1
    show_section "安装AWVS扫描器"

    local host_ip host_port
    prompt_host_ip "AWVS" || return 1
    prompt_host_port "AWVS" "${AWVS_DEFAULT_PORT}" || return 1

    if ! docker_pull_image "${AWVS_IMAGE}"; then return 1; fi

    msg_info "正在启动容器服务..."
    docker rm -f "${AWVS_CONTAINER}" >/dev/null 2>&1
    docker run -dit -p "${host_port}:3443" \
        --name "${AWVS_CONTAINER}" --cap-add LINUX_IMMUTABLE \
        --restart always "${AWVS_IMAGE}" >/dev/null 2>&1

    if action "AWVS容器创建成功" "容器启动失败, 请检查端口是否被占用"; then
        docker_wait_healthy "${AWVS_CONTAINER}" "AWVS"
        msg_success "AWVS部署完成"
        show_access_info \
            "访问地址:https://${host_ip}:${host_port}" \
            "默认用户:admin@admin.com" \
            "默认密码:Admin123"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载AWVS
# ═══════════════════════════════════════════════════════════════

remove_awvs() {
    show_section "卸载AWVS扫描器"
    docker_remove_container_and_image "${AWVS_CONTAINER}" "${AWVS_IMAGE}" "AWVS"
}

register_main_menu "配置AWVS" "config_awvs"