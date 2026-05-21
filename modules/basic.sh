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
#  📝 模块描述 : 基础环境配置模块 (Root, SSH, DNS)
#  📁 文件路径 : modules/basic.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 基础配置主菜单
# ═══════════════════════════════════════════════════════════════

config_basic() {
    while true; do
        show_submenu "基础配置" \
            "启用ROOT用户" \
            "启用SSH服务" \
            "允许ROOT用户SSH登录" \
            "设置DNS名称服务器" \
            "查看网络接口信息" \
            "解除DNS的53端口占用"

        local choice
        msg_prompt "请选择操作 [0-6, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) enable_root_user ;;
            2) enable_ssh ;;
            3) enable_root_ssh ;;
            4) push_path "设置DNS名称服务器"; config_dns; pop_path; continue ;;
            5) show_network_info ;; 
            6) unlock_dns_port ;;  
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 启用 ROOT 用户 (设置密码并解除锁定)
# ═══════════════════════════════════════════════════════════════

enable_root_user() {
    show_section "启用ROOT用户"

    if [[ $EUID -eq 0 ]]; then
        msg_warning "当前已是ROOT用户"

        if confirm "是否修改ROOT密码?"; then
            set_root_password
        fi
        return
    fi

    set_root_password
}

set_root_password() {
    local password

    read_password "请输入新的ROOT密码" password

    if [[ -z $password ]]; then
        msg_error "密码不能为空"
        return 1
    fi

    printf "root:%s" "$password" | chpasswd
    if action "ROOT密码设置成功" "ROOT密码设置失败"; then
        local current_shell
        current_shell=$(getent passwd root | cut -d: -f7)
        if [[ "$current_shell" =~ (nologin|false)$ ]]; then
            usermod -s /bin/bash root >/dev/null 2>&1 || true
        fi
        passwd -u root >/dev/null 2>&1 || true
        msg_success "现在可以使用 ${BRIGHT_WHITE}su -${NC} 切换到ROOT用户"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# 启用 SSH 服务 (OpenSSH-Server)
# ═══════════════════════════════════════════════════════════════

enable_ssh() {
    show_section "启用SSH服务"

    if ! command_exists sshd && ! is_package_installed openssh-server; then
        msg_info "正在安装OpenSSH Server"
        if ! install_package openssh-server; then
            msg_error "安装失败"
            return 1
        fi
    fi

    enable_service ssh
    start_service ssh

    local port
    port=$(grep -E "^Port\s+" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
    [[ -z $port ]] && port=22

    msg_success "SSH服务运行中，端口号: ${BRIGHT_WHITE}${port}${NC}"
}

# ═══════════════════════════════════════════════════════════════
# 允许 ROOT 用户通过 SSH 远程登录
# ═══════════════════════════════════════════════════════════════

enable_root_ssh() {
    show_section "允许ROOT用户SSH登录"

    local sshd_config="/etc/ssh/sshd_config"

    if [[ ! -f $sshd_config ]]; then
        msg_error "SSH配置文件不存在"
        return 1
    fi

    backup_file "$sshd_config"

    if grep -qE "^#?PermitRootLogin" "$sshd_config"; then
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$sshd_config"
    else
        echo "PermitRootLogin yes" >> "$sshd_config"
    fi
    
    restart_service ssh
    if action "已启用ROOT用户SSH登录" "配置重启失败"; then
        msg_info "请使用'ssh root@<ip>'连接"
    else
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# DNS 配置管理
# ═══════════════════════════════════════════════════════════════

config_dns() {
    while true; do
        show_submenu "配置DNS" \
            "自动配置DNS" \
            "手动配置DNS" \
            "DNS备份管理"

        msg_prompt "请选择操作 [0-3, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) auto_config_dns ;;
            2) manual_config_dns ;;
            3) push_path "备份管理"; manage_dns_backups; pop_path; continue ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

auto_config_dns() {
    show_section "自动配置DNS"

    local dns_servers=(
        "223.5.5.5"
        "223.6.6.6"
        "119.29.29.29"
        "114.114.114.114"
        "1.1.1.1"
        "8.8.8.8"
    )

    apply_dns_config "auto" "${dns_servers[@]}"
}

manual_config_dns() {
    show_section "手动配置DNS"

    local dns_list=()
    msg_info "请输入DNS服务器地址(输入空行结束)"

    while true; do
        read -r -p "  ${CYAN}DNS $(( ${#dns_list[@]} + 1 )): ${NC}" dns

        [[ -z $dns ]] && break

        if validate_ip "$dns"; then
            dns_list+=("$dns")
        fi
    done

    if [[ ${#dns_list[@]} -eq 0 ]]; then
        msg_warning "未输入任何DNS地址"
        return 1
    fi

    apply_dns_config "manual" "${dns_list[@]}"
}

apply_dns_config() {
    local desc="$1"
    shift
    local servers=("$@")
    local resolv_conf="/etc/resolv.conf"

    backup_file "$resolv_conf" ".bak" "$desc"

    if [[ -L "$resolv_conf" ]]; then
        msg_info "检测到/etc/resolv.conf是软链接,正在转换为普通文件..."
        rm -f "$resolv_conf"
    fi

    {
        echo "# Generated by LinuxEnvConfig"
        echo "# $(date)"
        echo ""
    } > "$resolv_conf"

    for server in "${servers[@]}"; do
        echo "nameserver $server" >> "$resolv_conf"
    done

    msg_success "DNS配置已更新"
    msg_info "当前DNS服务器:"
    for server in "${servers[@]}"; do
        echo "  - $server"
    done

    if check_network_connection; then
        msg_success "DNS测试成功"
    else
        msg_warning "DNS测试失败,请检查配置"
    fi
}

manage_dns_backups() {
    local _DNS_FILE="/etc/resolv.conf"
    while true; do
        show_submenu "DNS备份管理" \
            "恢复历史备份" \
            "删除历史备份" \
            "清空全部备份"
        
        msg_prompt "请选择操作 [0-3, q退出]"
        
        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) restore_selected_dns ;;
            2) delete_selected_dns ;;
            3) backup_clear_all "DNS" "$_DNS_FILE" ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

restore_selected_dns() {
    local _DNS_FILE="/etc/resolv.conf"
    if ! backup_select "恢复DNS历史备份" "$_DNS_FILE" "DNS"; then return; fi

    backup_preview "$_SELECTED_BACKUP" "^nameserver"

    if confirm "确定要将DNS配置恢复到此版本吗?"; then
        cp "$_SELECTED_BACKUP" "$_DNS_FILE"
        msg_success "DNS配置恢复成功"
    fi
}

delete_selected_dns() {
    local _DNS_FILE="/etc/resolv.conf"
    if ! backup_select "删除DNS历史备份" "$_DNS_FILE" "DNS"; then return; fi

    backup_preview "$_SELECTED_BACKUP" "^nameserver"

    if confirm "确定要删除此备份吗?(不可撤销)"; then
        rm -f "$_SELECTED_BACKUP"
        msg_success "备份已删除"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 解除 DNS 53 端口占用问题
# ═══════════════════════════════════════════════════════════════

unlock_dns_port() {
    show_section "解除DNS服务53端口占用"

    if is_service_active systemd-resolved; then
        msg_info "发现systemd-resolved占用53端口"

        if confirm "是否停止systemd-resolved?"; then
            stop_service systemd-resolved
            disable_service systemd-resolved

            local resolved_conf="/etc/systemd/resolved.conf"
            if [[ -f $resolved_conf ]]; then
                if grep -q "^DNSStubListener=yes" "$resolved_conf"; then
                    sed -i 's/^DNSStubListener=yes/DNSStubListener=no/' "$resolved_conf"
                elif ! grep -q "DNSStubListener" "$resolved_conf"; then
                    echo "DNSStubListener=no" >> "$resolved_conf"
                fi

                msg_success "systemd-resolved已配置"
            fi
        fi
    else
        msg_info "未发现systemd-resolved占用53端口"
    fi

    local pids
    pids=$(lsof -i :53 2>/dev/null | grep -v "COMMAND" | awk '{print $2}' | sort -u)

    if [[ -n $pids ]]; then
        msg_warning "发现以下进程占用53端口:"
        lsof -i :53 2>/dev/null | grep -v "COMMAND" | sed 's/^/  /'

        if confirm "是否终止这些进程?"; then
            for pid in $pids; do
                kill -9 "$pid" 2>/dev/null || true
            done
            msg_success "53端口已释放"
        fi
    else
        msg_info "53端口未被占用"
    fi
}

register_main_menu "基础配置" "config_basic"
