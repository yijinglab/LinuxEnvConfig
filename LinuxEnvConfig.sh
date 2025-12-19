#!/usr/bin/env bash

# Copyright 2024 Hunan Yijing Technologies Co., Ltd
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

# 脚本名称: LinuxEnvConfig.sh
# 功能描述: Linux 基础‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭环境配置脚本
# 适用系统: Ubuntu/Debian/Kali Linux
# 作者: mingy


set -e

# COLORS
readonly COLOUR_RESET='\e[0m'
readonly aCOLOUR=(
    '\e[38;5;154m' # 0绿色 - 用于行、项目符号和分隔符
    '\e[1m'        # 1粗体白色 - 用于主要描述
    '\e[90m'       # 2灰色 - 用于版权信息
    '\e[91m'       # 3红色 - 用于更新通知警告
    '\e[33m'       # 4黄色 - 用于强调
    '\e[34m'       # 5蓝色
    '\e[35m'       # 6品红
    '\e[36m'       # 7青色
    '\e[37m'       # 8浅灰色
    '\e[92m'       # 9浅绿色
    '\e[93m'       # 10浅黄色
    '\e[94m'       # 11浅蓝色
    '\e[95m'       # 12浅品红
    '\e[96m'       # 13浅青色
    '\e[97m'       # 14白色
    '\e[40m'       # 15背景黑色
    '\e[41m'       # 16背景红色
    '\e[42m'       # 17背景绿色
    '\e[43m'       # 18背景黄色
    '\e[44m'       # 19背景蓝色
    '\e[45m'       # 20背景品红
    '\e[46m'       # 21背景青色
    '\e[47m'       # 22背景浅灰色
)

readonly GREEN_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
# readonly GREEN_BULLET=" ${aCOLOUR[0]}-$COLOUR_RESET"
# readonly GREEN_SEPARATOR="${aCOLOUR[0]}:$COLOUR_RESET"

Show() {
    local level=$1
    local message=$2
    
    case $level in
        # OK
        0)  echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]}  OK  $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $message" ;;
        # FAILED
        1)  echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $message"
            exit 1 ;;
        # INFO
        2)  echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]} INFO $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $message" ;;
        # NOTICE
        3)  echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[4]}NOTICE$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $message" ;;
    esac
}

action() {
    local exit_status=$?
    local success_msg=$1
    local error_msg=$2

    if [ $exit_status -eq 0 ]; then
		Show 0 "$success_msg"
	else
		Show 1 "$error_msg"
	fi
}

# 检查输入是否是有效的IPv4地址
validate_ip() {
    local ip=$1
    local regex='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

    if [[ $ip =~ $regex ]]; then
        return 0
    else
        Show 2 "错误: 请输入正确的IP地址格式。"
        return 1
    fi
}

Warn() {
    echo -e "${aCOLOUR[3]}$1$COLOUR_RESET"
}

GreyStart() {
    echo -e "${aCOLOUR[2]}\c"
}

ColorReset() {
    echo -e "$COLOUR_RESET\c"
}

# 定义红色文本
RED='\033[0;31m'
# 定义绿色文本
GREEN='\033[0;32m'
# 定义黄色文本
YELLOW="\e[33m"
# 无颜色
NC='\033[0m'

declare -a menu_options
declare -A commands

menu_options=(
    "基础配置"
    "配置 APT"
    "配置 JDK"
    "配置 Miniconda3"
    "配置 Docker"
    "配置 Docker-compose"
    "配置 Vulfocus"
    "配置 ARL"
    "配置 Metasploit-framework"
    "配置 Viper"
    "配置 Empire"
    "配置 Starkiller"
    "配置 Dnscat2"
    "配置 Beef"
    "配置 Bluelotus"
    "配置 HFish"
    "配置 CTFd"
    "配置 AWVS"
    "配置 ocr_api_server"
    "配置 oh-my-zsh"
    "配置 crAPI"
)

commands=(
    ["基础配置"]="basic_config"
    ["配置 APT"]="config_apt_source"
    ["配置 JDK"]="config_jdk"
    ["配置 Miniconda3"]="config_miniconda3"
    ["配置 Docker"]="config_docker"
    ["配置 Docker-compose"]="config_docker_compose"
    ["配置 Vulfocus"]="config_vulfocus"
    ["配置 ARL"]="config_arl"
    ["配置 Metasploit-framework"]="config_metasploit"
    ["配置 Viper"]="config_viper"
    ["配置 Empire"]="config_empire"
    ["配置 Starkiller"]="config_starkiller"
    ["配置 Dnscat2"]="config_dnscat2"
    ["配置 Beef"]="config_beef"
    ["配置 Bluelotus"]="config_bluelotus"
    ["配置 HFish"]="config_hfish"
    ["配置 CTFd"]="config_ctfd"
    ["配置 AWVS"]="config_awvs"
    ["配置 ocr_api_server"]="config_ocr_api_server"
    ["配置 oh-my-zsh"]="config_ohmyzsh"
    ["配置 crAPI"]="config_crAPI"
)

# 基础配置
basic_config() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 启用ROOT用户"
    echo "2. 启用SSH服务"
    echo "3. 允许ROOT用户SSH登录"
    echo "4. 设置DNS名称服务器"
    echo "5. 获取当前主机网卡及IP地址信息"
    echo "6. 解除DNS协议53端口占用"
    echo "7. 返回主菜单"
    read -r -p "$(echo -e "${RED}(基础配置)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" choice
    case $choice in
        1)  enable_root_user ;;
        2)  enable_ssh ;;
        3)  root_ssh_login ;;
        4)  config_nameserver ;;
        5)  get_ip_addr ;;
        6)  unlock_dns_port ;;
        7)  Show 2 "返回主菜单" ;;
        *)  Show 2 "无效的选择" ;;
    esac
}

# 启用root用户
enable_root_user() {
    # 读取用户输入的新密码
    read -r -sp "$(echo -e "${GREEN}请输入新的root密码: ${NC}")" new_password
    echo

    # 使用chpasswd命令设置root用户的新密码
    echo "root:${new_password}" | sudo chpasswd

    # 检查命令是否成功执行
    action "root密码设置成功" "root密码设置失败"
}

# 启用 SSH 服务
enable_ssh() {
    Show 2 "启用SSH服务开始"
    Show 2 "检查openssh-server是否安装..."
    if dpkg -l | grep -q openssh-server; then
        Show 0 "已安装openssh-server"
    else
        Show 2 "openssh-server 未安装，正在安装..."
        sudo apt-get update
        sudo apt-get install openssh-server -y >& /dev/null
        action "安装openssh-server成功" "安装openssh-server失败"
    fi

    Show 2 "开始启动 SSH 服务..."
    sudo systemctl start ssh >&/dev/null
    action "启动SSH服务成功" "启动SSH服务失败"

    Show 2 "设置 SSH 服务开机自启..."
    sudo systemctl enable ssh >&/dev/null
    action "设置SSH服务开机自启成功" "设置SSH服务开机自启失败"

    # 显示 SSH 服务状态
    Show 2 "检查SSH服务状态..."
    sudo systemctl --no-pager status ssh
    Show 0 "启用SSH服务成功"
}

# 设置nameserver
config_nameserver() {
    Show 2 "配置名称服务器开始"
    # 定义新的名称服务器地址
    nameservers=("114.114.114.114" "223.5.5.5" "1.1.1.1")

    # 获取当前的名称服务器配置
    current_nameservers=$(cat /etc/resolv.conf)

    # 检查是否需要更改名称服务器
    if [[ $current_nameservers == *"${nameservers[0]}"* && $current_nameservers == *"${nameservers[1]}"* ]]; then
        Show 0 "名称服务器已设置为 (${nameservers[*]})。"
    else
        # 备份当前的resolv.conf文件
        Show 2 "备份当前的resolv.conf文件..."
        if [ -f /etc/resolv.conf.backup ]; then
            Show 2 "备份文件已存在，跳过备份步骤"
        else
            Show 2 "备份文件不存在，正在备份..."
            sudo cp /etc/resolv.conf /etc/resolv.conf.backup
        fi

        Show 2 "清空当前的resolv.conf文件"
        true > /etc/resolv.conf

        # 添加新的名称服务器
        Show 2 "添加新的名称服务器..."
        for ns in "${nameservers[@]}"; do
            echo "nameserver $ns" >> /etc/resolv.conf
        done

        # 输出结果
        Show 0 "名称服务器已设置为 (${nameservers[*]})。"
    fi

    # 显示当前的 resolv.conf 配置
    cat /etc/resolv.conf
    Show 0 "配置名称服务器成功"
}

# 允许ROOT‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭用户SSH登录
root_ssh_login() {
    Show 2 "修改SSH服务配置文件允许root用户登录"
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    action "SSH服务配置已更改为允许root用户登录" "SSH服务配置更改失败"

    Show 2 "重启SSH服务"
    
    if sudo systemctl restart ssh >& /dev/null; then
        Show 0 "SSH服务重启成功"
        Show 2 "尝试以root用户登录SSH服务"
        Show 2 "示例: ssh root@ip"
    else
        Show 1 "SSH服务重启失败"
    fi
}

# 获取当前主机网卡及IP地址信息
get_ip_addr() {
    Show 2 "获取当前主机网卡及IP地址信息"
    ip -4 addr show | awk '/:/ {print $0}' | awk '{print $2}' | grep -v lo | while read -r ifname; do
        ip -4 addr show "${ifname}" | awk '/inet/ {print $2}' | while read -r ipaddr; do
            Show 0 "- ${ifname} ${ipaddr}"
        done
    done
}

# 解除DNS协议53端口占用
unlock_dns_port() {
    Show 2 "解除DNS协议53端口占用"

    Show 2 "停止systemd-resolved"
    sudo systemctl stop systemd-resolved

    Show 2 "修改systemd-resolved配置"
    sudo sed -i 's/#DNS=.*/DNS=114.114.114.114/' /etc/systemd/resolved.conf
    sudo sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf

    Show 2 "创建软链接"
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

    Show 2 "启动systemd-resolved"
    sudo systemctl start systemd-resolved

    Show 0 "DNS协议53端口占用解除成功"
}

# 配置JDK
config_jdk() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 OracleJDK"
    echo "2. 安装 OpenJDK"
    echo "3. 删除当前JDK环境"
    echo "4. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置JDK)${NC} : ${GREEN}请输入序号(1-4) >> ${NC}")" choice
    case $choice in
        1)
            echo -e "${YELLOW}[+] 选择OracleJDK安装源: ${NC}"
            echo "1. study.yijinglab.com"
            echo "2. www.injdk.cn"
            echo "3. 返回主菜单"
            read -r -p "$(echo -e "${RED}(配置JDK/安装OracleJDK)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" version
            case $version in
                1)  
                    Show 2 "选择 study.yijinglab.com"
                    read -r -p "$(echo -e "${GREEN}请输入客户端密钥(教学平台->课程云盘->客户端密钥): ${NC}")" client_key
                    if [ -z "$client_key" ]; then
                        Show 1 "客户端密钥不能为空"
                    fi
                    ;;
                2)  Show 2 "选择 injdk.cn" ;;
                3)  Show 2 "返回主菜单" ;;
                *)  Show 1 "无效的选择" ;;
            esac
            install_oracle_jdk
            ;;
        2)  install_openjdk ;;
        3)  remove_jdk ;;
        4)  Show 2 "返回主菜单" ;;
        *)  Show 2 "无效的选择" ;;
    esac
}

# 定义函数来获取临时URL
GetTempUrl() {
    token=$1
    ExeName=$2

    # 定义API URL和错误消息
    url_api='https://study.yijinglab.com/api/tools/oss/tempurl'

    error_messages=(
        "15010004:未通过验证,请先登录,获取正确客户端密钥"
        "15010005:请求内容异常"
        "15010001:参数不正确"
    )

    # 构建请求的数据
    data=$(jq -n --arg token "$token" --arg ExeName "$ExeName" '{token: $token, tempUrl: $ExeName}')

    # 发送POST请求
    resp=$(curl -s -X POST -H "Content-Type: application/json" -d "$data" "$url_api")

    # 解析JSON响应
    code=$(echo "$resp" | jq -r '.code')
    success=$(echo "$resp" | jq -r '.success')
    errorCode=$(echo "$resp" | jq -r '.errorCode')
    tempUrl=$(echo "$resp" | jq -r '.tempUrl')
    msg=$(echo "$resp" | jq -r '.msg')

    # 处理成功情况
    if [ "$success" = "true" ]; then
        Show 0 "获取OracleJDK下载地址成功"
        JDK_URL=$tempUrl
    else
        # 处理错误消息
        for error in "${error_messages[@]}"; do
            key=$(echo "$error" | cut -d: -f1)
            value=$(echo "$error" | cut -d: -f2)
            if [ "$code" = "$key" ] || [ "$errorCode" = "$key" ]; then
                Show 1 "$value"
            fi
        done
        Show 1 "$msg"
    fi
}

# 安装Oracle JDK
install_oracle_jdk() {
    # 定义常量
    local JDK_VERSIONS=("jdk1.8.0_421" "jdk-11.0.24" "jdk-17.0.12" "jdk-21.0.4" "jdk-22.0.2" "jdk-23.0.1")
    local JDK_NAMES=("jdk-8u421-linux-x64.tar.gz" "jdk-11.0.24_linux-x64_bin.tar.gz" "jdk-17.0.12_linux-x64_bin.tar.gz" "jdk-21.0.4_linux-x64_bin.tar.gz" "jdk-22.0.2_linux-x64_bin.tar.gz" "jdk-23_linux-x64_bin.tar.gz")
    local JDK_URLS=("https://d10.injdk.cn/openjdk/oraclejdk/8/jdk-8u421-linux-x64.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/11/jdk-11.0.24_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/17/jdk-17_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/21/jdk-21_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/22/jdk-22_linux-x64_bin.tar.gz" "https://d10.injdk.cn/openjdk/oraclejdk/23/jdk-23_linux-x64_bin.tar.gz")

    Show 2 "安装Oracle JDK"
    echo -e "${YELLOW}[+] 选择想要安装的OracleJDK版本: ${NC}"
    echo "1. Oracle JDK 8 LTS"
    echo "2. Oracle JDK 11 LTS"
    echo "3. Oracle JDK 17 LTS"
    echo "4. Oracle JDK 21 LTS"
    echo "5. Oracle JDK 22 LTS"
    echo "6. Oracle JDK 23 LTS"
    echo "7. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置JDK/安装OracleJDK)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" version
    case $version in
        1|2|3|4|5|6)
            local index=$((version - 1))
            JDK_VER=${JDK_VERSIONS[$index]}
            JDK_NAME=${JDK_NAMES[$index]}
            JDK_URL=${JDK_URLS[$index]}

            if [ -n "$client_key" ]; then
                GetTempUrl "$client_key" "$JDK_NAME"
            fi
            check_oracle_jdk
            ;;
        7)  Show 2 "返回主菜单" ;;
        *)  Show 2 "无效的选择" ;;
    esac
}

