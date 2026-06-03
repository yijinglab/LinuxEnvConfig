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
#  📝 模块描述 : 灯塔 ARL 资产侦察系统配置模块
#  📁 文件路径 : modules/arl.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ═══════════════════════════════════════════════════════════════
# 全局变量定义
# ═══════════════════════════════════════════════════════════════

readonly ARL_DIR="/opt/docker_arl"
readonly ARL_DEFAULT_PORT="5003"
readonly ARL_RABBITMQ_IMAGE="registry.cn-hangzhou.aliyuncs.com/mingy123/rabbitmq:3.8.19-management-alpine"
readonly ARL_MONGO_IMAGE="registry.cn-hangzhou.aliyuncs.com/mingy123/mongo:4.0.27"
readonly ARL_DEFAULT_VERSION="v2.6.3"
readonly ARL_CONFIG_FILE="${ARL_DIR}/config-docker.yaml"
readonly ARL_CONTAINER_DICT_DIR="/code/app/dicts"
readonly ARL_CONTAINER_PATTERN="arl-(web|worker)|arl_(web|worker)"
readonly ARL_FINGER_GIT_URL="https://gitee.com/yijingsec/ARL-Finger-ADD.git"
readonly ARL_LATEST_RELEASE_API="https://gitee.com/api/v5/repos/yijingsec/ARL/releases/latest"
readonly ARL_DOWNLOAD_URL_TEMPLATE="https://gitee.com/yijingsec/ARL/releases/download"
readonly ARL_DEFAULT_USER="admin"
readonly ARL_DEFAULT_PASS="arlpass"

# ═══════════════════════════════════════════════════════════════
# 内部辅助函数
# ═══════════════════════════════════════════════════════════════

get_python_command() {
    if command -v python3 &>/dev/null; then
        echo "python3"
    elif command -v python &>/dev/null; then
        echo "python"
    else
        return 1
    fi
}


# ═══════════════════════════════════════════════════════════════
# ARL配置主菜单
# ═══════════════════════════════════════════════════════════════

config_arl() {
    while true; do
        show_submenu "ARL灯塔配置" \
            "安装ARL" \
            "停止ARL" \
            "启动ARL" \
            "卸载ARL" \
            "添加指纹" \
            "修改常用配置"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_arl; pause ;;
            2) stop_arl; pause ;;
            3) start_arl; pause ;;
            4) remove_arl; pause ;;
            5) add_fingerprint_to_arl; pause ;;
            6) modify_arl_config; pause ;;
            *) msg_error "无效选择"; pause ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装灯塔ARL
# ═══════════════════════════════════════════════════════════════

