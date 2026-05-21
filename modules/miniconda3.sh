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
#  📝 模块描述 : Miniconda3 Python 环境配置模块
#  📁 文件路径 : modules/miniconda3.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 私有辅助函数
# ═══════════════════════════════════════════════════════════════

_get_conda_arch() {
    local arch
    arch=$(get_arch)
    case "$arch" in
        amd64|x86_64) echo "x86_64" ;;
        arm64|aarch64) echo "aarch64" ;;
        ppc64el|ppc64le) echo "ppc64le" ;;
        s390x) echo "s390x" ;;
        *) echo "$arch" ;;
    esac
}

_select_miniconda_source() {
    local title="${1:-Miniconda3选择源}"
    
    show_submenu "$title" \
        "哈工大miniconda" \
        "北京大学miniconda" \
        "清华大学miniconda" \
        "浙江大学miniconda" \
        "南京大学miniconda" \
        "官方源miniconda"
    
    local choice
    msg_prompt "请选择序号 [1-6, 0返回, q退出]"

    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        exit 0
    fi
    
    if [[ "$choice" == "0" ]]; then
        return 255
    fi

    case "$choice" in
        1) RET_MIRROR_URL="https://mirrors.hit.edu.cn/anaconda"; msg_info "选择使用哈工大miniconda软件源" ;;
        2) RET_MIRROR_URL="https://mirrors.pku.edu.cn/anaconda"; msg_info "选择使用北京大学miniconda软件源" ;;
        3) RET_MIRROR_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda"; msg_info "选择使用清华大学miniconda软件源" ;;
        4) RET_MIRROR_URL="https://mirrors.zju.edu.cn/anaconda"; msg_info "选择使用浙江大学miniconda软件源" ;;
        5) RET_MIRROR_URL="https://mirrors.nju.edu.cn/anaconda"; msg_info "选择使用南京大学miniconda软件源" ;;
        6) RET_MIRROR_URL="https://repo.anaconda.com"; msg_info "选择使用官方源miniconda软件源" ;;
        *) msg_error "无效选择"; return 1 ;;
    esac
    return 0
}

# ═══════════════════════════════════════════════════════════════
# Miniconda3 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_miniconda3() {
    while true; do
        show_submenu "Miniconda3配置" \
            "安装Miniconda3" \
            "卸载Miniconda3" \
            "配置软件源"

        msg_prompt "请选择操作 [0-3, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_miniconda3; [[ $? -eq 255 ]] && continue ;;
            2) remove_miniconda3; [[ $? -eq 255 ]] && continue ;;
            3) push_path "配置软件源"; configure_conda_mirror; pop_path; continue ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 安装Miniconda3
# ═══════════════════════════════════════════════════════════════

install_miniconda3() {
    msg_info "正在准备安装Miniconda3..."

    _select_miniconda_source "安装Miniconda3源选择"
    local ret=$?
    if [[ $ret -eq 255 ]]; then return 255; fi
    if [[ $ret -ne 0 ]]; then return 1; fi
    
    local mirror_url="$RET_MIRROR_URL"
    local arch
    arch=$(_get_conda_arch)
    local installer_name="Miniconda3-latest-Linux-${arch}.sh"
    local download_url="${mirror_url}/miniconda/${installer_name}"
    
    local install_script="/tmp/${installer_name}"
    local install_dir="/opt/miniconda3"
    
    rm -f "$install_script" >/dev/null 2>&1

    local ua="Wget/1.21.1"

    msg_info "正在验证镜像源状态..."
    local http_info
    http_info=$(curl -s -L -m 15 -A "$ua" -I "$download_url" 2>/dev/null)
    
    local status_code
    status_code=$(echo "$http_info" | grep "HTTP/" | awk '{print $2}' | tail -n1)
    
    local content_type
    content_type=$(echo "$http_info" | grep -i "^content-type:" | awk '{print $2}' | tr -d '\r' | tr '[:upper:]' '[:lower:]')

    if [[ "$status_code" != "200" ]]; then
        msg_error "镜像源连接异常 (HTTP $status_code)"
        msg_info "请检查网络或尝试更换其他镜像源。"
        return 1
    fi

    if [[ "$content_type" == *"text/html"* ]]; then
        msg_error "镜像源返回了验证页面而非安装包"
        msg_info "当前镜像可能存在反爬虫限制，建议更换为 清华大学 或 北京大学 镜像。"
        return 1
    fi

    msg_info "正在下载安装脚本..."
    if ! download_file "$download_url" "$install_script" "$ua"; then
        msg_error "下载失败"
        return 1
    fi

    if ! head -n 1 "$install_script" | grep -q "#!"; then
        msg_error "下载的文件格式非法 (非脚本文件)"
        msg_info "内容可能为镜像源的验证页面，请尝试更换镜像源。"
        sudo rm -f "$install_script"
        return 1
    fi

    msg_info "执行安装程序 (请稍候)..."
    if [ -d "$install_dir" ]; then
        msg_warning "检测到已存在安装目录: $install_dir"
        read -r -p "  ${BRIGHT_CYAN}是否覆盖安装? [y/N]: ${NC}" confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            msg_info "安装已取消"
            return 255
        fi
        sudo rm -rf "$install_dir"
    fi

    sudo bash "$install_script" -b -p "$install_dir" >/dev/null 2>&1
    if ! action "Miniconda3安装成功" "安装程序执行失败"; then
        return 1
    fi

    if [ -f "$install_dir/bin/activate" ]; then
        # shellcheck disable=SC1091
        source "$install_dir/bin/activate"
    else
        msg_error "环境初始化失败: 未找到activate脚本"
        return 1
    fi
    
    sudo "$install_dir/bin/conda" init bash >/dev/null 2>&1
    sudo "$install_dir/bin/conda" init zsh >/dev/null 2>&1

    configure_condarc "$mirror_url" "$install_dir"

    msg_info "正在更新Conda基础环境..."
    if [ "$mirror_url" = "https://repo.anaconda.com" ]; then
        for channel in "main" "r" "msys2"; do
            sudo "$install_dir/bin/conda" tos accept --override-channels --channel "https://repo.anaconda.com/pkgs/${channel}" >/dev/null 2>&1 || true
        done
    fi
    
    sudo "$install_dir/bin/conda" update -n base -c defaults conda -y >/dev/null 2>&1
    action "Conda基础环境更新成功" "Conda基础环境更新失败"

    msg_info "正在清理临时缓存..."
    sudo "$install_dir/bin/conda" clean -a -y >/dev/null 2>&1
    rm -f "$install_script"

    msg_success "Miniconda3安装与环境配置完成"
}

