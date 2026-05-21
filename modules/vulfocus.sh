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
#  📝 模块描述 : Vulfocus 漏洞测试平台配置模块
#  📁 文件路径 : modules/vulfocus.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly VULFOCUS_CONTAINER="vulfocus"
readonly VULFOCUS_IMAGE="swr.cn-south-1.myhuaweicloud.com/mingy/vulfocus:20251218"

# ═══════════════════════════════════════════════════════════════
# Vulfocus 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_vulfocus() {
    while true; do
        show_submenu "Vulfocus漏洞平台配置" \
            "安装Vulfocus" "停止Vulfocus" "启动Vulfocus" "卸载Vulfocus"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_vulfocus ;; 2) stop_vulfocus ;;
            3) start_vulfocus ;;   4) remove_vulfocus ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

install_vulfocus() {
    check_docker || return 1
    show_section "安装Vulfocus平台"

    if docker ps -a --format '{{.Names}}' | grep -q "^${VULFOCUS_CONTAINER}$"; then
        msg_success "检测到Vulfocus容器已存在, 请选择启动或卸载重装"
        return 0
    fi

    local host_ip
    prompt_host_ip "Vulfocus" || return 1

    docker_pull_image "${VULFOCUS_IMAGE}"

    msg_info "正在启动Vulfocus容器..."
    docker run -d -p 88:80 \
        --name "${VULFOCUS_CONTAINER}" --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e VUL_IP="${host_ip}" \
        "${VULFOCUS_IMAGE}" >/dev/null 2>&1

    if action "Vulfocus安装成功" "启动Vulfocus容器失败"; then
        show_access_info \
            "访问地址: http://${host_ip}:88" \
            "默认用户: admin" \
            "默认密码: admin"
    fi
}

stop_vulfocus() {
    show_section "停止Vulfocus服务"
    docker_stop_container "${VULFOCUS_CONTAINER}" "Vulfocus"
}

start_vulfocus() {
    show_section "启动Vulfocus服务"
    local default_ip
    default_ip=$(get_best_ip)

    if docker_start_container "${VULFOCUS_CONTAINER}" "Vulfocus"; then
        show_access_info \
            "访问地址: http://${default_ip}:88" \
            "默认用户: admin" \
            "默认密码: admin"
    fi
}

remove_vulfocus() {
    show_section "卸载Vulfocus平台"
    docker_remove_container_and_image "${VULFOCUS_CONTAINER}" "${VULFOCUS_IMAGE}" "Vulfocus"
}

register_main_menu "配置Vulfocus" "config_vulfocus"