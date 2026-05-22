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
#  📝 模块描述 : LinuxEnvConfig 主入口脚本
#  📁 文件路径 : main.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 版本与项目信息
# ═══════════════════════════════════════════════════════════════

readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="LinuxEnvConfig"

# ═══════════════════════════════════════════════════════════════
# 路径初始化
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ═══════════════════════════════════════════════════════════════
# 库文件加载
# ═══════════════════════════════════════════════════════════════

load_lib() {
    local lib="$1"
    local lib_path="$SCRIPT_DIR/lib/${lib}.sh"

    if [[ -f $lib_path ]]; then
        # shellcheck source=/dev/null
        source "$lib_path"
    else
        echo "错误: 无法加载库文件: $lib" >&2
        exit 1
    fi
}

load_module() {
    local module="$1"
    local module_path="$SCRIPT_DIR/modules/${module}.sh"

    if [[ -f $module_path ]]; then
        # shellcheck source=/dev/null
        source "$module_path"
    else
        echo "警告: 模块不存在: $module" >&2
    fi
}

# ═══════════════════════════════════════════════════════════════
# 加载核心库
# ═══════════════════════════════════════════════════════════════

load_lib "common"
load_lib "core"
load_lib "io"
load_lib "utils"
load_lib "network"
load_lib "menu"

# ═══════════════════════════════════════════════════════════════
# 预加载模块（注册主菜单）
# ═══════════════════════════════════════════════════════════════

CORE_MODULES=(
    "basic"
    "apt"
    "jdk"
    "miniconda3"
    "docker"
    "docker-compose"
)

LOADED_MODULES=()

for module_name in "${CORE_MODULES[@]}"; do
    if [[ -f "$SCRIPT_DIR/modules/${module_name}.sh" ]]; then
        # shellcheck source=/dev/null
        source "$SCRIPT_DIR/modules/${module_name}.sh"
        LOADED_MODULES+=("${module_name}.sh")
    fi
done

