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
#  📝 模块描述 : OCR API 识别服务配置模块
#  📁 文件路径 : modules/ocr-api.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly OCR_CONTAINER="ocr_api_server"
readonly OCR_IMAGE="registry.cn-hangzhou.aliyuncs.com/mingy123/ocr_api_server:latest"

# ═══════════════════════════════════════════════════════════════
# OCR API 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_ocr_api_server() {
    while true; do
        show_submenu "OCR API服务配置" \
            "安装OCR-API服务" "停止OCR-API服务" \
            "启动OCR-API服务" "卸载OCR-API服务"

        local choice
        msg_prompt "请选择操作 [0-4, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_ocr_api_server ;; 2) stop_ocr_api_server ;;
            3) start_ocr_api_server ;;   4) remove_ocr_api_server ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

install_ocr_api_server() {
    check_docker || return 1
    show_section "安装OCR API服务"

    if docker ps -a --format '{{.Names}}' | grep -q "^${OCR_CONTAINER}$"; then
        msg_success "检测到OCR API服务容器已存在"
        return 0
    fi

    local host_ip
    host_ip=$(get_best_ip)

    docker_pull_image "${OCR_IMAGE}"

    msg_info "正在启动OCR API容器服务..."
    docker run -d -p 9898:9898 \
        --name "${OCR_CONTAINER}" --restart always \
        "${OCR_IMAGE}" >/dev/null 2>&1

    if action "OCR API容器创建成功" "启动OCR API容器失败"; then
        msg_info "正在等待服务初始化..."
        sleep 3
        msg_success "OCR API服务部署完成"
        show_access_info \
            "健康检查: http://${host_ip}:9898/ping"
        msg_warning "提示: 访问后如返回'pong'则代表服务运行正常"
    fi
}

stop_ocr_api_server() {
    show_section "停止OCR API服务"
    docker_stop_container "${OCR_CONTAINER}" "OCR API"
}

start_ocr_api_server() {
    show_section "启动OCR API服务"
    local host_ip
    host_ip=$(get_best_ip)

    if docker_start_container "${OCR_CONTAINER}" "OCR API"; then
        show_access_info \
            "健康检查: http://${host_ip}:9898/ping"
        msg_warning "提示: 访问后如返回'pong'则代表服务运行正常"
    fi
}

remove_ocr_api_server() {
    show_section "卸载OCR API服务"
    docker_remove_container_and_image "${OCR_CONTAINER}" "${OCR_IMAGE}" "OCR API"
}

register_main_menu "配置OCR-API" "config_ocr_api_server"