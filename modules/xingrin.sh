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
#  📝 模块描述 : XingRin分布式安全扫描平台配置模块
#  📁 文件路径 : modules/xingrin.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly XINGRIN_DIR="/opt/xingrin"
readonly XINGRIN_REPO="https://github.com/yyhuni/xingrin.git"

# ═══════════════════════════════════════════════════════════════
# 主配置菜单
# ═══════════════════════════════════════════════════════════════

config_xingrin() {
    while true; do
        show_submenu "XingRin平台配置" \
            "安装XingRin" \
            "卸载XingRin" \
            "启动XingRin" \
            "停止XingRin" \
            "查看XingRin状态"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_xingrin ;;
            2) remove_xingrin ;;
            3) start_xingrin ;;
            4) stop_xingrin ;;
            5) show_xingrin_status ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

_init_xingrin_data() {
    local docker_dir="$1"
    msg_info "正在初始化系统数据与管理员账户..."
    cd "${docker_dir}" || return 1
    local prev_msg=""
    local lines_printed=0
    sudo bash ./scripts/init-data.sh 2>&1 | while read -r line; do
        local status_msg=""
        if [[ "$line" =~ "等待 Server 服务" ]]; then
            status_msg="正在等待后台服务就绪..."
        elif [[ "$line" =~ "Server 服务已就绪" ]]; then
            status_msg="后台服务就绪完成"
        elif [[ "$line" =~ "执行数据库迁移" ]]; then
            status_msg="正在执行数据库表迁移..."
        elif [[ "$line" =~ "初始化引擎配置" ]]; then
            status_msg="正在初始化扫描引擎配置..."
        elif [[ "$line" =~ "初始化字典" ]]; then
            status_msg="正在初始化内置扫描字典..."
        elif [[ "$line" =~ "初始化指纹库" ]]; then
            status_msg="正在解析并加载指纹库..."
        elif [[ "$line" =~ "初始化 Nuclei 模板" ]]; then
            status_msg="正在导入Nuclei模板信息..."
        elif [[ "$line" =~ "初始化 admin 用户" ]]; then
            status_msg="正在创建默认管理员账户..."
        elif [[ "$line" =~ "admin 用户创建成功" ]]; then
            status_msg="管理员账户初始化成功"
        elif [[ "$line" =~ "数据初始化完成" ]]; then
            status_msg="数据初始化工作全部完成"
        fi
        [[ -z "$status_msg" ]] && continue
        while [[ $lines_printed -gt 0 ]]; do
            printf "\033[A\r\033[K"
            ((lines_printed--))
        done
        if [[ -n "$prev_msg" ]]; then
            printf "  ${GRAY}➜ %s${NC}\n" "$prev_msg"
            printf "  ${BRIGHT_BLUE}➜${NC} ${CYAN}%s${NC}\n" "$status_msg"
            lines_printed=2
        else
            printf "  ${BRIGHT_BLUE}➜${NC} ${CYAN}%s${NC}\n" "$status_msg"
            lines_printed=1
        fi
        prev_msg="$status_msg"
    done
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        msg_warning "数据初始化脚本执行失败，请稍后手动运行:cd ${docker_dir} && sudo bash ./scripts/init-data.sh"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 生命周期实现
# ═══════════════════════════════════════════════════════════════

install_xingrin() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装XingRin"

    local skip_clone=false
    if [[ -d "${XINGRIN_DIR}" ]]; then
        msg_warning "检测到已存在安装目录: ${XINGRIN_DIR}"
        if ! confirm "是否覆盖安装并重新拉取代码?"; then
            skip_clone=true
            msg_info "跳过克隆代码，继续后续配置与启动步骤..."
        else
            sudo rm -rf "${XINGRIN_DIR}"
        fi
    fi

    local host_ip
    prompt_host_ip "XingRin" || return 1

    local cmd
    for cmd in git curl jq; do
        if ! command_exists "$cmd"; then
            msg_warning "系统未检测到${cmd},正在尝试自动安装..."
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -y >/dev/null 2>&1
                sudo apt-get install -y "$cmd" >/dev/null 2>&1
            fi
        fi
    done

    if [[ "$skip_clone" == "false" ]]; then
        msg_info "正在从远程仓库克隆XingRin代码..."
        sudo git clone --depth 1 "${XINGRIN_REPO}" "${XINGRIN_DIR}" 2>&1 | sed 's/^/  /'
        if ! action "克隆代码成功" "克隆代码失败"; then
            return 1
        fi
    fi

    msg_info "正在创建必要的数据目录..."
    sudo mkdir -p "${XINGRIN_DIR}"/{results,logs,fingerprints,wordlists,nuclei-repos}
    sudo chmod -R 777 "${XINGRIN_DIR}"

    local app_version="latest"
    if [[ -f "${XINGRIN_DIR}/VERSION" ]]; then
        app_version=$(cat "${XINGRIN_DIR}/VERSION" | tr -d '[:space:]')
    fi
    msg_info "识别到系统版本:${app_version}"

    local docker_dir="${XINGRIN_DIR}/docker"
    if [[ ! -f "${docker_dir}/.env.example" ]]; then
        msg_error "未找到 .env.example 模板文件，安装终止"
        return 1
    fi

    update_env_var() {
        local file="$1" key="$2" value="$3"
        if grep -q "^$key=" "$file"; then
            sudo sed -i "s|^$key=.*|$key=$value|" "$file"
        else
            echo "$key=$value" | sudo tee -a "$file" >/dev/null
        fi
    }

    if [[ ! -f "${docker_dir}/.env" ]]; then
        sudo cp "${docker_dir}/.env.example" "${docker_dir}/.env"
        msg_info "正在生成系统随机秘钥与密码..."
        local django_key db_pass worker_key
        if command -v openssl &>/dev/null; then
            django_key=$(openssl rand -hex 32)
            db_pass=$(openssl rand -hex 16)
            worker_key=$(openssl rand -hex 16)
        else
            django_key=$(date +%s%N | sha256sum | head -c 64)
            db_pass=$(date +%s%N | sha256sum | head -c 32)
            worker_key=$(date +%s%N | sha256sum | head -c 32)
        fi
        update_env_var "${docker_dir}/.env" "DJANGO_SECRET_KEY" "$django_key"
        update_env_var "${docker_dir}/.env" "DB_PASSWORD" "$db_pass"
        update_env_var "${docker_dir}/.env" "WORKER_API_KEY" "$worker_key"
    fi
    update_env_var "${docker_dir}/.env" "IMAGE_TAG" "$app_version"

    if confirm "是否使用远程PostgreSQL数据库？"; then
        local db_host="" db_port="" db_user="" db_pass_input=""
        
        while [[ -z "${db_host}" ]]; do
            read -r -p "  ${CYAN}请输入远程数据库地址: ${NC}" db_host
        done
        read -r -p "  ${CYAN}请输入远程数据库端口 [5432]: ${NC}" db_port
        db_port=${db_port:-5432}
        while [[ -z "${db_user}" ]]; do
            read -r -p "  ${CYAN}请输入远程数据库用户名: ${NC}" db_user
        done
        while [[ -z "${db_pass_input}" ]]; do
            read -r -p "  ${CYAN}请输入远程数据库密码: ${NC}" db_pass_input
        done
        
        msg_info "正在校验远程数据库连接..."
        if ! sudo docker run --rm -e PGPASSWORD="$db_pass_input" postgres:15 \
            psql "postgresql://$db_user@$db_host:$db_port/postgres" -c "SELECT 1" >/dev/null 2>&1; then
            msg_error "远程数据库连接失败, 请检查配置"
            return 1
        fi
        msg_success "远程数据库连接验证成功"
        
        msg_info "正在初始化业务数据库与依赖库..."
        sudo docker run --rm -e PGPASSWORD="$db_pass_input" postgres:15 \
            psql "postgresql://$db_user@$db_host:$db_port/postgres" -c "CREATE DATABASE xingrin;" >/dev/null 2>&1 || true
        sudo docker run --rm -e PGPASSWORD="$db_pass_input" postgres:15 \
            psql "postgresql://$db_user@$db_host:$db_port/postgres" -c "CREATE DATABASE prefect;" >/dev/null 2>&1 || true
            
        msg_info "正在创建pg_ivm扩展..."
        if ! sudo docker run --rm -e PGPASSWORD="$db_pass_input" postgres:15 \
            psql "postgresql://$db_user@$db_host:$db_port/xingrin" -c "CREATE EXTENSION IF NOT EXISTS pg_ivm;" >/dev/null 2>&1; then
            msg_error "远程数据库pg_ivm扩展缺失或启用失败！"
            return 1
        fi
        msg_success "pg_ivm扩展已启用"
        
        update_env_var "${docker_dir}/.env" "DB_HOST" "$db_host"
        update_env_var "${docker_dir}/.env" "DB_PORT" "$db_port"
        update_env_var "${docker_dir}/.env" "DB_USER" "$db_user"
        update_env_var "${docker_dir}/.env" "DB_PASSWORD" "$db_pass_input"
    fi

    if confirm "当前是否为远程VPS部署？"; then
        update_env_var "${docker_dir}/.env" "PUBLIC_HOST" "$host_ip"
    else
        update_env_var "${docker_dir}/.env" "PUBLIC_HOST" "server"
    fi

    local ssl_dir="${docker_dir}/nginx/ssl"
    if [[ ! -f "${ssl_dir}/fullchain.pem" || ! -f "${ssl_dir}/privkey.pem" ]]; then
        msg_info "未检测到HTTPS证书,正在生成自签证书..."
        sudo mkdir -p "$ssl_dir"
        if sudo docker run --rm -v "${ssl_dir}:/ssl" alpine/openssl \
            req -x509 -nodes -newkey rsa:2048 -days 365 \
            -keyout /ssl/privkey.pem \
            -out /ssl/fullchain.pem \
            -subj "/C=CN/ST=NA/L=NA/O=XingRin/CN=localhost" \
            -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" >/dev/null 2>&1; then
            msg_success "自签证书生成成功"
        else
            msg_warning "自签证书生成失败,请手动将证书放置在:${ssl_dir}"
        fi
    fi

    msg_info "正在预拉取核心镜像..."
    local worker_image="yyhuni/xingrin-worker:${app_version}"
    local server_image="yyhuni/xingrin-server:${app_version}"
    docker_pull_image "$worker_image"
    docker_pull_image "$server_image"

    local templates_dir="/opt/xingrin/nuclei-repos/nuclei-templates"
    if [[ ! -d "${templates_dir}/.git" ]]; then
        msg_info "正在预下载Nuclei模板仓库..."
        sudo mkdir -p "/opt/xingrin/nuclei-repos"
        if sudo git clone --depth 1 https://github.com/projectdiscovery/nuclei-templates.git "$templates_dir" 2>&1 | sed 's/^/  /'; then
            msg_success "Nuclei模板仓库下载完成"
        else
            msg_warning "Nuclei模板仓库下载失败,将在服务启动后重试"
        fi
    fi

    msg_info "正在启动XingRin容器编排堆栈..."
    local -a COMPOSE_CMD=("${COMPOSE_CMD[@]}")
    local env_db_host
    env_db_host=$(grep -E "^DB_HOST=" "${docker_dir}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'") || env_db_host="postgres"
    if [[ "$env_db_host" == "postgres" || "$env_db_host" == "localhost" || "$env_db_host" == "127.0.0.1" ]]; then
        COMPOSE_CMD+=(--profile local-db)
    fi
    docker_compose_start "${docker_dir}" "XingRin" "up" || return 1

    _init_xingrin_data "${docker_dir}"

    show_access_info "XingRin部署成功" \
        "访问地址:https://${host_ip}:8083/" \
        "默认账户:admin" \
        "默认密码:admin" \
        "注意事项:请首次登录后立即修改默认密码！"
}

