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
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  📝 模块描述 : ScopeSentry分布式资产侦察管理系统
#  📁 文件路径 : modules/scopesentry.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly SCOPESENTRY_DIR="/opt/ScopeSentry"
readonly SCOPESENTRY_IMAGE="autumn27/scopesentry:latest"
readonly SCOPESENTRY_SCAN="autumn27/scopesentry-scan:latest"
readonly SCOPESENTRY_MONGO="mongo:7.0.28"
readonly SCOPESENTRY_REDIS="redis:7.0.11"
readonly SCOPESENTRY_DEFAULT_PORT="8082"

# ═══════════════════════════════════════════════════════════════
# ScopeSentry配置主菜单
# ═══════════════════════════════════════════════════════════════

config_scopesentry() {
    while true; do
        show_submenu "ScopeSentry" \
            "安装ScopeSentry" \
            "卸载ScopeSentry" \
            "启动ScopeSentry" \
            "停止ScopeSentry" \
            "查看ScopeSentry状态" \
            "重置ScopeSentry密码"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_scopesentry ;;
            2) remove_scopesentry ;;
            3) start_scopesentry ;;
            4) stop_scopesentry ;;
            5) show_scopesentry_status ;;
            6) reset_scopesentry_password ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 内部辅助函数
# ═══════════════════════════════════════════════════════════════

get_scopesentry_info() {
    host_ip=$(get_best_ip)
    
    if [[ -f "${SCOPESENTRY_DIR}/docker-compose.yml" ]]; then
        host_port=$(grep -oP '"?\K\d+(?=:8082)' "${SCOPESENTRY_DIR}/docker-compose.yml" | head -n 1)
    fi
    host_port=${host_port:-${SCOPESENTRY_DEFAULT_PORT}}

    if [[ -d "${SCOPESENTRY_DIR}" ]]; then
        cd "${SCOPESENTRY_DIR}" || return 1
        check_docker_compose || return 1
        local raw_creds
        raw_creds=$(sudo "${COMPOSE_CMD[@]}" logs scope-sentry 2>/dev/null | grep "User/Password:" | tail -n 1 | sed -n 's/.*User\/Password: //p' | tr -d '\r')
        if [[ -n "$raw_creds" ]]; then
            scopesentry_user=${raw_creds%%/*}
            scopesentry_pass=${raw_creds#*/}
        fi
        plugin_key=$(sudo "${COMPOSE_CMD[@]}" logs scope-sentry 2>/dev/null | grep "Plugin Key:" | tail -n 1 | sed -n 's/.*Plugin Key: //p' | tr -d '\r')
    fi
    scopesentry_user=${scopesentry_user:-"ScopeSentry"}
    scopesentry_pass=${scopesentry_pass:-"未知,请查看日志"}
    plugin_key=${plugin_key:-"未获取到,请通过查看日志获取"}
}

# ═══════════════════════════════════════════════════════════════
# 安装ScopeSentry
# ═══════════════════════════════════════════════════════════════

install_scopesentry() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装ScopeSentry"
    
    if [ -d "${SCOPESENTRY_DIR}" ]; then
        msg_success "检测到ScopeSentry已安装,路径: ${SCOPESENTRY_DIR}"
        return 0
    fi

    msg_info "创建安装目录: ${SCOPESENTRY_DIR}"
    sudo mkdir -p "${SCOPESENTRY_DIR}"
    cd "${SCOPESENTRY_DIR}" || return 1

    local mongo_user mongo_password redis_password host_ip host_port
    prompt_host_ip "ScopeSentry" || return 1
    prompt_host_port "ScopeSentry服务" "${SCOPESENTRY_DEFAULT_PORT}" || return 1
    msg_prompt_required "请设置MongoDB用户" mongo_user
    msg_prompt_required "请设置MongoDB密码" mongo_password
    msg_prompt_required "请设置Redis密码" redis_password

    # 生成配置文件
    msg_info "正在生成.env环境配置文件..."
    sudo bash -c "cat << EOF > .env