for module_path in "$SCRIPT_DIR"/modules/*.sh; do
    [[ -f $module_path ]] || continue
    module_file=$(basename "$module_path")
    
    is_loaded=false
    for loaded in "${LOADED_MODULES[@]}"; do
        [[ "$module_file" == "$loaded" ]] && is_loaded=true && break
    done
    
    if [[ "$is_loaded" == false ]]; then
        # shellcheck source=/dev/null
        source "$module_path"
    fi
done

# ═══════════════════════════════════════════════════════════════
# 环境预配置
# ═══════════════════════════════════════════════════════════════

install_project_deps() {
    local required_tools=("curl" "wget" "git" "jq" "unzip")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        return 0
    fi

    msg_info "安装缺失组件: ${missing_tools[*]}"
    install_packages "${missing_tools[@]}"
}

_show_preconf_summary() {
    local apt_status="$1"
    local deps_status="$2"
    local update_status="$3"
    local gpg_status="${4:-}"

    local total_w=60
    local border; border=$(printf '─%.0s' $(seq 1 $((total_w - 2))))

    echo ""
    echo -e "  ${GREEN}╭${border}╮${NC}"
    
    local title="⚙  预配置检查结果"
    local tw; tw=$(str_display_width "$title")
    local lp=$(( (total_w - 2 - tw) / 2 ))
    local rp=$(( total_w - 2 - tw - lp ))
    echo -e "  ${GREEN}│${NC}$(printf '%*s' "$lp" ' ')${BOLD}${BRIGHT_WHITE}${title}${NC}$(printf '%*s' "$rp" ' ')${GREEN}│${NC}"
    echo -e "  ${GREEN}├${border}┤${NC}"

    _summary_row() {
        local icon="$1" label="$2" status="$3" color="${4:-${NC}}"
        local icon_w; icon_w=$(str_display_width "$icon")
        local label_w; label_w=$(str_display_width "$label")
        local status_w; status_w=$(str_display_width "$status")
        
        local left_text="   ${icon} ${WHITE}${label}${NC}"
        local left_w=$((3 + icon_w + 1 + label_w))
        local pad=$((total_w - 2 - left_w - status_w - 3))
        [[ $pad -lt 0 ]] && pad=0
        
        echo -e "  ${GREEN}│${NC}${left_text}$(printf '%*s' "$pad" ' ')${color}${status}${NC}   ${GREEN}│${NC}"
    }

    case "$apt_status" in
        ok)      _summary_row "${BRIGHT_GREEN}✔${NC}" "APT镜像源" "已配置" "${BRIGHT_GREEN}" ;;
        skip)    _summary_row "${BRIGHT_YELLOW}⏭${NC}" "APT镜像源" "已跳过" "${BRIGHT_YELLOW}" ;;
        nomod)   _summary_row "${GRAY}─${NC}"          "APT镜像源" "模块未加载" "${GRAY}" ;;
    esac

    case "$deps_status" in
        ok)      _summary_row "${BRIGHT_GREEN}✔${NC}" "基础工具库" "检查通过" "${BRIGHT_GREEN}" ;;
        install) _summary_row "${BRIGHT_GREEN}✔${NC}" "基础工具库" "修复成功" "${BRIGHT_GREEN}" ;;
        fail)    _summary_row "${BRIGHT_RED}✘${NC}"   "基础工具库" "安装失败" "${BRIGHT_RED}" ;;
    esac

    case "$update_status" in
        ok)          _summary_row "${BRIGHT_GREEN}✔${NC}" "项目代码状态" "已是最新" "${BRIGHT_GREEN}" ;;
        updated)     _summary_row "${BRIGHT_GREEN}✔${NC}" "项目代码状态" "更新成功" "${BRIGHT_GREEN}" ;;
        skip)        _summary_row "${BRIGHT_YELLOW}⏭${NC}" "项目代码状态" "检查跳过" "${BRIGHT_YELLOW}" ;;
        skip_update) _summary_row "${BRIGHT_YELLOW}⏭${NC}" "项目代码状态" "跳过更新" "${BRIGHT_YELLOW}" ;;
        fail)        _summary_row "${BRIGHT_YELLOW}⚠${NC}" "项目代码状态" "检查失败" "${BRIGHT_YELLOW}" ;;
    esac

    if [[ -n "$gpg_status" ]]; then
        case "$gpg_status" in
            ok)      _summary_row "${BRIGHT_GREEN}✔${NC}" "Kali GPG" "密钥已更新" "${BRIGHT_GREEN}" ;;
            noop)    _summary_row "${BRIGHT_GREEN}✔${NC}" "Kali GPG" "无需操作" "${BRIGHT_GREEN}" ;;
            fail)    _summary_row "${BRIGHT_YELLOW}⚠${NC}" "Kali GPG" "更新失败" "${BRIGHT_YELLOW}" ;;
        esac
    fi

    echo -e "  ${GREEN}╰${border}╯${NC}"
}

init_config() {
    clear_screen

    check_root
    check_os
    
    local os arch memory disk
    os=$(get_os_name)
    arch=$(get_arch)
    memory=$(get_memory_info)
    disk=$(get_disk_usage)
    
    if ! ensure_network_ready; then
        exit 1
    fi

    show_banner_rich \
        "🐧 $SCRIPT_NAME v$SCRIPT_VERSION" \
        "适用系统: Ubuntu / Kali Linux" \
        "脚本作用: Linux 基础环境配置 " \
        "✨ Developed by mingy@蚁景科技 ✨" \
        60 1
    
    local entries=(
        "操作系统:|$os"             "系统架构:|$arch"
        "系统内存:|$memory"         "磁盘使用:|$disk"
    )

    local col_w=26
    for ((i=0; i<${#entries[@]}; i+=2)); do
        local e1="${entries[i]}"
        local e2="${entries[i+1]:-}"
        
        local line="  ${GREEN}│${NC}  "
        
        if [[ -n $e1 ]]; then
            local n1="${e1%%|*}"
            local v1="${e1#*|}"
            local pure_v1
            pure_v1=$(echo -e "$v1" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
            local w1
            w1=$(str_display_width "${n1}  ${pure_v1}")
            local p1=$((col_w - w1))
            [[ $p1 -lt 0 ]] && p1=0
            line+="${WHITE}${n1}${NC}  ${v1}$(printf '%*s' "$p1" ' ')"
        else
            line+="$(printf '%*s' "$col_w" ' ')"
        fi
        
        line+="  "
        
        if [[ -n $e2 ]]; then
            local n2="${e2%%|*}"
            local v2="${e2#*|}"
            local pure_v2
            pure_v2=$(echo -e "$v2" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
            local w2
            w2=$(str_display_width "${n2}  ${pure_v2}")
            local p2=$((col_w - w2))
            [[ $p2 -lt 0 ]] && p2=0
            line+="${WHITE}${n2}${NC}  ${v2}$(printf '%*s' "$p2" ' ')"
        else
            line+="$(printf '%*s' "$col_w" ' ')"
        fi
        
        line+="  ${GREEN}│${NC}"
        echo -e "$line"
    done
    
    local total_w=60
    local border
    border=$(printf '─%.0s' $(seq 1 $((total_w - 2))))
    echo -e "  ${GREEN}╰${border}╯${NC}"

    local apt_result="skip" deps_result="ok" update_result="skip" gpg_result=""

    show_section "APT源预配置" "1" "3"
    if command -v init_apt_config >/dev/null 2>&1; then
        if init_apt_config; then
            apt_result="ok"
        else
            apt_result="skip"
        fi
    else
        apt_result="nomod"
        msg_info "APT配置模块未加载"
    fi

  show_section "基础工具检查" "2" "3"
  local required_tools=("curl" "wget" "git" "jq" "unzip")
  local missing_tools=()
  for tool in "${required_tools[@]}"; do
     command_exists "$tool" || ((missing_count++))
     if ! command_exists "$tool"; then
         missing_tools+=("$tool")
     fi
  done

  if [[ ${#missing_tools[@]} -eq 0 ]]; then
      msg_success "系统已安装所有必备组件 (${#required_tools[@]}/${#required_tools[@]})"
      deps_result="ok"
  else
     msg_info "共缺失 ${#missing_tools[@]} 个组件: ${missing_tools[*]}"
      if install_project_deps; then
          deps_result="install"
      else
          deps_result="fail"
      fi
  fi

    show_section "项目更新检查" "3" "3"
    if confirm "是否检查项目更新?"; then
        local update_ret=0
        check_project_update || update_ret=$?
        
        if [[ $update_ret -eq 0 ]]; then
            update_result="ok"
        elif [[ $update_ret -eq 2 ]]; then
            update_result="skip_update"
        else
            update_result="fail"
        fi
    else
        msg_info "跳过项目更新检查"
        update_result="skip"
    fi

    local gpg_ret=0
    update_kali_gpg_key || gpg_ret=$?
    case $gpg_ret in
        0) gpg_result="ok" ;;
        1) gpg_result="fail" ;;
        2) gpg_result="noop" ;;
    esac

    _show_preconf_summary "$apt_result" "$deps_result" "$update_result" "$gpg_result"
    
    show_header "✅ 预检查工作全部完成，准备进入主菜单" 60 "$BRIGHT_GREEN"

    pause
}

main() {
    init_config
    
    local choice
    while true; do
        show_main_menu

        msg_prompt "请选择操作 [1-${#MAIN_MENU_ITEMS[@]}, q退出]"

        local ret=0
        handle_main_menu "$choice" || ret=$?
        
        if [[ $ret -eq 255 ]]; then
            break
        fi
    done

    clear_screen
    
    show_banner_rich \
        "👋 感谢使用 $SCRIPT_NAME" \
        "作者: mingy@蚁景科技" \
        "" \
        "https://gitee.com/yijingsec/LinuxEnvConfig"

    echo ""
}

main "$@"