install_arl() {
    check_docker || return 1
    check_docker_compose || return 1
    show_section "安装灯塔ARL"
    
    local host_ip
    prompt_host_ip "灯塔ARL" || return 1

    local host_port
    prompt_host_port "灯塔ARL" "${ARL_DEFAULT_PORT}" "host_port" || return 1

    msg_info "正在预拉取核心镜像..."
    docker_pull_image "${ARL_RABBITMQ_IMAGE}"
    docker_pull_image "${ARL_MONGO_IMAGE}"

    msg_info "正在创建ARL安装目录..."
    sudo mkdir -p "${ARL_DIR}"
    msg_info "正在创建arl_db数据卷..."
    sudo docker volume create arl_db >/dev/null 2>&1 || true

    local latest_tag_name
    msg_info "正在获取灯塔ARL最新版本号..."
    latest_tag_name=$(curl -s --connect-timeout 5 "${ARL_LATEST_RELEASE_API}" | grep -E -o '"tag_name":"([^"]+)"' | awk -F'"' '{print $4}' || true)
    
    local download_url
    if [[ -n "${latest_tag_name}" ]]; then
        msg_success "获取成功，发现最新版本 ARL: ${latest_tag_name}"
        download_url="${ARL_DOWNLOAD_URL_TEMPLATE}/${latest_tag_name}/docker.zip"
    else
        msg_warning "获取最新版本号失败，将使用默认主线版本下载"
        download_url="${ARL_DOWNLOAD_URL_TEMPLATE}/${ARL_DEFAULT_VERSION}/docker.zip"
    fi

    while true; do
        msg_info "开始下载ARL压缩包..."
        download_file "${download_url}" "${ARL_DIR}/docker.zip"
        if action "下载ARL压缩包成功" "下载ARL压缩包失败 (网络连接超时或源站错误)"; then
            msg_info "验证ARL压缩包完整性..."
            sudo unzip -tq "${ARL_DIR}/docker.zip" >/dev/null 2>&1
            if action "ARL压缩包完整性校验成功" "ARL压缩包损坏或格式不正确"; then
                break
            else
                sudo rm -f "${ARL_DIR}/docker.zip"
            fi
        fi

        if ! confirm "下载或校验失败，是否尝试重新下载?"; then
            return 1
        fi
    done

    msg_info "开始解压ARL压缩包..."
    cd "${ARL_DIR}" || return 1
    sudo unzip -o docker.zip > /dev/null 2>&1

    if [[ "${host_port}" != "${ARL_DEFAULT_PORT}" ]]; then
        msg_info "正在将ARL映射端口从${ARL_DEFAULT_PORT}修改为${host_port}..."
        sudo sed -i -E "s/- [\"']?${ARL_DEFAULT_PORT}:443[\"']?/- \"${host_port}:443\"/g" docker-compose.yml
    fi

    if docker_compose_start "${ARL_DIR}" "灯塔ARL" "up"; then
        show_access_info \
            "访问地址: https://${host_ip}:${host_port}" \
            "默认用户: admin" \
            "默认密码: arlpass"
        msg_warning "登录后请尽快修改默认密码!"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 停止灯塔ARL
# ═══════════════════════════════════════════════════════════════

stop_arl() {
    show_section "停止灯塔ARL"
    docker_compose_stop "${ARL_DIR}" "灯塔ARL"
}

# ═══════════════════════════════════════════════════════════════
# 启动灯塔ARL
# ═══════════════════════════════════════════════════════════════

start_arl() {
    show_section "启动灯塔ARL"
    if [[ ! -d "${ARL_DIR}" ]]; then
        msg_error "未找到ARL安装目录, 请先安装"
        return 1
    fi

    local host_ip
    prompt_host_ip "灯塔ARL" || return 1

    local current_port="${ARL_DEFAULT_PORT}"
    if [[ -f "${ARL_DIR}/docker-compose.yml" ]]; then
        local extracted_port
        extracted_port=$(grep -oE "[0-9]+:443" "${ARL_DIR}/docker-compose.yml" | cut -d: -f1 || true)
        if [[ -n "${extracted_port}" ]]; then
            current_port="${extracted_port}"
        fi
    fi

    local host_port
    prompt_host_port "灯塔ARL" "${current_port}" "host_port" || return 1

    if [[ "${host_port}" != "${current_port}" ]]; then
        msg_info "正在将 ARL 映射端口从 ${current_port} 修改为 ${host_port}..."
        sudo sed -i -E "s/- [\"']?${current_port}:443[\"']?/- \"${host_port}:443\"/g" "${ARL_DIR}/docker-compose.yml"
    fi

    if docker_compose_start "${ARL_DIR}" "灯塔ARL" "up"; then
        show_access_info \
            "访问地址: https://${host_ip}:${host_port}" \
            "默认用户: admin" \
            "默认密码: arlpass"
        msg_warning "登录后请尽快修改默认密码!"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载灯塔ARL
# ═══════════════════════════════════════════════════════════════

remove_arl() {
    show_section "卸载灯塔ARL"
    check_docker_compose || return 1

    if [[ -d "${ARL_DIR}" ]]; then
        if confirm "检测到ARL安装目录, 确定要删除吗?"; then
            msg_info "停止并清理ARL容器..."
            cd "${ARL_DIR}" || return 1
            sudo "${COMPOSE_CMD[@]}" down -v >/dev/null 2>&1
            
            msg_info "删除ARL相关数据卷..."
            sudo docker volume rm arl_db >/dev/null 2>&1
            
            msg_info "清理安装目录..."
            cd ~ || return 1
            sudo rm -rf "${ARL_DIR}"
            msg_success "物理环境清理完成"
        fi
    else
        msg_info "未检测到ARL安装目录, 跳过物理清理"
    fi

    local images
    images=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "(^|/)arl(-|:)|rabbitmq:3.8.19|mongo:4.0.27" | grep -v "TAG" || true)
    
    if [[ -n "$images" ]]; then
        echo -e "  ${YELLOW}发现相关镜像:${NC}"
        echo "    - ${images//$'\n'/$'\n'    - }"
        if confirm "是否删除上述ARL相关Docker镜像?"; then
            msg_info "正在清理镜像..."
            echo "$images" | while read -r img; do
                sudo docker rmi "$img" >/dev/null 2>&1 && msg_info "已删除: $img" | sed 's/^/  /'
            done
            msg_success "镜像清理操作完成"
        fi
    fi

    msg_success "灯塔ARL卸载流程执行完毕"
}

# ═══════════════════════════════════════════════════════════════
# 给ARL添加指纹
# ═══════════════════════════════════════════════════════════════

add_fingerprint_to_arl() {
    show_section "给ARL添加指纹"
    
    if [[ ! -d "${ARL_DIR}" ]]; then
        msg_error "未找到ARL安装目录, 无法添加指纹"
        return 1
    fi

    cd "${ARL_DIR}" || return 1

    local arl_ip
    prompt_host_ip "灯塔ARL" "arl_ip" || return 1

    local current_port="${ARL_DEFAULT_PORT}"
    if [[ -f "${ARL_DIR}/docker-compose.yml" ]]; then
        local extracted_port
        extracted_port=$(grep -oE "[0-9]+:443" "${ARL_DIR}/docker-compose.yml" | cut -d: -f1 || true)
        if [[ -n "${extracted_port}" ]]; then
            current_port="${extracted_port}"
        fi
    fi

    local arl_port
    prompt_host_port "灯塔ARL" "${current_port}" "arl_port" || return 1
    
    local arl_pass
    read -r -p "  ${CYAN}请输入ARL的密码 [${ARL_DEFAULT_PASS}]: ${NC}" arl_pass
    arl_pass="${arl_pass:-${ARL_DEFAULT_PASS}}"

    msg_info "准备指纹更新脚本..."
    sudo rm -rf "${ARL_DIR}/ARL-Finger-ADD"
    local clone_success=false
    if sudo git clone "${ARL_FINGER_GIT_URL}" "${ARL_DIR}/ARL-Finger-ADD" 2>&1 | sed 's/^/  /'; then
        clone_success=true
    fi

    if $clone_success; then
        cd "${ARL_DIR}/ARL-Finger-ADD" || { sudo rm -rf "${ARL_DIR}/ARL-Finger-ADD"; return 1; }
        
        local py_cmd
        py_cmd=$(get_python_command)
        if [[ -n "$py_cmd" ]]; then
            msg_info "正在执行指纹添加 (这可能需要一些时间)..."
            sudo "$py_cmd" ARL-Finger-ADD.py "https://${arl_ip}:${arl_port}/" "${ARL_DEFAULT_USER}" "${arl_pass}" >/dev/null 2>&1
            action "指纹添加任务已完成" "指纹添加任务执行失败"
        else
            msg_error "需要 Python 环境"
        fi
        
        cd "${ARL_DIR}" || true
        sudo rm -rf "${ARL_DIR}/ARL-Finger-ADD"
    else
        msg_error "克隆指纹项目失败"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# YAML 配置文件修改工具
# ═══════════════════════════════════════════════════════════════

modify_yaml_value() {
    local file="$1"
    local block="$2"
    local key="$3"
    local val="$4"

    local py_cmd
    py_cmd=$(get_python_command) || { msg_error "需要 Python 环境"; return 1; }

    sudo "$py_cmd" -c '
import sys
filepath = sys.argv[1]
block = sys.argv[2]
key = sys.argv[3]
new_val = sys.argv[4]

with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

new_lines = []
in_block = False
block_indent = -1

for line in lines:
    stripped = line.strip()
    if not stripped:
        new_lines.append(line)
        continue
    indent = len(line) - len(line.lstrip())
    if in_block:
        if not stripped.startswith("#") and indent <= block_indent:
            in_block = False
            block_indent = -1
    no_comment = stripped.split("#", 1)[0].strip()
    clean_strip = no_comment.replace(" ", "").replace("\"", "").replace(chr(39), "")
    if clean_strip == block + ":":
        in_block = True
        block_indent = indent
        new_lines.append(line)
        continue
    if in_block and not stripped.startswith("#"):
        parts = stripped.split(":", 1)
        if len(parts) > 0 and parts[0].strip() == key:
            indent_str = line[:len(line) - len(line.lstrip())]
            new_lines.append(f"{indent_str}{key}: {new_val}\n")
            continue
    new_lines.append(line)

with open(filepath, "w", encoding="utf-8") as f:
    f.writelines(new_lines)
' "$file" "$block" "$key" "$val"
}

read_yaml_value() {
    local file="$1"
    local block="$2"
    local key="$3"

    local py_cmd
    py_cmd=$(get_python_command) || return 1

    sudo "$py_cmd" -c '
import sys
filepath = sys.argv[1]
block = sys.argv[2]
key = sys.argv[3]

with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

in_block = False
block_indent = -1

for line in lines:
    stripped = line.strip()
    if not stripped:
        continue
    indent = len(line) - len(line.lstrip())
    if in_block:
        if not stripped.startswith("#") and indent <= block_indent:
            in_block = False
            block_indent = -1
    no_comment = stripped.split("#", 1)[0].strip()
    clean_strip = no_comment.replace(" ", "").replace("\"", "").replace(chr(39), "")
    if clean_strip == block + ":":
        in_block = True
        block_indent = indent
        continue
    if in_block and not stripped.startswith("#"):
        parts = stripped.split(":", 1)
        if len(parts) > 0 and parts[0].strip() == key:
            print(parts[1].strip())
            sys.exit(0)
sys.exit(1)
' "$file" "$block" "$key"
}

# ═══════════════════════════════════════════════════════════════
# 修改 ARL 常用配置菜单与具体逻辑
# ═══════════════════════════════════════════════════════════════

modify_arl_config() {
    local config_file="${ARL_CONFIG_FILE}"
    if [[ ! -f "$config_file" ]]; then
        msg_error "未找到 ARL 配置文件: $config_file"
        return 1
    fi

    push_path "修改ARL常用配置"
    while true; do
        show_submenu "修改ARL常用配置" \
            "修改FOFA API" \
            "修改三方 API" \
            "管理禁止域名" \
            "修改爆破字典路径" \
            "应用配置并重启服务"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) pop_path; return ;;
            q|Q) exit 0 ;;
            1) modify_arl_fofa "$config_file"; pause ;;
            2) modify_arl_thirdparty_api "$config_file"; pause ;;
            3) manage_arl_forbidden_domains "$config_file" ;;
            4) modify_arl_dict "$config_file" ;;
            5) restart_arl_services; pause ;;
            *) msg_error "无效选择"; pause ;;
        esac
    done
    pop_path
}

