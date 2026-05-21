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
#  📝 模块描述 : Oh My Zsh 环境美化与增强配置模块
#  📁 文件路径 : modules/ohmyzsh.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# Oh My Zsh 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_ohmyzsh() {
    while true; do
        show_submenu "Oh My Zsh配置" \
            "安装OhMyZsh" \
            "更新OhMyZsh" \
            "卸载OhMyZsh" \
            "配置OhMyZsh主题(ys)" \
            "配置OhMyZsh常用插件"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_ohmyzsh ;;
            2) update_ohmyzsh ;;
            3) uninstall_ohmyzsh ;;
            4) config_ohmyzsh_theme ;;
            5) config_ohmyzsh_plugin ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装 Oh My Zsh
# ═══════════════════════════════════════════════════════════════

install_ohmyzsh() {
    show_section "安装Oh My Zsh框架"

    msg_info "正在检查基础环境(zsh, git)..."
    install_package "zsh" || return 1

    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        msg_success "检测到系统已安装Oh My Zsh"
        return 0
    fi

    msg_info "正在从Gitee加速源拉取安装脚本..."
    local tmp_script="/tmp/omz_install.sh"
    
    if download_file "https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh" "${tmp_script}"; then
        msg_info "正在执行静默安装(请稍候)..."
        env REPO="mirrors/oh-my-zsh" \
               REMOTE="https://gitee.com/mirrors/oh-my-zsh.git" \
               CHSH=no \
               RUNZSH=no \
               sh "${tmp_script}" 2>&1 | sed 's/^/  /'
        action "Oh My Zsh框架安装成功" "安装脚本执行失败"
        rm -f "${tmp_script}"
    else
        msg_error "下载安装脚本失败, 请检查网络"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 配置 Oh My Zsh 主题
# ═══════════════════════════════════════════════════════════════

config_ohmyzsh_theme() {
    show_section "配置Oh My Zsh主题"
    
    if [[ ! -f "${HOME}/.zshrc" ]]; then
        msg_error "未找到.zshrc文件, 请先安装Oh My Zsh"
        return 1
    fi

    msg_info "正在配置ys主题..."
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ys"/' "${HOME}/.zshrc"

    msg_info "正在微调ys主题提示符样式..."
    local ys_theme_file="${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
    if [[ -f "${ys_theme_file}" ]]; then
        sed -i "s|%(#,%{\\\$bg\[yellow\]%}%{\\\$fg\[black\]%}%n%{\\\$reset_color%},%{\\\$fg\[cyan\]%}%n) \\\\|%(#,%{\\\$fg\[red\]%}%n%{\\\$reset_color%},%{\\\$fg\[cyan\]%}%n) \\\\|g" "${ys_theme_file}"
        sed -i "s|%{\\\$reset_color%}in \\\\|%{\\\$fg\[blue\]%}✅ \\\\|g" "${ys_theme_file}"
        msg_success "主题美化配置完成"
    else
        msg_warning "未找到ys主题文件, 无法进行提示符微调"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 配置 Oh My Zsh 插件
# ═══════════════════════════════════════════════════════════════

config_ohmyzsh_plugin() {
    show_section "配置Oh My Zsh插件"

    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        msg_error "检测到Oh My Zsh尚未安装"
        return 1
    fi

    local custom_plugin_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins"
    
    msg_info "正在安装zsh-syntax-highlighting(加速镜像)..."
    local plugin_dir="${custom_plugin_dir}/zsh-syntax-highlighting"
    if [[ -d "${plugin_dir}" ]]; then
        msg_success "语法高亮插件已存在"
    else
        git clone --depth 1 https://gitee.com/yijingsec/zsh-syntax-highlighting.git "${plugin_dir}" 2>&1 | sed 's/^/  /'
        action "克隆语法高亮插件成功" "克隆语法高亮插件失败"
    fi

    msg_info "正在安装zsh-autosuggestions(加速镜像)..."
    local plugin_dir="${custom_plugin_dir}/zsh-autosuggestions"
    if [[ -d "${plugin_dir}" ]]; then
        msg_success "自动建议插件已存在"
    else
        git clone --depth 1 https://gitee.com/yijingsec/zsh-autosuggestions.git "${plugin_dir}" 2>&1 | sed 's/^/  /'
        action "克隆自动建议插件成功" "克隆自动建议插件失败"
    fi

    msg_info "正在更新.zshrc插件列表..."
    if ! grep -q "zsh-syntax-highlighting" "${HOME}/.zshrc"; then
        sed -i 's/^plugins=(/plugins=(zsh-syntax-highlighting zsh-autosuggestions /' "${HOME}/.zshrc"
        action "插件启用成功" "插件启用配置失败"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 更新 Oh My Zsh
# ═══════════════════════════════════════════════════════════════

update_ohmyzsh() {
    show_section "更新Oh My Zsh"
    
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        msg_info "正在检查更新(请稍候)..."
        zsh -c "source ~/.zshrc; omz update --unattended" 2>&1 | sed 's/^/  /'
        msg_success "更新操作完成"
    else
        msg_error "Oh My Zsh尚未安装"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 卸载 Oh My Zsh
# ═══════════════════════════════════════════════════════════════

uninstall_ohmyzsh() {
    show_section "卸载Oh My Zsh"

    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        msg_info "系统中未检测到Oh My Zsh资源"
        return 0
    fi

    if confirm "确定要彻底卸载Oh My Zsh吗?"; then
        msg_info "正在执行卸载程序..."
        echo "y" | zsh -c "source ~/.zshrc; uninstall_oh_my_zsh" 2>&1 | sed 's/^/  /'
        msg_success "Oh My Zsh已成功移除"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置OhMyZsh" "config_ohmyzsh"