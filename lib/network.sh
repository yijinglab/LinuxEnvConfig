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
#  📝 模块描述 : 网络连通性检测与镜像源管理
#  📁 文件路径 : lib/network.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# 网络连通性检查
# ═══════════════════════════════════════════════════════════════

check_network_connection() {
    check_ip_connectivity
}

get_local_ip() {
    local interface="${1:-}"
    if [[ -n $interface ]]; then
        ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1
    else
        ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || hostname -I | awk '{print $1}'
    fi
}

get_public_ip() {
    local apis=(
        "https://ifconfig.me/ip"
        "https://api64.ipify.org"
        "https://ipinfo.io/ip"
    )
    for api in "${apis[@]}"; do
        local ip
        ip=$(curl -fsSL --max-time 3 "$api" 2>/dev/null | grep -oP '\d+(\.\d+){3}')
        if [[ -n $ip ]]; then
            echo "$ip"
            return 0
        fi
    done
    return 1
}

is_private_ip() {
    local ip=$1
    [[ $ip =~ ^10\. ]] && return 0
    [[ $ip =~ ^192\.168\. ]] && return 0
    [[ $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
    [[ $ip =~ ^100\.(6[4-9]|[7-9][0-9]|1[0-1][0-9]|12[0-7])\. ]] && return 0
    [[ $ip =~ ^169\.254\. ]] && return 0
    return 1
}

is_cloud_vps() {
    if timeout 1 bash -c 'cat < /dev/null > /dev/tcp/169.254.169.254/80' 2>/dev/null; then
        return 0
    fi
    local local_ip
    local_ip=$(get_local_ip)
    if [[ ! $local_ip =~ ^192\.168\. ]]; then
        if command -v systemd-detect-virt >/dev/null && systemd-detect-virt -q; then
            return 0
        fi
    fi
    return 1
}

get_best_ip() {
    local local_ip pub_ip
    local_ip=$(get_local_ip)

    if ! is_private_ip "$local_ip"; then
        echo "$local_ip"
        return 0
    fi

    pub_ip=$(get_public_ip)
    
    if [[ -n $pub_ip ]] && is_cloud_vps; then
        echo "$pub_ip"
    else
        echo "$local_ip"
    fi
}

get_network_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"
}

show_network_info() {
    show_section "网络接口信息"
    local interfaces
    interfaces=$(get_network_interfaces)
    if [[ -z $interfaces ]]; then msg_warning "未找到接口"; return 1; fi
    
    echo ""
    local widths="14 20 20"
    msg_table_row "$widths" "${BOLD}接口" "IP地址" "MAC地址${NC}"
    draw_line "-"

    for iface in $interfaces; do
        local ip mac
        ip=$(get_local_ip "$iface")
        mac=$(cat "/sys/class/net/$iface/address" 2>/dev/null || echo "N/A")
        [[ -z $ip ]] && ip="未配置"
        
        msg_table_row "$widths" "$iface" "${CYAN}$ip${NC}" "$mac"
    done
    echo ""
}

check_ip_connectivity() {
    local targets=("223.5.5.5" "119.29.29.29" "8.8.8.8")
    for target in "${targets[@]}"; do
        if ping -c 1 -W 2 "$target" >/dev/null 2>&1; then return 0; fi
    done
    return 1
}

check_dns_resolution() {
    local domains=("www.baidu.com" "www.aliyun.com" "google.com")
    for domain in "${domains[@]}"; do
        if getent hosts "$domain" >/dev/null 2>&1 || nslookup "$domain" >/dev/null 2>&1; then return 0; fi
    done
    return 1
}

check_http_access() {
    local urls=("https://www.baidu.com" "https://www.aliyun.com")
    for url in "${urls[@]}"; do
        if curl -fsSL -I --max-time 5 "$url" >/dev/null 2>&1; then return 0; fi
    done
    return 1
}

ensure_network_ready() {
    if ! check_ip_connectivity; then
        show_network_troubleshooting "IP_FAIL"
        return 1
    fi

    if ! check_dns_resolution; then
        msg_warning "网络已连接，但域名解析(DNS)失败"
        if confirm "是否立即尝试配置DNS以修复此问题?"; then
            if declare -f config_dns >/dev/null; then
                config_dns
                if check_dns_resolution; then
                    msg_success "DNS修复成功"
                else
                    show_network_troubleshooting "DNS_FAIL"
                    return 1
                fi
            else
                msg_error "未加载DNS配置模块，无法自动修复"
                show_network_troubleshooting "DNS_FAIL"
                return 1
            fi
        else
            show_network_troubleshooting "DNS_FAIL"
            return 1
        fi
    fi

    if ! check_http_access; then
        msg_warning "DNS正常，但HTTP请求失败(可能存在代理阻断或防火墙限制)"
    fi

    return 0
}

show_network_troubleshooting() {
    local reason="$1"
    
    echo ""
    show_section "🚩 网络连接故障排查"
    case "$reason" in
        "IP_FAIL")
            msg_error "无法访问公网IP，处于断网状态"
            echo "  可能的排查思路:"
            echo "  1. 检查物理网线是否插好或网卡是否启用"
            echo "  2. 检查网关(Gateway)配置是否正确"
            echo "  3. 检查路由器是否可以访问外网"
            echo "  4. 检查是否需要静态IP配置"
            ;;
        "DNS_FAIL")
            msg_error "无法解析域名，DNS服务不可用"
            echo "  可能的排查思路:"
            echo "  1. 检查/etc/resolv.conf中的nameserver配置"
            echo "  2. 检查防火墙是否拦截了UDP 53端口"
            echo "  3. 尝试更换其他的公共DNS服务器"
            ;;
    esac
    
    echo ""
    msg_info "脚本将安全退出，请解决网络问题后重试。"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# 项目在线更新