# 检查 Oracle JDK
check_oracle_jdk() {
    Show 2 "检查OracleJDK安装情况"
    if [ -f "$JDK_NAME" ]; then
        Show 2 "存在 ${JDK_NAME} 文件"
        Show 2 "删除 ${JDK_NAME} 文件"
        rm -rf "$JDK_NAME"
    else
        Show 2 "不存在 ${JDK_NAME} 文件"
    fi

    Show 2 "下载 ${JDK_NAME} 文件"
    
    if ! wget -q --show-progress "$JDK_URL" -O "$JDK_NAME"; then
        rm -f "$JDK_NAME" >/dev/null 2>&1
        Show 1  "下载 ${JDK_NAME} 文件失败"
    else
        Show 0  "下载 ${JDK_NAME} 文件成功"
    fi

    # 设置解压目录
    JDK_DIR="/usr/lib/jvm"
    Show 2 "设置解压安装目录为：${JDK_DIR}"

    if [ ! -d "$JDK_DIR" ]; then
        Show 2 "开始创建 ${JDK_DIR} 目录..."
        sudo mkdir -p "${JDK_DIR}"
        action "创建 ${JDK_DIR} 目录成功" "创建 ${JDK_DIR} 目录失败"
    fi

    # 解压JDK
    Show 2 "开始解压OracleJDK文件"
    sudo tar -xzf "$JDK_NAME" -C $JDK_DIR
    action "解压OracleJDK文件成功" "解压OracleJDK文件失败"

    Show 2 "配置Java环境变量"

    sudo update-alternatives --install /usr/bin/java java "/usr/lib/jvm/${JDK_VER}/bin/java" 2
    sudo update-alternatives --set java "/usr/lib/jvm/${JDK_VER}/bin/java"

    sudo update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/${JDK_VER}/bin/javac" 2
    sudo update-alternatives --set javac "/usr/lib/jvm/${JDK_VER}/bin/javac"

    # 设置keytool
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/keytool" ]; then
        sudo update-alternatives --install /usr/bin/keytool keytool "/usr/lib/jvm/${JDK_VER}/bin/keytool" 2
        sudo update-alternatives --set keytool "/usr/lib/jvm/${JDK_VER}/bin/keytool"
    fi

    # 设置jar
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/jar" ]; then
        sudo update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/${JDK_VER}/bin/jar" 2
        sudo update-alternatives --set jar "/usr/lib/jvm/${JDK_VER}/bin/jar"
    fi

    # 设置jarsigner
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/jarsigner" ]; then
        sudo update-alternatives --install /usr/bin/jarsigner jarsigner "/usr/lib/jvm/${JDK_VER}/bin/jarsigner" 2
        sudo update-alternatives --set jarsigner "/usr/lib/jvm/${JDK_VER}/bin/jarsigner"
    fi

    Show 0 "成功安装和配置Oracle JDK"
}

# 安装OpenJDK
install_openjdk() {
    Show 2 "安装OpenJDK"
    echo -e "${YELLOW}[+] 选择想要安装的OpenJDK版本: ${NC}"
    echo "1. OpenJDK 11 LTS"
    echo "2. OpenJDK 17 LTS"
    echo "3. OpenJDK 21 LTS"
    echo "4. OpenJDK 22 LTS"
    echo "5. OpenJDK 23 LTS"
    echo "6. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置JDK/安装OpenJDK)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice

    case $choice in
        1)
            Show 2 "安装OpenJDK 11 LTS"
            JDK_VER="11.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        2)
            Show 2 "安装OpenJDK 17 LTS"
            JDK_VER="17.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        3)
            Show 2 "安装OpenJDK 21 LTS"
            JDK_VER="21.0.1"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        4)
            Show 2 "安装OpenJDK 22 LTS"
            JDK_VER="22.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        5)
            Show 2 "安装OpenJDK 23 LTS"
            JDK_VER="23"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        6)  Show 2 "返回主菜单" ;;
        *)  Show 2 "无效的选择" ;;
    esac
}

# 检查 OpenJDK
check_openjdk() {
    Show 2 "检查OpenJDK安装情况"
    if [ -f "openjdk-${JDK_VER}_linux-x64_bin.tar.gz" ]; then
        Show 2 "存在 openjdk-${JDK_VER}_linux-x64_bin.tar.gz 文件"
        Show 2 "删除 openjdk-${JDK_VER}_linux-x64_bin.tar.gz 文件"
        rm -f "openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
    fi

    Show 2 "开始下载OpenJDK文件"
    wget -q --show-progress "$JDK_URL"

    # 检查是否下载成功
    if [ -f "openjdk-${JDK_VER}_linux-x64_bin.tar.gz" ]; then
        Show 0 "下载OpenJDK文件成功"
    else
        rm -f "openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
        Show 1 "下载OpenJDK文件失败"
    fi

    # 设置解压目录
    JDK_DIR="/usr/lib/jvm"
    Show 2 "设置解压安装目录为：${JDK_DIR}"

    if [ ! -d "$JDK_DIR" ]; then
        Show 2 "创建 ${JDK_DIR} 目录"
        sudo mkdir -p "${JDK_DIR}"
        action "创建 ${JDK_DIR} 目录成功" "创建 ${JDK_DIR} 目录失败"
    fi

    # 解压JDK
    Show 2 "开始解压缩OpenJDK文件"
    sudo tar -xzf "openjdk-${JDK_VER}_linux-x64_bin.tar.gz" -C ${JDK_DIR}

    # 检查解压是否成功
    action "解压OpenJDK文件成功" "解压OpenJDK文件失败"

    # 配置Java和Javac
    Show 2 "配置Java环境变量"

    # 设置Java
    sudo update-alternatives --install /usr/bin/java java "/usr/lib/jvm/jdk-${JDK_VER}/bin/java" 2
    sudo update-alternatives --set java "/usr/lib/jvm/jdk-${JDK_VER}/bin/java"

    # 设置Javac
    sudo update-alternatives --install /usr/bin/javac javac "/usr/lib/jvm/jdk-${JDK_VER}/bin/javac" 2
    sudo update-alternatives --set javac "/usr/lib/jvm/jdk-${JDK_VER}/bin/javac"

    # 设置keytool
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/keytool" ]; then
        sudo update-alternatives --install /usr/bin/keytool keytool "/usr/lib/jvm/${JDK_VER}/bin/keytool" 2
        sudo update-alternatives --set keytool "/usr/lib/jvm/${JDK_VER}/bin/keytool"
    fi

    # 设置jar
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/jar" ]; then
        sudo update-alternatives --install /usr/bin/jar jar "/usr/lib/jvm/${JDK_VER}/bin/jar" 2
        sudo update-alternatives --set jar "/usr/lib/jvm/${JDK_VER}/bin/jar"
    fi

    # 设置jarsigner
    if [ -f "/usr/lib/jvm/${JDK_VER}/bin/jarsigner" ]; then
        sudo update-alternatives --install /usr/bin/jarsigner jarsigner "/usr/lib/jvm/${JDK_VER}/bin/jarsigner" 2
        sudo update-alternatives --set jarsigner "/usr/lib/jvm/${JDK_VER}/bin/jarsigner"
    fi

    Show 0 "安装和配置OpenJDK成功"
}

# 删除当前JDK环境
remove_jdk() {
    Show 2 "定位JDK安装目录"
    JDK_DIR="$(dirname "$(dirname "$(readlink -f "$(which java)")")")"

    Show 2 "检查JDK目录是否存在"
    if [ -d "$JDK_DIR" ]; then
        Show 2 "在 $JDK_DIR 目录找到JDK"

        Show 2 "移除Java和Javac的配置"
        update-alternatives --remove java /usr/bin/java
        update-alternatives --remove javac /usr/bin/javac
        update-alternatives --remove keytool /usr/bin/keytool
        update-alternatives --remove jar /usr/bin/jar
        update-alternatives --remove jarsigner /usr/bin/jarsigner

        Show 2 配置默认的Java和Javac版本
        echo 0 | sudo update-alternatives --config java >/dev/null 2>&1
        echo 0 | sudo update-alternatives --config javac >/dev/null 2>&1
        echo 0 | sudo update-alternatives --config keytool >/dev/null 2>&1
        echo 0 | sudo update-alternatives --config jar >/dev/null 2>&1
        echo 0 | sudo update-alternatives --config jarsigner >/dev/null 2>&1

        Show 2 "删除JDK目录"
        sudo rm -rf "$JDK_DIR"
        Show 0 "删除JDK成功"
    else
        Show 1 "找不到JDK, 或者无法确定JDK安装路径"
    fi
}

# 配置APT源
config_apt_source_version(){
    local version=$1
    local source_url=$2
    local type=$3
    Show 2 "开始配置APT源"
    if [ -f "/etc/apt/sources.list.bak" ]; then
        Show 2 "已存在APT源配置文件备份, 跳过备份"
    else
        Show 2 "备份/etc/apt/sources.list文件"
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    fi

    # 根据系统类型配置源
    Show 2 "修改APT源配置文件"
    case $type in
        "ubuntu")
            sudo tee /etc/apt/sources.list <<-EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb $source_url/ubuntu $version main restricted universe multiverse
deb $source_url/ubuntu $version-updates main restricted universe multiverse
deb $source_url/ubuntu $version-backports main restricted universe multiverse
deb $source_url/ubuntu $version-security main restricted universe multiverse
# deb-src $source_url/ubuntu $version main restricted universe multiverse
# deb-src $source_url/ubuntu $version-updates main restricted universe multiverse
# deb-src $source_url/ubuntu $version-backports main restricted universe multiverse
# deb-src $source_url/ubuntu $version-security main restricted universe multiverse
EOF
            ;;
        "debian")
            sudo tee /etc/apt/sources.list <<-EOF
deb $source_url/debian $version main contrib non-free
deb $source_url/debian $version-updates main contrib non-free
deb $source_url/debian $version-backports main contrib non-free
deb $source_url/debian-security $version/updates main contrib non-free
# deb-src $source_url/debian $version main contrib non-free
# deb-src $source_url/debian $version-updates main contrib non-free
# deb-src $source_url/debian $version-backports main contrib non-free
# deb-src $source_url/debian-security $version/updates main contrib non-free
EOF
            ;;
    esac
    action "APT源配置文件修改成功" "APT源配置文件修改失败"

    Show 2 "更新APT源"
    sudo apt-get update
    action "APT源更新成功" "APT源更新失败"
}

# 配置APT源
config_apt_source() {
    echo -e "${YELLOW}[+] 请选择要使用的APT软件源: ${NC}"
    echo "1. 华为云"
    echo "2. 阿里云"
    echo "3. 腾讯云"
    echo "4. 清华大学"
    echo "5. 北京大学"
    echo "6. 中国科大"
    echo "7. 官方APT源 - Ubuntu"
    echo "8. 官方APT源 - Debian"
    echo "9. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置APT源)${NC} : ${GREEN}请输入序号(1-9) >> ${NC}")" choice

    # 根据用户选择设置APT软件源
    case $choice in
        1)
            Show 2 "选择使用华为云APT软件源"
            local mirror_url="https://mirrors.huaweicloud.com"
            local kali_mirror="1"
            ;;
        2)
            Show 2 "选择使用阿里云APT软件源"
            local mirror_url="https://mirrors.aliyun.com"
            local kali_mirror="0"
            ;;
        3)
            Show 2 "选择使用腾讯云APT软件源"
            local mirror_url="https://mirrors.cloud.tencent.com"
            local kali_mirror="0"
            ;;
        4)
            Show 2 "选择使用清华大学APT软件源"
            local mirror_url="https://mirrors.tuna.tsinghua.edu.cn"
            local kali_mirror="0"
            ;;
        5)
            Show 2 "选择使用北京大学APT软件源"
            local mirror_url="https://mirrors.pku.edu.cn"
            local kali_mirror="1"
            ;;
        6)
            Show 2 "选择使用中国科大APT软件源"
            local mirror_url="https://mirrors.ustc.edu.cn"
            local kali_mirror="0"
            ;;
        7)
            Show 2 "选择使用Ubuntu官方APT软件源"
            local mirror_url="http://archive.ubuntu.com"
            local kali_mirror="2"
            ;;
        8)
            Show 2 "选择使用Debian官方APT软件源"
            local mirror_url="http://deb.debian.org"
            local kali_mirror="2"
            ;;
        9)
            Show 2 "返回主菜单"
            return
            ;;
        *)
            Show 2 "无效的选择"
            return
            ;;
    esac
 
    # 配置Kali Linux的APT软件源
    configure_kali_apt_source() {
        local mirror_type=$1
        local mirror_url=$2

        if [ -f "/etc/apt/sources.list.bak" ]; then
            Show 2 "已存在APT源配置文件备份, 跳过备份"
        else
            Show 2 "备份/etc/apt/sources.list文件"
            if ! sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak; then
                Show 1 "备份原有APT源失败"
                return 1
            fi
        fi

        if ! sudo wget -q https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg; then
            Show 1 "下载Kali GPG密钥失败"
            return 1
        fi

        case $mirror_type in
            0) local kali_mirror_url="$mirror_url/kali" ;;
            1) local kali_mirror_url="https://mirrors.aliyun.com/kali" ;;
            2) local kali_mirror_url="http://http.kali.org/kali" ;;
        esac

        sudo tee /etc/apt/sources.list <<-EOF
deb ${kali_mirror_url} kali-rolling main contrib non-free non-free-firmware
# deb-src ${kali_mirror_url} kali-rolling main contrib non-free non-free-firmware
EOF

        action "Kali Linux APT源配置成功" "Kali Linux APT源配置失败"

        Show 2 "更新APT源"
        sudo apt-get update >& /dev/null
        action "APT源更新成功" "APT源更新失败"
    }

    Show 2 "根据当前系统版本类型, 自动配置APT源"
    case "$(lsb_release -cs)" in
        kali-rolling)
            # Kali
            configure_kali_apt_source "$kali_mirror" "$mirror_url" ;;
        bionic|focal|jammy|lunar|noble|plucky)
            # Ubuntu (18.04, 20.04, 22.04, 23.04, 24.04, 25.04)
            config_apt_source_version "$(lsb_release -cs)" "$mirror_url" "ubuntu" ;;
        buster|bullseye|bookworm|trixie)
            # Debian (10, 11, 12, 13)
            config_apt_source_version "$(lsb_release -cs)" "$mirror_url" "debian" ;;
        *)
            Show 1 "不支持的系统版本, 请手动配置APT源: $(uname -vm)"
            return 1
            ;;
    esac
    Show 0 "APT源配置成功"
}

# 配置Miniconda3
config_miniconda3() {
	echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Miniconda3"
    echo "2. 卸载 Miniconda3"
    echo "3. 配置 Miniconda3 软件源"
    echo "4. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置miniconda3)${NC} : ${GREEN}请输入序号(1-4) >> ${NC}")" choice
    case $choice in
        1)  install_miniconda3 ;;
        2)  remove_miniconda3 ;;
        3)  configure_conda_mirror ;;
        4)  Show 2 "返回主菜单" ;;
        *)  Show 2 "无效的选择" ;;
    esac
}

