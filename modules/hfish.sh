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
#  📝 模块描述 : HFish 蜜罐系统配置模块
#  📁 文件路径 : modules/hfish.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# HFish 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_hfish() {
    while true; do
        show_submenu "HFish配置" \
            "安装HFish" "更新HFish" "停止HFish" \
            "启动HFish" "卸载HFish" "获取数据库信息"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_hfish ;; 2) update_hfish ;;
            3) stop_hfish ;;    4) start_hfish ;;
            5) remove_hfish ;;  6) get_hfish_db_info ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装HFish
# ═══════════════════════════════════════════════════════════════

install_hfish() {
    check_docker || return 1
    show_section "安装HFish蜜罐系统"

    local host_ip
    prompt_host_ip "HFish" || return 1

    msg_info "创建HFish目录..."
    sudo mkdir -p /opt/hfish && cd /opt/hfish || return
    sudo rm -f docker-compose.* > /dev/null 2>&1

    msg_info "生成DockerCompose配置文件..."
    sudo tee docker-compose.yml > /dev/null <<-'EOF'
services:
  hfish:
    image: registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest
    container_name: hfish
    volumes:
      - /opt/hfish:/usr/share/hfish
    network_mode: host
    privileged: true
    depends_on:
      - mysql
  mysql:
    container_name: mysql8
    image: registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0
    command: --default-authentication-plugin=mysql_native_password
    environment:
      - MYSQL_ROOT_PASSWORD=123456
EOF

    docker_pull_image "registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0"
    docker_pull_image "registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest"

    msg_info "正在启动HFish容器服务..."
    check_docker_compose || return 1
    sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'
    if action "HFish启动操作完成" "启动服务失败"; then
        msg_info "正在等待容器就绪..."
        sleep 5
        msg_success "HFish安装部署完成"
        _display_hfish_info "${host_ip}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 更新与生命周期管理
# ═══════════════════════════════════════════════════════════════

update_hfish() {
    show_section "更新HFish服务"
    docker_pull_image "registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest"
    action "镜像更新成功，请重新启动以生效" "镜像更新失败"
}

stop_hfish() {
    show_section "停止HFish服务"
    docker_compose_stop "/opt/hfish" "HFish"
}

start_hfish() {
    show_section "启动HFish服务"

    local host_ip
    prompt_host_ip "HFish" "host_ip" "false"

    if docker_compose_start "/opt/hfish" "HFish"; then
        msg_success "HFish启动成功"
        _display_hfish_info "${host_ip}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 辅助与卸载
# ═══════════════════════════════════════════════════════════════

_display_hfish_info() {
    local host_ip=$1
    if ! command_exists jq; then
        install_package jq >/dev/null 2>&1
    fi

    local mysql_ip
    mysql_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql8 2>/dev/null || echo "未知")

    show_access_info \
        "访问地址: https://${host_ip}:4433/web" \
        "后台账号: admin" \
        "后台密码: HFish2021" \
        "MySQL IP: ${mysql_ip}" \
        "MySQL端口: 3306" \
        "MySQL库名: hfish" \
        "MySQL用户: root" \
        "MySQL密码: 123456"
}

get_hfish_db_info() {
    show_section "获取数据库配置信息"
    local host_ip
    host_ip=$(get_best_ip)
    _display_hfish_info "${host_ip}"
}

remove_hfish() {
    show_section "卸载HFish蜜罐"
    docker_compose_remove "/opt/hfish" "HFish" \
        "registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest" \
        "registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0"
}

register_main_menu "配置HFish" "config_hfish"