# ═══════════════════════════════════════════════════════════════

get_remote_version() {
    local api_url="https://gitee.com/api/v5/repos/yijingsec/LinuxEnvConfig/tags"
    local response
    response=$(curl -fsSL --max-time 10 "$api_url" 2>/dev/null || echo "")
    if [[ -z "$response" ]]; then
        echo ""
        return
    fi
    if command_exists jq; then
        echo "$response" | jq -r ".[0].name" 2>/dev/null
    else
        echo "$response" | grep -oP '"name":"\K[^"]+' | head -n 1
    fi
}

check_project_update() {
    show_section "项目更新检查"
    if ! check_network_connection; then
        msg_warning "网络不可用，跳过更新检查"
        return 1
    fi

    if [[ -d "$SCRIPT_DIR/.git" ]] && command_exists git; then
        local current_branch
        current_branch=$(git -c safe.directory="*" -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
        if [[ "$current_branch" != "master" && -n "$current_branch" ]]; then
            msg_info "当前处于开发分支[${current_branch}]，已跳过版本更新检测"
            return 0
        fi

        msg_info "通过Git检查项目更新..."
        local repo_url="https://gitee.com/yijingsec/LinuxEnvConfig.git"
        local remote_latest
        remote_latest=$(git -c safe.directory="*" ls-remote "$repo_url" HEAD 2>/dev/null | cut -f1 || true)
        local local_current
        local_current=$(git -c safe.directory="*" -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null || true)

        if [[ -n "$remote_latest" && -n "$local_current" ]]; then
            if [[ "$remote_latest" != "$local_current" ]]; then
                msg_info "发现新版本(本地:${local_current:0:7}，远程:${remote_latest:0:7})"
                if confirm "是否更新到最新项目?"; then
                    msg_info "正在更新项目..."
                    git -c safe.directory="*" -C "$SCRIPT_DIR" restore . >/dev/null 2>&1 || true
                    git -c safe.directory="*" -C "$SCRIPT_DIR" pull --quiet
                    if action "更新项目成功!请重新运行脚本" "更新项目失败，请稍后重试或检查网络"; then
                        exit 0
                    else
                        return 1
                    fi
                else
                    msg_info "已跳过更新"
                    return 2
                fi
            else
                msg_success "项目代码已是最新"
                return 0
            fi
        fi
        msg_warning "无法获取Git提交记录，回退到版本号模式..."
    fi

    msg_info "正在通过API检查版本..."
    local remote_version
    remote_version=$(get_remote_version)
    if [[ -z $remote_version ]]; then
        msg_warning "无法获取远程版本信息"
        return 1
    fi

    if [[ "$remote_version" != "$SCRIPT_VERSION" ]]; then
        msg_info "发现新版本:$remote_version(当前:$SCRIPT_VERSION)"
        if confirm "是否更新到最新项目?"; then
            update_project_tarball "$remote_version"
        else
            msg_info "已跳过更新"
            return 2
        fi
    else
        msg_success "已是最新版本($SCRIPT_VERSION)"
    fi
}
update_project_tarball() {
    local version="${1:-}"

    msg_info "正在更新项目..."

    local backup_dir
    backup_dir="$SCRIPT_DIR/.backup.$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp -r "$SCRIPT_DIR"/*.sh "$backup_dir/" 2>/dev/null || true

    local temp_dir
    temp_dir=$(mktemp -d)

    if curl -fsSL -o "$temp_dir/update.tar.gz" \
        "https://gitee.com/yijingsec/LinuxEnvConfig/repository/archive/${version}.tar.gz" 2>/dev/null; then

        tar -xzf "$temp_dir/update.tar.gz" -C "$temp_dir"

        cp -r "$temp_dir"/LinuxEnvConfig-*/* "$SCRIPT_DIR/"

        msg_success "更新完成! 请重新运行脚本"
        rm -rf "$temp_dir"

        exit 0
    else
        msg_error "更新失败"
        rm -rf "$temp_dir"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# APT镜像源检测
# ═══════════════════════════════════════════════════════════════

test_mirror_speed() {
    local mirror_url="$1"
    local timeout=3

    local start_time end_time elapsed
    start_time=$(date +%s%N)

    if curl -fsSL -I --max-time "$timeout" -o /dev/null "$mirror_url" 2>/dev/null; then
        end_time=$(date +%s%N)
        elapsed=$(( (end_time - start_time) / 1000000 ))
        echo "$elapsed"
        return 0
    fi

    echo "999999"
    return 1
}

recommend_mirror() {
    show_section "APT镜像速度测试"
    msg_info "正在探测各镜像源延迟 (请稍候)..."
    echo "" >&2

    local widths="20 20 10"
    msg_table_row "$widths" "${BOLD}${BRIGHT_CYAN}镜像源" "响应延迟" "状态${NC}" >&2
    draw_line "─" >&2

    declare -A mirrors
    mirrors[aliyun]="https://mirrors.aliyun.com"
    mirrors[tencent]="https://mirrors.cloud.tencent.com"
    mirrors[huawei]="https://repo.huaweicloud.com"
    mirrors[tsinghua]="https://mirrors.tuna.tsinghua.edu.cn"
    mirrors[ustc]="https://mirrors.ustc.edu.cn"

    local fastest=""
    local fastest_time=999999

    for name in aliyun tencent huawei tsinghua ustc; do
        local url="${mirrors[$name]}"
        local time
        time=$(test_mirror_speed "$url")

        local status_color="${NC}"
        local status_text=""
        
        if [[ $time -lt 999999 ]]; then
            if [[ $time -lt 200 ]]; then
                status_color="${BRIGHT_GREEN}"
                status_text="极快"
            elif [[ $time -lt 500 ]]; then
                status_color="${BRIGHT_YELLOW}"
                status_text="良好"
            else
                status_color="${YELLOW}"
                status_text="一般"
            fi
            
            if [[ $time -lt $fastest_time ]]; then
                fastest_time=$time
                fastest=$name
            fi
            
            msg_table_row "$widths" "$name" "${status_color}${time}ms" "${status_text}${NC}" >&2
        else
            msg_table_row "$widths" "$name" "${RED}超时" "不可用${NC}" >&2
        fi
    done



    echo "" >&2
    if [[ -n $fastest ]]; then
        msg_success "推荐镜像:${BRIGHT_GREEN}${fastest}${NC}(${fastest_time}ms)"
        echo "$fastest"
        return 0
    else
        msg_error "所有镜像测试失败"
        return 1
    fi
}

# ═══════════════════════════════════════════════════════════════
# Kali GPG密钥管理
# ═══════════════════════════════════════════════════════════════

update_kali_gpg_key() {
    if [[ "$OS_ID" != "kali" ]]; then
        return 2
    fi

    local kali_ver="$OS_VER"
    local threshold="2025.1"
    [[ "$kali_ver" =~ ^25\. ]] && threshold="25.01"

    if [[ "$(printf "%s\n%s\n" "$threshold" "$kali_ver" | sort -V | head -n1)" != "$kali_ver" ]]; then
        return 2
    fi

    show_section "Kali GPG密钥更新"
    msg_info "检测到旧版Kali($kali_ver)，正在更新GPG密钥..."

    if wget -q -O - https://archive.kali.org/archive-key.asc 2>/dev/null | \
        apt-key add - >/dev/null 2>&1; then
        msg_success "GPG密钥更新成功"
        return 0
    fi

    if gpg --fetch-keys https://archive.kali.org/archive-key.asc 2>/dev/null; then
        msg_success "GPG密钥更新成功"
        return 0
    fi

    msg_warning "GPG密钥更新失败, 可能不影响正常使用"
    return 1
}