# 安装Miniconda3
install_miniconda3() {
    Show 2 "开始安装 miniconda3"

    echo -e "${YELLOW}[+] 请选择要使用的软件源: ${NC}"
    echo "1. 中国科大 miniconda"
    echo "2. 哈工大 miniconda"
    echo "3. 北京大学 miniconda"
    echo "4. 清华大学 miniconda"
    echo "5. 浙江大学 miniconda"
    echo "6. 南京大学 miniconda"
    echo "7. 官方源 miniconda"
    read -r -p "$(echo -e "${RED}(配置miniconda3/安装miniconda3)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" choice

    # 根据用户选择设置 Miniconda3 软件源
    if [[ "$choice" == "1" ]]; then
        Show 2 "选择使用中国科大miniconda软件源"
        local mirror_url="https://mirrors.ustc.edu.cn/anaconda"
    elif [[ "$choice" == "2" ]]; then
        Show 2 "选择使用哈工大miniconda软件源"
        local mirror_url="https://mirrors.hit.edu.cn/anaconda"
    elif [[ "$choice" == "3" ]]; then
        Show 2 "选择使用北京大学miniconda软件源"
        local mirror_url="https://mirrors.pku.edu.cn/anaconda"
    elif [[ "$choice" == "4" ]]; then
        Show 2 "选择使用清华大学miniconda软件源"
        local mirror_url="https://mirrors.tuna.tsinghua.edu.cn/anaconda"
    elif [[ "$choice" == "5" ]]; then
        Show 2 "选择使用浙江大学miniconda软件源"
        local mirror_url="https://mirrors.zju.edu.cn/anaconda"
    elif [[ "$choice" == "6" ]]; then
        Show 2 "选择使用南京大学miniconda软件源"
        local mirror_url="https://mirrors.nju.edu.cn/anaconda"
    elif [[ "$choice" == "7" ]]; then
        Show 2 "选择使用官方源miniconda软件源"
        local mirror_url="https://repo.anaconda.com"
    else
        Show 1 "输入错误, 退出安装"
    fi

    Show 2 "检查miniconda3安装脚本是否存在"
    local install_script="/opt/miniconda3.sh"
    local install_dir="/opt/miniconda3"
    if [ -f "$install_script" ]; then
        Show 2 "存在miniconda3安装脚本"
        Show 2 "删除miniconda3安装脚本"
        rm -f "$install_script" >/dev/null 2>&1
    fi

    # 临时禁用set -e，避免curl失败导致脚本退出
    set +e
    
    # 检查URL状态码
    local status_code
    Show 3 "正在检查镜像源状态..."
    status_code=$(curl -s -m 10 -o /dev/null -w "%{http_code}" "${mirror_url}/miniconda/Miniconda3-latest-Linux-x86_64.sh" 2>/dev/null)
    Show 3 "检测到HTTP状态码: '$status_code'"
    case $status_code in
        200)
            # 状态码为200则下载安装脚本
            Show 2 "下载miniconda3安装脚本"
            if sudo wget --show-progress "${mirror_url}/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O "$install_script"; then
                Show 0 "下载miniconda3安装脚本成功"
            else
                echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 下载miniconda3安装脚本失败"
                Show 2 "错误详情：下载过程中断或网络异常"
                return 1
            fi
            ;;
        403)
            echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 下载miniconda3安装脚本失败"
            Show 2 "错误详情: 你的IP被ban了, 无法访问镜像源 (403)"
            Show 2 "建议："
            Show 2 "  1. 更换网络环境（如使用手机热点）"
            Show 2 "  2. 等待一段时间后重试"
            Show 2 "  3. 尝试使用其他镜像源"
            return 1
            ;;
        404)
            echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 下载miniconda3安装脚本失败"
            Show 2 "错误详情：文件不存在 (404)"
            Show 2 "建议：检查镜像源地址是否正确"
            return 1
            ;;
        5**)
            echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 下载miniconda3安装脚本失败"
            Show 2 "错误详情：服务器内部错误 ($status_code)"
            Show 2 "建议：稍后重试或尝试其他镜像源"
            return 1
            ;;
        *)
            echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 下载miniconda3安装脚本失败"
            Show 2 "错误详情: 未知HTTP状态码 ($status_code)"
            Show 2 "建议：检查网络连接或尝试其他镜像源"
            return 1
            ;;
    esac

    Show 2 "执行miniconda3安装脚本"
    if sudo bash "$install_script" -b -p "$install_dir" >/dev/null; then
        Show 0 "安装miniconda3成功"
        Show 0 "安装目录: $install_dir"
    else
        Show 1 "安装miniconda3失败"
    fi

    Show 2 "初始化conda"
    if [ -f "$install_dir/bin/activate" ]; then
        # shellcheck disable=SC1091
        source "$install_dir/bin/activate"
    else
        Show 1 "未找到 $install_dir/bin/activate 脚本, 无法初始化conda"
    fi
    $install_dir/bin/conda init bash
    $install_dir/bin/conda init zsh
    Show 0 "初始化conda完成"

    configure_condarc "$mirror_url" "$install_dir"

    Show 2 "开始更新conda"
    
    if [ "$mirror_url" = "https://repo.anaconda.com" ]; then
        Show 2 "使用官方源需要TOS授权"
        sudo $install_dir/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
        sudo $install_dir/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
        sudo $install_dir/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2
    fi
    sudo $install_dir/bin/conda update conda -y >/dev/null
    action "更新conda成功" "更新conda失败"

    Show 2 "清理conda缓存"
    sudo $install_dir/bin/conda clean -a -y >/dev/null

    Show 2 "清理conda缓存完成"
    Show 0 "安装miniconda3完成"
    
    # 重新启用set -e
    set -e
}

# 配置conda镜像源
configure_condarc() {
    local mirror_url=$1
    local install_dir=$2
    Show 2 "配置conda镜像源"
    
    # 确定conda配置文件路径
    local condarc_path
    if [ "$EUID" -eq 0 ]; then
        # 如果是root用户，配置root的condarc
        condarc_path="/root/.condarc"
        Show 3 "检测到root用户，配置文件路径: $condarc_path"
    else
        # 普通用户
        condarc_path="$HOME/.condarc"
        Show 3 "检测到普通用户，配置文件路径: $condarc_path"
    fi
    
    # 写入conda配置文件
    cat <<EOF | sudo tee "$condarc_path" >/dev/null
channels:
  - defaults
show_channel_urls: true
auto_activate_base: false
channel_alias: ${mirror_url}
default_channels:
  - ${mirror_url}/pkgs/main
  - ${mirror_url}/pkgs/free
  - ${mirror_url}/pkgs/r
  - ${mirror_url}/pkgs/msys2
custom_channels:
  conda-forge: ${mirror_url}/cloud
  msys2: ${mirror_url}/cloud
  bioconda: ${mirror_url}/cloud
  menpo: ${mirror_url}/cloud
  pytorch: ${mirror_url}/cloud
  simpleitk: ${mirror_url}/cloud
EOF
    
    # 验证文件是否写入成功
    if [ -f "$condarc_path" ] && [ -s "$condarc_path" ]; then
        Show 0 "配置conda镜像源完成"
    else
        Show 1 "配置conda镜像源失败"
        Show 2 "错误详情：无法写入配置文件到 $condarc_path"
        return 1
    fi

    users=$(ls /home)
    if [ -z "$users" ]; then
        Show 2 "没有找到其他用户目录, 跳过其他用户配置"
    else
        for user in $users; do
            Show 2 "正在为用户 ${user} 配置conda环境..."
            if su - "$user" -c "$install_dir/bin/conda init zsh;$install_dir/bin/conda init bash" 2>/dev/null; then
                Show 0 "为用户 ${user} 配置conda环境成功"
            else
                Show 2 "为用户 ${user} 配置conda环境失败, 但继续配置镜像源"
            fi
            configure_conda_user "$mirror_url" "$user"
        done
    fi
}

# 配置用户conda镜像源
configure_conda_user() {
    local mirror_url=$1
    local user=$2
    local user_condarc="/home/$user/.condarc"
    
    Show 2 "为用户 $user 配置conda镜像源"
    Show 2 "配置文件路径: $user_condarc"
    
    # 检查用户目录是否存在
    if [ ! -d "/home/$user" ]; then
        Show 2 "用户 $user 的家目录不存在，跳过配置"
        return 1
    fi
    
    # 写入用户conda配置文件
    cat <<EOF | sudo tee "$user_condarc" >/dev/null
channels:
  - defaults
show_channel_urls: true
auto_activate_base: false
channel_alias: ${mirror_url}
default_channels:
  - ${mirror_url}/pkgs/main
  - ${mirror_url}/pkgs/free
  - ${mirror_url}/pkgs/r
  - ${mirror_url}/pkgs/msys2
custom_channels:
  conda-forge: ${mirror_url}/cloud
  msys2: ${mirror_url}/cloud
  bioconda: ${mirror_url}/cloud
  menpo: ${mirror_url}/cloud
  pytorch: ${mirror_url}/cloud
  simpleitk: ${mirror_url}/cloud
EOF
    
    # 验证文件是否写入成功并设置正确的权限
    if [ -f "$user_condarc" ] && [ -s "$user_condarc" ]; then
        Show 0 "为用户 $user 配置conda镜像源完成"
    else
        Show 1 "为用户 $user 配置conda镜像源失败"
    fi
}

# 配置conda镜像源
configure_conda_mirror() {
    echo -e "${YELLOW}[+] 请选择要使用的软件源: ${NC}"
    echo "1. 中国科大 miniconda"
    echo "2. 哈工大 miniconda"
    echo "3. 北京大学 miniconda"
    echo "4. 清华大学 miniconda"
    echo "5. 浙江大学 miniconda"
    echo "6. 南京大学 miniconda"
    echo "7. 官方源 miniconda"
    read -r -p "$(echo -e "${RED}(配置miniconda3/配置miniconda3软件源)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" choice

    # 根据用户选择设置 Miniconda3 软件源

    if [[ "$choice" == "1" ]]; then
        Show 2 "选择使用中国科大miniconda软件源"
        local mirror_url="https://mirrors.ustc.edu.cn/anaconda"
    elif [[ "$choice" == "2" ]]; then
        Show 2 "选择使用哈工大miniconda软件源"
        local mirror_url="https://mirrors.hit.edu.cn/anaconda"
    elif [[ "$choice" == "3" ]]; then
        Show 2 "选择使用北京大学miniconda软件源"
        local mirror_url="https://mirrors.pku.edu.cn/anaconda"
    elif [[ "$choice" == "4" ]]; then
        Show 2 "选择使用清华大学miniconda软件源"
        local mirror_url="https://mirrors.tuna.tsinghua.edu.cn/anaconda"
    elif [[ "$choice" == "5" ]]; then
        Show 2 "选择使用浙江大学miniconda软件源"
        local mirror_url="https://mirrors.zju.edu.cn/anaconda"
    elif [[ "$choice" == "6" ]]; then
        Show 2 "选择使用南京大学miniconda软件源"
        local mirror_url="https://mirrors.nju.edu.cn/anaconda"
    elif [[ "$choice" == "7" ]]; then
        Show 2 "选择使用官方源miniconda软件源"
        local mirror_url="https://repo.anaconda.com"
    else
        Show 1 "输入错误, 退出安装"
    fi
    local install_dir="/opt/miniconda3"

    configure_condarc "$mirror_url" "$install_dir"
}

# 卸载Miniconda3
remove_miniconda3() {
    Show 2 "开始卸载miniconda3"
    local install_dir="/opt/miniconda3"

    # 定义要删除的文件和目录
    declare -a files=("$install_dir" "$HOME/.condarc")

    # 定义要处理的配置文件
    declare -a config_files=(".bashrc" ".zshrc")

    Show 2 "删除miniconda3文件和目录"
    for file in "${files[@]}"; do
        sudo rm -rf "${file}"
        action "删除 ${file} 成功" "删除 ${file} 失败"
    done

    local conda_init_start="# >>> conda initialize >>"
    local conda_init_end="# <<< conda initialize <<"

    for config in "${config_files[@]}"; do
        Show 2 "检查配置文件: ${HOME}/${config}"
        if [ -f "${HOME}/${config}" ]; then
            # 使用sed命令删除配置文件中的conda初始化代码
            Show 2 "删除conda初始化代码"
            sudo sed -i "/${conda_init_start}/,/${conda_init_end}/d" "${HOME}/${config}"

            # 检查sed命令是否成功执行
            action "移除conda初始化代码成功" "移除conda初始化代码失败"
        else
            Show 2 "未找到 ${config} 文件"
        fi
    done

    users=$(ls /home)
    if [ -z "$users" ]; then
        Show 2 "没有找到其他用户目录, 跳过用户目录配置删除"
    else
        for user in $users; do
            Show 2 "删除用户 $user 的conda配置文件"
            sudo rm -rf "/home/${user}/.condarc"
            action "删除 /home/${user}/.condarc 成功" "删除 /home/${user}/.condarc 失败"

            for config in "${config_files[@]}"; do
                Show 2 "检查配置文件: /home/${user}/${config}"
                if [ -f "/home/${user}/${config}" ]; then
                    # 使用sed命令删除配置文件中的conda初始化代码
                    Show 2 "移除conda初始化代码"
                    sudo sed -i "/${conda_init_start}/,/${conda_init_end}/d" "/home/${user}/${config}"

                    # 检查sed命令是否成功执行
                    action "移除conda初始化代码成功" "移除conda初始化代码失败"
                else
                    Show 2 "未找到 ${config} 文件"
                fi
            done
        done
    fi

    Show 0 "卸载miniconda3完成"
}

# 检查Docker
check_docker() {
    Show 2 "检查Docker是否安装"
    if which docker > /dev/null 2>&1; then
        Show 0 "确定Docker已安装"
        Show 2 "启动Docker服务"
        systemctl start docker >& /dev/null
        action "启动Docker服务成功" "启动Docker服务失败"
    else
        Show 2 "Docker未安装, 开始安装"
        install_docker
    fi
}

# 配置Docker
config_docker() {
	echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Docker"
    echo "2. 卸载 Docker"
    echo "3. 配置 Docker 国内镜像"
    echo "4. 获取 Docker 国内镜像源配置"
    echo "5. 取消 Docker 国内镜像"
    echo "6. 配置 Docker 网络代理"
    echo "7. 获取 Docker 网络代理配置"
    echo "8. 取消 Docker 网络代理"
    echo "9. 拉取 Docker 镜像"
    echo "10. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Docker)${NC} : ${GREEN}请输入序号(1-10) >> ${NC}")" choice
    case $choice in
        1) install_docker ;;
        2) remove_docker ;;
        3) configure_docker_mirror ;;
        4) get_docker_mirror_config ;;
        5) unconfigure_docker_mirror ;;
        6) configure_docker_proxy ;;
        7) get_docker_proxy_config ;;
        8) unconfigure_docker_proxy ;;
        9)  pull_docker_image ;;
        10) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装Docker
