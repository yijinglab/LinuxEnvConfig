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
#  📝 模块描述 : DeepAudit深度审计分析
#  📁 文件路径 : modules/deepaudit.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly DEEPAUDIT_DIR="/opt/DeepAudit"
readonly DEEPAUDIT_IMAGE_BACKEND="ghcr.nju.edu.cn/lintsinghua/deepaudit-backend:latest"
readonly DEEPAUDIT_IMAGE_FRONTEND="ghcr.nju.edu.cn/lintsinghua/deepaudit-frontend:latest"
readonly DEEPAUDIT_IMAGE_SANDBOX="ghcr.nju.edu.cn/lintsinghua/deepaudit-sandbox:latest"
readonly DEEPAUDIT_DB="docker.gh-proxy.org/docker.io/postgres:15-alpine"
readonly DEEPAUDIT_REDIS="docker.gh-proxy.org/docker.io/redis:7-alpine"
readonly DEEPAUDIT_DEFAULT_PORT="3000"

# ═══════════════════════════════════════════════════════════════
# DeepAudit配置主菜单
# ═══════════════════════════════════════════════════════════════

config_deepaudit() {
    while true; do
        show_submenu "DeepAudit深度审计分析" \
            "安装DeepAudit" \
            "卸载DeepAudit" \
            "启动DeepAudit" \
            "停止DeepAudit" \
            "查看DeepAudit状态"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_deepaudit ;;
            2) remove_deepaudit ;;
            3) start_deepaudit ;;
            4) stop_deepaudit ;;
            5) show_deepaudit_status ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装DeepAudit
# ═══════════════════════════════════════════════════════════════

install_deepaudit() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装DeepAudit"

    if [ -d "${DEEPAUDIT_DIR}" ]; then
        msg_success "检测到DeepAudit已安装,路径: ${DEEPAUDIT_DIR}"
        return 0
    fi

    msg_info "创建安装目录: ${DEEPAUDIT_DIR}"
    sudo mkdir -p "${DEEPAUDIT_DIR}"
    cd "${DEEPAUDIT_DIR}" || return 1

    local host_ip host_port llm_provider llm_model llm_api_key llm_base_url
    prompt_host_ip "DeepAudit" || return 1
    prompt_host_port "DeepAudit服务" "${DEEPAUDIT_DEFAULT_PORT}" || return 1
    
    msg_prompt "请输入LLM提供商 [默认: openai]" llm_provider
    llm_provider=${llm_provider:-openai}
    
    msg_prompt "请输入LLM模型名称 [默认: gpt-4o]" llm_model
    llm_model=${llm_model:-gpt-4o}
    
    msg_prompt_required "请输入LLM API KEY" llm_api_key
    
    msg_prompt "请输入LLM BASE URL (可选,留空则使用默认)" llm_base_url

    local docker_socket="/var/run/docker.sock"
    if command -v podman &> /dev/null; then
        local user_uid
        user_uid=$(id -u "${SUDO_USER:-$USER}" 2>/dev/null || echo 1000)
        if [ -S "/run/user/${user_uid}/podman/podman.sock" ]; then
            docker_socket="/run/user/${user_uid}/podman/podman.sock"
        elif [ -S "/run/podman/podman.sock" ]; then
            docker_socket="/run/podman/podman.sock"
        elif [ -S "/var/run/podman/podman.sock" ]; then
            docker_socket="/var/run/podman/podman.sock"
        fi
    fi

    msg_info "正在生成Compose部署文件..."
    sudo tee docker-compose.yml >/dev/null << 'EOF'