MONGO_INITDB_ROOT_USERNAME=${mongo_user}
MONGO_INITDB_ROOT_PASSWORD=${mongo_password}
REDIS_PASSWORD=${redis_password}
EOF"

    # 下载 Compose 配置
    msg_info "正在从远程仓库下载Compose部署文件..."
    download_file "https://raw.giteeusercontent.com/yijingsec/ScopeSentry/raw/main/single-host-deployment.yml" "docker-compose.yml" || return 1
    
    # 修复 version 废弃警告
    sudo sed -i '/version:/d' "docker-compose.yml"

    # 替换默认端口 (如果有变化)
    if [[ "${host_port}" != "${SCOPESENTRY_DEFAULT_PORT}" ]]; then
        sudo sed -i "s/${SCOPESENTRY_DEFAULT_PORT}:${SCOPESENTRY_DEFAULT_PORT}/${host_port}:${SCOPESENTRY_DEFAULT_PORT}/g" "docker-compose.yml"
    fi

    # 拉取镜像
    docker_pull_image "$SCOPESENTRY_IMAGE"
    docker_pull_image "$SCOPESENTRY_MONGO"
    docker_pull_image "$SCOPESENTRY_REDIS"
    docker_pull_image "$SCOPESENTRY_SCAN"

    # 分两步启动以提高稳定性：先启动数据库，再启动主程序
    msg_info "正在初始化基础设施(MongoDB & Redis)..."
    _docker_compose_render_premium "Infrastructure" "up" mongodb redis
    
    msg_info "正在启动核心服务与扫描节点..."
    _docker_compose_render_premium "ScopeSentry" "up"
    
    # 启动状态自修复机制
    local i total_services running_services
    total_services=$(sudo "${COMPOSE_CMD[@]}" config --services 2>/dev/null | wc -l)
    for i in {1..3}; do
        running_services=$(sudo "${COMPOSE_CMD[@]}" ps --format "{{.State}}" 2>/dev/null | grep -ic "running" || echo 0)
        if [[ "$running_services" -ge "$total_services" ]]; then
            break
        fi
        msg_warning "部分服务($running_services/$total_services)未就绪,正在尝试修复启动($i/3)..."
        sleep 5
        _docker_compose_render_premium "Recovery" "up"
    done
    
    if action "容器编排指令执行完成" "服务启动失败"; then
        msg_info "正在等待系统初始化(约20秒)..."
        sleep 20
        
        local raw_creds="" plugin_key="" count=0
        msg_info "正在从日志中提取初始凭据..."
        while [[ -z "$raw_creds" || -z "$plugin_key" ]] && [[ $count -lt 5 ]]; do
            raw_creds=$(sudo "${COMPOSE_CMD[@]}" logs scope-sentry 2>/dev/null | grep "User/Password:" | tail -n 1 | sed -n 's/.*User\/Password: //p' | tr -d '\r')
            plugin_key=$(sudo "${COMPOSE_CMD[@]}" logs scope-sentry 2>/dev/null | grep "Plugin Key:" | tail -n 1 | sed -n 's/.*Plugin Key: //p' | tr -d '\r')
            [[ -z "$raw_creds" || -z "$plugin_key" ]] && sleep 5 && ((count++))
        done

        local user="ScopeSentry" pass="未知"
        if [[ -n "$raw_creds" ]]; then
            user=${raw_creds%%/*}
            pass=${raw_creds#*/}
        fi

        show_access_info "ScopeSentry部署成功" \
            "URL地址: http://${host_ip}:${host_port}" \
            "用户账户: ${user}" \
            "用户密码: ${pass}" \
            "插件密钥: ${plugin_key:-请通过 docker compose logs 查看}"
    else
        return 1
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════
# 卸载ScopeSentry
# ═══════════════════════════════════════════════════════════════

remove_scopesentry() {
    show_section "卸载ScopeSentry"
    docker_compose_remove "${SCOPESENTRY_DIR}" "ScopeSentry" \
        "$SCOPESENTRY_IMAGE" "$SCOPESENTRY_MONGO" "$SCOPESENTRY_REDIS" "$SCOPESENTRY_SCAN"
}

# ═══════════════════════════════════════════════════════════════
# 启动ScopeSentry
# ═══════════════════════════════════════════════════════════════

start_scopesentry() {
    show_section "启动ScopeSentry"
    docker_compose_start "${SCOPESENTRY_DIR}" "ScopeSentry" "up" || return 1
    
    # 启动状态自修复机制 (针对依赖等待时间不足的情况)
    local i total_services running_services
    total_services=$(sudo "${COMPOSE_CMD[@]}" config --services 2>/dev/null | wc -l)
    for i in {1..3}; do
        running_services=$(sudo "${COMPOSE_CMD[@]}" ps --format "{{.State}}" 2>/dev/null | grep -ic "running" || echo 0)
        if [[ "$running_services" -ge "$total_services" ]]; then
            break
        fi
        msg_warning "部分服务($running_services/$total_services)未就绪,正在尝试修复启动($i/3)..."
        sleep 5
        _docker_compose_render_premium "Recovery" "up"
    done

    local host_ip host_port scopesentry_user scopesentry_pass plugin_key
    get_scopesentry_info
    show_access_info "ScopeSentry访问信息" \
        "URL地址: http://${host_ip}:${host_port}" \
        "用户账户: ${scopesentry_user}" \
        "用户密码: ${scopesentry_pass}" \
        "插件密钥: ${plugin_key}"
}

