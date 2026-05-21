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
#  📝 模块描述 : Java JDK 环境配置模块
#  📁 文件路径 : modules/jdk.sh
#  👤 作者信息 : mingy
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


# ═══════════════════════════════════════════════════════════════
# JDK 配置主菜单
# ═══════════════════════════════════════════════════════════════

config_jdk() {
    while true; do
        show_submenu "JDK配置" \
            "安装OracleJDK" \
            "安装OpenJDK" \
            "切换JDK版本" \
            "删除JDK环境" \
            "查看已安装JDK"

        local choice
        msg_prompt "请选择操作 [0-5, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) push_path "安装OracleJDK"; config_jdk_oracle; pop_path; continue ;;
            2) push_path "安装OpenJDK"; config_jdk_openjdk; pop_path; continue ;;
            3) switch_jdk ;;
            4) remove_jdk ;;
            5) list_installed_jdk ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

# ═══════════════════════════════════════════════════════════════
# OracleJDK 配置（三级菜单示例）
# ═══════════════════════════════════════════════════════════════

config_jdk_oracle() {
    while true; do
        show_submenu "OracleJDK安装" \
            "从study.yijinglab.com安装" \
            "从www.injdk.cn安装"

        msg_prompt "请选择安装源 [0-2, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_oracle_from_yijinglab || continue ;;
            2) install_oracle_from_injdk || continue ;;
            *) msg_error "无效选择" ;;
        esac

        pause
    done
}

readonly ORACLE_JDK_VERSIONS=("jdk1.8.0_421" "jdk-11.0.24" "jdk-17.0.12" "jdk-21.0.4" "jdk-22.0.2" "jdk-23.0.1")
readonly ORACLE_JDK_NAMES=("jdk-8u421-linux-x64.tar.gz" "jdk-11.0.24_linux-x64_bin.tar.gz" "jdk-17.0.12_linux-x64_bin.tar.gz" "jdk-21.0.4_linux-x64_bin.tar.gz" "jdk-22.0.2_linux-x64_bin.tar.gz" "jdk-23_linux-x64_bin.tar.gz")
readonly ORACLE_JDK_LABELS=("Oracle JDK 8 LTS" "Oracle JDK 11 LTS" "Oracle JDK 17 LTS" "Oracle JDK 21 LTS" "Oracle JDK 22 LTS" "Oracle JDK 23 LTS")

install_oracle_from_yijinglab() {
    push_path "study.yijinglab.com"
    show_section "从yijinglab安装OracleJDK"

    local client_key
    msg_prompt "请输入客户端密钥" "client_key"

    if [[ -z $client_key ]]; then
        msg_error "客户端密钥不能为空"
        pop_path
        return 1
    fi

    echo ""
    show_submenu "OracleJDK版本选择" "${ORACLE_JDK_LABELS[@]}"
    local version
    msg_prompt "请选择版本 [1-6, 0返回, q退出]" "version"

    if [[ $version == "q" || $version == "Q" ]]; then
        exit 0
    fi

    if [[ $version == "0" ]]; then
        pop_path
        return 1
    fi

    if [[ $version =~ ^[0-9]+$ ]] && [[ $version -ge 1 && $version -le 6 ]]; then
        local index=$((version - 1))
        local jdk_ver=${ORACLE_JDK_VERSIONS[$index]}
        local jdk_name=${ORACLE_JDK_NAMES[$index]}

        msg_info "正在获取 $jdk_name 的下载链接..."
        local download_url
        download_url=$(get_yijinglab_download_url "$client_key" "$jdk_name")

        if [[ -n $download_url ]]; then
            install_manual_jdk_package "$download_url" "$jdk_name" "$jdk_ver"
        fi
    else
        msg_error "无效选择"
    fi

    pop_path
}