services:
  db:
    image: docker.gh-proxy.org/docker.io/postgres:15-alpine
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=deepaudit
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - deepaudit-network

  redis:
    image: docker.gh-proxy.org/docker.io/redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - deepaudit-network

  backend:
    image: ghcr.nju.edu.cn/lintsinghua/deepaudit-backend:latest
    restart: unless-stopped
    volumes:
      - backend_uploads:/app/uploads
      - ${DOCKER_SOCKET:-/var/run/docker.sock}:/var/run/docker.sock
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/deepaudit
      - REDIS_URL=redis://redis:6379/0
      - AGENT_ENABLED=true
      - SANDBOX_ENABLED=true
      - SANDBOX_IMAGE=ghcr.nju.edu.cn/lintsinghua/deepaudit-sandbox:latest
      - LLM_PROVIDER=${LLM_PROVIDER:-openai}
      - LLM_MODEL=${LLM_MODEL:-gpt-4o}
      - LLM_API_KEY=${LLM_API_KEY:-your-api-key-here}
      - LLM_BASE_URL=${LLM_BASE_URL:-}
      - HTTP_PROXY=
      - HTTPS_PROXY=
      - NO_PROXY=*
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
      db-migrate:
        condition: service_completed_successfully
    networks:
      - deepaudit-network

  db-migrate:
    image: ghcr.nju.edu.cn/lintsinghua/deepaudit-backend:latest
    restart: "no"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/deepaudit
    command: [".venv/bin/alembic", "upgrade", "head"]
    depends_on:
      db:
        condition: service_healthy
    networks:
      - deepaudit-network

  frontend:
    image: ghcr.nju.edu.cn/lintsinghua/deepaudit-frontend:latest
    restart: unless-stopped
    ports:
      - "${DEEPAUDIT_PORT:-3000}:80"
    environment:
      - HTTP_PROXY=
      - HTTPS_PROXY=
      - http_proxy=
      - https_proxy=
      - NO_PROXY=*
    depends_on:
      - backend
    networks:
      - deepaudit-network

  sandbox-pull:
    image: ghcr.nju.edu.cn/lintsinghua/deepaudit-sandbox:latest
    restart: "no"
    command: echo "Sandbox image ready"

networks:
  deepaudit-network:
    driver: bridge

volumes:
  postgres_data:
  backend_uploads:
  redis_data:
EOF

    msg_info "正在生成.env环境配置文件..."
    sudo tee .env >/dev/null << EOF