# ═══════════════════════════════════════════════════════════════
# 停止ScopeSentry
# ═══════════════════════════════════════════════════════════════

stop_scopesentry() {
    show_section "停止ScopeSentry"
    docker_compose_stop "${SCOPESENTRY_DIR}" "ScopeSentry"
}

# ═══════════════════════════════════════════════════════════════
# 查看ScopeSentry状态
# ═══════════════════════════════════════════════════════════════

show_scopesentry_status() {
    show_section "ScopeSentry状态信息"
    if [[ ! -d "${SCOPESENTRY_DIR}" ]]; then
        msg_error "未检测到安装目录"
        return 1
    fi
    check_docker_compose || return 1
    cd "${SCOPESENTRY_DIR}" || return 1
    
    local widths="18 12 10 18"
    echo ""
    msg_table_row "$widths" "${BOLD}服务名称" "运行状态" "健康状况" "端口映射${NC}"
    draw_line "-" "${GRAY}"
    
    # 获取并解析容器状态
    local line
    while read -r line; do
        [[ -z "$line" ]] && continue
        local service state health ports
        # 兼容旧版本 compose 的解析方式
        IFS='|' read -r service state health ports <<< "$line"
        
        # 状态颜色化处理
        local state_color="${NC}"
        case "${state,,}" in
            running) state_color="${GREEN}" ;;
            exited|dead) state_color="${RED}" ;;
            *) state_color="${YELLOW}" ;;
        esac
        
        local health_color="${NC}"
        case "${health,,}" in
            healthy) health_color="${GREEN}" ;;
            unhealthy) health_color="${RED}" ;;
            starting) health_color="${YELLOW}" ;;
            *) health_color="${GRAY}" ;;
        esac
        
        # 简化端口映射显示
        local simple_ports
        simple_ports=$(echo "$ports" | grep -oE "[0-9]+->[0-9]+" | head -n 1)
        [[ -z "$simple_ports" ]] && simple_ports="-"

        msg_table_row "$widths" "${CYAN}${service}${NC}" "${state_color}${state}${NC}" "${health_color}${health:- -}${NC}" "${WHITE}${simple_ports}${NC}"
    done < <(sudo "${COMPOSE_CMD[@]}" ps --format "{{.Service}}|{{.State}}|{{.Health}}|{{.Ports}}")
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 重置ScopeSentry密码
# ═══════════════════════════════════════════════════════════════

reset_scopesentry_password() {
    show_section "重置ScopeSentry密码"
    if [[ ! -d "${SCOPESENTRY_DIR}" ]]; then
        msg_error "未检测到安装目录"
        return 1
    fi
    
    if [[ ! -f "${SCOPESENTRY_DIR}/.env" ]]; then
        msg_error "未检测到配置文件(.env)"
        return 1
    fi
    
    check_docker_compose || return 1
    cd "${SCOPESENTRY_DIR}" || return 1
    
    # 检查 MongoDB 容器是否正在运行
    local mongo_status
    mongo_status=$(sudo "${COMPOSE_CMD[@]}" ps mongodb --format "{{.State}}" 2>/dev/null)
    if [[ "$mongo_status" != "running" ]]; then
        msg_error "MongoDB服务未运行,请先启动ScopeSentry"
        return 1
    fi
    
    local mongo_user mongo_pass
    mongo_user=$(grep "MONGO_INITDB_ROOT_USERNAME" "${SCOPESENTRY_DIR}/.env" | cut -d'=' -f2)
    mongo_pass=$(grep "MONGO_INITDB_ROOT_PASSWORD" "${SCOPESENTRY_DIR}/.env" | cut -d'=' -f2)
    
    msg_info "正在执行数据库重置指令..."
    local reset_cmd="db = db.getSiblingDB('ScopeSentry'); db.user.updateOne({ 'username': 'ScopeSentry' }, { \$set: { 'password': 'b0ce71fcbed8a6ca579d52800145119cc7d999dc8651b62dfc1ced9a984e6e64' } })"
    
    sudo "${COMPOSE_CMD[@]}" exec -T mongodb mongosh -u "${mongo_user}" -p "${mongo_pass}" --eval "${reset_cmd}" >/dev/null 2>&1
    if action "密码重置成功(已恢复为默认:ScopeSentry)" "数据库指令执行失败,请检查容器日志"; then
        local host_ip host_port scopesentry_user scopesentry_pass plugin_key
        get_scopesentry_info
        show_access_info "ScopeSentry账户信息" \
            "URL地址: http://${host_ip}:${host_port}" \
            "用户账户: ScopeSentry" \
            "用户密码: ScopeSentry" \
            "插件密钥: ${plugin_key}"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置ScopeSentry" config_scopesentry