install_docker() {
    Show 2 "开始安装Docker"
    Show 2 "更新APT源..."
    sudo apt-get update >/dev/null
    action "更新APT源成功" "更新APT源失败"

    Show 2 "正在安装依赖包"
    sudo apt-get install apt-transport-https ca-certificates curl gnupg -y >/dev/null
    action "安装依赖包成功" "安装依赖包失败"

    if [[ "$(lsb_release -is)" == "Ubuntu" ]] || [[ "$(lsb_release -is)" == "Debian" ]]; then
        local repo_name
        repo_name=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

        Show 0 "检测到系统为: ${repo_name}"
        echo -e "${YELLOW}[+] 请选择要使用的镜像源: ${NC}"
        echo "1. 清华大学 Docker-CE"
        echo "2. 北京大学 Docker-CE"
        echo "3. 阿里云 Docker-CE"
        echo "4. 华为云 Docker-CE"
        echo "5. 腾讯云 Docker-CE"
        echo "6. 官方源 Docker-CE"
        read -r -p "$(echo -e "${RED}(配置Docker/配置Docker镜像源)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice

        # 根据用户选择设置 Docker 软件源
        if [[ "$choice" == "1" ]]; then
            Show 2 "选择使用清华大学Docker-CE镜像源"
            local mirror_url="https://mirrors.tuna.tsinghua.edu.cn"
        elif [[ "$choice" == "2" ]]; then
            Show 2 "选择使用北京大学Docker-CE镜像源"
            local mirror_url="https://mirrors.pku.edu.cn"
        elif [[ "$choice" == "3" ]]; then
            Show 2 "选择使用阿里云Docker-CE镜像源"
            local mirror_url="https://mirrors.aliyun.com"
        elif [[ "$choice" == "4" ]]; then
            Show 2 "选择使用华为云Docker-CE镜像源"
            local mirror_url="https://mirrors.huaweicloud.com"
        elif [[ "$choice" == "5" ]]; then
            Show 2 "选择使用腾讯云Docker-CE镜像源"
            local mirror_url="https://mirrors.cloud.tencent.com"
        elif [[ "$choice" == "6" ]]; then
            Show 2 "选择使用官方源Docker-CE镜像源"
            local mirror_url="https://download.docker.com"
        else
            Show 1 "输入错误, 退出安装"
        fi

        Show 2 "设置Docker软件源"
        sudo install -d /etc/apt/keyrings
        if [[ "$choice" == "6" ]]; then
            sudo curl -fsSL "${mirror_url}/linux/${repo_name}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        fi
        sudo curl -fsSL "${mirror_url}/docker-ce/linux/${repo_name}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        
        # 明确读取VERSION_CODENAME
        if [ -f /etc/os-release ]; then
            VERSION_CODENAME=$(grep -E '^VERSION_CODENAME=' /etc/os-release | cut -d'=' -f2)
            if [ -n "$VERSION_CODENAME" ]; then
                sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${mirror_url}/docker-ce/linux/${repo_name} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                action "设置Docker软件源成功" "设置Docker软件源失败"
            else
                Show 1 "无法从/etc/os-release获取版本代号"
            fi
        else
            Show 1 "未找到/etc/os-release文件, 无法设置Docker软件源"
        fi

        Show 2 "更新软件包列表"
        sudo apt-get update >/dev/null
        action "更新软件包列表成功" "更新软件包列表失败"

        Show 2 "安装Docker软件开始"
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
        action "安装Docker软件成功" "安装Docker软件失败"

    elif [[ "$(lsb_release -cs)" == "kali-rolling" ]]; then
        # 针对 Kali Rolling 的特定安装逻辑
        Show 0 "检测到系统为: Kali Rolling"
        echo -e "${YELLOW}[+] 请选择要使用的镜像源: ${NC}"
        echo "1. 清华大学 Docker-CE"
        echo "2. 阿里云 Docker-CE"
        echo "3. 华为云 Docker-CE"
        echo "4. 腾讯云 Docker-CE"
        echo "5. 官方源 Docker-CE"
        read -r -p "$(echo -e "${RED}(配置Docker/配置Docker镜像源)${NC} : ${GREEN}请输入序号(1-5) >> ${NC}")" choice

        # 根据用户选择设置 Docker 软件源
        if [[ "$choice" == "1" ]]; then
            Show 2 "选择使用清华大学Docker-CE镜像源"
            local mirror_url="https://mirrors.tuna.tsinghua.edu.cn"
        elif [[ "$choice" == "2" ]]; then
            Show 2 "选择使用阿里云Docker-CE镜像源"
            local mirror_url="https://mirrors.aliyun.com"
        elif [[ "$choice" == "3" ]]; then
            Show 2 "选择使用华为云Docker-CE镜像源"
            local mirror_url="https://mirrors.huaweicloud.com"
        elif [[ "$choice" == "4" ]]; then
            Show 2 "选择使用腾讯云Docker-CE镜像源"
            local mirror_url="https://mirrors.cloud.tencent.com"
        elif [[ "$choice" == "5" ]]; then
            Show 2 "选择使用官方源Docker-CE镜像源"
            local mirror_url="https://download.docker.com"
        else
            Show 1 "输入错误, 退出安装"
        fi

        Show 2 "设置 Docker 软件源"
        if [[ "$choice" == "5" ]]; then
            sudo curl -fsSL "${mirror_url}/linux/debian/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        fi
        curl -fsSL "${mirror_url}/docker-ce/linux/debian/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${mirror_url}/docker-ce/linux/debian/ bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        action "设置Docker软件源成功" "设置Docker软件源失败"

        Show 2 "更新软件包列表"
        sudo apt-get update >/dev/null
        action "更新软件包列表成功" "更新软件包列表失败"

        Show 2 "开始安装Docker"
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null
        action "安装Docker成功" "安装Docker失败"
    else
        Show 1 "当前系统版本不支持"
    fi

    Show 2 "安装Docker版本: "
    docker --version
}

# 卸载Docker
remove_docker() {
    Show 2 "开始卸载Docker"
    Show 2 "卸载Docker相关软件"
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io

    Show 2 "删除Docker数据目录"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/apt/keyrings/docker.gpg
    sudo rm -rf /etc/apt/sources.list.d/docker.list

    Show 2 "删除Docker配置文件"
    sudo rm -rf /etc/docker

    Show 0 "成功卸载Docker"
}

# 配置Docker为国内镜像源
configure_docker_mirror() {
    Show 2 "配置Docker国内镜像源"
    sudo mkdir -p /etc/docker

    # 定义Docker镜像源列表
    local mirrors=(
        "https://docker.m.daocloud.io"
        "https://docker.1ms.run"
        "https://docker.gh-proxy.org"
        "https://docker.xuanyuan.me"
        "https://dockerproxy.net"
        "https://hub.rat.dev"
        "https://docker.m.ixdev.cn"
    )

    Show 2 "开始检测镜像源可用性"
    local available_mirrors=()
    
    for mirror in "${mirrors[@]}"; do
        # 移除 https:// 前缀用于测试
        local mirror_host=${mirror#https://}
        if timeout 30 docker pull "${mirror_host}/library/hello-world:latest" &> /dev/null; then
            Show 0 "✅ 镜像源可用: ${mirror}"
            available_mirrors+=("${mirror}")
            docker rmi "${mirror_host}/library/hello-world:latest" &> /dev/null
        else
            Show 3 "❌ 镜像源不可用: ${mirror}，将被跳过"
        fi
    done

    if [ ${#available_mirrors[@]} -eq 0 ]; then
        Show 1 "❌ 没有可用的镜像源，配置失败"
        return 1
    fi

    Show 2 "使用以下可用镜像源进行配置:"
    printf '%s\n' "${available_mirrors[@]}"

    # 生成daemon.json内容
    local daemon_json="{\n  \"registry-mirrors\": [\n"
    for i in "${!available_mirrors[@]}"; do
        daemon_json+="    \"${available_mirrors[i]}\""
        if [ $((i + 1)) -lt ${#available_mirrors[@]} ]; then
            daemon_json+=","
        fi
        daemon_json+="\n"
    done
    daemon_json+="  ]\n}"

    if echo -e "${daemon_json}" | sudo tee /etc/docker/daemon.json > /dev/null; then
        Show 0 "修改配置文件成功"
        Show 2 "重启Docker服务"
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        Show 0 "配置Docker国内镜像源成功, 共配置 ${#available_mirrors[@]} 个可用镜像源"
    else
        Show 2 "修改配置文件失败"
        Show 1 "配置Docker国内镜像源失败"
        return 1
    fi
}

# 获取Docker国内镜像源配置
get_docker_mirror_config() {
    Show 2 "获取Docker国内镜像源配置"
    if [ -f "/etc/docker/daemon.json" ]; then
        cat /etc/docker/daemon.json
    else
        Show 3 "未找到Docker国内镜像源配置文件"
    fi
}

# 取消配置Docker为国内镜像源
unconfigure_docker_mirror() {
    Show 2 "取消配置Docker使用国内镜像开始"
    Show 2 "删除配置文件"
    sudo rm -f /etc/docker/daemon.json
    Show 2 "重启 Docker 服务"
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    Show 0 "取消配置Docker使用国内镜像成功"
}

# 配置Docker网络代理
configure_docker_proxy() {
    Show 2 "配置Docker网络代理开始"
	echo -e "${YELLOW}[+] 选择代理协议类型: ${NC}"
    echo "1. HTTP / HTTPS"
    echo "2. SOCKS5"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Docker/配置Docker网络代理)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" type
    case $type in
        1) proxy_type=http ;;
        2) proxy_type=socks5 ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
    # 输入代理地址
    read -r -p "$(echo -e "${GREEN}输入代理地址 (Ex: 127.0.0.1:7890): ${NC}")" proxy_ip_port

    # 配置文件路径
    CONFIG_FILE="/etc/systemd/system/docker.service.d/proxy.conf"

    Show 2 "检查并创建配置目录"
    sudo mkdir -p /etc/systemd/system/docker.service.d

    Show 2 "根据选择创建或更新配置文件"
    if [ -f "$CONFIG_FILE" ]; then
        Show 2 "配置文件已存在，将覆盖原有配置"
    else
        Show 2 "配置文件不存在，将创建新的配置文件"
    fi
    cat <<EOF | sudo tee $CONFIG_FILE > /dev/null
[Service]
Environment="HTTP_PROXY=${proxy_type}://${proxy_ip_port}"
Environment="HTTPS_PROXY=${proxy_type}://${proxy_ip_port}"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

    Show 2 "重新加载systemd管理器配置"
    sudo systemctl daemon-reload

    Show 2 "重启Docker服务"
    sudo systemctl restart docker
    action "成功配置Docker使用网络代理: ${proxy_type}://${proxy_ip_port}" "配置Docker网络代理失败"
}

# 获取Docker网络代理配置
get_docker_proxy_config() {
    Show 2 "获取Docker网络代理配置"
    if [ -f "/etc/systemd/system/docker.service.d/proxy.conf" ]; then
        cat /etc/systemd/system/docker.service.d/proxy.conf
    else
        Show 3 "未找到Docker网络代理配置文件"
    fi
}

# 取消配置Docker网络代理
unconfigure_docker_proxy() {
    Show 2 "取消配置Docker网络代理开始"
    Show 2 "删除配置文件"
    sudo rm -f /etc/systemd/system/docker.service.d/proxy.conf

    Show 2 "重新加载systemd管理器配置"
    sudo systemctl daemon-reload

    Show 2 重启Docker服务
    sudo systemctl restart docker
    action "取消配置Docker使用网络代理成功" "取消配置Docker使用网络代理失败"
}

# 拉取 Docker 镜像
pull_docker_image() {
    # 提示用户输入要拉取的Docker镜像名称
    read -r -p "$(echo -e "${YELLOW}请输入要拉取的Docker镜像名称: ${NC}")" image_name

    # 检查输入是否为空
    if [ -z "${image_name}" ]; then
        Show 1 "错误: 镜像名称不能为空"
        return 1
    fi

    # 定义Docker镜像源列表
    local mirrors=(
        "docker.io"
        "docker.1ms.run"
        "docker.gh-proxy.org"
        "docker.xuanyuan.me"
        "docker.m.daocloud.io"
        "lynn520.xyz"
        "dockerproxy.net"
        "hub.rat.dev"
        "docker.m.ixdev.cn"
    )

    Show 2 "开始测试镜像源可用性并拉取: ${image_name}"
    
    for mirror in "${mirrors[@]}"; do
        Show 2 "测试 ${mirror} 镜像源"
        
        # 测试镜像源可用性
        if timeout 30 docker pull "${mirror}/library/hello-world:latest" &> /dev/null; then
            Show 0 "✅ ${mirror} 镜像源可用，正在拉取目标镜像"
            
            # 清理测试镜像
            docker rmi "${mirror}/library/hello-world:latest" &> /dev/null
            
            # 拉取目标镜像
            if timeout 300 docker pull "${mirror}/${image_name}"; then
                Show 0 "✅ ${image_name} 镜像拉取成功！"
                
                # 重新标记镜像
                docker tag "${mirror}/${image_name}" "${image_name}"
                docker rmi "${mirror}/${image_name}" &> /dev/null
                
                Show 0 "镜像处理完成，已标记为: ${image_name}"
                return 0
            else
                Show 3 "❌ ${image_name} 镜像拉取失败"
            fi
        else
            Show 3 "❌ ${mirror} 镜像源不可用"
        fi
    done
    Show 1 "所有镜像源都失败，请检查网络连接"
}

# 配置Docker-compose
config_docker_compose() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Docker-compose"
    echo "2. 卸载 Docker-compose"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Docker-compose)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice

    case $choice in
        1) install_docker_compose ;;
        2) remove_docker_compose ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装Docker-compose
install_docker_compose() {
    echo -e "${YELLOW}[+] 请选择Docker-compose的安装源: ${NC}"
    echo "1. Gitee"
    echo "2. Github"
    read -r -p "$(echo -e "${RED}(配置Docker-compose/安装Docker-compose)${NC} : ${GREEN}请输入序号(1-2) >> ${NC}")" choice
    local docker_compose_url
    # 根据用户选择设置 Docker 软件源
    if [[ "$choice" == "1" ]]; then
        Show 2 "选择从Gitee下载安装Docker-compose"
        docker_compose_url="https://gitee.com/yijingsec/compose/releases/download/$(curl -s https://gitee.com/api/v5/repos/yijingsec/compose/releases/latest | grep -E -o '\"tag_name\":\"([^\"]+)\"' | awk -F\" '{print $4}')/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
        action "Gitee Docker-compose 下载地址: ${docker_compose_url}" "Gitee Docker-compose 下载地址获取失败"
    elif [[ "$choice" == "2" ]]; then
        Show 2 "选择从Github下载安装Docker-compose"
        docker_compose_url="https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\1/')/docker-compose-$(uname -s)-$(uname -m)"
        action "Github Docker-compose 下载地址: ${docker_compose_url}" "Github Docker-compose 下载地址获取失败"
    else
        Show 1 "输入错误, 退出安装"
    fi

    Show 2 "开始安装docker-compose"
    if [ -f "/usr/local/bin/docker-compose" ]; then
        read -r -p "已安装docker-compose, 是否卸载? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            remove_docker_compose
        fi
    fi
    Show 2 "开始下载docker-compose"
    # sudo curl -L "$docker_compose_url" -o /usr/local/bin/docker-compose
    sudo wget -q --show-progress "$docker_compose_url" -O /usr/local/bin/docker-compose
    if sudo chmod +x /usr/local/bin/docker-compose; then
        Show 0 "安装docker-compose成功"
        Show 2 "安装docker-compose版本:"
        sudo docker-compose --version
    else
        Show 1 "安装docker-compose失败"
    fi
}