modify_arl_fofa() {
    local config_file="$1"
    show_section "修改 FOFA API"

    local current_email; current_email=$(read_yaml_value "$config_file" "FOFA" "EMAIL" || echo "")
    local current_key; current_key=$(read_yaml_value "$config_file" "FOFA" "KEY" || echo "")

    msg_info "当前 FOFA 邮箱: ${current_email:-未配置}"
    msg_info "当前 FOFA Key : ${current_key:-未配置}"
    draw_line "-"

    local email
    read -r -p "  ${CYAN}请输入新的 FOFA 邮箱 (回车保持不变): ${NC}" email
    email="${email:-$current_email}"
    email=$(echo "$email" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

    local key
    read -r -p "  ${CYAN}请输入新的 FOFA Key  (回车保持不变): ${NC}" key
    key="${key:-$current_key}"
    key=$(echo "$key" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

    modify_yaml_value "$config_file" "FOFA" "EMAIL" "\"$email\""
    modify_yaml_value "$config_file" "FOFA" "KEY" "\"$key\""
    
    msg_success "FOFA API 配置修改完成"
}

modify_arl_thirdparty_api() {
    local config_file="$1"
    push_path "修改三方 API"
    while true; do
        show_submenu "修改三方 API" \
            "奇安信 Hunter (hunter_qax)" \
            "360 Quake (quake_360)" \
            "钟馗之眼 ZoomEye (zoomeye)" \
            "Chaos (chaos)" \
            "VirusTotal (virustotal)" \
            "SecurityTrails (securitytrails)"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"
        [[ "$choice" == "0" ]] && { pop_path; return; }
        [[ "$choice" =~ ^[qQ]$ ]] && { pop_path; return; }

        local plugin_name=""
        local token_key="api_key"
        case $choice in
            1) plugin_name="hunter_qax"; token_key="api_key" ;;
            2) plugin_name="quake_360"; token_key="quake_token" ;;
            3) plugin_name="zoomeye"; token_key="api_key" ;;
            4) plugin_name="chaos"; token_key="api_key" ;;
            5) plugin_name="virustotal"; token_key="api_key" ;;
            6) plugin_name="securitytrails"; token_key="api_key" ;;
            *) msg_error "无效选择"; continue ;;
        esac

        show_section "配置 $plugin_name"
        local current_key; current_key=$(read_yaml_value "$config_file" "$plugin_name" "$token_key" || echo "")
        local current_enable; current_enable=$(read_yaml_value "$config_file" "$plugin_name" "enable" || echo "")

        msg_info "当前API Key/Token : ${current_key:-未配置}"
        msg_info "当前启用状态      : ${current_enable:-false}"
        draw_line "-"

        local new_key
        read -r -p "  ${CYAN}请输入新的 API Key/Token (回车保持不变): ${NC}" new_key
        new_key="${new_key:-$current_key}"
        new_key=$(echo "$new_key" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")

        local enable_choice
        if confirm "是否启用该插件?"; then
            enable_choice="true"
        else
            enable_choice="false"
        fi

        modify_yaml_value "$config_file" "$plugin_name" "$token_key" "\"$new_key\""
        modify_yaml_value "$config_file" "$plugin_name" "enable" "$enable_choice"

        msg_success "$plugin_name 配置修改完成"
        break
    done
    pop_path
}