remove_xingrin() {
    show_section "卸载XingRin"
    check_docker_compose || return 1

    local -a COMPOSE_CMD=("${COMPOSE_CMD[@]}")
    if [[ -d "${XINGRIN_DIR}/docker" ]]; then
        local env_db_host
        env_db_host=$(grep -E "^DB_HOST=" "${XINGRIN_DIR}/docker/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'") || env_db_host="postgres"
        if [[ "$env_db_host" == "postgres" || "$env_db_host" == "localhost" || "$env_db_host" == "127.0.0.1" ]]; then
            COMPOSE_CMD+=(--profile local-db)
        fi
        msg_info "正在停止并清理容器资源..."
        cd "${XINGRIN_DIR}/docker" || return 1
        sudo "${COMPOSE_CMD[@]}" down -v >/dev/null 2>&1
    fi

    local app_version="latest"
    if [[ -f "${XINGRIN_DIR}/VERSION" ]]; then
        app_version=$(cat "${XINGRIN_DIR}/VERSION" | tr -d '[:space:]')
    fi

    if [[ -d "${XINGRIN_DIR}" ]]; then
        if confirm "检测到XingRin数据和配置目录, 确定要完全卸载清理吗?"; then
            cd ~ || return 1
            sudo rm -rf "${XINGRIN_DIR}"
            msg_success "物理环境清理完成"
        fi
    fi

    local images=(
        "yyhuni/xingrin-worker:${app_version}"
        "yyhuni/xingrin-server:${app_version}"
        "postgres:15"
        "redis:alpine"
        "nginx:alpine"
        "prefecthq/prefect:2.14-python3.10"
    )

    local image_exists=false
    local img
    for img in "${images[@]}"; do
        if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "${img}"; then
            image_exists=true
            break
        fi
    done

    if [[ "$image_exists" == "true" ]]; then
        if confirm "是否清理XingRin相关Docker镜像?"; then
            msg_info "正在清理本地镜像..."
            for img in "${images[@]}"; do
                docker rmi "${img}" >/dev/null 2>&1 || true
            done
            msg_success "镜像清理完成"
        fi
    fi

    msg_success "XingRin卸载完成"
}

