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
#  📝 模块描述 : BlueLotus XSS 接收平台配置模块
#  📁 文件路径 : modules/bluelotus.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly BLUELOTUS_IMAGE="registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest"
readonly BLUELOTUS_CONTAINER="bluelotus"
readonly BLUELOTUS_PORT="5080"

# ═══════════════════════════════════════════════════════════════
# BlueLotus 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_bluelotus() {
    while true; do
        show_submenu "BlueLotus框架配置" \
            "安装BlueLotus" \
            "停止BlueLotus" \
            "启动BlueLotus" \
            "卸载BlueLotus"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_bluelotus ;;
            2) stop_bluelotus ;;
            3) start_bluelotus ;;
            4) remove_bluelotus ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装BlueLotus
# ═══════════════════════════════════════════════════════════════

install_bluelotus() {
    check_docker || return 1
    show_section "安装BlueLotus框架"

    local host_ip
    prompt_host_ip "BlueLotus" || return 1

    if ! docker_pull_image "${BLUELOTUS_IMAGE}"; then
        return 1
    fi

    msg_info "正在启动容器服务..."
    docker rm -f "${BLUELOTUS_CONTAINER}" >/dev/null 2>&1
    
    docker run -dit \
        -p "${BLUELOTUS_PORT}:80" \
        --name "${BLUELOTUS_CONTAINER}" \
        --restart always \
        "${BLUELOTUS_IMAGE}" >/dev/null 2>&1
        
    if action "BlueLotus容器创建成功" "启动服务失败, 请检查端口 ${BLUELOTUS_PORT} 是否被占用"; then
        docker_wait_healthy "${BLUELOTUS_CONTAINER}" "BlueLotus"
        msg_success "BlueLotus部署完成"
        show_access_info \
            "访问地址:http://${host_ip}:${BLUELOTUS_PORT}/login.php" \
            "默认密码:bluelotus"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 生命周期管理
# ═══════════════════════════════════════════════════════════════

stop_bluelotus() {
    show_section "停止BlueLotus框架"
    docker_stop_container "${BLUELOTUS_CONTAINER}" "BlueLotus"
}

start_bluelotus() {
    show_section "启动BlueLotus框架"

    local host_ip
    prompt_host_ip "BlueLotus" "host_ip" "false"

    if docker_start_container "${BLUELOTUS_CONTAINER}" "BlueLotus"; then
        show_access_info \
            "访问地址: http://${host_ip}:${BLUELOTUS_PORT}/login.php" \
            "默认密码: bluelotus"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载BlueLotus
# ═══════════════════════════════════════════════════════════════

remove_bluelotus() {
    show_section "卸载BlueLotus平台"
    docker_remove_container_and_image "${BLUELOTUS_CONTAINER}" "${BLUELOTUS_IMAGE}" "BlueLotus"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置BlueLotus" "config_bluelotus"