install_oracle_from_injdk() {
    push_path "www.injdk.cn"
    show_section "从injdk安装OracleJDK"

    local JDK_URLS=("https://d10.injdk.cn/openjdk/oraclejdk/8/jdk-8u421-linux-x64.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/11/jdk-11.0.24_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/17/jdk-17_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/21/jdk-21_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/22/jdk-22_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/23/jdk-23_linux-x64_bin.tar.gz")

    echo ""
    show_submenu "OracleJDK版本选择" "${ORACLE_JDK_LABELS[@]}"
    local version
    msg_prompt "请选择版本 [1-6, 0返回, q退出]" "version"

    if [[ $version == "q" || $version == "Q" ]]; then
        exit 0
    fi

    if [[ $version == "0" ]]; then
        pop_path
        return 1
    fi

    if [[ $version =~ ^[0-9]+$ ]] && [[ $version -ge 1 && $version -le 6 ]]; then
        local index=$((version - 1))
        local jdk_ver=${ORACLE_JDK_VERSIONS[$index]}
        local jdk_name=${ORACLE_JDK_NAMES[$index]}
        local jdk_url=${JDK_URLS[$index]}

        install_manual_jdk_package "$jdk_url" "$jdk_name" "$jdk_ver"
    else
        msg_error "无效选择"
    fi

    pop_path
}

get_yijinglab_download_url() {
    local token="$1"
    local exe_name="$2"
    local api_url='https://study.yijinglab.com/api/tools/oss/tempurl'

    local resp
    resp=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"token\":\"$token\",\"tempUrl\":\"$exe_name\"}" \
        "$api_url" 2>/dev/null)

    if [[ -z $resp ]]; then
        return 1
    fi

    local success temp_url
    success=$(echo "$resp" | jq -r '.success' 2>/dev/null)
    temp_url=$(echo "$resp" | jq -r '.tempUrl' 2>/dev/null)

    if [[ "$success" == "true" ]] && [[ -n $temp_url ]]; then
        echo "$temp_url"
        return 0
    fi

    local code msg
    code=$(echo "$resp" | jq -r '.code' 2>/dev/null)
    msg=$(echo "$resp" | jq -r '.msg' 2>/dev/null)

    case $code in
        15010004) msg_error "未通过验证，请先登录获取客户端密钥" ;;
        15010005) msg_error "请求内容异常" ;;
        15010001) msg_error "参数不正确" ;;
        *) msg_error "获取下载链接失败: ${msg:-未知错误}" ;;
    esac

    return 1
}

install_manual_jdk_package() {
    local url="$1"
    local filename="$2"
    local target_dir_name="$3"
    local install_base="/usr/lib/jvm"

    [[ -f "$filename" ]] && rm -f "$filename"

    msg_info "正在从镜像下载: $filename"
    if ! download_file "$url" "$filename"; then
        msg_error "下载失败"
        rm -f "$filename"
        return 1
    fi

    msg_success "下载完成"

    sudo mkdir -p "$install_base"

    msg_info "正在解压安装到 $install_base/$target_dir_name"
    [[ -d "$install_base/$target_dir_name" ]] && sudo rm -rf "$install_base/$target_dir_name"

    if ! sudo tar -xzf "$filename" -C "$install_base"; then
        msg_error "解压失败"
        rm -f "$filename"
        return 1
    fi

    rm -f "$filename"

    configure_jdk_env "$install_base/$target_dir_name"

    msg_success "JDK $target_dir_name 安装并配置成功"
}

# ═══════════════════════════════════════════════════════════════
# OpenJDK 配置
# ═══════════════════════════════════════════════════════════════

config_jdk_openjdk() {
    while true; do
        show_submenu "OpenJDK安装选择" \
            "通过APT安装OpenJDK (推荐)" \
            "从华为主机镜像安装 (Legacy)"

        local choice
        msg_prompt "请选择安装方式 [0-2, q退出]"

        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) openjdk_apt_menu ;;
            2) openjdk_mirror_menu ;;
            *) msg_error "无效选择" ;;
        esac
        pause
    done
}