start_xingrin() {
    show_section "启动XingRin"
    local docker_dir="${XINGRIN_DIR}/docker"
    check_docker_compose || return 1

    local -a COMPOSE_CMD=("${COMPOSE_CMD[@]}")
    local env_db_host
    env_db_host=$(grep -E "^DB_HOST=" "${docker_dir}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'") || env_db_host="postgres"
    if [[ "$env_db_host" == "postgres" || "$env_db_host" == "localhost" || "$env_db_host" == "127.0.0.1" ]]; then
        COMPOSE_CMD+=(--profile local-db)
    fi

    docker_compose_start "${docker_dir}" "XingRin" "up" || return 1

    _init_xingrin_data "${docker_dir}"

    local host_ip
    host_ip=$(get_best_ip)
    show_access_info "XingRin访问信息" \
        "访问地址:https://${host_ip}:8083/" \
        "默认账户:admin" \
        "默认密码:admin（若已修改请使用新密码）"
}

stop_xingrin() {
    show_section "停止XingRin"
    local docker_dir="${XINGRIN_DIR}/docker"
    check_docker_compose || return 1

    local -a COMPOSE_CMD=("${COMPOSE_CMD[@]}")
    local env_db_host
    env_db_host=$(grep -E "^DB_HOST=" "${docker_dir}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'") || env_db_host="postgres"
    if [[ "$env_db_host" == "postgres" || "$env_db_host" == "localhost" || "$env_db_host" == "127.0.0.1" ]]; then
        COMPOSE_CMD+=(--profile local-db)
    fi

    docker_compose_stop "${docker_dir}" "XingRin"
}

show_xingrin_status() {
    show_section "XingRin状态信息"
    local docker_dir="${XINGRIN_DIR}/docker"
    if [[ ! -d "$docker_dir" ]]; then
        msg_error "未检测到安装目录"
        return 1
    fi
    check_docker_compose || return 1
    cd "$docker_dir" || return 1

    local -a COMPOSE_CMD=("${COMPOSE_CMD[@]}")
    local env_db_host
    env_db_host=$(grep -E "^DB_HOST=" "${docker_dir}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' "'"'") || env_db_host="postgres"
    if [[ "$env_db_host" == "postgres" || "$env_db_host" == "localhost" || "$env_db_host" == "127.0.0.1" ]]; then
        COMPOSE_CMD+=(--profile local-db)
    fi

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
# 模块注册
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置XingRin" config_xingrin