# 卸载Docker-compose
remove_docker_compose() {
    Show 2 "卸载docker-compose开始"
    sudo rm -rf /usr/local/bin/docker-compose
    action "卸载docker-compose成功" "卸载docker-compose失败"
}

# 检查 docker compose 命令
check_docker_compose() {
    Show 2 "检查docker compose命令是否存在"
    if docker compose >/dev/null 2>&1; then
        Show 0 "docker compose命令存在"
        COMPOSE_CMD=(docker compose)
        # 检查docker-compose命令是否存在
    elif command -v docker-compose >/dev/null 2>&1; then
        Show 0 "docker-compose命令存在"
        COMPOSE_CMD=(docker-compose)
    else
        Show 2 "docker-compose命令不存在"
        # 安装docker-compose
        install_docker_compose
        COMPOSE_CMD=(docker-compose)
    fi
}

# 配置vulfocus
config_vulfocus() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Vulfocus"
    echo "2. 卸载 Vulfocus"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Vulfocus)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice

    case $choice in
        1) install_vulfocus ;;
        2) remove_vulfocus ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装vulfocus
install_vulfocus() {
    check_docker
    Show 2 "开始安装vulfocus"
    read -r -p "$(echo -e "${YELLOW}输入启动vulfocus的主机地址: ${NC}")" host_ip

    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    # 安装vulfocus
    Show 2 "开始拉取vulfocus镜像"
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/vulfocus:latest
    action "拉取vulfocus镜像成功" "拉取vulfocus镜像失败"

    Show 2 "开始启动vulfocus"
    sudo docker run -d -p 88:80 --name vulfocus --restart always -v /var/run/docker.sock:/var/run/docker.sock -e VUL_IP="${host_ip}" registry.cn-hangzhou.aliyuncs.com/mingy123/vulfocus:latest
    action "启动vulfocus成功" "启动vulfocus失败"

    # 打印访问信息
    Show 0 "访问地址: http://${host_ip}:88"
    Show 0 "默认用户: admin"
    Show 0 "默认密码: admin"
}

# 卸载vulfocus
remove_vulfocus() {
    Show 2 "开始卸载vulfocus"
    Show 2 "停止vulfocus"
    sudo docker stop vulfocus
    Show 2 "删除vulfocus"
    sudo docker rm vulfocus
    Show 0 "卸载vulfocus完成"
}

# 配置ARL
config_arl() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 ARL"
    echo "2. 停止 ARL"
    echo "3. 启动 ARL"
    echo "4. 卸载 ARL"
    echo "5. 添加指纹"
    echo "6. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置ARL)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice

    case $choice in
        1) install_arl ;;
        2) stop_arl ;;
        3) start_arl ;;
        4) remove_arl ;;
        5) add_fingerprint_to_arl ;;
        6) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装灯塔ARL
install_arl() {
    check_docker
    Show 2 "开始安装灯塔ARL" 
    read -r -p "$(echo -e "${YELLOW}输入启动灯塔ARL的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    Show 2 "创建docker_arl目录"
    sudo mkdir -p /opt/docker_arl
    Show 2 "创建arl_db卷"
    sudo docker volume create arl_db

    # 获取最新版本的 ARL 下载链接并下载
    # sudo curl -Ls "https://gitee.com/yijingsec/ARL/releases/download/$(curl -s https://gitee.com/api/v5/repos/yijingsec/ARL/releases/latest | grep -E -o '\"tag_name\":\"([^\"]+)\"' | awk -F\" '{print $4}')/docker.zip" -o /opt/docker_arl/docker.zip && cd /opt/docker_arl && unzip -o docker.zip

    local latest_tag_name
    latest_tag_name=$(curl -s https://gitee.com/api/v5/repos/yijingsec/ARL/releases/latest | grep -E -o '"tag_name":"([^\"]+)"' | awk -F\" '{print $4}')
    Show 0 "发现最新版本ARL: ${latest_tag_name}"
    Show 2 "开始下载ARL压缩包..."
    local download_url="https://gitee.com/yijingsec/ARL/releases/download/${latest_tag_name}/docker.zip"
    curl -Ls "${download_url}" -o /opt/docker_arl/docker.zip
    action "下载ARL压缩包成功" "下载ARL压缩包失败"

    Show 2 "开始解压ARL压缩包"
    cd /opt/docker_arl
    unzip -o docker.zip

    check_docker_compose

    Show 2 "开始启动ARL服务"
    # 检查命令是否成功执行
    if sudo "${COMPOSE_CMD[@]}" up -d; then
        Show 0 "成功启动ARL服务"
        Show 0 "访问地址: https://${host_ip}:5003"
        Show 0 "默认用户: admin"
        Show 0 "默认密码: arlpass"
    else
        Show 1 "启动ARL服务失败, 请重试"
    fi
}

# 停止灯塔ARL
stop_arl() {
    Show 2 "停止灯塔ARL开始"
    check_docker_compose
    cd /opt/docker_arl
    if sudo "${COMPOSE_CMD[@]}" ps | grep arl_ | grep Up >/dev/null 2>&1; then
        sudo "${COMPOSE_CMD[@]}" stop
        Show 0 "停止灯塔ARL完成"
    else
        Show 2 "灯塔ARL服务已停止"
    fi
}

# 启动灯塔ARL
start_arl() {
    Show 2 "启动灯塔ARL开始"
    read -r -p "$(echo -e "${YELLOW}输入启动灯塔ARL的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    check_docker_compose

    Show 2 "启动灯塔ARL服务"
    cd /opt/docker_arl
    
    if sudo "${COMPOSE_CMD[@]}" ps -a | grep arl_ | grep Exited >/dev/null 2>&1; then
        if sudo "${COMPOSE_CMD[@]}" up -d; then
            Show 0 "启动灯塔ARL成功"
            Show 0 "访问地址: https://${host_ip}:5003"
            Show 0 "默认用户: admin"
            Show 0 "默认密码: arlpass"
        else
            Show 1 "启动灯塔ARL失败, 请重试"
        fi
    else
        Show 0 "灯塔ARL服务已经启动"
    fi
}

# 卸载灯塔ARL
remove_arl() {
    Show 2 "开始卸载ARL"

    check_docker_compose

    Show 2 "停止灯塔ARL服务"
    cd /opt/docker_arl
    sudo "${COMPOSE_CMD[@]}" down
    Show 2 "删除arl_db卷"
    sudo docker volume rm arl_db
    Show 2 "删除docker_arl目录"
    cd ~
    sudo rm -rf /opt/docker_arl
    read -r -p "是否删除ARL镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/arl:latest
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/rabbitmq:3.8.19-management-alpine
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/mongo:4.0.27
        Show 0 "删除ARL镜像成功"
    fi
    echo "卸载ARL完成"
}

# 给ARL添加指纹
add_fingerprint_to_arl() {
    Show 2 "开始给ARL添加指纹"
    read -r -p "$(echo -e "${YELLOW}请输入ARL的IP地址: ${NC}")" arl_ip
    if [ -z "${arl_ip}" ]; then
        Show 1 "请输入正确的ARL_IP地址"
    fi
    read -r -p "$(echo -e "${YELLOW}请输入ARL的密码: ${NC}")" arl_pass
    if [ -z "${arl_pass}" ]; then
        Show 1 "请输入正确的ARL密码"
    fi
    # 如果存在ARL-Finger-ADD目录则删除
    if [ -d "/opt/docker_arl/ARL-Finger-ADD" ]; then
        rm -rf /opt/docker_arl/ARL-Finger-ADD
    fi
    Show 2 "开始克隆ARL-Finger-ADD项目"
    git clone https://gitee.com/yijingsec/ARL-Finger-ADD.git /opt/docker_arl/ARL-Finger-ADD
    cd /opt/docker_arl/ARL-Finger-ADD
    Show 2 "开始添加指纹"
    if command -v python3 &>/dev/null; then
        python3 ARL-Finger-ADD.py "https://${arl_ip}:5003/" admin "${arl_pass}"
    elif command -v python &>/dev/null; then
        python ARL-Finger-ADD.py "https://${arl_ip}:5003/" admin "${arl_pass}"
    else
        Show 1 "Python3未安装, 请先安装Python3"
    fi
    Show 2 "添加指纹完成"
}

# 配置Metasploit-framework
config_metasploit() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Metasploit-framework"
    echo "2. 卸载 Metasploit-framework"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Metasploit-framework)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice

    case $choice in
        1) install_metasploit ;;
        2) remove_metasploit ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装Metasploit-framework
install_metasploit() {
    Show 2 "开始安装 Metasploit-framework"
    if [[ "$(lsb_release -is)" == "Ubuntu" ]]; then
        Show 2 "当前系统为 Ubuntu"
        Show 2 "下载 Metasploit-framework"
        wget -q --show-progress https://gitee.com/yijingsec/metasploit-omnibus/raw/master/config/templates/metasploit-framework-wrappers/msfupdate.erb -O msfinstall && chmod 755 msfinstall
        action "下载Metasploit安装脚本完成" "下载Metasploit安装脚本失败"

        Show 2 "安装 Metasploit-framework"
        ./msfinstall > /dev/null
        action "安装 Metasploit-framework 完成" "安装 Metasploit-framework 失败"
    elif [[ "$(lsb_release -is)" == "Kali" ]]; then
        Show 2 "当前系统为 Kali"
        Show 2 "配置 Kali APT 源"
        sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list > /dev/null
        Show 2 "导入 Kali APT 源的 GPG 公钥"
        wget -qO - https://archive.kali.org/archive-key.asc | sudo apt-key add -
        Show 2 "更新 APT 软件包列表"
        sudo apt-get update > /dev/null
        Show 2 "安装metasploit-framework"
        sudo apt-get install metasploit-framework -y > /dev/null
        action "安装Metasploit-framework完成" "安装Metasploit-framework失败"
    else
        Show 1 "脚本不适用当前系统, 无法安装Metasploit-framework"
    fi
    Show 2 "安装Metasploit版本: "
    msfconsole --version
}

# 卸载Metasploit-framework
remove_metasploit() {
    Show 2 "开始卸载Metasploit-framework"
    sudo apt-get remove metasploit-framework -y > /dev/null
    sudo rm -rf /usr/share/keyrings/metasploit-framework.gpg > /dev/null
    action "卸载Metasploit-framework完成" "卸载Metasploit-framework失败"
}

# 配置Viper
config_viper() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Viper"
    echo "2. 更新 Viper 版本"
    echo "3. 更新 Viper 密码"
    echo "4. 启动 Viper"
    echo "5. 关闭 Viper"
    echo "6. 卸载 Viper"
    echo "7. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Viper)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" choice
    case $choice in
        1) install_viper ;;
        2) update_viper_version ;;
        3) update_viper_password ;;
        4) start_viper ;;
        5) stop_viper ;;
        6) remove_viper ;;
        7) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装Viper
install_viper() {
    check_docker
    Show 2 "开始安装Viper"
    read -r -p "$(echo -e "${YELLOW}输入启动Viper的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    Show 2 "创建安装目录"
    mkdir -p /root/VIPER/nginxconfig && cd /root/VIPER && rm -f docker-compose.* > /dev/null 2>&1

    Show 2 "应用系统优化"

    # Network stack tuning
    sysctl -w net.ipv4.tcp_timestamps=0
    sysctl -w net.ipv4.tcp_tw_reuse=1
    sysctl -w net.ipv4.tcp_fin_timeout=3
    sysctl -w net.ipv4.tcp_keepalive_time=1800
    sysctl -w net.ipv4.tcp_rmem="4096 87380 8388608"
    sysctl -w net.ipv4.tcp_wmem="4096 87380 8388608"
    sysctl -w net.ipv4.tcp_max_syn_backlog=262144
    sysctl -w net.ipv4.ip_local_port_range="1024 65535"
    sysctl -w net.core.rmem_max=16777216
    sysctl -w net.core.wmem_max=16777216
    sysctl -w net.ipv4.tcp_window_scaling=0
    sysctl -w net.ipv4.tcp_sack=0
    sysctl -w net.core.netdev_max_backlog=30000
    sysctl -w net.ipv4.tcp_no_metrics_save=1
    sysctl -w net.core.somaxconn=262144
    sysctl -w net.ipv4.tcp_syncookies=0
    sysctl -w net.ipv4.tcp_max_orphans=262144
    sysctl -w net.ipv4.tcp_synack_retries=2
    sysctl -w net.ipv4.tcp_syn_retries=2

    # File descriptor limits
    echo "ulimit -HSn 65535" >> /etc/rc.local
    echo "ulimit -HSn 65535" >> /root/.bash_profile
    echo "ulimit -SHn 65535" >> /etc/profile
    ulimit -SHn 65535

    # Virtual memory settings
    sysctl -w vm.max_map_count=262144

    # Make rc.local executable if it exists
    [ -f /etc/rc.local ] && chmod +x /etc/rc.local

    Show 2 "系统优化完成"

    Show 2 "创建docker-compose.yml文件"
    tee docker-compose.yml <<-'EOF'
services:
  viper:
    image: registry.cn-shenzhen.aliyuncs.com/toys/viper:latest
    container_name: viper-c
    network_mode: "host"
    restart: always
    volumes:
      - /root/VIPER/loot:/root/.msf4/loot
      - /root/VIPER/db:/root/viper/Docker/db
      - /root/VIPER/module:/root/viper/Docker/module
      - /root/VIPER/log:/root/viper/Docker/log
      - /root/VIPER/nginxconfig:/root/viper/Docker/nginxconfig
    ulimits:
      nofile:
        soft: 65534
        hard: 65534
      nproc:
        soft: 65534
        hard: 65534
    command: ["VIPER_PASSWORD"]
EOF

    read -r -p "$(echo -e "${YELLOW}输入VIPER密码: ${NC}")" VIPER_PASSWORD
    sed -i "s/VIPER_PASSWORD/${VIPER_PASSWORD}/g" docker-compose.yml
    cd /root/VIPER
    check_docker_compose
    sudo "${COMPOSE_CMD[@]}" up -d
    Show 2 "正在等待系统启动"
    sleep 15
    Show 0 "访问地址: https://${host_ip}:60000 登录到服务器"
    Show 0 "用户名: root"
    Show 0 "密  码: ${VIPER_PASSWORD}"
    Show 0 "安装Viper完成"
}

