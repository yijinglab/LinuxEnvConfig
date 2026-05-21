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
#  📝 模块描述 : BeEF 浏览器渗透框架配置模块
#  📁 文件路径 : modules/beef.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly BEEF_IMAGE="registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest"
readonly BEEF_CONTAINER="beef"
readonly BEEF_PORT="3000"

# ═══════════════════════════════════════════════════════════════
# BeEF 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_beef() {
    while true; do
        show_submenu "BeEF框架配置" \
            "安装BeEF" \
            "停止BeEF" \
            "启动BeEF" \
            "卸载BeEF"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_beef ;;
            2) stop_beef ;;
            3) start_beef ;;
            4) remove_beef ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装BeEF
# ═══════════════════════════════════════════════════════════════

install_beef() {
    check_docker || return 1
    show_section "安装BeEF框架"

    local host_ip
    prompt_host_ip "BeEF" || return 1

    if ! docker_pull_image "${BEEF_IMAGE}"; then
        return 1
    fi

    msg_info "正在启动容器服务..."
    docker rm -f "${BEEF_CONTAINER}" >/dev/null 2>&1
    
    docker run -dit \
        -p "${BEEF_PORT}:3000" \
        --name "${BEEF_CONTAINER}" \
        "${BEEF_IMAGE}" >/dev/null 2>&1
        
    if action "BeEF容器创建成功" "启动服务失败, 请检查端口 ${BEEF_PORT} 是否被占用"; then
        docker_wait_healthy "${BEEF_CONTAINER}" "BeEF"
        msg_success "BeEF部署完成"
        show_access_info \
            "访问地址:http://${host_ip}:${BEEF_PORT}/ui/panel" \
            "默认用户:beef" \
            "默认密码:yijingsec"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 生命周期管理
# ═══════════════════════════════════════════════════════════════

stop_beef() {
    show_section "停止BeEF框架"
    docker_stop_container "${BEEF_CONTAINER}" "BeEF"
}

start_beef() {
    show_section "启动BeEF框架"

    local host_ip
    prompt_host_ip "BeEF" "host_ip" "false"

    if docker_start_container "${BEEF_CONTAINER}" "BeEF"; then
        show_access_info \
            "访问地址: http://${host_ip}:${BEEF_PORT}/ui/panel" \
            "默认用户: beef" \
            "默认密码: yijingsec"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载BeEF
# ═══════════════════════════════════════════════════════════════

remove_beef() {
    show_section "卸载BeEF框架"
    docker_remove_container_and_image "${BEEF_CONTAINER}" "${BEEF_IMAGE}" "BeEF"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置BeEF" "config_beef"