# ═══════════════════════════════════════════════════════════════
# 配置Conda镜像源
# ═══════════════════════════════════════════════════════════════

configure_condarc() {
    local mirror_url=$1
    local install_dir=$2
    msg_info "配置Conda镜像源"

    local targets=()
    targets+=("/root")
    
    local users
    users=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)
    for u in $users; do
        if [ -d "/home/$u" ]; then
            targets+=("/home/$u")
        fi
    done

    for home_dir in "${targets[@]}"; do
        local user_name
        user_name=$(basename "$home_dir")
        [[ "$home_dir" == "/root" ]] && user_name="root"
        
        msg_info "正在为用户${user_name}配置镜像源..."
        
        if [[ "$mirror_url" == "https://repo.anaconda.com" ]]; then
            cat <<EOF | sudo tee "${home_dir}/.condarc" >/dev/null
channels:
  - defaults
show_channel_urls: true
auto_activate_base: false
EOF
        else
            cat <<EOF | sudo tee "${home_dir}/.condarc" >/dev/null
channels:
  - defaults
show_channel_urls: true
auto_activate_base: false
channel_alias: ${mirror_url}
default_channels:
  - ${mirror_url}/pkgs/main
  - ${mirror_url}/pkgs/r
custom_channels:
  conda-forge: ${mirror_url}/cloud
  bioconda: ${mirror_url}/cloud
  pytorch: ${mirror_url}/cloud
EOF
        fi
        if [[ "$user_name" != "root" ]]; then
            sudo chown "${user_name}:${user_name}" "${home_dir}/.condarc"
            su - "$user_name" -c "$install_dir/bin/conda init bash;$install_dir/bin/conda init zsh" >/dev/null 2>&1 || true
        fi
    done

    msg_success "Conda镜像源配置完成"
}

configure_conda_mirror() {
    local install_dir="/opt/miniconda3"
    if [[ ! -d "$install_dir" ]]; then
        msg_warning "检测到 Miniconda3 尚未安装或不在默认路径 ($install_dir)"
        msg_info "镜像源配置将写入用户配置文件 (.condarc)，但在安装后方可生效。"
        read -r -p "  ${BRIGHT_CYAN}是否继续配置镜像源? [Y/n]: ${NC}" confirm_choice
        if [[ "$confirm_choice" =~ ^[Nn]$ ]]; then
            return 255
        fi
    fi

    _select_miniconda_source "Miniconda3镜像配置"
    local ret=$?
    if [[ $ret -eq 255 ]]; then return 255; fi
    if [[ $ret -ne 0 ]]; then return 1; fi
    
    local mirror_url="$RET_MIRROR_URL"
    local install_dir="/opt/miniconda3"
    configure_condarc "$mirror_url" "$install_dir"
}

# ═══════════════════════════════════════════════════════════════
# 卸载Miniconda3
# ═══════════════════════════════════════════════════════════════

remove_miniconda3() {
    msg_warning "确认要卸载Miniconda3及所有环境吗?"
    read -r -p "  ${BRIGHT_CYAN}请输入 'yes' 确认: ${NC}" confirm
    if [[ "$confirm" != "yes" ]]; then
        msg_info "已取消卸载"
        return 255
    fi

    msg_info "开始卸载Miniconda3"
    local install_dir="/opt/miniconda3"

    if [ -d "$install_dir" ]; then
        sudo rm -rf "$install_dir"
        action "删除安装目录成功" "删除安装目录失败"
    fi

    local targets=("/root")
    local users
    users=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)
    for u in $users; do [[ -d "/home/$u" ]] && targets+=("/home/$u"); done

    local conda_init_start="# >>> conda initialize >>"
    local conda_init_end="# <<< conda initialize <<"

    for home_dir in "${targets[@]}"; do
        msg_info "正在清理环境配置文件: $home_dir"
        sudo rm -f "${home_dir}/.condarc"
        
        for config in ".bashrc" ".zshrc"; do
            if [ -f "${home_dir}/${config}" ]; then
                sudo sed -i "/${conda_init_start}/,/${conda_init_end}/d" "${home_dir}/${config}"
            fi
        done
        
        sudo rm -rf "${home_dir}/.conda"
    done

    msg_success "Miniconda3卸载完成"
    
    hash -r 2>/dev/null || true
    unset CONDA_EXE CONDA_PREFIX CONDA_SHLVL 2>/dev/null || true
    
    msg_info "提示: 建议重启终端或运行 'source ~/.bashrc' (或 .zshrc) 以刷新环境变量。"
}

# ═══════════════════════════════════════════════════════════════
# 注册菜单
# ═══════════════════════════════════════════════════════════════

register_main_menu "配置Miniconda3" "config_miniconda3"