manage_arl_forbidden_domains() {
    local config_file="$1"
    
    local py_cmd
    py_cmd=$(get_python_command) || { msg_error "需要 Python 环境"; return 1; }

    push_path "管理禁止域名"
    while true; do
        show_submenu "禁止域名操作" \
            "新增禁止域名" \
            "删除禁止域名"
        
        local domains
        domains=$(sudo "$py_cmd" -c '
import sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    lines = f.readlines()
in_block = False
block_indent = -1
for line in lines:
    stripped = line.strip()
    if not stripped:
        continue
    indent = len(line) - len(line.lstrip())
    if in_block:
        if not stripped.startswith("#") and not stripped.startswith("-") and indent <= block_indent:
            in_block = False
            block_indent = -1
    no_comment = stripped.split("#", 1)[0].strip()
    if no_comment.replace(" ", "").replace("\"", "").replace(chr(39), "") == "FORBIDDEN_DOMAINS:":
        in_block = True
        block_indent = indent
        continue
    if in_block and stripped.startswith("-"):
        domain = stripped.replace("-", "").strip().strip("\"").strip(chr(39))
        print(domain)
' "$config_file")

        local domain_list=()
        if [[ -n "$domains" ]]; then
            mapfile -t domain_list <<< "$domains"
        fi

        draw_line "-"
        if [[ ${#domain_list[@]} -eq 0 ]]; then
            msg_warning "当前无禁止域名配置"
        else
            msg_info "当前已配置的禁止域名:"
            local i
            for i in "${!domain_list[@]}"; do
                echo -e "      ${GREEN}$((i+1)).${NC} ${domain_list[$i]}"
            done
        fi
        draw_line "-"

        local choice
        msg_prompt "请选择操作 [0-2, q退出]"
        [[ "$choice" == "0" ]] && { pop_path; return; }
        [[ "$choice" =~ ^[qQ]$ ]] && { pop_path; return; }

        case $choice in
            1)
                local new_domain
                read -r -p "  ${CYAN}请输入要新增的域名 (例如 company.com): ${NC}" new_domain
                if [[ -z "$new_domain" ]]; then
                    msg_error "域名不能为空"
                    continue
                fi
                sudo "$py_cmd" -c '
import sys
filepath = sys.argv[1]
new_domain = sys.argv[2]
with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

target_index = -1
for i, line in enumerate(lines):
    stripped = line.strip()
    no_comment = stripped.split("#", 1)[0].strip()
    if no_comment.replace(" ", "").replace("\"", "").replace(chr(39), "") == "FORBIDDEN_DOMAINS:":
        target_index = i
        break

if target_index != -1:
    last_item_idx = target_index
    indent = len(lines[target_index]) - len(lines[target_index].lstrip())
    list_indent = indent + 4
    
    for j in range(target_index + 1, len(lines)):
        line_j = lines[j]
        stripped_j = line_j.strip()
        if not stripped_j:
            continue
        indent_j = len(line_j) - len(line_j.lstrip())
        if stripped_j.startswith("#"):
            continue
        if stripped_j.startswith("-"):
            last_item_idx = j
            list_indent = indent_j
        elif indent_j <= indent:
            break
            
    lines.insert(last_item_idx + 1, " " * list_indent + f"- {new_domain}\n")

with open(filepath, "w", encoding="utf-8") as f:
    f.writelines(lines)
' "$config_file" "$new_domain"
                msg_success "已成功新增禁止域名: $new_domain"
                ;;
            2)
                if [[ ${#domain_list[@]} -eq 0 ]]; then
                    msg_error "当前没有禁止域名可供删除"
                    continue
                fi
                local del_idx
                read -r -p "  ${CYAN}请输入要删除的域名编号 (1-${#domain_list[@]}): ${NC}" del_idx
                if ! [[ "$del_idx" =~ ^[0-9]+$ ]] || [[ "$del_idx" -lt 1 ]] || [[ "$del_idx" -gt ${#domain_list[@]} ]]; then
                    msg_error "无效编号"
                    continue
                fi
                local del_domain="${domain_list[$((del_idx-1))]}"
                sudo "$py_cmd" -c '
import sys
filepath = sys.argv[1]
del_domain = sys.argv[2]
with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

target_index = -1
for i, line in enumerate(lines):
    stripped = line.strip()
    no_comment = stripped.split("#", 1)[0].strip()
    if no_comment.replace(" ", "").replace("\"", "").replace(chr(39), "") == "FORBIDDEN_DOMAINS:":
        target_index = i
        break

if target_index != -1:
    indent = len(lines[target_index]) - len(lines[target_index].lstrip())
    for j in range(target_index + 1, len(lines)):
        line_j = lines[j]
        stripped_j = line_j.strip()
        if not stripped_j:
            continue
        indent_j = len(line_j) - len(line_j.lstrip())
        if stripped_j.startswith("#"):
            continue
        if stripped_j.startswith("-"):
            domain = stripped_j.replace("-", "").strip().strip("\"").strip(chr(39))
            if domain == del_domain:
                del lines[j]
                break
        elif indent_j <= indent:
            break

with open(filepath, "w", encoding="utf-8") as f:
    f.writelines(lines)
' "$config_file" "$del_domain"
                msg_success "已成功删除禁止域名: $del_domain"
                ;;
            *)
                msg_error "无效选择"
                ;;
        esac
        pause
    done
    pop_path
}

update_arl_dict_file() {
    local config_file="$1"
    local containers="$2"
    local yaml_key="$3"
    local dict_name="$4"

    local local_path
    read -r -p "  ${CYAN}请输入本地${dict_name}的绝对路径: ${NC}" local_path
    if [[ -z "$local_path" ]]; then
        msg_error "路径不能为空"
        pause
        return 1
    fi
    if [[ ! -f "$local_path" ]]; then
        msg_error "本地文件不存在: $local_path"
        pause
        return 1
    fi

    local filename; filename=$(basename "$local_path")
    local container_path="${ARL_CONTAINER_DICT_DIR}/$filename"

    local copy_failed=false
    if [[ -n "$containers" ]]; then
        local c
        for c in $containers; do
            msg_info "正在复制 $filename 到容器 $c 的 ${ARL_CONTAINER_DICT_DIR}/ ..."
            if sudo docker cp "$local_path" "$c:$container_path" 2>&1 | sed 's/^/  /'; then
                msg_success "成功复制到容器 $c"
            else
                msg_error "复制到容器 $c 失败"
                copy_failed=true
            fi
        done
    fi

    if $copy_failed; then
        msg_error "由于容器复制过程出现错误，未更新 YAML 配置文件中的字典路径"
        pause
        return 1
    fi

    modify_yaml_value "$config_file" "ARL" "$yaml_key" "\"$container_path\""
    msg_success "配置文件中的${dict_name}路径已更新为: $container_path"
    pause
}

modify_arl_dict() {
    local config_file="$1"

    push_path "修改爆破字典路径"
    while true; do
        show_submenu "修改爆破字典路径" \
            "修改域名爆破字典" \
            "修改文件泄漏字典"

        local current_domain_dict; current_domain_dict=$(read_yaml_value "$config_file" "ARL" "DOMAIN_DICT" || echo "")
        local current_file_leak_dict; current_file_leak_dict=$(read_yaml_value "$config_file" "ARL" "FILE_LEAK_DICT" || echo "")

        draw_line "-"
        msg_info "当前域名爆破字典: ${current_domain_dict:-未配置}"
        msg_info "当前文件泄漏字典: ${current_file_leak_dict:-未配置}"
        draw_line "-"

        local containers
        containers=$(sudo docker ps -a --format '{{.Names}}' | grep -E "${ARL_CONTAINER_PATTERN}" || true)
        if [[ -z "$containers" ]]; then
            msg_warning "未检测到运行中的 ARL 容器，字典文件将在下次启动或手动复制后生效"
        fi

        local choice
        msg_prompt "请选择修改的字典 [0-2, q退出]"
        [[ "$choice" == "0" ]] && { pop_path; return; }
        [[ "$choice" =~ ^[qQ]$ ]] && { pop_path; return; }

        case $choice in
            1)
                update_arl_dict_file "$config_file" "$containers" "DOMAIN_DICT" "域名爆破字典"
                ;;
            2)
                update_arl_dict_file "$config_file" "$containers" "FILE_LEAK_DICT" "文件泄漏字典"
                ;;
            *)
                msg_error "无效选择"
                pause
                ;;
        esac
    done
    pop_path
}

restart_arl_services() {
    if confirm "要立即重启 ARL 服务以应用新配置吗?"; then
        docker_compose_stop "${ARL_DIR}" "灯塔ARL"
        docker_compose_start "${ARL_DIR}" "灯塔ARL" "up"
    fi
}

register_main_menu "配置ARL" "config_arl"

