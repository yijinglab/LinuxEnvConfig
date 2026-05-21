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
#  📝 模块描述 : 一键安装与全局命令注册工具
#  📁 文件路径 : install.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# 终端颜色与状态消息定义
# ═══════════════════════════════════════════════════════════════
readonly RED=$'\033[31m'
readonly GREEN=$'\033[32m'
readonly YELLOW=$'\033[33m'
readonly BLUE=$'\033[34m'
readonly CYAN=$'\033[36m'
readonly WHITE=$'\033[37m'
readonly GRAY=$'\033[90m'
readonly BRIGHT_RED=$'\033[91m'
readonly BRIGHT_GREEN=$'\033[92m'
readonly BRIGHT_YELLOW=$'\033[93m'
readonly BRIGHT_WHITE=$'\033[97m'
readonly NC=$'\033[0m'
readonly BOLD=$'\033[1m'

msg_info()    { echo -e "  ${BLUE}[INFO]${NC} $1"; }
msg_error()   { echo -e "  ${RED}[FAIL]${NC} $1" >&2; }
msg_success() { echo -e "  ${GREEN}[ OK ]${NC} $1"; }
msg_warning() { echo -e "  ${YELLOW}[WARN]${NC} $1"; }

draw_line() {
    local char="${1:-━}"
    local color="${2:-$GRAY}"
    local width=50
    printf "  %b" "$color"
    printf "${char}%.0s" $(seq 1 "$width")
    printf "%b\n" "$NC"
}

show_install_success() {
    echo ""
    draw_line "━" "$GREEN"
    echo -e "  ${BRIGHT_GREEN}🎉 安装注册成功！${NC}"
    echo -e "  ${WHITE}使用命令:${NC} ${BRIGHT_GREEN}lec${NC}"
    echo -e "  ${WHITE}安装路径:${NC} ${GRAY}${INSTALL_DIR}${NC}"
    echo -e "  ${WHITE}使用说明:${NC} 任意路径输入${BRIGHT_GREEN}lec${NC}即可启动"
    draw_line "━" "$GREEN"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 权限与依赖检查
# ═══════════════════════════════════════════════════════════════

if [[ $EUID -ne 0 ]]; then
   msg_error "必须使用 sudo 权限运行此安装脚本"
   exit 1
fi

SCRIPT_PATH=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
fi

CURRENT_DIR=$(dirname "$SCRIPT_PATH")
INSTALL_DIR="/opt/LinuxEnvConfig"
BIN_PATH="/usr/local/bin/lec"

IS_LOCAL=false
if [[ -n "$SCRIPT_PATH" && -f "${CURRENT_DIR}/main.sh" && -d "${CURRENT_DIR}/.git" ]]; then
    IS_LOCAL=true
fi

if [[ "$IS_LOCAL" == "true" ]]; then
    INSTALL_DIR="$CURRENT_DIR"
    msg_info "本地安装路径: ${BRIGHT_WHITE}${INSTALL_DIR}${NC}"
else
    msg_info "远程安装路径: ${BRIGHT_WHITE}${INSTALL_DIR}${NC}"
    
    if ! command -v git &>/dev/null; then
        msg_warning "系统未检测到 git，正在自动安装必备组件..."
        if command -v apt-get &>/dev/null; then
            apt-get update -y 2>&1 | sed 's/^/  /'
            apt-get install -y git 2>&1 | sed 's/^/  /'
        else
            msg_error "未检测到 git 且当前系统不支持 apt-get，请手动安装 git 后重试"
            exit 1
        fi
    fi

    if [[ -d "$INSTALL_DIR" ]]; then
        msg_warning "检测到已存在旧版本目录，正在执行覆盖更新..."
        rm -rf "$INSTALL_DIR"
    fi
    msg_info "正在从远程仓库克隆项目代码..."
    git clone https://gitee.com/yijingsec/LinuxEnvConfig.git "$INSTALL_DIR" 2>&1 | sed 's/^/  /'
fi

msg_info "正在创建全局命令: ${BRIGHT_WHITE}${BIN_PATH}${NC} ..."
cat << EOF > "$BIN_PATH"
#!/usr/bin/env bash
cd "$INSTALL_DIR" && exec sudo bash main.sh "\$@"
EOF

chmod +x "$BIN_PATH"

show_install_success
