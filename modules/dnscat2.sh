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
#  📝 模块描述 : dnscat2 DNS 隧道配置模块
#  📁 文件路径 : modules/dnscat2.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly DNSCAT2_IMAGE="registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07"
readonly DNSCAT2_CONTAINER="dnscat2"

# ═══════════════════════════════════════════════════════════════
# dnscat2 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_dnscat2() {
    while true; do
        show_submenu "dnscat2 DNS隧道配置" \
            "安装dnscat2镜像" \
            "启动dnscat2(直连模式)" \
            "启动dnscat2(中继模式)" \
            "卸载dnscat2框架"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_dnscat2 ;;
            2) start_dnscat2_direct_mode ;;
            3) start_dnscat2_relay_mode ;;
            4) remove_dnscat2 ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装dnscat2
# ═══════════════════════════════════════════════════════════════

install_dnscat2() {
    unlock_dns_port

    check_docker || return 1
    show_section "安装dnscat2框架"

    docker_pull_image "${DNSCAT2_IMAGE}"
    action "dnscat2镜像环境准备就绪" "下载dnscat2镜像失败"
}

# ═══════════════════════════════════════════════════════════════
# 启动dnscat2直连模式
# ═══════════════════════════════════════════════════════════════

start_dnscat2_direct_mode() {
    unlock_dns_port

    show_section "启动dnscat2 (直连模式)"
    
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${DNSCAT2_IMAGE}"; then
        msg_error "未检测到镜像, 请先执行安装"
        return 1
    fi

    msg_info "正在预清理冲突资源..."
    docker rm -f "${DNSCAT2_CONTAINER}" >/dev/null 2>&1

    msg_warning "注意: 直连模式将占用主机 UDP 53 端口"
    msg_info "正在进入交互式控制台(按 Ctrl+C 退出)..."
    
    docker run -it \
        --name "${DNSCAT2_CONTAINER}" \
        --rm \
        -p 53:53/udp \
        "${DNSCAT2_IMAGE}" server
}

# ═══════════════════════════════════════════════════════════════
# 启动dnscat2中继模式
# ═══════════════════════════════════════════════════════════════

start_dnscat2_relay_mode() {
    unlock_dns_port

    show_section "启动dnscat2 (中继模式)"
    
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${DNSCAT2_IMAGE}"; then
        msg_error "未检测到镜像, 请先执行安装"
        return 1
    fi

    local subdomain
    read -r -p "  ${CYAN}请输入用于中继的子域名 (如: a.example.com): ${NC}" subdomain
    if [[ -z "${subdomain}" ]]; then
        msg_error "子域名不能为空"
        return 1
    fi

    msg_info "正在进入交互式控制台(按 Ctrl+C 退出)..."
    docker rm -f "${DNSCAT2_CONTAINER}" >/dev/null 2>&1

    docker run -it \
        --name "${DNSCAT2_CONTAINER}" \
        --rm \
        -p 53:53/udp \
        "${DNSCAT2_IMAGE}" server "${subdomain}"
}

# ═══════════════════════════════════════════════════════════════
# 卸载dnscat2
# ═══════════════════════════════════════════════════════════════

remove_dnscat2() {
    show_section "卸载dnscat2框架"
    docker_remove_container_and_image "${DNSCAT2_CONTAINER}" "${DNSCAT2_IMAGE}" "dnscat2"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置Dnscat2" "config_dnscat2"