openjdk_apt_menu() {
    while true; do
        local available=()
        local display_names=()

        msg_info "正在从APT仓库动态扫描OpenJDK版本..."

        local found_versions=""
        if command -v apt-cache >/dev/null 2>&1; then
            found_versions=$(apt-cache pkgnames openjdk- | grep -E '^openjdk-[0-9]+-jdk$' | grep -oE '[0-9]+' | sort -n | uniq)
        fi

        if [[ -z $found_versions ]]; then
            msg_warning "无法自动获取仓库版本，使用预设列表..."
            local fallback_versions=("8" "11" "17" "21" "22" "23")
            for v in "${fallback_versions[@]}"; do
                if is_package_available "openjdk-$v-jdk"; then
                    found_versions="$found_versions $v"
                fi
            done
        fi

        for v in $found_versions; do
            available+=("$v")
            if [[ $v == "8" || $v == "11" || $v == "17" || $v == "21" || $v == "25" ]]; then
                display_names+=("OpenJDK $v LTS")
            else
                display_names+=("OpenJDK $v")
            fi
        done

        if [[ ${#available[@]} -eq 0 ]]; then
            msg_error "仓库中未找到任何 openjdk-*-jdk 包"
            return
        fi

        show_submenu "OpenJDK (APT)" "${display_names[@]}"

        local choice
        msg_prompt "请选择版本 [0-${#available[@]}, q退出]"
        
        if [[ $choice == "q" || $choice == "Q" ]]; then
            exit 0
        fi
        
        if [[ $choice == "0" ]]; then
            return
        fi

        if [[ $choice =~ ^[0-9]+$ ]] && [[ $choice -ge 1 && $choice -le ${#available[@]} ]]; then
            local idx=$((choice - 1))
            install_openjdk_apt "${available[$idx]}"
            return
        else
            msg_error "无效选择"
        fi
    done
}

openjdk_mirror_menu() {
    while true; do
        show_submenu "OpenJDK (Mirror)" \
            "OpenJDK 11.0.2" \
            "OpenJDK 17.0.2" \
            "OpenJDK 21.0.1" \
            "OpenJDK 22.0.2" \
            "OpenJDK 23"

        local choice
        msg_prompt "请选择版本 [0-5, q退出]"
        case $choice in
            0) return ;;
            q|Q) exit 0 ;;
            1) install_openjdk_mirror "11.0.2"; return ;;
            2) install_openjdk_mirror "17.0.2"; return ;;
            3) install_openjdk_mirror "21.0.1"; return ;;
            4) install_openjdk_mirror "22.0.2"; return ;;
            5) install_openjdk_mirror "23"; return ;;
        esac
    done
}

install_openjdk_apt() {
    local version="$1"
    show_section "通过APT安装OpenJDK $version"

    local pkg_name="openjdk-${version}-jdk"

    if ! is_package_available "$pkg_name"; then
        msg_error "软件包 $pkg_name 在当前系统的 APT 仓库中不可用。"
        msg_info "请尝试执行 'apt update' 更新软件源或检查您的系统版本是否支持该版本。"
        return 1
    fi

    if install_package "$pkg_name"; then
        local jdk_path
        jdk_path=$(find /usr/lib/jvm -name "java-${version}-*" -type d 2>/dev/null | grep -v "common" | head -1)
        [[ -n $jdk_path ]] && configure_jdk_env "$jdk_path"
        msg_success "OpenJDK $version 安装成功"
    else
        msg_error "安装失败"
    fi
}

install_openjdk_mirror() {
    local version="$1"
    show_section "从镜像安装OpenJDK $version"

    local filename="openjdk-${version}_linux-x64_bin.tar.gz"
    local url="https://mirrors.huaweicloud.com/openjdk/${version}/${filename}"
    local jdk_ver="jdk-${version}"

    install_manual_jdk_package "$url" "$filename" "$jdk_ver"
}

# ═══════════════════════════════════════════════════════════════
# JDK 环境配置
# ═══════════════════════════════════════════════════════════════

configure_jdk_env() {
    local jdk_path="$1"
    local env_file="/etc/profile.d/jdk.sh"

    msg_info "正在配置系统 Alternatives..."
    local priority=100
    
    local binaries=("java" "javac" "keytool" "jar" "jarsigner")
    for bin in "${binaries[@]}"; do
        if [[ -x "$jdk_path/bin/$bin" ]]; then
            sudo update-alternatives --install "/usr/bin/$bin" "$bin" "$jdk_path/bin/$bin" "$priority" >/dev/null 2>&1
            sudo update-alternatives --set "$bin" "$jdk_path/bin/$bin" >/dev/null 2>&1
        fi
    done

    cat > "$env_file" << 'EOF'
if [ -x /usr/bin/java ]; then
    export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    export CLASSPATH=.:$JAVA_HOME/lib
fi
EOF

    export JAVA_HOME="$jdk_path"

    msg_info "环境变量文件已更新: $env_file"
}

# ═══════════════════════════════════════════════════════════════
# JDK 信息收集 (内部工具函数)
# ═══════════════════════════════════════════════════════════════

