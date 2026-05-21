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
#  📝 模块描述 : Empire 后渗透框架配置模块
#  📁 文件路径 : modules/empire.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly EMPIRE_IMAGE="registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest"
readonly EMPIRE_CONTAINER="ps-empire"

# ═══════════════════════════════════════════════════════════════
# Empire 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_empire() {
    while true; do
        show_submenu "Empire框架配置" \
            "安装Empire" \
            "更新Empire" \
            "停止Empire" \
            "启动Empire" \
            "卸载Empire"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_empire ;;
            2) update_empire ;;
            3) stop_empire ;;
            4) start_empire ;;
            5) remove_empire ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装Empire
# ═══════════════════════════════════════════════════════════════

install_empire() {
    check_docker || return 1
    show_section "安装Empire框架"

    local host_ip
    prompt_host_ip "Empire" || return 1

    if ! docker_pull_image "${EMPIRE_IMAGE}"; then
        return 1
    fi

    msg_info "正在启动容器服务..."
    docker rm -f "${EMPIRE_CONTAINER}" >/dev/null 2>&1
    
    docker run -d \
        --name "${EMPIRE_CONTAINER}" \
        -p 6000-6010:6000-6010 \
        -p 1337:1337 \
        -p 5000:5000 \
        --restart always \
        "${EMPIRE_IMAGE}" >/dev/null 2>&1
        
    if action "Empire容器创建成功" "启动服务失败, 请检查端口 1337 是否被占用"; then
        docker_wait_healthy "${EMPIRE_CONTAINER}" "Empire"
        msg_success "Empire部署完成"
        show_access_info \
            "服务端地址: http://${host_ip}:1337" \
            "默认用户名: empireadmin" \
            "默认密码  : password123" \
            "监听器范围: 6000-6010 (需在Empire中手动开启)"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 更新Empire
# ═══════════════════════════════════════════════════════════════

update_empire() {
    show_section "更新Empire框架"
    
    msg_info "正在获取最新镜像..."
    if docker_pull_image "${EMPIRE_IMAGE}"; then
        msg_info "正在清理旧容器..."
        docker rm -f "${EMPIRE_CONTAINER}" >/dev/null 2>&1
        msg_success "更新完成, 请选择菜单 [1] 重新执行安装以应用新镜像"
    else
        msg_error "镜像更新失败"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 生命周期管理
# ═══════════════════════════════════════════════════════════════

stop_empire() {
    show_section "停止Empire服务"
    docker_stop_container "${EMPIRE_CONTAINER}" "Empire"
}

start_empire() {
    show_section "启动Empire服务"

    local host_ip
    prompt_host_ip "Empire" "host_ip" "false"

    if docker_start_container "${EMPIRE_CONTAINER}" "Empire"; then
        show_access_info \
            "服务端地址: http://${host_ip}:1337" \
            "默认用户名: empireadmin" \
            "默认密码  : password123" \
            "监听器范围: 6000-6010 (需在Empire中手动开启)"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载Empire
# ═══════════════════════════════════════════════════════════════

remove_empire() {
    show_section "卸载Empire框架"
    docker_remove_container_and_image "${EMPIRE_CONTAINER}" "${EMPIRE_IMAGE}" "Empire"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置Empire" "config_empire"