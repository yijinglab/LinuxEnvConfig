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
#  📝 模块描述 : Viper 图形化渗透测试框架配置模块
#  📁 文件路径 : modules/viper.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly VIPER_DIR="/root/VIPER"
readonly VIPER_IMAGE="registry.cn-shenzhen.aliyuncs.com/toys/viper:latest"

# ═══════════════════════════════════════════════════════════════
# Viper 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_viper() {
    while true; do
        show_submenu "Viper框架配置" \
            "一键安装Viper" "更新Viper版本" "更新Viper密码" \
            "停止Viper" "启动Viper" "卸载Viper"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_viper ;;   2) update_viper_version ;;
            3) update_viper_password ;; 4) stop_viper ;;
            5) start_viper ;;     6) remove_viper ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 内部工具函数
# ═══════════════════════════════════════════════════════════════

_optimize_viper_system() {
    msg_info "正在应用深度系统性能优化参数..."
    
    {
        sysctl -w net.ipv4.tcp_timestamps=0
        sysctl -w net.ipv4.tcp_tw_reuse=1
        sysctl -w net.ipv4.tcp_fin_timeout=3
        sysctl -w net.ipv4.tcp_keepalive_time=1800
        sysctl -w net.ipv4.tcp_rmem="4096 87380 8388608"
        sysctl -w net.ipv4.tcp_wmem="4096 87380 8388608"
        sysctl -w net.ipv4.tcp_max_syn_backlog=262144
        sysctl -w net.ipv4.ip_local_port_range="1024 65535"
        sysctl -w net.core.rmem_max=16777216
        sysctl -w net.core.wmem_max=16777216
        sysctl -w net.ipv4.tcp_window_scaling=0
        sysctl -w net.ipv4.tcp_sack=0
        sysctl -w net.core.netdev_max_backlog=30000
        sysctl -w net.ipv4.tcp_no_metrics_save=1
        sysctl -w net.core.somaxconn=262144
        sysctl -w net.ipv4.tcp_syncookies=0
        sysctl -w net.ipv4.tcp_max_orphans=262144
        sysctl -w net.ipv4.tcp_synack_retries=2
        sysctl -w net.ipv4.tcp_syn_retries=2
        sysctl -w vm.max_map_count=262144
    } >/dev/null 2>&1

    {
        if [[ -f /etc/rc.local ]]; then
            grep -q "ulimit -HSn 65535" /etc/rc.local || echo "ulimit -HSn 65535" >> /etc/rc.local
            chmod +x /etc/rc.local
        fi
        grep -q "ulimit -HSn 65535" /root/.bash_profile || echo "ulimit -HSn 65535" >> /root/.bash_profile
        grep -q "ulimit -SHn 65535" /etc/profile || echo "ulimit -SHn 65535" >> /etc/profile
        ulimit -SHn 65535
    } >/dev/null 2>&1
    
    msg_success "系统深度优化配置完成"
}

# ═══════════════════════════════════════════════════════════════
# 安装 Viper
# ═══════════════════════════════════════════════════════════════

install_viper() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装Viper框架"

    if [[ -d "${VIPER_DIR}" ]]; then
        msg_success "检测到Viper已安装, 路径: ${VIPER_DIR}"
        return 0
    fi

    local host_ip
    host_ip=$(get_best_ip)
    
    local viper_pass
    read -r -p "  ${CYAN}请设置Viper登录密码: ${NC}" viper_pass
    if [[ -z "${viper_pass}" ]]; then
        msg_error "密码不能为空"
        return 1
    fi

    _optimize_viper_system

    msg_info "正在准备安装目录..."
    sudo mkdir -p "${VIPER_DIR}/nginxconfig"
    cd "${VIPER_DIR}" || return 1

    msg_info "正在生成DockerCompose配置文件..."
    sudo tee docker-compose.yml > /dev/null <<EOF
services:
  viper:
    image: ${VIPER_IMAGE}
    container_name: viper-c
    network_mode: "host"
    restart: always
    volumes:
      - ./loot:/root/.msf4/loot
      - ./db:/root/viper/Docker/db
      - ./module:/root/viper/Docker/module
      - ./log:/root/viper/Docker/log
      - ./nginxconfig:/root/viper/Docker/nginxconfig
    command: ["${viper_pass}"]
    ulimits:
      nofile:
        soft: 65534
        hard: 65534
      nproc:
        soft: 65534
        hard: 65534
EOF

    docker_pull_image "${VIPER_IMAGE}"

    msg_info "正在启动Viper容器服务..."
    sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'
    if action "Viper容器启动操作完成" "启动Viper失败"; then
        msg_info "正在等待系统初始化(约15秒)..."
        sleep 15
        msg_success "Viper部署成功"
        show_access_info \
            "访问地址: https://${host_ip}:60000" \
            "默认账号: root" \
            "设置密码: ${viper_pass}"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 功能逻辑
# ═══════════════════════════════════════════════════════════════

update_viper_version() {
    show_section "更新Viper版本"
    if [[ ! -d "${VIPER_DIR}" ]]; then
        msg_error "Viper未安装"
        return 1
    fi
    if ! confirm "更新版本将重启服务, 确定继续吗?"; then return 0; fi

    cd "${VIPER_DIR}" || return 1
    check_docker_compose || return 1
    msg_info "正在拉取最新镜像..."
    sudo "${COMPOSE_CMD[@]}" pull 2>&1 | sed 's/^/  /'
    msg_info "正在重新创建容器..."
    sudo "${COMPOSE_CMD[@]}" up -d 2>&1 | sed 's/^/  /'
    msg_success "Viper已更新至最新版本"
}

update_viper_password() {
    show_section "修改Viper登录密码"
    if [[ ! -d "${VIPER_DIR}" ]]; then
        msg_error "Viper未安装"
        return 1
    fi
    local new_pass
    read -r -p "  ${CYAN}请输入新的登录密码: ${NC}" new_pass
    if [[ -z "${new_pass}" ]]; then
        msg_error "密码不能为空"
        return 1
    fi
    cd "${VIPER_DIR}" || return 1
    check_docker_compose || return 1
    msg_info "正在更新配置文件..."
    sudo sed -i "s/command: .*/command: [\"${new_pass}\"]/" docker-compose.yml
    msg_info "正在应用新密码(容器将重启)..."
    sudo "${COMPOSE_CMD[@]}" up -d >/dev/null 2>&1
    msg_success "密码修改完成并已生效"
}

stop_viper() {
    show_section "停止Viper服务"
    docker_compose_stop "${VIPER_DIR}" "Viper"
}

start_viper() {
    show_section "启动Viper服务"
    local host_ip
    host_ip=$(get_best_ip)

    if docker_compose_start "${VIPER_DIR}" "Viper"; then
        msg_success "服务已恢复运行"
        show_access_info \
            "访问地址: https://${host_ip}:60000" \
            "默认账号: root" \
            "设置密码: ${viper_pass:-查询安装记录}"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载 Viper
# ═══════════════════════════════════════════════════════════════

remove_viper() {
    show_section "卸载Viper平台"
    docker_compose_remove "${VIPER_DIR}" "Viper" "${VIPER_IMAGE}"
}

register_main_menu "配置Viper" "config_viper"