_collect_installed_jdks() {
    _JDK_NAMES=()
    _JDK_VERSIONS=()
    _JDK_PATHS=()
    _JDK_TYPES=()
    _JDK_CURRENT=()

    local current_java_path=""
    if command -v java &>/dev/null; then
        current_java_path=$(readlink -f "$(command -v java)" 2>/dev/null | sed 's:/bin/java::')
    fi

    if [[ -d /usr/lib/jvm ]]; then
        for jdk_dir in /usr/lib/jvm/*; do
            [[ -d $jdk_dir ]] || continue
            [[ -L $jdk_dir ]] && continue

            local name version jdk_type is_current

            name=$(basename "$jdk_dir")

            [[ $name == .* ]] && continue

            if [[ -x "$jdk_dir/bin/java" ]]; then
                local ver_output
                ver_output=$("$jdk_dir/bin/java" -version 2>&1)
                version=$(echo "$ver_output" | head -1 | grep -oP '"[^"]+"' | tr -d '"' || echo "unknown")
                if [[ $ver_output == *openjdk* || $ver_output == *OpenJDK* ]]; then
                    jdk_type="OpenJDK"
                else
                    jdk_type="OracleJDK"
                fi
            else
                version="N/A"
                if [[ $name == *openjdk* ]] || [[ $name == java-* ]]; then
                    jdk_type="OpenJDK"
                elif [[ $name == jdk* ]]; then
                    jdk_type="OracleJDK"
                else
                    jdk_type="其他"
                fi
            fi

            is_current="  "
            if [[ -n $current_java_path && "$jdk_dir" == "$current_java_path" ]]; then
                is_current="✔"
            fi

            _JDK_NAMES+=("$name")
            _JDK_VERSIONS+=("$version")
            _JDK_PATHS+=("$jdk_dir")
            _JDK_TYPES+=("$jdk_type")
            _JDK_CURRENT+=("$is_current")
        done
    fi

    while read -r line; do
        local pkg ver
        pkg=$(echo "$line" | awk '{print $2}')
        ver=$(echo "$line" | awk '{print $3}')

        [[ $pkg == *-jdk ]] && continue
        [[ $pkg != *-jre* ]] && continue

        if [[ $pkg == *-headless* ]]; then
            local main_pkg="${pkg/-headless/}"
            local already_has_main=false
            for existing in "${_JDK_NAMES[@]}"; do
                if [[ "$existing" == "$main_pkg"* ]]; then
                    already_has_main=true
                    break
                fi
            done
            [[ "$already_has_main" == "true" ]] && continue
        fi

        if [[ $pkg == openjdk* ]]; then
            local pkg_major
            pkg_major=$(echo "$pkg" | grep -oP '\-\d+\-' | tr -d '-')
            local is_redundant=false
            for existing in "${_JDK_NAMES[@]}"; do
                if [[ "$existing" == *"openjdk"* && "$existing" == *"$pkg_major"* ]]; then
                    is_redundant=true
                    break
                fi
            done
            [[ "$is_redundant" == "true" ]] && continue
        fi

        if [[ -n $pkg ]]; then
            _JDK_NAMES+=("$pkg")
            _JDK_VERSIONS+=("$ver")
            _JDK_PATHS+=("(apt)")
            _JDK_TYPES+=("APT")
            _JDK_CURRENT+=("  ")
        fi
    done < <(dpkg -l 2>/dev/null | grep -E "^ii.*(openjdk|oracle-java)")
}

# ═══════════════════════════════════════════════════════════════
# JDK 管理 - 查看已安装JDK
# ═══════════════════════════════════════════════════════════════

_print_jdk_table() {
    local count=${#_JDK_NAMES[@]}
    
    local widths="6 10 28 14 30"
    msg_table_row "$widths" "${BOLD}${BRIGHT_CYAN}序号" "类型" "名称" "版本" "安装路径${NC}"
    draw_line "─"

    local i
    for ((i=0; i<count; i++)); do
        local marker=""
        if [[ "${_JDK_CURRENT[$i]}" == "✔" ]]; then
            marker="${BRIGHT_GREEN}★当前${NC}"
        fi

        local type_display
        case "${_JDK_TYPES[$i]}" in
            OracleJDK)  type_display="${BRIGHT_YELLOW}Oracle${NC}" ;;
            OpenJDK)    type_display="${BRIGHT_BLUE}OpenJDK${NC}" ;;
            APT)        type_display="${BRIGHT_MAGENTA}APT${NC}" ;;
            *)          type_display="${WHITE}${_JDK_TYPES[$i]}${NC}" ;;
        esac

        msg_table_row "$widths" "$((i+1))" "$type_display" "${_JDK_NAMES[$i]}" "${_JDK_VERSIONS[$i]}" "${_JDK_PATHS[$i]} $marker"
    done
}

list_installed_jdk() {
    show_section "已安装的JDK"

    _collect_installed_jdks

    local count=${#_JDK_NAMES[@]}

    if [[ $count -eq 0 ]]; then
        echo ""
        msg_warning "未检测到已安装的JDK"
        return
    fi

    echo ""
    _print_jdk_table
    echo ""

    if [[ -n ${JAVA_HOME:-} ]]; then
        msg_info "当前JAVA_HOME: ${BRIGHT_GREEN}${JAVA_HOME}${NC}"
    else
        msg_warning "未设置JAVA_HOME环境变量"
    fi

    if command -v java &>/dev/null; then
        msg_info "当前java:"
        java -version 2>&1 | sed 's/^/  /'
    fi
}

# ═══════════════════════════════════════════════════════════════
# JDK 管理 - 切换JDK版本
# ═══════════════════════════════════════════════════════════════

switch_jdk() {
    show_section "切换JDK版本"

    _collect_installed_jdks

    local switchable_names=()
    local switchable_versions=()
    local switchable_paths=()
    local switchable_types=()
    local switchable_current=()

    local i
    for ((i=0; i<${#_JDK_NAMES[@]}; i++)); do
        if [[ -x "${_JDK_PATHS[$i]}/bin/java" ]]; then
            switchable_names+=("${_JDK_NAMES[$i]}")
            switchable_versions+=("${_JDK_VERSIONS[$i]}")
            switchable_paths+=("${_JDK_PATHS[$i]}")
            switchable_types+=("${_JDK_TYPES[$i]}")
            switchable_current+=("${_JDK_CURRENT[$i]}")
        fi
    done

    local count=${#switchable_names[@]}

    if [[ $count -eq 0 ]]; then
        echo ""
        msg_warning "未检测到可切换的JDK"
        return
    fi

    if [[ $count -eq 1 ]]; then
        echo ""
        msg_warning "仅安装了一个JDK，无需切换"
        msg_info "当前JDK: ${switchable_names[0]} (${switchable_versions[0]})"
        return
    fi

    local total_all=${#_JDK_NAMES[@]}
    local filtered=$((total_all - count))
    if [[ $filtered -gt 0 ]]; then
        echo ""
        msg_info "已过滤${filtered}个不可切换的条目(JRE包、目录不完整等)"
    fi

    echo ""
    local widths="6 10 28 14"
    msg_table_row "$widths" "${BOLD}${BRIGHT_CYAN}序号" "类型" "名称" "版本" "状态${NC}"
    draw_line "─"

    for ((i=0; i<count; i++)); do
        local status_display
        if [[ "${switchable_current[$i]}" == "✔" ]]; then
            status_display="${BRIGHT_GREEN}当前${NC}"
        else
            status_display="${GRAY}--${NC}"
        fi

        local type_display
        case "${switchable_types[$i]}" in
            OracleJDK)  type_display="${BRIGHT_YELLOW}Oracle${NC}" ;;
            OpenJDK)    type_display="${BRIGHT_BLUE}OpenJDK${NC}" ;;
            *)          type_display="${WHITE}${switchable_types[$i]}${NC}" ;;
        esac

        msg_table_row "$widths" "$((i+1))" "$type_display" "${switchable_names[$i]}" "${switchable_versions[$i]}" "$status_display"
    done

    echo ""
    msg_prompt "请选择要切换的JDK [1-${count}, 0取消]"

    if [[ $choice == "0" || -z $choice ]]; then
        msg_info "已取消"
        return
    fi

    if ! [[ $choice =~ ^[0-9]+$ ]] || [[ $choice -lt 1 || $choice -gt $count ]]; then
        msg_error "无效选择"
        return
    fi

    local idx=$((choice - 1))
    local target_path="${switchable_paths[$idx]}"
    local target_name="${switchable_names[$idx]}"

    if [[ "${switchable_current[$idx]}" == "✔" ]]; then
        msg_info "${target_name} 已经是当前活跃版本，无需切换"
        return
    fi

    msg_info "正在切换到: ${BRIGHT_GREEN}${target_name}${NC} (${switchable_versions[$idx]})"

    local binaries=("java" "javac" "keytool" "jar" "jarsigner")
    local switched=0
    for bin in "${binaries[@]}"; do
        if [[ -x "$target_path/bin/$bin" ]]; then
            sudo update-alternatives --install "/usr/bin/$bin" "$bin" "$target_path/bin/$bin" 200 2>/dev/null || true
            if sudo update-alternatives --set "$bin" "$target_path/bin/$bin" 2>/dev/null; then
                ((switched++))
            fi
        fi
    done

    if [[ $switched -eq 0 ]]; then
        msg_error "切换失败: 未能更新任何alternatives"
        return 1
    fi

    local env_file="/etc/profile.d/jdk.sh"
    cat > "$env_file" << 'EOF'
if [ -x /usr/bin/java ]; then
    export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    export CLASSPATH=.:$JAVA_HOME/lib
fi
EOF

    export JAVA_HOME="$target_path"

    # shellcheck source=/dev/null
    [[ -f "$env_file" ]] && source "$env_file"

    echo ""
    msg_success "JDK已切换到: ${target_name}"
    echo ""

    msg_info "验证切换结果:"
    java -version 2>&1 | sed 's/^/  /'
    javac -version 2>&1 | sed 's/^/  /'
    msg_info "JAVA_HOME -> ${JAVA_HOME}"
}

# ═══════════════════════════════════════════════════════════════
# JDK 管理 - 删除JDK环境
# ═══════════════════════════════════════════════════════════════

remove_jdk() {
    show_section "删除JDK环境"

    _collect_installed_jdks

    local count=${#_JDK_NAMES[@]}

    if [[ $count -eq 0 ]]; then
        echo ""
        msg_warning "未检测到已安装的JDK"
        return
    fi

    echo ""
    _print_jdk_table
    echo ""

    if [[ -n ${JAVA_HOME:-} ]]; then
        msg_info "当前JAVA_HOME: ${BRIGHT_GREEN}${JAVA_HOME}${NC}"
    fi

    echo ""
    msg_prompt "请选择要删除的JDK [1-${count}, 0取消]"

    if [[ $choice == "0" || -z $choice ]]; then
        msg_info "已取消"
        return
    fi

    if ! [[ $choice =~ ^[0-9]+$ ]] || [[ $choice -lt 1 || $choice -gt $count ]]; then
        msg_error "无效选择"
        return
    fi

    local idx=$((choice - 1))
    local target_name="${_JDK_NAMES[$idx]}"
    local target_path="${_JDK_PATHS[$idx]}"
    local target_type="${_JDK_TYPES[$idx]}"

    echo ""

    if [[ "${_JDK_CURRENT[$idx]}" == "✔" ]]; then
        msg_warning "你选择的是当前正在使用的JDK!"
    fi

    if [[ "$target_type" == "APT" ]]; then
        if confirm "确定卸载APT包 ${target_name}?"; then
            remove_package "$target_name"
            msg_success "APT包 ${target_name} 卸载完成"
        else
            msg_info "已取消"
        fi
    else
        if [[ -d $target_path ]]; then
            if confirm "确定删除 ${target_name} (${target_path}) 并清理系统链接?"; then
                local binaries=("java" "javac" "keytool" "jar" "jarsigner")
                for bin in "${binaries[@]}"; do
                    sudo update-alternatives --remove "$bin" "$target_path/bin/$bin" 2>/dev/null || true
                done

                sudo rm -rf "$target_path"

                local remaining
                remaining=$(find /usr/lib/jvm -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
                if [[ $remaining -eq 0 ]]; then
                    [[ -f /etc/profile.d/jdk.sh ]] && sudo rm -f /etc/profile.d/jdk.sh
                    msg_info "已清理环境变量文件 (无剩余JDK)"
                fi

                msg_success "JDK ${target_name} 已删除"
            else
                msg_info "已取消"
            fi
        else
            msg_error "路径不存在: $target_path"
        fi
    fi
}

register_main_menu "配置JDK" "config_jdk"