# 更新Viper版本
update_viper_version() {
    Show 2 "开始更新Viper"
    check_docker_compose
    Show 2 "移除所有容器"
    cd /root/VIPER
    sudo "${COMPOSE_CMD[@]}" down
    Show 2 "删除数据文件"
    rm -rf ./db/*
    rm -f ./module/*
    Show 2 "拉取最新镜像"
    sudo "${COMPOSE_CMD[@]}" pull
    Show 2 "启动容器"
    sudo "${COMPOSE_CMD[@]}" up -d
    Show 0 "更新Viper完成"
}

# 更新Viper密码
update_viper_password() {
    Show 2 "开始更新Viper密码"
    cd /root/VIPER
    read -r -p "$(echo -e "${YELLOW}输入VIPER密码: ${NC}")" VIPER_PASSWORD
    Show 2 "更新docker-compose.yml文件"
    sed -i "s/VIPER_PASSWORD/${VIPER_PASSWORD}/g" docker-compose.yml
    check_docker_compose
    Show 2 "更新Viper容器"
    sudo "${COMPOSE_CMD[@]}" down
    sudo "${COMPOSE_CMD[@]}" up -d
    Show 0 "更新Viper密码完成"
}

# 启动Viper
start_viper() {
    Show 2 "开始启动Viper"
    cd /root/VIPER
    check_docker_compose
    sudo "${COMPOSE_CMD[@]}" start
    Show 0 "启动Viper完成"
}

# 关闭Viper
stop_viper() {
    Show 2 "开始关闭Viper"
    cd /root/VIPER
    check_docker_compose
    sudo "${COMPOSE_CMD[@]}" stop
    Show 0 "关闭Viper完成"
}

# 卸载Viper
remove_viper() {
    Show 2 "开始卸载Viper"
    cd /root/VIPER
    check_docker_compose
    Show 2 "删除Viper容器"
    sudo "${COMPOSE_CMD[@]}" down
    Show 2 "删除Viper目录"
    cd ~ && sudo rm -rf /root/VIPER
    Show 0 "卸载Viper完成"
}

# 配置Empire
config_empire() {
    echo "请选择操作: "
    echo "1. 安装 Empire"
    echo "2. 更新 Empire"
    echo "3. 关闭 Empire"
    echo "4. 启动 Empire"
    echo "5. 卸载 Empire"
    echo "6. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Empire)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice
    case $choice in
        1) install_empire ;;
        2) update_empire ;;
        3) stop_empire ;;
        4) start_empire ;;
        5) remove_empire ;;
        6) echo "返回主菜单" ;;
        *) echo "无效的选择" ;;
    esac
}

# 安装empire
install_empire() {
    Show 2 "开始安装Empire"
    check_docker
    read -r -p "$(echo -e "${YELLOW}输入启动Empire的主机地址: ${NC}")" host_ip
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    Show 2 "开始拉取Empire镜像"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    action "Empire镜像拉取完毕" "Empire镜像拉取失败"

    docker run -d --name ps-empire -p 6000-6010:6000-6010 -p 1337:1337 -p 5000:5000 registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    action "Empire容器启动完毕" "Empire容器启动失败"

    Show 0 "服务端: http://${host_ip}:1337"
    Show 0 "用户名: empireadmin"
    Show 0 "密  码: password123"
}

# 更新Empire
update_empire() {
    Show 2 "开始更新Empire"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    action "Empire镜像更新完毕" "Empire镜像更新失败"
    Show 2 "更新Empire容器"
    docker stop ps-empire
    docker rm ps-empire -f
    Show 0 "完成Empire更新, 请启动Empire"
}

# 关闭Empire
stop_empire() {
    Show 2 "关闭Empire开始"
    docker stop ps-empire
    action "关闭Empire容器成功" "关闭Empire容器失败"
}

# 启动Empire
start_empire() {
    Show 2 "启动Empire开始"
    docker start ps-empire
    action "启动Empire容器成功" "启动Empire容器失败"
}

# 卸载Empire‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭
remove_empire() {
    Show 2 "卸载Empire开始"
    docker stop ps-empire
    docker rm ps-empire -f
    Show 2 "删除Empire容器完成"
    read -r -p "是否要删除镜像? (y/n) " yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
        Show 0 "删除Empire镜像完成"
    fi
    Show 0 "卸载Empire完成"
}

# 配置 Starkiller‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭
config_starkiller() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Starkiller"
    echo "2. 更新 Starkiller"
    echo "3. 关闭 Starkiller"
    echo "4. 启动 Starkiller"
    echo "5. 卸载 Starkiller"
    echo "6. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Starkiller)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice
    case $choice in
        1) install_starkiller ;;
        2) update_starkiller ;;
        3) stop_starkiller ;;
        4) start_starkiller ;;
        5) remove_starkiller ;;
        6) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装 Starkiller
install_starkiller() {
    check_docker
    Show 2 "安装Starkiller开始‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
    read -r -p "$(echo -e "${YELLOW}输入启动Starkiller的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    Show 2 "开始拉取Starkiller镜像‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
    action "拉取Starkiller镜像完毕" "拉取Starkiller镜像失败"

    Show 2 "启动Starkiller容器"
    docker run -d --name ps-starkiller -p 4173:4173 registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
    action "启动Starkiller容器成功" "启动Starkiller容器失败"

    Show 2 "启动Starkiller完成"
    Show 0 "服务地址: http://${host_ip}:4173"
    Show 0 "默认用户: empireadmin"
    Show 0 "默认密码: password123"
}

# 更新 Starkiller
update_starkiller() {
    Show 2 "更新Starkiller开始"
    Show 2 "开始拉取最新Starkiller镜像‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
    
    if docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest; then
        Show 0 "拉取最新Starkiller镜像成功"
        Show 0 "更新Starkiller成功,请启动Starkiller"
    else
        Show 2 "拉取最新Starkiller镜像失败"
        Show 1 "更新Starkiller失败"
    fi
}

# 关闭 Starkiller
stop_starkiller() {
    Show 2 "关闭Starkiller开始"
    docker stop ps-starkiller > /dev/null
    action "关闭Starkiller完成" "关闭Starkiller失败"
}

# 启动 Starkiller
start_starkiller() {
    Show 2 "检测Starkiller是否启动"
    # 检查ps-starkiller容器是否已经启动
    if docker ps --format "{{.Names}}" | grep 'ps-starkiller' > /dev/null; then
        Show 0 "Starkiller已经启动"
    else
        Show 0 "Starkiller未启动"
        Show 2 "启动Starkiller开始"
        # 提示用户输入主机地址
        read -r -p "$(echo -e "${YELLOW}输入启动Starkiller的主机地址: ${NC}")" host_ip
        # 检查是否输入了IP地址
        if [ -z "${host_ip}" ]; then
            Show 1 "请输入正确的IP地址"
        fi
        # 启动ps-starkiller容器
        if docker start ps-starkiller > /dev/null; then
            Show 0 "启动Starkiller完成"
            Show 0 "服务地址: http://${host_ip}:4173"
            Show 0 "默认用户: empireadmin"
            Show 0 "默认密码: password123"
        else
            Show 1 "启动Starkiller失败"
        fi
    fi
}

# 卸载 Starkiller
remove_starkiller() {
    Show 2 "卸载Starkiller开始"
    if docker rm ps-starkiller -f; then
        Show 0 "删除Starkiller容器完成"
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
            Show 0 "删除Starkiller镜像完成"
        else
            Show 1 "删除Starkiller镜像失败"
        fi
        Show 0 "卸载Starkiller完成"
    else
        Show 1 "卸载Starkiller失败"
    fi
}

# 配置 HFish
config_hfish() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 HFish‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
    echo "2. 更新 HFish"
    echo "3. 关闭 HFish"
    echo "4. 启动 HFish"
    echo "5. 卸载 HFish"
    echo "6. 获取数据库信息"
    echo "7. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置HFish)${NC} : ${GREEN}请输入序号(1-7) >> ${NC}")" choice
    case $choice in
        1) install_hfish ;;
        2) update_hfish ;;
        3) stop_hfish ;;
        4) start_hfish ;;
        5) remove_hfish ;;
        6) get_hfish_db_info ;;
        7) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装 HFish
install_hfish() {
    check_docker
    Show 2 "开始安装HFish"
    read -r -p "$(echo -e "${YELLOW}输入启动HFish的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    Show 2 "创建HFish目录"
    mkdir -p /opt/hfish && cd /opt/hfish && rm -f docker-compose.* > /dev/null 2>&1

    Show 2 "创建docker-compose.yml文件"
    tee docker-compose.yml <<-'EOF'
version: '3'
services:
  hfish:
    image: registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest
    container_name: hfish
    volumes:
      - /opt/hfish:/usr/share/hfish
    network_mode: host
    privileged: true
    # restart: always
    depends_on:
      - mysql
  mysql:
    container_name: mysql8
    image: registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0
    command: --default-authentication-plugin=mysql_native_password
    environment:
      - MYSQL_ROOT_PASSWORD=123456
EOF

    # read -r -p "输入MySQL数据库密码(回车默认为123456): " MYSQL_PASSWORD
    # sed -i "s/123456/${MYSQL_PASSWORD}/g" docker-compose.yml
    Show 2 "拉取HFish镜像并启动HFish容器"
    cd /opt/hfish
    check_docker_compose
    sudo "${COMPOSE_CMD[@]}" up -d
    Show 2 "正在等待HFish容器启动"
    sleep 3
    MySQL_IP=$(docker network inspect hfish_default | jq -r '.[].Containers | to_entries[] | select(.value.Name == "mysql8") | .value.IPv4Address' | awk -F/ '{print $1}')
    Show 0 "访问地址: https://${host_ip}:4433/web"
    Show 0 "用户名: admin"
    Show 0 "密  码: HFish"
    Show 0 "MySQL IP 地 址: ${MySQL_IP}"
    Show 0 "MySQL 端 口 号: 3306"
    Show 0 "MySQL 数据库名: hfish"
    Show 0 "MySQL 用 户 名: root"
    Show 0 "MySQL 密    码: HFish2021"
    Show 0 "安装HFish完成"
}

# 更新 HFish
update_hfish() {
    Show 2 "更新HFish开始"
    Show 2 "开始拉取最新HFish镜像"
    if docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest; then
        Show 0 "拉取最新HFish镜像成功‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
        Show 0 "更新HFish成功"
    else
        Show 2 "拉取最新HFish镜像失败"
        Show 1 "更新HFish失败"
    fi
}

# 关闭 HFish
stop_hfish() {
    Show 2 "停止HFish开始"
    cd /opt/hfish
    check_docker_compose
    sudo "${COMPOSE_CMD[@]}" stop
    action "停止HFish成功" "停止HFish失败"
}

# 启动 HFish
start_hfish() {
    Show 2 "启动HFish开始"
    read -r -p "$(echo -e "${YELLOW}输入启动HFish的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    cd /opt/hfish
    check_docker_compose
    if sudo "${COMPOSE_CMD[@]}" start; then
        Show 0 "启动HFish完成"
        Show 0 "访问地址: https://${host_ip}:4433/web 登录到服务器"
        Show 0 "用户名: admin"
        Show 0 "密  码: HFish2021"
    fi
}

# 卸载 HFish
remove_hfish() {
    Show 2 "卸载HFish开始"
    Show 2 "删除HFish容器"
    cd /opt/hfish
    check_docker_compose
    if sudo "${COMPOSE_CMD[@]}" down; then
        Show 0 "删除HFish容器完成"
        Show 2 "删除HFish目录"
        rm -rf /opt/hfish
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0
            Show 0 "删除HFish镜像完成"
        fi
        Show 0 "卸载HFish完成"
    else
        Show 1 "卸载HFish失败"
    fi
}

# 获取HFish数据库配置信息
get_hfish_db_info() {
    Show 2 "HFish数据库信息如下: "
    MySQL_IP=$(docker network inspect hfish_default | jq -r '.[].Containers | to_entries[] | select(.value.Name == "mysql8") | .value.IPv4Address' | awk -F/ '{print $1}')
    Show 0 "MySQL IP 地 址: ${MySQL_IP}"
    Show 0 "MySQL 端 口 号: 3306"
    Show 0 "MySQL 数据库名: hfish"
    Show 0 "MySQL 用 户 名: root"
    Show 0 "MySQL 密    码: HFish2021"
}

# 配置 Dnscat2
config_dnscat2() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Dnscat2"
    echo "2. 启动 Dnscat2 (直连模式)"
    echo "3. 启动 Dnscat2 (中继模式)"
    echo "4. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Dnscat2)${NC} : ${GREEN}请输入序号(1-4) >> ${NC}")" choice
    case $choice in
        1) install_dnscat2 ;;
        2) start_dnscat2_direct_mode ;;
        3) start_dnscat2_relay_mode ;;
        4) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装dnscat2
install_dnscat2() {
    check_docker
    Show 2 "开始安装Dnscat2"
    if docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07; then
        Show 0 "拉取最新Dnscat2镜像成功"
        Show 0 "安装Dnscat2成功, 请启动Dnscat2"
    else
        Show 2 "拉取最新Dnscat2镜像失败"
        Show 1 "安装Dnscat2失败"
    fi
}

# 启动dnscat2直连模式
start_dnscat2_direct_mode() {
    Show 2 "启动Dnscat2(直连模式)开始"
    docker run -it --name dnscat2 --rm -p 53:53/udp registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07 server
    action "启动Dnscat2(直连模式)成功" "启动Dnscat2(直连模式)失败"
}

# 启动Dnscat2中继模式
start_dnscat2_relay_mode() {
    Show 2 "启动Dnscat2(中继模式)开始"
    read -r -p "$(echo -e "${YELLOW}输入启动Dnscat2的子域名: ${NC}")" subdomain
    if [ -z "${subdomain}" ]; then
        Show 1 "请输入正确的子域名"
    fi
    docker run -it --name dnscat2 --rm -p 53:53/udp registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07 server "${subdomain}"
    action "启动Dnscat2(中继模式)完成" "启动Dnscat2(中继模式)失败"
}

# 配置Beef
config_beef() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Beef"
    echo "2. 关闭 Beef"
    echo "3. 启动 Beef"
    echo "4. 卸载 Beef"
    echo "5. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Beef)${NC} : ${GREEN}请输入序号(1-5) >> ${NC}")" choice

    case $choice in
        1) install_beef ;;
        2) stop_beef ;;
        3) start_beef ;;
        4) remove_beef ;;
        5) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装Beef
install_beef() {
    check_docker
    Show 2 "开始安装Beef"
    read -r -p "$(echo -e "${YELLOW}输入启动Beef的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    Show 2 "开始拉取最新Beef镜像"
    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest
    action "拉取最新Beef镜像成功" "拉取最新Beef镜像失败"

    Show 2 "启动Beef容器服务"
    if docker run -dit --name beef -p 3000:3000 registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest; then
        Show 0 "启动Beef容器服务成功"
        Show 0 "访问地址: http://${host_ip}:3000/ui/panel 登录到服务器"
        Show 0 "用户名: beef"
        Show 0 "密  码: yijingsec"
    else
        Show 1 "安装Beef失败"
    fi
}

# 关闭Beef
stop_beef() {
    Show 2 "关闭Beef开始"
    docker stop beef
    action "关闭Beef成功" "关闭Beef失败"
}

# 启动Beef
start_beef() {
    Show 2 "启动Beef开始"
    read -r -p "$(echo -e "${YELLOW}输入启动Beef的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    
    if docker start beef; then
        Show 0 "启动Beef成功"
        Show 0 "访问地址: http://${host_ip}:3000/ui/panel 登录到服务器"
        Show 0 "默认用户: beef"
        Show 0 "默认密码: yijingsec"
    else
        Show 1 "启动Beef失败"
    fi
}

# 卸载Beef
remove_beef() {
    Show 2 "卸载Beef开始"
    if docker rm beef -f; then
        Show 0 "删除Beef容器成功"
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest
            Show 0 "删除Beef镜像成功"
        fi
        Show 0 "卸载Beef成功"
    else
        Show 1 "卸载Beef失败"
    fi

}

# 配置Bluelotus
config_bluelotus() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 Bluelotus"
    echo "2. 关闭 Bluelotus"
    echo "3. 启动 Bluelotus"
    echo "4. 卸载 Bluelotus"
    echo "5. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置Bluelotus)${NC} : ${GREEN}请输入序号(1-5) >> ${NC}")" choice
    case $choice in
        1) install_bluelotus ;;
        2) stop_bluelotus ;;
        3) start_bluelotus ;;
        4) remove_bluelotus ;;
        5) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装 Bluelotus
install_bluelotus() {
    check_docker
    Show 2 "开始安装Bluelotus"
    read -r -p "$(echo -e "${YELLOW}输入启动Bluelotus的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    Show 2 "开始拉取最新Bluelotus镜像"
    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest
    action "拉取最新Bluelotus镜像成功" "拉取最新Bluelotus镜像失败"

    Show 2 "启动Bluelotus容器服务"
    
    if docker run -dit --name bluelotus -p 5080:80 registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest; then
        Show 0 "安装Bluelotus成功"
        Show 0 "访问地址: http://${host_ip}:5080/login.php 登录到服务器"
        Show 0 "默认密码: bluelotus"
    else
        Show 1 "安装Bluelotus失败"
    fi
}

# 关闭Bluelotus
stop_bluelotus() {
    Show 2 "关闭Bluelotus开始"
    docker stop bluelotus
    action "关闭Bluelotus成功" "关闭Bluelotus失败"
}

# 启动Bluelotus
start_bluelotus() {
    Show 2 "启动Bluelotus开始"
    read -r -p "$(echo -e "${YELLOW}输入启动Bluelotus的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi
    Show 2 "启动Bluelotus容器服务"
    if docker start bluelotus; then
        Show 0 "启动Bluelotus成功"
        Show 0 "访问地址: http://${host_ip}:5080/login.php 登录到服务器"
        Show 0 "默认密码: bluelotus"
    else
        Show 1 "启动Bluelotus失败"
    fi
}

# 卸载Bluelotus
remove_bluelotus() {
    Show 2 "卸载Bluelotus开始"
    if docker rm bluelotus -f; then
        Show 0 "删除Bluelotus容器成功"
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest
            Show 0 "删除Bluelotus镜像成功"
        fi
        Show 0 "卸载Bluelotus成功"
    else
        Show 1 "卸载Bluelotus失败"
    fi
}

# 配置CTFd
config_ctfd() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 CTFd"
    echo "2. 卸载 CTFd"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置CTFd)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice
    case $choice in
        1) install_ctfd ;;
        2) remove_ctfd ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装CTFd
install_ctfd() {
    check_docker
    Show 2 "开始安装CTFd"
    read -r -p "$(echo -e "${YELLOW}输入启动CTFd的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    read -r -p "$(echo -e "${YELLOW}输入启动CTFd的主机端口: ${NC}")" host_port
    if [ -z "${host_port}" ]; then
        Show 1 "请输入正确的端口号"
    fi
    Show 2 "拉取最新CTFd镜像"
    docker pull ctfd/ctfd
    action "拉取CTFd镜像成功" "拉取CTFd镜像失败"
    Show 2 "启动CTFd容器服务"
    docker run --name ctfd -dit -p "${host_port}:8000" ctfd/ctfd
    Show 0 "访问地址: http://${host_ip}:${host_port}"
}

# 卸载CTFd
remove_ctfd() {
    Show 2 "开始卸载CTFd"
    docker rm ctfd -f
    action "删除CTFd容器成功" "删除CTFd容器失败, 请检查容器是否存在"

    read -r -p "是否要删除镜像? (y/n) " yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi ctfd/ctfd
        Show 0 "删除镜像成功"
    fi
    Show 0 "卸载CTFd完成"
}

# 配置AWVS
config_awvs() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 AWVS"
    echo "2. 卸载 AWVS"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置AWVS)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice
    case $choice in
        1) install_awvs ;;
        2) remove_awvs ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装AWVS
install_awvs() {
    check_docker
    Show 2 "开始安装AWVS"
    read -r -p "$(echo -e "${YELLOW}输入启动AWVS的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        Show 1 "请输入正确的IP地址"
    fi

    read -r -p "$(echo -e "${YELLOW}输入启动AWVS的主机端口: ${NC}")" host_port
    if [ -z "${host_port}" ]; then
        Show 1 "请输入正确的端口号"
    fi
    Show 2 "拉取最新AWVS镜像"
    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
    action "拉取AWVS镜像成功" "拉取AWVS镜像失败"

    Show 2 "启动AWVS容器服务"
    docker run -dit -p "${host_port}:3443" --name yijingsec-awvs --cap-add LINUX_IMMUTABLE registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
    while true; do
        sleep 3
        
        if docker ps | grep "yijingsec-awvs" > /dev/null 2>&1; then
            Show 0 "容器启动成功"
            break
        fi
    done
    Show 0 "访问地址: https://${host_ip}:${host_port}"
    Show 0 "默认用户: admin@admin.com"
    Show 0 "默认密码: Admin123"
}

# 卸载AWVS
remove_awvs() {
    Show 2 "开始卸载AWVS"
    Show 2 "删除AWVS容器"
    if docker rm yijingsec-awvs -f; then
        Show 0 "删除AWVS容器成功"
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
        fi
    else
        Show 1 "删除AWVS容器失败, 请检查容器是否启动"
    fi
    Show 0 "卸载AWVS完成"
}

# 配置ocr_api_server
config_ocr_api_server() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 ocr_api_server"
    echo "2. 卸载 ocr_api_server"
    echo "3. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置ocr_api_server)${NC} : ${GREEN}请输入序号(1-3) >> ${NC}")" choice
    case $choice in
        1) install_ocr_api_server ;;
        2) remove_ocr_api_server ;;
        3) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装ocr_api_server
install_ocr_api_server() {
    check_docker
    Show 2 "开始安装ocr_api_server"
    # 接收用户输入作为host_ip
    read -r -p "$(echo -e "${YELLOW}输入启动ocr_api_server的主机地址: ${NC}")" host_ip
    # 检查是否输入了IP地址
    if validate_ip "$host_ip"; then
        Show 0 "你的IP地址为: ${host_ip}"
    else
        return 1
    fi

    # 安装ocr_api_server
    Show 2 "拉取最新ocr_api_server镜像"
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/ocr_api_server:latest
    action "拉取ocr_api_server镜像成功" "拉取ocr_api_server镜像失败"

    Show 2 "启动ocr_api_server容器服务"
    sudo docker run -d -p 9898:9898 --name ocr_api_server registry.cn-hangzhou.aliyuncs.com/mingy123/ocr_api_server:latest
    action "启动ocr_api_server容器服务成功" "启动ocr_api_server容器服务失败"

    sleep 5

    # 打印访问信息
    Show 0 "ocr_api_server 服务已启动"
    Show 0 "访问地址: http://${host_ip}:9898/ping"
    Show 3 "访问后响应 pong, 表明服务启动成功"
}

# 卸载ocr_api_server
remove_ocr_api_server() {
    Show 2 "开始卸载ocr_api_server"
    Show 2 "删除ocr_api_server容器"
    if sudo docker rm -f ocr_api_server; then
        Show 0 "删除ocr_api_server容器成功"
        read -r -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/ocr_api_server:latest
            Show 0 "删除镜像成功"
        fi
    else
        Show 1 "删除容器失败"
    fi
    Show 0 "卸载ocr_api_server完成"
}

# 配置oh-my-zsh
config_ohmyzsh() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 oh-my-zsh"
    echo "2. 更新 oh-my-zsh"
    echo "3. 卸载 oh-my-zsh"
    echo "4. 配置 oh-my-zsh 主题"
    echo "5. 配置 oh-my-zsh 插件"
    echo "6. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置oh-my-zsh)${NC} : ${GREEN}请输入序号(1-6) >> ${NC}")" choice
    case $choice in
        1) install_ohmyzsh ;;
        2) update_ohmyzsh ;;
        3) uninstall_ohmyzsh ;;
        4) config_ohmyzsh_theme ;;
        5) config_ohmyzsh_plugin ;;
        6) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装oh-my-zsh
install_ohmyzsh() {
    Show 2 "安装oh-my-zsh开始"
    if command -v git >/dev/null && command -v zsh >/dev/null; then
        Show 0 "git和zsh已安装"
    else
        Show 2 "安装git和zsh"
        apt-get install -y git zsh >/dev/null
        action "git和zsh安装成功" "git和zsh安装失败"
    fi

    Show 2 "安装oh-my-zsh"
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        Show 2 "oh-my-zsh未安装, 正在安装..."
        # sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        # sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

        # 下载安装脚本
        if [ -f "install.sh" ]; then
            Show 0 "install.sh文件已存在"
        else
            Show 0 "install.sh文件不存在, 正在下载..."
            wget -q --show-progress https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh
        fi

        # 替换默认的 GitHub 源为 Gitee
        sed -i "s|REPO=${REPO:-ohmyzsh/ohmyzsh}|REPO=${REPO:-mirrors/oh-my-zsh}|" install.sh
        sed -i "s|REMOTE=${REMOTE:-https://github.com/${REPO}.git}|REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}|" install.sh
        sh install.sh
        Show 0 "安装oh-my-zsh成功"
    else
        Show 0 "oh-my-zsh已安装"
    fi
}

# 配置oh-my-zsh主题
config_ohmyzsh_theme() {
    Show 2 "开始配置oh-my-zsh主题"
    Show 2 "设置oh-my-zsh主题为ys"
    sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="ys"|g' "${HOME}/.zshrc"

    Show 2 "设置oh-my-zsh主题ys的提示符"
    # sed -i 's|%(#,%{\$bg\[yellow\]%}%{\$fg\[black\]%}%n%{\$reset_color%},%{\$fg\[cyan\]%}%n) \\|%(#,%{\$fg\[red\]%}%n%{\$reset_color%},%{\$fg\[cyan\]%}%n) \\|g' "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
    # sed -i 's|%{$reset_color%}in \\|%{$fg[blue]%}✅ \\|g' "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
    
    sed -i "s|%(#,%{\\\$bg\[yellow\]%}%{\\\$fg\[black\]%}%n%{\\\$reset_color%},%{\\\$fg\[cyan\]%}%n) \\\\|%(#,%{\\\$fg\[red\]%}%n%{\\\$reset_color%},%{\\\$fg\[cyan\]%}%n) \\\\|g" "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
    sed -i "s|%{\\\$reset_color%}in \\\\|%{\\\$fg\[blue\]%}✅ \\\\|g" "${HOME}/.oh-my-zsh/themes/ys.zsh-theme"
    Show 0 "oh-my-zsh主题配置完成"
}

# 配置 oh-my-zsh 插件
config_ohmyzsh_plugin() {
    Show 2 "开始配置 oh-my-zsh 插件"
    Show 2 "安装oh-my-zsh插件zsh-syntax-highlighting"

    local syntax_highlighting_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    if [ -d "$syntax_highlighting_dir" ]; then
        if [ "$(ls -A "$syntax_highlighting_dir")" ]; then
            Show 0 "zsh-syntax-highlighting 目录已存在且不为空，跳过安装"
        else
            Show 0 "zsh-syntax-highlighting 目录已存在且为空，正在安装..."
            git clone https://gitee.com/yijingsec/zsh-syntax-highlighting.git "$syntax_highlighting_dir"
        fi
    else
        Show 2 "zsh-syntax-highlighting 未安装，正在安装..."
        git clone https://gitee.com/yijingsec/zsh-syntax-highlighting.git "$syntax_highlighting_dir"
    fi

    Show 2 "安装oh-my-zsh插件zsh-autosuggestions"
    # 安装 oh-my-zsh 插件 zsh-autosuggestions
    local autosuggestions_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    if [ -d "$autosuggestions_dir" ]; then
        if [ "$(ls -A "$autosuggestions_dir")" ]; then
            Show 0 "zsh-autosuggestions 目录已存在且不为空，跳过安装"
        else
            Show 0 "zsh-autosuggestions 目录已存在且为空，正在安装..."
            git clone https://gitee.com/yijingsec/zsh-autosuggestions.git "$autosuggestions_dir"
        fi
    else
        Show 2 "zsh-autosuggestions 未安装，正在安装..."
        git clone https://gitee.com/yijingsec/zsh-autosuggestions "$autosuggestions_dir"
    fi

    Show 2 "启用 oh-my-zsh 插件"
    sed -i 's|plugins=(git)|plugins=(git zsh-syntax-highlighting zsh-autosuggestions)|g' "${HOME}/.zshrc"

    Show 2 "配置 oh-my-zsh 完成"
}

# 更新oh-my-zsh
update_ohmyzsh() {
    Show 2 "更新oh-my-zsh开始"
    zsh -c "source ~/.zshrc;omz update"
    Show 2 "更新oh-my-zsh完成"
}

# 卸载oh-my-zsh
uninstall_ohmyzsh() {
    Show 2 "卸载oh-my-zsh开始"
    zsh -c "source ~/.zshrc;uninstall_oh_my_zsh"
    Show 2 "卸载oh-my-zsh完成"
}

# 配置crAPI靶场
config_crAPI() {
    echo -e "${YELLOW}[+] 请选择操作: ${NC}"
    echo "1. 安装 crAPI 靶场"
    echo "2. 卸载 crAPI 靶场"
    echo "3. 停止 crAPI 靶场"
    echo "4. 启动 crAPI 靶场"
    echo "5. 返回主菜单"
    read -r -p "$(echo -e "${RED}(配置crAPI)${NC} : ${GREEN}请输入序号(1-5) >> ${NC}")" choice
    case $choice in
        1) install_crapi ;;
        2) uninstall_crapi ;;
        3) stop_crapi ;;
        4) start_crapi ;;
        5) Show 2 "返回主菜单" ;;
        *) Show 2 "无效的选择" ;;
    esac
}

# 安装crAPI靶场
install_crapi() {
    check_docker
    Show 2 "开始安装crAPI靶场"
    # 安装crAPI靶场
    Show 2 "获取crAPI靶场docker-compose.yml文件"
    sudo mkdir -p crAPI
    sudo wget -q --show-progress https://gitee.com/yijingsec/crAPI/releases/download/v1.1.5/docker-compose.yml -O crAPI/docker-compose.yml
    action "获取crAPI靶场docker-compose.yml文件成功" "获取crAPI靶场docker-compose.yml文件失败"

    Show 2 "开始安装crAPI靶场"
    sudo docker compose -f crAPI/docker-compose.yml up -d

    Show 2 "等待crAPI靶场启动"
    sleep 5
    Show 2 "检查crAPI靶场是否启动成功"

    # 检查crapi靶场容器状态是否都为running
    containers_status=$(sudo docker compose -f crAPI/docker-compose.yml ps --format "{{.Name}}:{{.State}}")
    all_up=true
    exited_containers=()

    while IFS=: read -r name status; do
        if [[ "$status" = "running" ]]; then
            all_up=true
            Show 2 "容器 $name 状态: $status"
        elif [[ "$status" == "exited" ]]; then
            exited_containers+=("$name")
            all_up=false
            Show 2 "容器 $name 状态: $status"
        fi
    done <<< "$containers_status"

    if $all_up; then
        Show 0 "crAPI靶场安装成功, 所有容器均已启动"
    else
        if [ ${#exited_containers[@]} -gt 0 ]; then
            Show 2 "错误: 以下容器已退出:"
            for container in "${exited_containers[@]}"; do
                echo "- $container"
            done
            Show 2 "请检查日志以获取更多信息"
            exit 1
        else
            Show 2 "错误: 部分容器未成功启动"
            exit 1
        fi
    fi
}

# 卸载crAPI靶场
uninstall_crapi() {
    Show 2 "开始卸载crAPI靶场"
    if  [ ! -d "crAPI" ]; then
        Show 1 "crAPI靶场目录不存在, 请先安装crAPI靶场"
    fi
    sudo docker compose -f crAPI/docker-compose.yml down
    action "卸载crAPI靶场成功" "卸载crAPI靶场失败"
    Show 2 "删除crAPI靶场目录"
    sudo rm -rf crAPI
}

# 停止crAPI靶场
stop_crapi() {
    Show 2 "停止crAPI靶场"
    if  [ ! -d "crAPI" ]; then
        Show 1 "crAPI靶场目录不存在, 请先安装crAPI靶场"
    fi
    sudo docker compose -f crAPI/docker-compose.yml stop
    action "停止crAPI靶场成功" "停止crAPI靶场失败"
}

# 启动crAPI靶场
start_crapi() {
    Show 2 "启动crAPI靶场"
    if  [ ! -d "crAPI" ]; then
        Show 1 "crAPI靶场目录不存在, 请先安装crAPI靶场"
    fi
    sudo docker compose -f crAPI/docker-compose.yml up -d
    action "启动crAPI靶场成功" "启动crAPI靶场失败"
}

# 显示菜单
show_menu() {
    clear
    YELLOW="\e[33m"
    NO_COLOR="\e[0m"

    echo -e "${GREEN_LINE}"
    echo '
    *************‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭LinuxEnvConfig‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭*************
‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭
    适配系统: Ubuntu / Debian / Kali (基于Debian)
    脚本作用: Linux 基础环境配置
‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭
                --- Made by mingy ---
    '
    echo -e "${GREEN_LINE}"
    echo -e "${YELLOW}[+] 请选择操作 >>> ${NC}"

    # 特殊处理的项数组
    special_items=("")
    for i in "${!menu_options[@]}"; do
        if [[ ${special_items[*]} =~ ${menu_options[i]} ]]; then
            # 如果当前项在特殊处理项数组中，使用特殊颜色
            echo -e "$((i + 1)). ${aCOLOUR[7]}${menu_options[i]}${NO_COLOR}"
        else
            # 否则，使用普通格式
            echo "$((i + 1)). ${menu_options[i]}"
        fi
    done
}

# 处理用户选择
handle_choice() {
    local choice=$1
    # 检查输入是否为空
    if [[ -z $choice ]]; then
        echo -e "${RED}输入不能为空，请重新选择。${NC}"
        return
    fi

    # 检查输入是否为数字
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效数字!${NC}"
        return
    fi

    # 检查数字是否在有效范围内
    if [[ $choice -lt 1 ]] || [[ $choice -gt ${#menu_options[@]} ]]; then
        echo -e "${RED}选项超出范围!${NC}"
        echo -e "${YELLOW}请输入 1 到 ${#menu_options[@]} 之间的数字。${NC}"
        return
    fi

    # 执行命令
    if [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo -e "${RED}无效选项，请重新选择。${NC}"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}

# 安装项目依赖的基础工具
install_project_dependencies() {
    Show 2 "检查项目依赖的基础工具"
    
    # 定义必需的基础工具列表
    local required_tools="git curl wget jq unzip"
    local missing_tools=""
    
    # 检查哪些工具未安装
    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools="$missing_tools $tool"
        fi
    done
    
    # 如果所有工具都已安装，直接返回
    if [ -z "$missing_tools" ]; then
        Show 2 "项目依赖工具已全部安装"
        return 0
    fi
    
    Show 2 "正在安装缺失的工具:$missing_tools"
    sudo apt update -y
    sudo apt install -y $missing_tools
    action "项目依赖工具安装完成" "项目依赖工具安装失败"
}

# 检查网络连接状态
check_network_connection() {
    # 第一步：检查基础网络连通性（ping IP）
    if ! ping -c 1 -W 3 223.6.6.6 >/dev/null 2>&1; then
        # 直接使用echo显示FAILED消息，避免调用Show 1导致退出
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 网络连接失败，无法访问外网"
        Show 2 "可能的原因："
        Show 2 "  - 网络线缆未连接"
        Show 2 "  - WiFi 未连接"
        Show 2 "  - 防火墙阻止连接"
        Show 2 "  - 代理设置错误"
        return 1
    else
        Show 2 "网络连通性正常"
    fi

    # 第二步：检查DNS解析是否正常
    if ! nslookup baidu.com >/dev/null 2>&1 && ! dig baidu.com >/dev/null 2>&1; then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET 网络连通正常，但DNS解析失败"
        Show 2 "可能的原因："
        Show 2 "  - DNS服务器配置错误"
        Show 2 "  - DNS服务器不可达"
        Show 2 "  - /etc/resolv.conf 配置问题"
        Show 2 "开始使用脚本配置DNS服务器, 基础配置 -> 设置DNS名称服务器"
        config_nameserver
    else
        Show 2 "DNS解析正常"
    fi

    # 第三步：验证HTTP连接是否正常
    local failed_sites=()
    local success_sites=()
    local test_sites=(
        "https://www.baidu.com"
        "https://www.qq.com"
        "https://www.google.com"
        "https://github.com"
    )
    
    Show 2 "开始测试HTTP/HTTPS连接"
    
    for site in "${test_sites[@]}"; do
        if curl --connect-timeout 5 -s -L --head "$site" >/dev/null 2>&1; then
            success_sites+=("$site")
            Show 2 "✓ $site 连接成功"
        else
            failed_sites+=("$site")
            Show 2 "✗ $site 连接失败"
        fi
    done
    
    # 至少需要一个站点成功连接才认为网络正常
    if [ ${#success_sites[@]} -eq 0 ]; then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET HTTP连接异常 (0/${#test_sites[@]} 站点可达)"
        Show 2 "可能的原因："
        Show 2 "  - 防火墙阻止HTTP/HTTPS连接"
        Show 2 "  - 代理配置问题"
        Show 2 "  - 网络限速或QoS限制"
        Show 2 "  - SSL/TLS证书问题"
        Show 2 "  - 网站服务异常"
        
        if [ ${#failed_sites[@]} -gt 0 ]; then
            Show 2 "失败的站点："
            for failed_site in "${failed_sites[@]}"; do
                Show 2 "  - $failed_site"
            done
        fi
        return 1
    else
        Show 0 "HTTP连接正常 (${#success_sites[@]}/${#test_sites[@]} 站点可达)"
        if [ ${#failed_sites[@]} -gt 0 ]; then
            Show 2 "注意：部分站点不可达，可能是临时性问题"
        fi
    fi

    Show 0 "网络连接完全正常(网络连通性 + DNS解析 + HTTP访问)"
    return 0
}

# 项目更新检查
project_update_check() {
    # 设置Gitee仓库的URL
    REPO_URL="https://gitee.com/yijingsec/LinuxEnvConfig.git"

    # 获取远程仓库的最新提交
    REMOTE_LATEST=$(git ls-remote $REPO_URL HEAD | cut -f1)

    # 获取本地仓库的当前提交
    LOCAL_CURRENT=$(git rev-parse HEAD)

    Show 2 "${GREEN}开始项目更新检查${NC}"

    # 比较远程和本地的提交
    if [ "$REMOTE_LATEST" != "$LOCAL_CURRENT" ]; then
        Show 3 "$(Warn "检测到项目有更新")"
        Show 3 "$(Warn "远程仓库的最新提交为: $REMOTE_LATEST")"
        Show 3 "$(Warn "本地仓库的当前提交为: $LOCAL_CURRENT")"
        read -r -p "$(echo -e "${YELLOW}>>> 是否要更新到最新项目? (y/n) >>> ${NC}")" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            git restore .
            if git pull; then
                Show 0 "更新项目成功"
                Show 3 "按任意键继续..."
                read -r -n 1
            else
                Show 1 "更新项目失败，请重试"
            fi
        fi
    else
        Show 0 "项目已是最新版本"
    fi
}

update_kali_gpg_key() {
    # 如果系统为kali，则更新GPG密钥
    if grep -qEi "kali-rolling" /etc/os-release; then
        # 检查是否已存在GPG密钥
        if [ -f /usr/share/keyrings/kali-archive-keyring.gpg ] && [ -r /usr/share/keyrings/kali-archive-keyring.gpg ]; then
            # 获取密钥的哈希值
            key_hash=$(sha256sum /usr/share/keyrings/kali-archive-keyring.gpg | cut -d' ' -f1)
            if [ "$key_hash" == "42a247ff5a26869e3739b6d3ad125938bb5da8e7bb43ed0791d2a190cd09c64f" ]; then
                Show 2 "Kali GPG密钥已下载"
            else
                if sudo wget --no-check-certificate -q https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg; then
                    new_key_hash=$(sha256sum /usr/share/keyrings/kali-archive-keyring.gpg | cut -d' ' -f1)
                    if [ "$new_key_hash" == "42a247ff5a26869e3739b6d3ad125938bb5da8e7bb43ed0791d2a190cd09c64f" ]; then
                        Show 0 "下载Kali GPG密钥成功"
                    else
                        Show 1 "下载的Kali GPG密钥哈希值不匹配"
                        return 1
                    fi
                else
                    Show 1 "下载Kali GPG密钥失败"
                    return 1
                fi
            fi
        else
            if sudo wget --no-check-certificate -q https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg; then
                new_key_hash=$(sha256sum /usr/share/keyrings/kali-archive-keyring.gpg | cut -d' ' -f1)
                if [ "$new_key_hash" == "42a247ff5a26869e3739b6d3ad125938bb5da8e7bb43ed0791d2a190cd09c64f" ]; then
                    Show 0 "下载Kali GPG密钥成功"
                else
                    Show 1 "下载的Kali GPG密钥哈希值不匹配"
                    return 1
                fi
            else
                Show 1 "下载Kali GPG密钥失败"
                return 1
            fi
        fi
    fi
}


# 主程序入口
main() {
    # 检查是否为root用户
    if [ "$(id -u)" -ne 0 ]; then
        Show 1 "‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭请使用root用户或sudo运行此脚本"
        exit 1
    fi

    # 检查系统
    if ! grep -qEi "ubuntu|debian|kali" /etc/os-release; then
        Show 1 "本脚本仅适用于Ubuntu‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭/‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭Debian / Kali系统"
        exit 1
    fi

    # 检查网络连接（非强制）
    Show 2 "正在检查网络连接状态"
    if ! check_network_connection; then
        Show 3 "网络连接检查失败，但您可以继续使用脚本的其他功能"
        Show 2 "以下功能可能会受到影响：‭​‭‮‏⁭⁫‪⁥⁣⁫‮‎⁦​‮⁥‮⁫‬‏‮⁨⁣⁣⁢⁭⁤⁪⁣‮‪⁮⁠​‌⁭⁭​‫⁦⁮‍‮⁨⁫‎‏⁤⁮⁯‍⁪‮⁡⁯‎‪⁨⁪⁭‬​⁦​‬⁨‏⁨⁪‪⁡⁠⁪⁤⁣‎⁢⁥⁬⁪⁭⁣⁭⁦‍‏‭"
        Show 2 "  - 项目更新检查"
        Show 2 "  - APT软件包安装"
        Show 2 "  - 需要网络的工具配置"
        echo ""
        read -r -p "$(echo -e "${YELLOW}网络检查失败，是否仍要继续? (y/n) ${NC}")" continue_without_network
        if [[ ! $continue_without_network == "y" && ! $continue_without_network == "Y" ]]; then
            Show 2 "用户选择退出"
            exit 0
        fi
    else
        Show 0 "网络连接检查通过"
    fi

    echo ""
    Show 0 "=== 预配置选项（可选） ==="
    
    # APT源配置（可选）
    Show 0 "如果因为APT源无法更新从而导致脚本执行失败, 可尝试切换APT镜像源"
    read -r -p "$(echo -e "${GREEN}是否要切换APT镜像源? (y/n) ${NC}")" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        if config_apt_source; then
            Show 0 "APT源配置完成"
        else
            Show 1 "APT源配置失败, 您仍可继续使用脚本的其他功能"
        fi
    else
        Show 2 "跳过APT源配置"
    fi

    # 项目依赖工具安装（可选）
    read -r -p "$(echo -e "${GREEN}是否要安装项目依赖的基础工具? (y/n) ${NC}")" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        # 安装项目依赖的基础工具
        if install_project_dependencies; then
            Show 0 "项目依赖工具安装完成"
        else
            Show 1 "项目依赖工具安装失败，您仍可继续使用脚本"
        fi
    else
        Show 2 "跳过安装项目依赖的基础工具"
    fi

    # 项目更新检查（可选，需要网络）
    read -r -p "$(echo -e "${GREEN}是否要检查项目更新? (y/n) ${NC}")" check_update
    if [[ $check_update == "y" || $check_update == "Y" ]]; then
        if check_network_connection >/dev/null 2>&1; then
            project_update_check
        else
            Show 2 "网络不可用，跳过项目更新检查"
        fi
    else
        Show 2 "跳过项目更新检查"
    fi

    # 更新Kali GPG密钥（可选，需要网络）
    if grep -qi "kali" /etc/os-release; then
        read -r -p "$(echo -e "${GREEN}是否要更新Kali GPG密钥? (y/n) ${NC}")" update_gpg
        if [[ $update_gpg == "y" || $update_gpg == "Y" ]]; then
            if check_network_connection >/dev/null 2>&1; then
                update_kali_gpg_key
            else
                Show 2 "网络不可用, 跳过Kali GPG密钥更新"
            fi
        else
            Show 2 "跳过Kali GPG密钥更新"
        fi
    fi

    echo ""
    Show 0 "=== 预配置完成，进入主菜单 ==="
    read -r -n 1 -p "$(echo -e "${GREEN}按任意键继续...${NC}")"

    while true; do
        show_menu
        read -r -p "$(echo -e "${GREEN}>>> 请输入选项的序号(输入q退出) >>> ${NC}")" choice
        if [[ $choice == 'q' || $choice == 'Q' ]]; then
            break
        fi
        handle_choice "$choice"
        Show 3 "按任意键继续..."
        read -r -n 1
    done
}

main "$@"
