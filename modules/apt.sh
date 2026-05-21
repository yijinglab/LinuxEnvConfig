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
#  📝 模块描述 : APT 源配置模块
#  📁 文件路径 : modules/apt.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# APT 源配置主菜单
# ═══════════════════════════════════════════════════════════════

config_apt() {
    while true; do
        show_submenu "APT源配置" \
            "自动选择最快镜像" \
            "阿里云镜像" \
            "腾讯云镜像" \
            "华为云镜像" \
            "清华大学镜像" \
            "中科大镜像" \
            "官方APT源" \
            "APT源备份管理"

        local choice
        msg_prompt "请选择操作 [0-8, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) auto_select_mirror ;;
            2) set_apt_mirror "aliyun" ;;
            3) set_apt_mirror "tencent" ;;
            4) set_apt_mirror "huawei" ;;
            5) set_apt_mirror "tsinghua" ;;
            6) set_apt_mirror "ustc" ;;
            7) set_apt_mirror "official" ;;
            8) push_path "备份管理"; manage_apt_backups; pop_path; continue ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# 镜像配置
# ═══════════════════════════════════════════════════════════════

declare -A APT_MIRRORS=(
    [aliyun]="https://mirrors.aliyun.com"
    [tencent]="https://mirrors.cloud.tencent.com"
    [huawei]="https://repo.huaweicloud.com"
    [tsinghua]="https://mirrors.tuna.tsinghua.edu.cn"
    [ustc]="https://mirrors.ustc.edu.cn"
    [official_ubuntu]="http://archive.ubuntu.com"
    [official_debian]="http://deb.debian.org"
    [official_kali]="http://http.kali.org"
)

# ═══════════════════════════════════════════════════════════════
# 设置APT镜像
# ═══════════════════════════════════════════════════════════════

set_apt_mirror() {
    local mirror_name="$1"
    local distro
    distro=$(get_distro_id)

    show_section "配置APT源"

    local mirror_url
    if [[ $mirror_name == "official" ]]; then
        case $distro in
            ubuntu) mirror_url="${APT_MIRRORS[official_ubuntu]}" ;;
            debian) mirror_url="${APT_MIRRORS[official_debian]}" ;;
            kali) mirror_url="${APT_MIRRORS[official_kali]}" ;;
            *) msg_error "未知的发行版:$distro"; return 1 ;;
        esac
    elif [[ -n ${APT_MIRRORS[$mirror_name]+x} ]]; then
        mirror_url="${APT_MIRRORS[$mirror_name]}"
    else
        msg_error "未知的镜像: $mirror_name"
        return 1
    fi

    msg_info "使用镜像:$mirror_name ($mirror_url)"

    local apt_config
    apt_config=$(generate_apt_config "$distro" "$mirror_url")

    if [[ -z $apt_config ]]; then
        msg_error "生成配置失败"
        return 1
    fi

    apply_apt_config "$apt_config" "$mirror_name"
}

# ═══════════════════════════════════════════════════════════════
# 生成 APT 配置
# ═══════════════════════════════════════════════════════════════

generate_apt_config() {
    local distro="$1"
    local mirror_url="$2"
    local codename
    codename=$(get_distro_codename)

    case $distro in
        ubuntu)
            cat << EOF

deb $mirror_url/ubuntu $codename main restricted universe multiverse
deb $mirror_url/ubuntu $codename-updates main restricted universe multiverse
deb $mirror_url/ubuntu $codename-backports main restricted universe multiverse
deb $mirror_url/ubuntu $codename-security main restricted universe multiverse
EOF
            ;;
        debian)
            cat << EOF

deb $mirror_url/debian $codename main contrib non-free non-free-firmware
deb $mirror_url/debian $codename-updates main contrib non-free non-free-firmware
deb $mirror_url/debian $codename-backports main contrib non-free non-free-firmware
deb $mirror_url/debian-security $codename-security main contrib non-free non-free-firmware
EOF
            ;;
        kali)
            cat << EOF

deb $mirror_url/kali kali-rolling main non-free non-free-firmware contrib
EOF
            ;;
        *)
            msg_error "不支持的发行版:$distro"
            return 1
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# 应用 APT 配置
# ═══════════════════════════════════════════════════════════════

apply_apt_config() {
    local config="$1"
    local mirror_tag="${2:-custom}"
    local sources_list="/etc/apt/sources.list"

    if [[ -f $sources_list ]]; then
        backup_file "$sources_list" ".bak" "$mirror_tag"
    fi

    if echo "$config" > "$sources_list"; then
        action "APT源配置已更新" "写入配置文件失败"
    else
        msg_error "权限不足，写入失败"
        return 1
    fi
    
    apt_update_with_progress
    action "软件包索引同步完成" "软件包索引同步失败"
}

# ═══════════════════════════════════════════════════════════════
# 自动选择镜像
# ═══════════════════════════════════════════════════════════════

auto_select_mirror() {
    show_section "自动选择最快镜像"

    if ! check_network_connection; then
        msg_error "网络连接失败，无法进行速度测试"
        return 1
    fi

    local fastest
    fastest=$(recommend_mirror | tail -n 1 | xargs)

    if [[ -n $fastest ]]; then
        msg_info "使用镜像:$fastest"
        set_apt_mirror "$fastest"
    else
        msg_error "无法确定最快的镜像"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# APT 历史备份管理
# ═══════════════════════════════════════════════════════════════

manage_apt_backups() {
    local _APT_FILE="/etc/apt/sources.list"
    while true; do
        show_submenu "APT备份管理" \
            "恢复历史备份" \
            "删除历史备份" \
            "清空全部备份"

        msg_prompt "请选择操作 [0-3, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) restore_selected_apt ;;
            2) delete_selected_apt ;;
            3) backup_clear_all "APT源" "$_APT_FILE" ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

restore_selected_apt() {
    local _APT_FILE="/etc/apt/sources.list"
    if ! backup_select "恢复APT历史备份" "$_APT_FILE" "APT"; then return; fi

    backup_preview "$_SELECTED_BACKUP" "^deb"

    if confirm "确定要恢复到此版本的源配置吗?"; then
        cp "$_SELECTED_BACKUP" "$_APT_FILE"
        msg_success "APT源恢复成功"

        if confirm "是否立即更新包列表?"; then
            apt_update_with_progress
        fi
    fi
}

delete_selected_apt() {
    local _APT_FILE="/etc/apt/sources.list"
    if ! backup_select "删除APT历史备份" "$_APT_FILE" "APT"; then return; fi

    if confirm "确定要彻底删除此备份文件吗?"; then
        rm -f "$_SELECTED_BACKUP"
        msg_success "备份文件已删除"
    fi
}

# ═══════════════════════════════════════════════════════════════
# 预配置（用于主脚本初始化）
# ═══════════════════════════════════════════════════════════════

init_apt_config() {
    msg_info "如果因APT源无法更新导致脚本失败, 可尝试切换镜像源"

    if ! confirm "是否配置APT镜像源?"; then
        msg_info "跳过APT源配置"
        return 1
    fi

    show_submenu "APT初始化方式" \
        "自动选择最快镜像" \
        "手动选择镜像"

    local choice
    msg_prompt "请选择 [1-2, 0返回, q退出]"

    case $choice in
        0) msg_info "跳过配置"; return 1 ;;
        q|Q) exit 0 ;;
        1) auto_select_mirror ;;
        2) config_apt ;;
        *)
            msg_info "跳过配置"
            return 1
            ;;
    esac
}

register_main_menu "配置APT源" "config_apt"
