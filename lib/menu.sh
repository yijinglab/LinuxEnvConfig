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
#  📝 模块描述 : 现代化菜单系统与注册机制
#  📁 文件路径 : lib/menu.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 菜单注册与路径管理
# ═══════════════════════════════════════════════════════════════

MAIN_MENU_ITEMS=()
MAIN_MENU_HANDLERS=()

MENU_PATH=()

push_path() { MENU_PATH+=("$1"); }
pop_path() {
    [[ ${#MENU_PATH[@]} -gt 0 ]] && unset 'MENU_PATH[${#MENU_PATH[@]}-1]'
}

register_main_menu() {
    MAIN_MENU_ITEMS+=("$1")
    MAIN_MENU_HANDLERS+=("$2")
}

# ═══════════════════════════════════════════════════════════════
# 内部辅助函数
# ═══════════════════════════════════════════════════════════════

_get_menu_path_display() {
    local path="${WHITE}主菜单${NC}"
    if [[ ${#MENU_PATH[@]} -gt 0 ]]; then
        local p
        for p in "${MENU_PATH[@]}"; do
            path+=" ${GRAY}>${NC} ${WHITE}${p}${NC}"
        done
    fi
    echo -e "${BRIGHT_YELLOW}↳${NC} ${path}"
}

# ═══════════════════════════════════════════════════════════════
# 主菜单渲染
# ═══════════════════════════════════════════════════════════════

show_main_menu() {
    local items=("${MAIN_MENU_ITEMS[@]}")
    local count=${#items[@]}
    local term_width; term_width=$(get_term_width)
    
    local cols=2 item_width=32 total_width=68
    [[ $term_width -lt 75 ]] && { cols=1; item_width=50; total_width=54; }
    
    local path_display; path_display=$(_get_menu_path_display)
    local path_w; path_w=$(str_display_width "$path_display")
    local exit_text="[q] 退出脚本"
    local exit_w; exit_w=$(str_display_width "$exit_text")
    
    local min_required_width=$((path_w + exit_w + 10))
    [[ $total_width -lt $min_required_width ]] && total_width=$min_required_width

    local top_border mid_border bottom_border
    ui_set_borders "$total_width"

    clear_screen
    echo ""
    
    show_banner_rich \
        "🐧 $SCRIPT_NAME v$SCRIPT_VERSION" \
        "适用系统: Ubuntu / Kali Linux" \
        "脚本作用: Linux 基础环境配置 " \
        "✨ Developed by mingy@蚁景科技 ✨" \
        "$total_width" 1

    ui_render_grid "$cols" "$item_width" "$total_width" "$BRIGHT_GREEN" "${items[@]}"
    
    echo -e "  ${GREEN}${mid_border}${NC}"
    ui_print_footer "$total_width" "$path_display" "$exit_text" "$WHITE" "$BRIGHT_GREEN"
    echo -e "  ${GREEN}${bottom_border}${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 子菜单
# ═══════════════════════════════════════════════════════════════

show_submenu() {
    local title="$1"
    shift
    local items=("$@")
    local count=${#items[@]}
    local term_width; term_width=$(get_term_width)
    
    local cols=1 item_width=40 total_width=50
    if [[ $count -gt 10 && $term_width -ge 75 ]]; then
        cols=2; item_width=32; total_width=68
    else
        local max_len; max_len=$(str_display_width "$title")
        local item
        for item in "${items[@]}"; do
            local w; w=$(str_display_width "  10. $item")
            [[ $w -gt $max_len ]] && max_len=$w
        done
        total_width=$((max_len + 12))
        [[ $total_width -lt 50 ]] && total_width=50
        [[ $total_width -gt 76 ]] && total_width=76
        item_width=$((total_width - 4))
    fi

    local path_display; path_display=$(_get_menu_path_display)
    local path_w; path_w=$(str_display_width "$path_display")
    
    local min_required_width=$((path_w + 8))
    if [[ $total_width -lt $min_required_width ]]; then
        total_width=$min_required_width
        item_width=$((cols == 1 ? total_width - 4 : (total_width - 4) / 2))
    fi

    local top_border mid_border bottom_border
    ui_set_borders "$total_width"

    clear_screen
    echo ""
    echo -e "  ${GREEN}${top_border}${NC}"
    ui_print_centered_row "$total_width" "${BOLD}${BRIGHT_GREEN}" "$title"
    echo -e "  ${GREEN}${mid_border}${NC}"
    
    local padding=$((total_width - 6 - path_w))
    [[ $padding -lt 0 ]] && padding=0
    echo -e "  ${GREEN}│${NC}  ${WHITE}${path_display}${NC}$(printf '%*s' "$padding" ' ')  ${GREEN}│${NC}"
    ui_print_blank_row "$total_width"
    
    ui_render_grid "$cols" "$item_width" "$total_width" "$BRIGHT_CYAN" "${items[@]}"
    
    ui_print_blank_row "$total_width"
    echo -e "  ${GREEN}${mid_border}${NC}"
    
    ui_print_footer "$total_width" "0. 返回上级菜单" "[q] 退出脚本" "$WHITE" "$BRIGHT_GREEN"
    echo -e "  ${GREEN}${bottom_border}${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 菜单调度
# ═══════════════════════════════════════════════════════════════

handle_main_menu() {
    local choice="$1"
    
    [[ $choice == "q" || $choice == "Q" ]] && return 255
    
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        msg_error "请输入有效的数字"
        pause
        return 0
    fi
    
    local idx=$((choice - 1))
    local count=${#MAIN_MENU_ITEMS[@]}
    
    if [[ $idx -lt 0 || $idx -ge $count ]]; then
        msg_error "选项超出范围 (1-$count)"
        pause
        return 0
    fi
    
    local handler="${MAIN_MENU_HANDLERS[$idx]}"
    
    if ! declare -f "$handler" > /dev/null; then
        msg_error "处理函数未找到: $handler"
        pause
        return 0
    fi
    
    push_path "${MAIN_MENU_ITEMS[$idx]}"
    $handler
    local ret=$?
    pop_path
    
    return $ret
}