LLM_PROVIDER=${llm_provider}
LLM_MODEL=${llm_model}
LLM_API_KEY=${llm_api_key}
LLM_BASE_URL=${llm_base_url}
DEEPAUDIT_PORT=${host_port}
DOCKER_SOCKET=${docker_socket}
EOF

    docker_pull_image "${DEEPAUDIT_DB}"
    docker_pull_image "${DEEPAUDIT_REDIS}"
    docker_pull_image "${DEEPAUDIT_IMAGE_BACKEND}"
    docker_pull_image "${DEEPAUDIT_IMAGE_FRONTEND}"
    docker_pull_image "${DEEPAUDIT_IMAGE_SANDBOX}"

    msg_info "正在启动DeepAudit服务..."
    sudo "${COMPOSE_CMD[@]}" up -d >/dev/null 2>&1
    if action "容器编排指令执行完成" "服务启动失败"; then
        local masked_api_key="***"
        if [[ ${#llm_api_key} -gt 6 ]]; then
            masked_api_key="${llm_api_key:0:3}***${llm_api_key: -3}"
        elif [[ -n "${llm_api_key}" ]]; then
            masked_api_key="${llm_api_key:0:1}***"
        fi

        show_access_info "DeepAudit部署成功" \
            "访问地址: http://${host_ip}:${host_port}" \
            "演示账号: demo@example.com" \
            "演示密码: demo123" \
            "模型平台: ${llm_provider}" \
            "基础地址: ${llm_base_url:-默认}" \
            "模型名称: ${llm_model}" \
            "API KEY : ${masked_api_key}" \
            "注意事项: 生产环境请修改演示账户密码"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载DeepAudit
# ═══════════════════════════════════════════════════════════════

remove_deepaudit() {
    show_section "卸载DeepAudit"
    docker_compose_remove "${DEEPAUDIT_DIR}" "DeepAudit" \
        "${DEEPAUDIT_DB}" "${DEEPAUDIT_REDIS}" "${DEEPAUDIT_IMAGE_BACKEND}" "${DEEPAUDIT_IMAGE_FRONTEND}" "${DEEPAUDIT_IMAGE_SANDBOX}"
}

# ═══════════════════════════════════════════════════════════════
# 启动DeepAudit
# ═══════════════════════════════════════════════════════════════

start_deepaudit() {
    show_section "启动DeepAudit"
    docker_compose_start "${DEEPAUDIT_DIR}" "DeepAudit" "up" || return 1
    
    local host_ip host_port llm_provider llm_model llm_api_key llm_base_url
    host_ip=$(get_best_ip)
    
    if [[ -f "${DEEPAUDIT_DIR}/.env" ]]; then
        host_port=$(grep "^DEEPAUDIT_PORT=" "${DEEPAUDIT_DIR}/.env" | cut -d'=' -f2)
        llm_provider=$(grep "^LLM_PROVIDER=" "${DEEPAUDIT_DIR}/.env" | cut -d'=' -f2)
        llm_model=$(grep "^LLM_MODEL=" "${DEEPAUDIT_DIR}/.env" | cut -d'=' -f2)
        llm_api_key=$(grep "^LLM_API_KEY=" "${DEEPAUDIT_DIR}/.env" | cut -d'=' -f2)
        llm_base_url=$(grep "^LLM_BASE_URL=" "${DEEPAUDIT_DIR}/.env" | cut -d'=' -f2)
    fi
    host_port=${host_port:-${DEEPAUDIT_DEFAULT_PORT}}
    llm_provider=${llm_provider:-openai}
    llm_model=${llm_model:-gpt-4o}

    local masked_api_key="***"
    if [[ ${#llm_api_key} -gt 6 ]]; then
        masked_api_key="${llm_api_key:0:3}***${llm_api_key: -3}"
    elif [[ -n "${llm_api_key}" ]]; then
        masked_api_key="${llm_api_key:0:1}***"
    fi

    show_access_info "DeepAudit访问信息" \
        "访问地址: http://${host_ip}:${host_port}" \
        "演示账号: demo@example.com" \
        "演示密码: demo123" \
        "模型平台: ${llm_provider}" \
        "基础地址: ${llm_base_url:-默认}" \
        "模型名称: ${llm_model}" \
        "API KEY : ${masked_api_key}" \
        "注意事项: 生产环境请修改演示账户密码"
}

# ═══════════════════════════════════════════════════════════════
# 停止DeepAudit
# ═══════════════════════════════════════════════════════════════

stop_deepaudit() {
    show_section "停止DeepAudit"
    docker_compose_stop "${DEEPAUDIT_DIR}" "DeepAudit"
}

# ═══════════════════════════════════════════════════════════════
# 查看DeepAudit状态
# ═══════════════════════════════════════════════════════════════

show_deepaudit_status() {
    show_section "DeepAudit状态信息"
    if [[ ! -d "${DEEPAUDIT_DIR}" ]]; then
        msg_error "未检测到安装目录"
        return 1
    fi
    check_docker_compose || return 1
    cd "${DEEPAUDIT_DIR}" || return 1
    
    local widths="18 12 10 18"
    echo ""
    msg_table_row "$widths" "${BOLD}服务名称" "运行状态" "健康状况" "端口映射${NC}"
    draw_line "-" "${GRAY}"
    
    local line
    while read -r line; do
        [[ -z "$line" ]] && continue
        local service state health ports
        IFS='|' read -r service state health ports <<< "$line"
        
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
        
        local simple_ports
        simple_ports=$(echo "$ports" | grep -oE "[0-9]+->[0-9]+" | head -n 1)
        [[ -z "$simple_ports" ]] && simple_ports="-"

        msg_table_row "$widths" "${CYAN}${service}${NC}" "${state_color}${state}${NC}" "${health_color}${health:- -}${NC}" "${WHITE}${simple_ports}${NC}"
    done < <(sudo "${COMPOSE_CMD[@]}" ps --format "{{.Service}}|{{.State}}|{{.Health}}|{{.Ports}}" 2>/dev/null)
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置DeepAudit" config_deepaudit
