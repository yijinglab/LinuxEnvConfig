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
#  📝 模块描述 : Metasploit Framework (MSF) 配置模块
#  📁 文件路径 : modules/metasploit.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# Metasploit 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_metasploit() {
    while true; do
        show_submenu "Metasploit框架配置" \
            "一键安装Metasploit" \
            "彻底卸载Metasploit"

        local choice
        msg_prompt "请选择操作 [0-2, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_metasploit ;;
            2) remove_metasploit ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装 Metasploit
# ═══════════════════════════════════════════════════════════════

install_metasploit() {
    show_section "安装Metasploit Framework"

    local os_type
    os_type=$(lsb_release -is)
    msg_info "检测到当前操作系统为: ${os_type}"

    case "${os_type}" in
        "Ubuntu"|"Debian")
            msg_info "正在通过官方安装脚本部署(请稍候)..."
            local tmp_install="/tmp/msfinstall"
            if download_file "https://gitee.com/yijingsec/metasploit-omnibus/raw/master/config/templates/metasploit-framework-wrappers/msfupdate.erb" "${tmp_install}"; then
                chmod +x "${tmp_install}"
                sudo "${tmp_install}" 2>&1 | sed 's/^/  /'
                action "Metasploit安装脚本执行成功" "安装脚本执行失败"
                rm -f "${tmp_install}"
            else
                msg_error "下载官方安装脚本失败, 请检查网络"
            fi
            ;;
        "Kali")
            msg_info "正在通过Kali官方软件源安装..."
            msg_info "正在更新软件包列表..."
            sudo apt-get update 2>&1 | sed 's/^/  /'
            
            msg_info "正在安装metasploit-framework..."
            sudo apt-get install -y metasploit-framework 2>&1 | sed 's/^/  /'
            action "Metasploit安装完成" "APT安装失败"
            ;;
        *)
            msg_error "暂不支持在 ${os_type} 系统上自动安装, 请手动部署"
            return 1
            ;;
    esac

    if command -v msfconsole >/dev/null; then
        msg_info "当前已安装版本信息:"
        msfconsole --version | sed 's/^/  /'
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载 Metasploit
# ═══════════════════════════════════════════════════════════════

remove_metasploit() {
    show_section "卸载Metasploit Framework"

    if ! command -v msfconsole >/dev/null; then
        msg_info "系统中未检测到已安装的Metasploit"
        return 0
    fi

    if confirm "确定要彻底卸载Metasploit Framework吗?"; then
        msg_info "正在清理软件包..."
        if sudo apt-get remove --purge -y metasploit-framework 2>&1 | sed 's/^/  /'; then
            sudo apt-get autoremove -y >/dev/null 2>&1
            msg_info "正在清理残留配置文件..."
            sudo rm -rf /usr/share/keyrings/metasploit-framework.gpg >/dev/null 2>&1
            sudo rm -rf ~/.msf4 >/dev/null 2>&1
            msg_success "Metasploit已成功卸载"
        else
            msg_error "卸载过程中出现错误"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置Metasploit" "config_metasploit"