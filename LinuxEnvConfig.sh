#!/usr/bin/env bash

# author: mingy
# LinuxEnvConfig
# Ubuntu / Debian / Kali Linux 基础环境配置脚本

set -e
UNAME_M="$(uname -m)"
readonly UNAME_M

UNAME_U="$(uname -s)"
readonly UNAME_U

# COLORS
readonly COLOUR_RESET='\e[0m'
readonly aCOLOUR=(
    '\e[38;5;154m' # 绿色 - 用于行、项目符号和分隔符 0
    '\e[1m'        # 粗体白色 - 用于主要描述
    '\e[90m'       # 灰色 - 用于版权信息
    '\e[91m'       # 红色 - 用于更新通知警告
    '\e[33m'       # 黄色 - 用于强调
    '\e[34m'       # 蓝色
    '\e[35m'       # 品红
    '\e[36m'       # 青色
    '\e[37m'       # 浅灰色
    '\e[92m'       # 浅绿色9
    '\e[93m'       # 浅黄色
    '\e[94m'       # 浅蓝色
    '\e[95m'       # 浅品红
    '\e[96m'       # 浅青色
    '\e[97m'       # 白色
    '\e[40m'       # 背景黑色
    '\e[41m'       # 背景红色
    '\e[42m'       # 背景绿色
    '\e[43m'       # 背景黄色
    '\e[44m'       # 背景蓝色19
    '\e[45m'       # 背景品红
    '\e[46m'       # 背景青色21
    '\e[47m'       # 背景浅灰色
)

readonly GREEN_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
readonly GREEN_BULLET=" ${aCOLOUR[0]}-$COLOUR_RESET"
readonly GREEN_SEPARATOR="${aCOLOUR[0]}:$COLOUR_RESET"

Show() {
    # OK
    if (($1 == 0)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]}  OK  $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # FAILED
    elif (($1 == 1)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
        exit 1
    # INFO
    elif (($1 == 2)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]} INFO $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # NOTICE
    elif (($1 == 3)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[4]}NOTICE$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
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
# 无颜色
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW="\e[33m"

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
)

# 基础配置
basic_config() {
    echo "请选择操作: "
    echo "1. 启用root用户"
    echo "2. 启用ssh服务"
    echo "3. 设置nameserver"
    echo "4. 允许root用户ssh登录"
    echo "5. 获取当前主机网卡及IP地址信息"
    echo "6. 解除dns协议53端口占用"
    echo "7. 返回主菜单"
    read -p "请输入选择(1-7): " choice
    case $choice in
        1)
            enable_root_user
            ;;
        2)
            enable_ssh
            ;;
        3)
            config_nameserver
            ;;
        4)
            root_ssh_login
            ;;
        5)
            get_ip_addr
            ;;
        6)
            unlock_dns_port
            ;;
        7)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 启用root用户
enable_root_user() {
    # 读取用户输入的新密码
    read -sp '请输入新的root密码: ' new_password
    echo

    # 使用chpasswd命令设置root用户的新密码
    echo "root:${new_password}" | sudo chpasswd

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "root密码已成功设置。"
    else
        echo "设置root密码失败。"
        exit 1
    fi
}

# 启用SSH服务
enable_ssh() {
    # 检查 openssh-server 是否安装
    if dpkg -l | grep -q openssh-server; then
        echo "openssh-server 已安装。"
    else
        echo "openssh-server 未安装，正在安装..."
        sudo apt-get update
        sudo apt-get install openssh-server -y
    fi

    # 启动 SSH 服务
    sudo systemctl start ssh
    echo "SSH 服务已启动。"

    # 设置 SSH 服务开机自启
    sudo systemctl enable ssh
    echo "SSH 服务已设置为开机自启。"

    # 显示 SSH 服务状态
    sudo systemctl status ssh
}

# 设置nameserver
config_nameserver() {
    # 定义新的名称服务器地址
    nameservers=("114.114.114.114" "223.5.5.5" "1.1.1.1")

    # 获取当前的名称服务器配置
    current_nameservers=$(cat /etc/resolv.conf)

    # 检查是否需要更改名称服务器
    if [[ $current_nameservers == *"${nameservers[0]}"* && $current_nameservers == *"${nameservers[1]}"* ]]; then
        echo "名称服务器已设置为 (${nameservers[*]})。"
    else
        # 备份当前的 resolv.conf 文件
        sudo cp /etc/resolv.conf /etc/resolv.conf.backup

        # 清空当前的 resolv.conf 文件
        > /etc/resolv.conf

        # 添加新的名称服务器
        for ns in "${nameservers[@]}"; do
            echo "nameserver $ns" >> /etc/resolv.conf
        done

        # 输出结果
        echo "名称服务器已设置为 (${nameservers[*]})。"
    fi

    # 显示当前的 resolv.conf 配置
    cat /etc/resolv.conf
}

# 允许root用户SSH登录
root_ssh_login() {
    # 修改ssh服务配置文件允许root用户登录
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "[+] SSH 服务配置已更改为允许root用户登录。"

    # 重启ssh服务
    sudo systemctl restart ssh
    echo "[+] SSH 服务已重启。"
    echo "[+] 尝试以root用户登录ssh服务。"
    echo "    示例： ssh root@ip"
}

# 获取当前主机网卡及IP地址信息
get_ip_addr() {
    echo "[+] 获取当前主机网卡及IP地址信息"
    ip -4 addr show | awk '/:/ {print $0}' | awk '{print $2}' | grep -v lo | while read -r ifname; do
        ip -4 addr show "${ifname}" | awk '/inet/ {print $2}' | while read -r ipaddr; do
            echo "- ${ifname} ${ipaddr}"
        done
    done
}

unlock_dns_port() {
    echo "[+] 解除dns协议53端口占用"
    # 停止systemd-resolved
    sudo systemctl stop systemd-resolved
    # 修改systemd-resolved配置
    sudo sed -i 's/#DNS=.*/DNS=114.114.114.114/' /etc/systemd/resolved.conf
    sudo sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf
    # 创建软链接
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    # 启动systemd-resolved
    sudo systemctl start systemd-resolved
}

# 配置JDK
config_jdk() {
    echo "请选择操作: "
    echo "1. 安装 OracleJDK"
    echo "2. 安装 OpenJDK"
    echo "3. 删除当前JDK环境"
    echo "4. 返回主菜单"
    read -p "请输入选择(1-4): " choice
    case $choice in
        1)
            install_oracle_jdk
            ;;
        2)
            install_openjdk
            ;;
        3)
            remove_jdk
            ;;
        4)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Oracle JDK
install_oracle_jdk() {
    echo "安装Oracle JDK"
    echo "选择想要安装的OracleJDK版本: "
    echo "1. Oracle JDK 8 LTS"
    echo "2. Oracle JDK 11 LTS"
    echo "3. Oracle JDK 17 LTS"
    echo "4. Oracle JDK 21 LTS"
    echo "5. 返回主菜单"
    read -p "请输入序号: " version
    case $version in
        1)
            echo "安装Oracle JDK 8 LTS"
            JDK_VER="jdk1.8.0_381"
            JDK_NAME="jdk-8u381-linux-x64.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/8/jdk-8u381-linux-x64.tar.gz"
            check_oracle_jdk
            ;;
        2)
            echo "安装Oracle JDK 11 LTS"
            JDK_VER="jdk-11.0.21"
            JDK_NAME="jdk-11.0.21_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/11/jdk-11.0.21_linux-x64_bin.tar.gz"
            check_oracle_jdk
            ;;
        3)
            echo "安装Oracle JDK 17 LTS"
            JDK_VER="jdk-17.0.9"
            JDK_NAME="jdk-17.0.9_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/17/jdk-17_linux-x64_bin.tar.gz"
            check_oracle_jdk
            ;;
        4)
            echo "安装Oracle JDK 21 LTS"
            JDK_VER="jdk-21.0.1"
            JDK_NAME="jdk-21.0.1_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/21/jdk-21_linux-x64_bin.tar.gz"
            check_oracle_jdk
            ;;
        5)
            echo "退出到主菜单"
            ;;
        *)
            echo "输入的序号无效"
            ;;
    esac
}

check_oracle_jdk() {
    # 下载JDK
    if [ -f $JDK_NAME ]; then
        echo "已存在 {$JDK_NAME} 文件, 无需下载。"
    else
        echo "下载 $JDK_NAME ..."
        wget -q --show-progress "$JDK_URL"
        
        # 检查是否下载成功
        if [ $? -ne 0 ]; then
            echo "下载Oracle JDK失败。"
            rm -f {$JDK_NAME}
            exit 1
        fi
    fi

    # 设置解压目录
    JDK_DIR="/usr/lib/jvm"

    if [ ! -d "$JDK_DIR" ]; then
        echo "创建 ${JDK_DIR} 目录..."
        sudo mkdir -p "${JDK_DIR}"

        if [ $? -eq 0 ]; then
            echo "目录创建成功。"
        else
            echo "目录创建失败。"
        fi
    fi

    # 解压JDK
    echo "Unpacking JDK..."
    sudo tar -xzf $JDK_NAME -C $JDK_DIR

    # 检查解压是否成功
    if [ $? -ne 0 ]; then
        echo "解压Oracle JDK失败。"
        exit 1
    fi

    # 配置Java和Javac
    echo "配置Java和Javac..."

    # 移动解压后的JDK到JDK目录
    # mv $JDK_DIR/jdk* $JDK_DIR/

    # 设置Java和Javac的替代选项
    sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/${JDK_VER}/bin/java 2
    sudo update-alternatives --set java /usr/lib/jvm/${JDK_VER}/bin/java

    sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/${JDK_VER}/bin/javac 2
    sudo update-alternatives --set javac /usr/lib/jvm/${JDK_VER}/bin/javac

    sudo update-alternatives --install /usr/bin/keytool keytool /usr/lib/jvm/${JDK_VER}/bin/keytool 2
    sudo update-alternatives --set keytool /usr/lib/jvm/${JDK_VER}/bin/keytool

    sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/${JDK_VER}/bin/jar 2
    sudo update-alternatives --set jar /usr/lib/jvm/${JDK_VER}/bin/jar

    sudo update-alternatives --install /usr/bin/jarsigner jarsigner /usr/lib/jvm/${JDK_VER}/bin/jarsigner 2
    sudo update-alternatives --set jarsigner /usr/lib/jvm/${JDK_VER}/bin/jarsigner

    # 检查update-alternatives是否成功
    if [ $? -ne 0 ]; then
        echo "未能成功配置Java和Javac。"
        exit 1
    fi

    echo "Oracle JDK已成功安装和配置。"
}


# 安装OpenJDK
install_openjdk() {
    echo "安装OpenJDK"
    echo "选择想要安装的OpenJDK版本: "
    # 输入数字，选择想要安装的不同openjdk版本
    echo "1. OpenJDK 11 LTS"
    echo "2. OpenJDK 17 LTS"
    echo "3. OpenJDK 21 LTS"
    echo "4. 返回到主菜单"
    read -p "请输入序号: " version
    # case $version in
    #     1)
    #         echo "安装OpenJDK 8 LTS"
    #         JDK_VER="jdk8u402-b06"
    #         JDK_URL="https://github.com/adoptium/temurin8-binaries/releases/download/$JDK_VER/OpenJDK8U-jdk_x64_linux_hotspot_8u402b06.tar.gz"
    #         ;;
    #     2)
    #         echo "安装OpenJDK 11 LTS"
    #         JDK_VER="jdk-11.0.22+7"
    #         JDK_URL="https://github.com/adoptium/temurin11-binaries/releases/download/$JDK_VER/OpenJDK11U-jdk_x64_linux_hotspot_11.0.22_7.tar.gz"
    #         ;;
    #     3)
    #         echo "安装OpenJDK 17 LTS"
    #         JDK_VER="jdk-17.0.10+7"
    #         JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/download/$JDK_VER/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
    #         ;;
    #     4)
    #         echo "安装OpenJDK 21 LTS"
    #         JDK_VER="jdk-21.0.2+13"
    #         JDK_URL="https://github.com/adoptium/temurin21-binaries/releases/download/$JDK_VER/OpenJDK21U-jdk_x64_linux_hotspot_21.0.2_13.tar.gz"
    #         ;;
    #     5)
    #         echo "退出"
    #         exit 0
    #         ;;
    #     *)
    #         echo "输入的序号无效"
    #         exit 1
    #         ;;
    # esac

    case $version in
        1)
            echo "安装OpenJDK 11 LTS"
            JDK_VER="11.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        2)
            echo "安装OpenJDK 17 LTS"
            JDK_VER="17.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        3)
            echo "安装OpenJDK 21 LTS"
            JDK_VER="21.0.1"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            check_openjdk
            ;;
        4)
            echo "退出到主菜单"
            ;;
        *)
            echo "输入的序号无效"
            ;;
    esac
}

check_openjdk() {
    # 下载JDK
    if [ -f "openjdk-${JDK_VER}_linux-x64_bin.tar.gz" ]; then
        echo "已存在openjdk-${JDK_VER}_linux-x64_bin.tar.gz文件, 无需下载。"
    else
        echo "下载OpenJDK..."
        wget -q --show-progress $JDK_URL
        
        # 检查是否下载成功
        if [ $? -ne 0 ]; then
            echo "下载OpenJDK失败。"
            rm -f openjdk-${JDK_VER}_linux-x64_bin.tar.gz
            exit 1
        fi
    fi

    # 设置解压目录
    JDK_DIR="/usr/lib/jvm"

    if [ ! -d "$JDK_DIR" ]; then
        echo "创建 ${JDK_DIR} 目录..."
        sudo mkdir -p "${JDK_DIR}"

        if [ $? -eq 0 ]; then
            echo "目录创建成功。"
        else
            echo "目录创建失败。"
        fi
    fi

    # 解压JDK
    echo "Unpacking JDK..."
    sudo tar -xzf openjdk-${JDK_VER}_linux-x64_bin.tar.gz -C ${JDK_DIR}

    # 检查解压是否成功
    if [ $? -ne 0 ]; then
        echo "解压OpenJDK失败。"
        exit 1
    fi

    # 配置Java和Javac
    echo "配置Java和Javac..."

    # 移动解压后的JDK到JDK目录
    # mv $JDK_DIR/jdk* $JDK_DIR/

    # 设置Java和Javac的替代选项
    sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-${JDK_VER}/bin/java 2
    sudo update-alternatives --set java /usr/lib/jvm/jdk-${JDK_VER}/bin/java

    sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-${JDK_VER}/bin/javac 2
    sudo update-alternatives --set javac /usr/lib/jvm/jdk-${JDK_VER}/bin/javac

    sudo update-alternatives --install /usr/bin/keytool keytool /usr/lib/jvm/${JDK_VER}/bin/keytool 2
    sudo update-alternatives --set keytool /usr/lib/jvm/${JDK_VER}/bin/keytool

    sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/${JDK_VER}/bin/jar 2
    sudo update-alternatives --set jar /usr/lib/jvm/${JDK_VER}/bin/jar

    sudo update-alternatives --install /usr/bin/jarsigner jarsigner /usr/lib/jvm/${JDK_VER}/bin/jarsigner 2
    sudo update-alternatives --set jarsigner /usr/lib/jvm/${JDK_VER}/bin/jarsigner

    # 检查update-alternatives是否成功
    if [ $? -ne 0 ]; then
        echo "未能成功配置Java和Javac。"
        exit 1
    fi
    echo "OpenJDK已成功安装和配置。"
}


# 删除当前JDK环境
remove_jdk() {
    # 定位JDK安装目录
    JDK_DIR=$(dirname $(dirname $(readlink -f $(which java))))

    # 检查JDK目录是否存在
    if [ -d "$JDK_DIR" ]; then
        echo "在 $JDK_DIR 找到JDK。"

        # 移除Java和Javac的配置
        update-alternatives --remove java /usr/bin/java
        update-alternatives --remove javac /usr/bin/javac
        update-alternatives --remove javac /usr/bin/keytool
        update-alternatives --remove javac /usr/bin/jar
        update-alternatives --remove javac /usr/bin/jarsigner

        # 配置默认的Java和Javac版本
        echo 0 | sudo update-alternatives --config java 2>&1 >/dev/null
        echo 0 | sudo update-alternatives --config javac 2>&1 >/dev/null
        echo 0 | sudo update-alternatives --config keytool 2>&1 >/dev/null
        echo 0 | sudo update-alternatives --config jar 2>&1 >/dev/null
        echo 0 | sudo update-alternatives --config jarsigner 2>&1 >/dev/null

        # 删除JDK目录
        sudo rm -rf "$JDK_DIR"
        echo "JDK已被卸载。"
    else
        echo "找不到JDK, 或者无法确定JDK安装路径。"
        exit 1
    fi
}

# 配置Docker为国内镜像
configure_docker_mirror() {
    echo "配置Docker为国内镜像"
    sudo mkdir -p /etc/docker

    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://06009bb76e000fc60fd1c01a26a6dfe0.mirror.swr.myhuaweicloud.com",
    "https://fl37993c.mirror.aliyuncs.com",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker
    Show 0 "docker 国内镜像地址配置完毕!"
}

# 配置APT源
config_apt_source_version(){
    local version=$1
    echo "apt源配置"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    # sudo sed -i 's/^deb .*$/#&/g' /etc/apt/sources.list
    sudo tee /etc/apt/sources.list <<-EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $version-security main restricted universe multiverse
EOF
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    echo "apt源更新成功"
}

# 配置APT源
config_apt_source() {
    echo "根据当前系统版本类型, 自动配置APT源"
    if [[ "$(lsb_release -rs)" == "18.04" ]]; then
        config_apt_source_version "bionic"
    elif [[ "$(lsb_release -rs)" == "20.04" ]]; then
        config_apt_source_version "focal"
    elif [[ "$(lsb_release -rs)" == "22.04" ]]; then
        config_apt_source_version "jammy"
    elif [[ "$(lsb_release -rs)" == "23.04" ]]; then
        config_apt_source_version "lunar"
    elif [[ "$(lsb_release -cs)" == "kali-rolling" ]]; then
        sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
        sudo tee /etc/apt/sources.list <<-'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free non-free-firmware
EOF
    else
        echo "不支持的系统版本, 请手动配置apt源"
    fi
    echo "配置完成"
}

# 配置Miniconda3
config_miniconda3() {
    echo "请选择操作: "
    echo "1. 安装 Miniconda3"
    echo "2. 卸载 Miniconda3"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice
    case $choice in
        1)
            install_miniconda3
            ;;
        2)
            remove_miniconda3
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Miniconda3
install_miniconda3() {
    echo "开始安装 Miniconda3"

    # 检查 Miniconda3 安装脚本是否存在
    if [ ! -f "/miniconda3.sh" ]; then
        # 下载 Miniconda3 安装脚本
        sudo wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda3.sh
        echo "安装脚本下载完成"
    else
        echo "/miniconda3.sh 已存在，跳过下载。"
    fi

    # 执行安装脚本
    sudo bash /miniconda3.sh -b -p /miniconda3
    echo "Miniconda3 成功安装到目录：/miniconda3"

    # 初始化 conda
    source /miniconda3/bin/activate
    /miniconda3/bin/conda init bash
    /miniconda3/bin/conda init zsh
    echo "conda 初始化完成"

    # 配置 conda 镜像源
    cat <<EOF | sudo tee ~/.condarc > /dev/null
channels:
  - defaults
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF

    echo "conda 镜像源配置完成"

    # 更新 conda
    sudo /miniconda3/bin/conda update conda -y
    echo "conda 更新完成"

    # 清理 conda 缓存
    sudo /miniconda3/bin/conda clean -a -y
    echo "清理 conda 缓存完成"
    echo "Miniconda3 安装完成"
}

# 卸载Miniconda3
remove_miniconda3() {
    echo "卸载 miniconda3"
    
    # 定义要删除的文件和目录
    declare -a files=("/miniconda3" "~/.condarc")
    
    # 定义要处理的配置文件
    declare -a config_files=(".bashrc" ".zshrc")
    
    # 删除文件和目录
    for file in "${files[@]}"; do
        sudo rm -rf "${file}"
        if [ $? -eq 0 ]; then
            echo "已成功删除 ${file}"
        else
            echo "删除 ${file} 失败"
            exit 1
        fi
    done
    
    # 删除conda初始化代码
    CONDA_INIT_START="# >>> conda initialize >>"
    CONDA_INIT_END="# <<< conda initialize <<"
    
    for config in "${config_files[@]}"; do
        # 检查配置文件是否存在
        if [ -f "${HOME}/${config}" ]; then
            # 使用sed命令删除配置文件中的conda初始化代码
            sudo sed -i "/${CONDA_INIT_START}/,/${CONDA_INIT_END}/d" "${HOME}/${config}"
            
            # 检查sed命令是否成功执行
            if [ $? -eq 0 ]; then
                echo "已成功移除 ${config} 中的conda初始化代码。"
            else
                echo "移除 ${config} 中的conda初始化代码失败。"
                exit 1
            fi
        else
            echo "未找到 ${config} 文件。"
        fi
    done

    echo "卸载 mimiconda3 完成"
}

check_docker() {
    which docker > /dev/null 2>&1

    if [ $? == 0 ]; then
        echo "Docker 已安装"
        service docker start > /dev/null 2>&1
        systemctl start docker > /dev/null 2>&1
    else
        echo "Docker 未安装，开始安装"
        install_docker
    fi
}

# 配置Docker
config_docker() {
    echo "请选择操作: "
    echo "1. 安装 Docker"
    echo "2. 卸载 Docker"
    echo "3. 配置 Docker国内镜像"
    echo "4. 返回主菜单"
    read -p "请输入选择(1-3): " choice
    case $choice in
        1)
            install_docker
            ;;
        2)
            remove_docker
            ;;
        3)
            configure_docker_mirror
            ;;
        4)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Docker
install_docker() {
    echo "开始安装 docker"
    # 更新软件包列表
    sudo apt-get update
    # 安装依赖包
    sudo apt-get install apt-transport-https ca-certificates curl gnupg -y

    if [[ "$(lsb_release -is)" == "Ubuntu" ]] || [[ "$(lsb_release -is)" == "Debian" ]]; then
        local repo_name=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

        echo "检测到系统为 ${repo_name}"
        echo "请选择要使用的镜像源: "
        echo "1. 清华大学 TUNA 镜像站"
        echo "2. 中国科学技术大学 USTC 镜像站"
        read -p "请输入选择(1 或 2): " choice

        # 根据用户选择设置 Docker 软件源
        if [[ "$choice" == "1" ]]; then
            echo "选择使用清华大学 TUNA 镜像站"
            local mirror_url="https://mirrors.tuna.tsinghua.edu.cn"
        elif [[ "$choice" == "2" ]]; then
            echo "选择使用中国科学技术大学 USTC 镜像站"
            local mirror_url="https://mirrors.ustc.edu.cn"
        else
            echo "输入错误，退出安装"
            return 1
        fi

        # 设置 Docker 软件源
        sudo install -d /etc/apt/keyrings
        sudo curl -fsSL "${mirror_url}/docker-ce/linux/${repo_name}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${mirror_url}/docker-ce/linux/${repo_name} "$(. /etc/os-release && echo "${VERSION_CODENAME}")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # 更新软件包列表并安装 Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [[ "$(lsb_release -cs)" == "kali-rolling" ]]; then
        # 针对 Kali Rolling 的特定安装逻辑
        echo "检测到系统为 Kali Rolling"
        echo "请选择要使用的镜像源: "
        echo "1. 清华大学 TUNA 镜像站"
        echo "2. 中国科学技术大学 USTC 镜像站"
        read -p "请输入选择(1 或 2): " choice

        # 根据用户选择设置 Docker 软件源
        if [[ "$choice" == "1" ]]; then
            echo "选择使用清华大学 TUNA 镜像站"
            local mirror_url="https://mirrors.tuna.tsinghua.edu.cn"
        elif [[ "$choice" == "2" ]]; then
            echo "选择使用中国科学技术大学 USTC 镜像站"
            local mirror_url="https://mirrors.ustc.edu.cn"
        else
            echo "输入错误，退出安装"
            return 1
        fi
        
        curl -fsSL ${mirror_url}/docker-ce/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${mirror_url}/docker-ce/linux/debian/ bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
    else
        echo "当前系统版本不支持"
        return 1
    fi

    # 验证 Docker 是否安装成功
    echo "安装 Docker 版本："
    docker --version
}

# 卸载Docker
remove_docker() {
    echo "开始卸载 docker"
    # 卸载 Docker 相关软件
    sudo apt-get remove -y docker-ce docker-ce-cli containerd.io

    # 删除 Docker 数据目录
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/apt/keyrings/docker.gpg
    sudo rm -rf /etc/apt/sources.list.d/docker.list

    # 清理残留的配置文件
    sudo rm -rf /etc/docker

    # 卸载完成
    echo "Docker 已卸载."
}

# 配置Docker-compose
config_docker_compose() {
    echo "请选择操作: "
    echo "1. 安装 Docker-compose"
    echo "2. 卸载 Docker-compose"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_docker_compose
            ;;
        2)
            remove_docker_compose
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Docker-compose
install_docker_compose() {
    echo "开始安装 docker-compose"
    sudo curl -L "https://gitee.com/yijingsec/compose/releases/download/$(curl -s https://gitee.com/api/v5/repos/yijingsec/compose/releases/latest | grep -E -o '\"tag_name\":\"([^\"]+)\"' | awk -F\" '{print $4}')/docker-compose-$(uname -s | tr A-Z a-z)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "安装 docker-compose 版本："
    sudo docker-compose --version
}

# 卸载Docker-compose
remove_docker_compose() {
    echo "开始卸载 docker-compose"
    sudo rm -rf /usr/local/bin/docker-compose
    echo "卸载 docker-compose 完成"
}

# 检查 docker compose 命令
check_docker_compose() {
    # 检查docker compose子命令是否存在
    if docker compose >/dev/null 2>&1; then
        echo "docker compose 子命令存在。"
        COMPOSE_CMD="docker compose"
        # 检查docker-compose命令是否存在
    elif command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose 命令存在。"
        COMPOSE_CMD="docker-compose"
    else
        echo "docker-compose 命令不存在"
        # 安装docker-compose
        install_docker_compose
        COMPOSE_CMD="docker-compose"
    fi
}

# 配置vulfocus
config_vulfocus() {
    echo "请选择操作: "
    echo "1. 安装 Vulfocus"
    echo "2. 卸载 Vulfocus"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_vulfocus
            ;;
        2)
            remove_vulfocus
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择."
            ;;
    esac
}

# 安装vulfocus
install_vulfocus() {
    # 接收用户输入作为host_ip
    echo "开始安装vulfocus"
    read -p "输入启动vulfocus的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    # 检查Docker是否安装
    check_docker

    # 安装vulfocus
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/vulfocus:latest
    sudo docker run -d -p 88:80 --name vulfocus --restart always -v /var/run/docker.sock:/var/run/docker.sock -e VUL_IP=${host_ip} registry.cn-hangzhou.aliyuncs.com/mingy123/vulfocus:latest
    echo "安装vulfocus完成"

    # 打印访问信息
    echo "Vulfocus 服务已启动。"
    echo "访问地址: http://${host_ip}:88"
    echo "默认用户: admin"
    echo "默认密码: admin"
}

# 卸载vulfocus
remove_vulfocus() {
    echo "开始卸载vulfocus"
    sudo docker stop vulfocus
    sudo docker rm vulfocus
    echo "卸载vulfocus完成"
}

# 配置ARL
config_arl() {
    echo "请选择操作: "
    echo "1. 安装 ARL"
    echo "2. 停止 ARL"
    echo "3. 启动 ARL"
    echo "4. 卸载 ARL"
    echo "5. 添加指纹"
    echo "6. 返回主菜单"
    read -p "请输入选择(1-6): " choice

    case $choice in
        1)
            install_arl
            ;;
        2)
            stop_arl
            ;;
        3)
            start_arl
            ;;
        4)
            remove_arl
            ;;
        5)
            add_fingerprint_to_arl
            ;;
        6)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装灯塔ARL
install_arl() {
    echo "开始安装灯塔ARL"
    read -p "输入启动灯塔ARL的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    # 检查Docker是否安装
    check_docker

    echo "创建 docker_arl 目录"
    sudo mkdir -p /opt/docker_arl
    echo "创建 arl_db 卷"
    sudo docker volume create arl_db

    # 获取最新版本的 ARL 下载链接并下载
    # sudo curl -Ls "https://gitee.com/yijingsec/ARL/releases/download/$(curl -s https://gitee.com/api/v5/repos/yijingsec/ARL/releases/latest | grep -E -o '\"tag_name\":\"([^\"]+)\"' | awk -F\" '{print $4}')/docker.zip" -o /opt/docker_arl/docker.zip && cd /opt/docker_arl && unzip -o docker.zip

    local latest_tag_name=$(curl -s https://gitee.com/api/v5/repos/yijingsec/ARL/releases/latest | grep -E -o '"tag_name":"([^\"]+)"' | awk -F\" '{print $4}')
    echo "发现最新版本: ${latest_tag_name}"
    echo "下载 ARL 压缩包..."
    local download_url="https://gitee.com/yijingsec/ARL/releases/download/${latest_tag_name}/docker.zip"
    curl -Ls "${download_url}" -o /opt/docker_arl/docker.zip

    # 解压 ARL 压缩包
    cd /opt/docker_arl
    unzip -o docker.zip

    # 启动 ARL 服务
    echo "启动 ARL 服务..."
    check_docker_compose
    sudo $COMPOSE_CMD up -d
    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        echo "ARL 服务已启动。"
        echo "访问地址: https://${host_ip}:5003"
        echo "默认用户: admin"
        echo "默认密码: arlpass"
    else
        echo "ARL 服务启动失败, 请重试"
        exit 1
    fi
}

# 停止灯塔ARL
stop_arl() {
    echo "停止灯塔ARL开始"
    cd /opt/docker_arl
    check_docker_compose
    sudo $COMPOSE_CMD ps | grep arl_ | grep Up >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        sudo $COMPOSE_CMD stop
        echo "停止灯塔ARL完成"
    else
        echo "灯塔ARL服务已经停止"
    fi
}

# 启动灯塔ARL
start_arl() {
    echo "启动灯塔ARL开始"
    read -p "输入启动灯塔ARL的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    echo "启动灯塔ARL服务"
    cd /opt/docker_arl
    check_docker_compose
    sudo $COMPOSE_CMD ps -a | grep arl_ | grep Exited >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        sudo $COMPOSE_CMD up -d
        if [ $? -eq 0 ]; then
            echo "启动灯塔ARL完成"
            echo "访问地址: https://${host_ip}:5003"
            echo "默认用户: admin"
            echo "默认密码: arlpass"
        else
            echo "启动灯塔ARL失败, 请重试"
            exit 0
        fi
    else
        echo "灯塔ARL服务已经启动"
    fi
}

# 卸载灯塔ARL
remove_arl() {
    echo "开始卸载ARL"
    cd /opt/docker_arl
    check_docker_compose
    echo "停止灯塔ARL服务"
    sudo $COMPOSE_CMD down
    echo "删除 arl_db 卷"
    sudo docker volume rm arl_db
    cd ~
    sudo rm -rf /opt/docker_arl
    read -p "是否要删除镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/arl:latest
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/rabbitmq:3.8.19-management-alpine
        sudo docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/mongo:4.0.27
    fi
    echo "卸载ARL完成"
}

# 给ARL添加指纹
add_fingerprint_to_arl() {
    echo "开始给ARL添加指纹"
    read -p "输入ARL的IP地址: " arl_ip
    if [ -z "${arl_ip}" ]; then
        echo "请输入正确的ARL_IP地址"
        exit 0
    fi
    read -p "输入ARL的密码: " arl_pass
    if [ -z "${arl_pass}" ]; then
        echo "请输入正确的ARL密码"
        exit 0
    fi
    # 如果存在ARL-Finger-ADD目录则删除
    if [ -d "/opt/docker_arl/ARL-Finger-ADD" ]; then
        rm -rf /opt/docker_arl/ARL-Finger-ADD
    fi
    git clone https://gitee.com/yijingsec/ARL-Finger-ADD.git /opt/docker_arl/ARL-Finger-ADD
    cd /opt/docker_arl/ARL-Finger-ADD
    if command -v python3 &>/dev/null; then
        python3 ARL-Finger-ADD.py https://${arl_ip}:5003/ admin ${arl_pass}
    elif command -v python &>/dev/null; then
        python ARL-Finger-ADD.py https://${arl_ip}:5003/ admin ${arl_pass}
    else
        echo "Python3未安装, 请先安装Python3"
        exit 0
    fi
}

# 配置Metasploit-framework
config_metasploit() {
    echo "请选择操作: "
    echo "1. 安装 Metasploit-framework"
    echo "2. 卸载 Metasploit-framework"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_metasploit
            ;;
        2)
            remove_metasploit
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Metasploit-framework
install_metasploit() {
    # 配置 apt 镜像源
    sudo echo "deb https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list > /dev/null
    # 导入 Kali 镜像源的 GPG 公钥
    wget -qO - https://archive.kali.org/archive-key.asc | sudo apt-key add -
    # 更新 apt 软件包列表
    sudo apt update
    # 安装 metasploit
    sudo apt install metasploit-framework -y
    echo "安装 metasploit 版本："
    msfconsole --version
}

# 卸载Metasploit-framework
remove_metasploit() {
    sudo apt remove metasploit-framework -y
}

# 配置Viper
config_viper() {
    echo "请选择操作: "
    echo "1. 安装 Viper"
    echo "2. 更新 Viper 版本"
    echo "3. 更新 Viper 密码"
    echo "4. 启动 Viper"
    echo "5. 关闭 Viper"
    echo "6. 卸载 Viper"
    echo "7. 返回主菜单"
    read -p "请输入选择(1-7): " choice
    case $choice in
        1)
            install_viper
            ;;
        2)
            update_viper_version
            ;;
        3)
            update_viper_password
            ;;
        4)
            start_viper
            ;;
        5)
            stop_viper
            ;;
        6)
            remove_viper
            ;;
        7)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Viper
install_viper() {
    # 检查Docker是否安装
    echo "开始安装Viper"
    check_docker
    read -p "输入启动Viper的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    mkdir -p /root/VIPER && cd /root/VIPER && rm -f docker-compose.* > /dev/null 2>&1

    tee docker-compose.yml <<-'EOF'
version: "3"
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
    command: ["VIPER_PASSWORD"]
EOF

    read -p "输入VIPER密码: " VIPER_PASSWORD
    sed -i "s/VIPER_PASSWORD/${VIPER_PASSWORD}/g" docker-compose.yml
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD up -d
    echo "正在等待系统启动"
    sleep 15
    echo "访问地址: https://${host_ip}:60000 登录到服务器"
    echo "用户名: root"
    echo "密  码: ${VIPER_PASSWORD}"
    echo "安装Viper完成"
}

# 更新Viper版本
update_viper_version() {
    echo "开始更新Viper"
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD down
    rm -rf ./db/*
    rm -f ./module/*
    sudo $COMPOSE_CMD pull
    sudo $COMPOSE_CMD up -d
    echo "更新Viper完成"
}

# 更新Viper密码
update_viper_password() {
    echo "开始更新Viper密码"
    cd /root/VIPER
    read -p "输入VIPER密码: " VIPER_PASSWORD
    sed -i "s/VIPER_PASSWORD/${VIPER_PASSWORD}/g" docker-compose.yml
    check_docker_compose
    sudo $COMPOSE_CMD down
    sudo $COMPOSE_CMD up -d
    echo "更新Viper密码完成"
}

# 启动Viper
start_viper() {
    echo "开始启动Viper"
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD start
    echo "启动Viper完成"
}

# 关闭Viper
stop_viper() {
    echo "开始关闭Viper"
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD stop
    echo "关闭Viper完成"
}

# 卸载Viper
remove_viper() {
    echo "开始卸载Viper"
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD down
    cd ~ && sudo rm -rf /root/VIPER
    echo "卸载Viper完成"
}

# 配置Viper
config_empire() {
    echo "请选择操作: "
    echo "1. 安装 Empire"
    echo "2. 更新 Empire"
    echo "3. 关闭 Empire"
    echo "4. 启动 Empire"
    echo "5. 卸载 Empire"
    echo "6. 返回主菜单"
    read -p "请输入选择(1-6): " choice
    case $choice in
        1)
            install_empire
            ;;
        2)
            update_empire
            ;;
        3)
            stop_empire
            ;;
        4)
            start_empire
            ;;
        5)
            remove_empire
            ;;
        6)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装empire
install_empire() {
    echo "开始安装 Empire"
    check_docker
    read -p "输入启动 Empire 的主机地址: " host_ip
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 0
    fi
    echo "开始拉取Empire镜像"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    if [ $? -eq 0 ]; then
        echo "Empire镜像拉取完毕"
    else
        echo "Empire镜像拉取失败"
        exit 0
    fi
    docker run -d --name ps-empire -p 6000-6010:6000-6010 -p 1337:1337 -p 5000:5000 registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    if [ $? -eq 0 ]; then
        echo "Empire容器启动成功"
    else
        echo "Empire容器启动失败"
        exit 0
    fi
    echo "服务端: http://${host_ip}:1337"
    echo "用户名: empireadmin"
    echo "密  码: password123"
}

# 更新Empire
update_empire() {
    echo "开始更新Empire"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    if [ $? -eq 0 ]; then
        echo "Empire镜像更新完毕"
    else
        echo "Empire镜像更新失败"
        exit 0
    fi
    docker stop ps-empire
    docker rm ps-empire -f
    echo "完成Empire更新"
}

# 关闭Empire
stop_empire() {
    echo "关闭Empire开始"
    docker stop ps-empire
    echo "关闭Empire完成"
}

# 启动Empire
start_empire() {
    echo "启动Empire开始"
    docker start ps-empire
    echo "启动Empire完成"
}

# 卸载Empire
remove_empire() {
    echo "卸载Empire开始"
    docker stop ps-empire
    docker rm ps-empire -f
    echo "删除Empire容器完成"
    read -p "是否要删除镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/empire:latest
    fi
    echo "卸载Empire完成"
}

# 配置 Starkiller
config_starkiller() {
    echo "请选择操作: "
    echo "1. 安装 Starkiller"
    echo "2. 更新 Starkiller"
    echo "3. 关闭 Starkiller"
    echo "4. 启动 Starkiller"
    echo "5. 卸载 Starkiller"
    echo "6. 返回主菜单"
    read -p "请输入选择(1-6): " choice
    case $choice in
        1)
            install_starkiller
            ;;
        2)
            update_starkiller
            ;;
        3)
            stop_starkiller
            ;;
        4)
            start_starkiller
            ;;
        5)
            remove_starkiller
            ;;
        6)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装 Starkiller
install_starkiller() {
    echo "安装Starkiller开始"
    read -p "输入启动Starkiller的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    echo "开始拉取Starkiller镜像"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
    if [ $? -eq 0 ]; then
        echo "拉取Starkiller镜像完毕"
    else
        echo "拉取Starkiller镜像失败"
        exit 0
    fi

    docker run -d --name ps-starkiller -p 4173:4173 registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
    if [ $? -eq 0 ]; then
        echo "启动Starkiller容器成功"
    else
        echo "启动Starkiller容器失败"
        exit 0
    fi
    
    echo "启动Starkiller完成"
    echo "服务地址: http://${host_ip}:4173"
    echo "默认用户: empireadmin"
    echo "默认密码: password123"
}

# 更新 Starkiller
update_starkiller() {
    echo "更新Starkiller开始"
    echo "开始拉取最新Starkiller镜像"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
    if [ $? -eq 0 ]; then
        echo "拉取最新Starkiller镜像成功"
        echo "更新Starkiller成功"
    else
        echo "拉取最新Starkiller镜像失败"
        echo "更新Starkiller失败"
    fi
}

# 关闭 Starkiller
stop_starkiller() {
    echo "关闭Starkiller开始"
    docker stop ps-starkiller
    if [ $? -eq 0 ]; then
        echo "关闭Starkiller完成"
    else
        echo "关闭Starkiller失败"
    fi
}

# 启动 Starkiller
start_starkiller() {
    echo "启动Starkiller开始"
    read -p "输入启动Starkiller的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    docker ps --format "{{.Names}}" | grep 'ps-starkiller'
    if [ $? -eq 0 ]; then
        echo "Starkiller已经启动"
    else
        docker start ps-starkiller
        if [ $? -eq 0 ]; then
            echo "启动Starkiller完成"
            echo "服务地址: http://${host_ip}:4173"
            echo "默认用户: empireadmin"
            echo "默认密码: password123"
        else
            echo "启动Starkiller失败"
        fi
    fi
}

# 卸载 Starkiller
remove_starkiller() {
    echo "卸载Starkiller开始"
    docker rm ps-starkiller -f
    if [ $? -eq 0 ]; then
        echo "删除Starkiller容器完成"
        read -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/starkiller:latest
        fi
        echo "删除Starkiller镜像完成"
        echo "卸载Starkiller完成"
    else
        echo "卸载Starkiller失败"
    fi
}

# 配置 HFish
config_hfish() {
echo "请选择操作: "
    echo "1. 安装 HFish"
    echo "2. 更新 HFish"
    echo "3. 关闭 HFish"
    echo "4. 启动 HFish"
    echo "5. 卸载 HFish"
    echo "6. 获取数据库信息"
    echo "7. 返回主菜单"
    read -p "请输入选择(1-7): " choice
    case $choice in
        1)
            install_hfish
            ;;
        2)
            update_hfish
            ;;
        3)
            stop_hfish
            ;;
        4)
            start_hfish
            ;;
        5)
            remove_hfish
            ;;
        6)
            get_hfish_db_info
            ;;
        7)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装 HFish
install_hfish() {
    # 检查Docker是否安装
    echo "开始安装HFish"
    check_docker
    read -p "输入启动HFish的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    mkdir -p /opt/hfish && cd /opt/hfish && rm -f docker-compose.* > /dev/null 2>&1

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

    # read -p "输入MySQL数据库密码(回车默认为123456): " MYSQL_PASSWORD
    # sed -i "s/123456/${MYSQL_PASSWORD}/g" docker-compose.yml
    cd /opt/hfish
    check_docker_compose
    sudo $COMPOSE_CMD up -d
    echo "正在等待系统启动"
    sleep 3
    if command -v jq >/dev/null 2>&1; then
        MySQL_IP=$(docker network inspect hfish_default | jq -r '.[].Containers | to_entries[] | select(.value.Name == "mysql8") | .value.IPv4Address' | awk -F/ '{print $1}')
    else
        echo "jq命令不存在, 开始安装jq"
        apt install jq
        MySQL_IP=$(docker network inspect hfish_default | jq -r '.[].Containers | to_entries[] | select(.value.Name == "mysql8") | .value.IPv4Address' | awk -F/ '{print $1}')
    fi
    echo "访问地址: https://${host_ip}:4433/web 登录到服务器"
    echo "用户名: admin"
    echo "密  码: HFish"
    echo "MySQL IP 地 址: ${MySQL_IP}"
    echo "MySQL 端 口 号: 3306"
    echo "MySQL 数据库名: hfish"
    echo "MySQL 用 户 名: root"
    echo "MySQL 密    码: HFish2021"

    echo "安装HFish完成"
}

# 更新 HFish
update_hfish() {
    echo "更新HFish开始"
    echo "开始拉取最新HFish镜像"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest
    if [ $? -eq 0 ]; then
        echo "拉取最新HFish镜像成功"
        echo "更新HFish成功"
    else
        echo "拉取最新HFish镜像失败"
        echo "更新HFish失败"
    fi
}

# 关闭 HFish
stop_hfish() {
    echo "关闭HFish开始"
    cd /opt/hfish
    check_docker_compose
    sudo $COMPOSE_CMD stop
    if [ $? -eq 0 ]; then
        echo "关闭HFish完成"
    else
        echo "关闭HFish失败"
    fi
}

# 启动 HFish
start_hfish() {
    echo "启动HFish开始"
    read -p "输入启动HFish的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    cd /opt/hfish
    check_docker_compose
    sudo $COMPOSE_CMD start
    if [ $? -eq 0 ]; then
        echo "启动HFish完成"
        echo "访问地址: https://${host_ip}:4433/web 登录到服务器"
        echo "用户名: admin"
        echo "密  码: HFish2021"
    fi
}

# 卸载 HFish
remove_hfish() {
    echo "卸载HFish开始"
    cd /opt/hfish
    check_docker_compose
    sudo $COMPOSE_CMD down
    if [ $? -eq 0 ]; then
        rm -rf /opt/hfish
        read -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/hfish-server:latest
            docker rmi registry.cn-hangzhou.aliyuncs.com/mingy123/mysql:8.0
        fi
        echo "卸载HFish完成"
    else
        echo "卸载HFish失败"
    fi
}

# 获取HFish数据库配置信息
get_hfish_db_info() {
    echo "HFish数据库信息如下: "
    MySQL_IP=$(docker network inspect hfish_default | jq -r '.[].Containers | to_entries[] | select(.value.Name == "mysql8") | .value.IPv4Address' | awk -F/ '{print $1}')
    echo "MySQL IP 地 址: ${MySQL_IP}"
    echo "MySQL 端 口 号: 3306"
    echo "MySQL 数据库名: hfish"
    echo "MySQL 用 户 名: root"
    echo "MySQL 密    码: HFish2021"
}

# 配置 Dnscat2
config_dnscat2() {
    echo "请选择操作: "
    echo "1. 安装 Dnscat2"
    echo "2. 启动 Dnscat2 (直连模式)"
    echo "3. 启动 Dnscat2 (中继模式)"
    echo "4. 返回主菜单"
    read -p "请输入选择(1-4): " choice

    case $choice in
        1)
            install_dnscat2
            ;;
        2)
            start_dnscat2_direct_mode
            ;;
        3)
            start_dnscat2_relay_mode
            ;;
        4)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装dnscat2
install_dnscat2() {
    echo "安装Dnscat2开始"
    docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07
    if [ $? -eq 0 ]; then
        echo "拉取最新Dnscat2镜像成功"
        echo "安装Dnscat2成功"
        echo "请继续选择配置Dnscat2, 启动Dnscat2"
    else
        echo "拉取最新Dnscat2镜像失败"
        echo "安装Dnscat2失败"
    fi
}

# 启动dnscat2直连模式
start_dnscat2_direct_mode() {
    echo "启动Dnscat2(直连模式)开始"
    docker run -it --name dnscat2 --rm -p 53:53/udp registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07 server
}

# 启动Dnscat2中继模式
start_dnscat2_relay_mode() {
    echo "启动Dnscat2(中继模式)开始"
    read -p "输入启动Dnscat2的子域名: " subdomain
    if [ -z "${subdomain}" ]; then
        echo "请输入正确的子域名"
        exit 1
    fi
    docker run -it --name dnscat2 --rm -p 53:53/udp registry.cn-hangzhou.aliyuncs.com/mingy123/dnscat2:v0.07 server "${subdomain}"
}

# 配置Beef
config_beef() {
    echo "请选择操作: "
    echo "1. 安装 Beef"
    echo "2. 关闭 Beef"
    echo "3. 启动 Beef"
    echo "4. 卸载 Beef"
    echo "5. 返回主菜单"
    read -p "请输入选择(1-5): " choice

    case $choice in
        1)
            install_beef
            ;;
        2)
            stop_beef
            ;;
        3)
            start_beef
            ;;
        4)
            remove_beef
            ;;
        5)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装Beef
install_beef() {
    echo "安装Beef开始"
    read -p "输入启动Beef的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest
    if [ $? -eq 0 ]; then
        echo "拉取最新Beef镜像成功"
    else
        echo "拉取最新Beef镜像失败"
        exit 0
    fi
    docker run -dit --name beef -p 3000:3000 registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest
    if [ $? -eq 0 ]; then
        echo "安装Beef成功"
        echo "访问地址: http://${host_ip}:3000/ui/panel 登录到服务器"
        echo "用户名: beef"
        echo "密  码: yijingsec"
    else
        echo "安装Beef失败"
        exit 0
    fi
}

# 关闭Beef
stop_beef() {
    echo "关闭Beef开始"
    docker stop beef
    if [ $? -eq 0 ]; then
        echo "关闭Beef成功"
    else
        echo "关闭Beef失败"
    fi
}

# 启动Beef
start_beef() {
    echo "启动Beef开始"
    read -p "输入启动Beef的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    docker start beef
    if [ $? -eq 0 ]; then
        echo "启动Beef成功"
        echo "访问地址: http://${host_ip}:3000/ui/panel 登录到服务器"
        echo "默认用户: beef"
        echo "默认密码: yijingsec"
    else
        echo "启动Beef失败"
    fi
}

# 卸载Beef
remove_beef() {
    echo "卸载Beef开始"
    docker rm beef -f
    if [ $? -eq 0 ]; then
        read -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/beef:latest
            echo "删除Beef镜像成功"
        fi
        echo "卸载Beef成功"
    else
        echo "卸载Beef失败"
    fi

}

# 配置Bluelotus
config_bluelotus() {
    echo "请选择操作: "
    echo "1. 安装 Bluelotus"
    echo "2. 关闭 Bluelotus"
    echo "3. 启动 Bluelotus"
    echo "4. 卸载 Bluelotus"
    echo "5. 返回主菜单"
    read -p "请输入选择(1-5): " choice

    case $choice in
        1)
            install_bluelotus
            ;;
        2)
            stop_bluelotus
            ;;
        3)
            start_bluelotus
            ;;
        4)
            remove_bluelotus
            ;;
        5)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装 Bluelotus
install_bluelotus() {
    echo "安装Bluelotus开始"
    read -p "输入启动Bluelotus的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest
    if [ $? -eq 0 ]; then
        echo "拉取最新Bluelotus镜像成功"
    else
        echo "拉取最新Bluelotus镜像失败"
        exit 0
    fi
    docker run -dit --name bluelotus -p 5080:80 registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest
    if [ $? -eq 0 ]; then
        echo "安装Bluelotus成功"
        echo "访问地址: http://${host_ip}:5080/login.php 登录到服务器"
        echo "默认密码: bluelotus"
    else
        echo "安装Bluelotus失败"
        exit 0
    fi
}

# 关闭Bluelotus
stop_bluelotus() {
    echo "关闭Bluelotus开始"
    docker stop bluelotus
    if [ $? -eq 0 ]; then
        echo "关闭Bluelotus成功"
    else
        echo "关闭Bluelotus失败"
    fi
}

# 启动Bluelotus
start_bluelotus() {
    echo "启动Bluelotus开始"
    read -p "输入启动Bluelotus的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi
    docker start bluelotus
    if [ $? -eq 0 ]; then
        echo "启动Bluelotus成功"
        echo "访问地址: http://${host_ip}:5080/login.php 登录到服务器"
        echo "默认密码: bluelotus"
    else
        echo "启动Bluelotus失败"
    fi
}

# 卸载Bluelotus
remove_bluelotus() {
    echo "卸载Bluelotus开始"
    docker rm bluelotus -f
    if [ $? -eq 0 ]; then
        read -p "是否要删除镜像? (y/n)" yn
        if [[ $yn == "y" || $yn == "Y" ]]; then
            docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/bluelotus:latest
            echo "删除Bluelotus镜像成功"
        fi
        echo "卸载Bluelotus成功"
    else
        echo "卸载Bluelotus失败"
    fi
}

# 配置CTFd
config_ctfd() {
    echo "请选择操作: "
    echo "1. 安装 CTFd"
    echo "2. 卸载 CTFd"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_ctfd
            ;;
        2)
            remove_ctfd
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装CTFd
install_ctfd() {
    # 检查Docker是否安装
    check_docker
    echo "开始安装CTFd"
    read -p "输入启动CTFd的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    read -p "输入启动CTFd的主机端口: " host_port
    if [ -z "${host_port}" ]; then
        echo "请输入正确的端口号"
        exit 1
    fi

    mkdir -p /opt/CTFd && cd /opt/CTFd
    docker run --name ctfd -dit -p "${host_port}:8000" -v /opt/CTFd:/ ctfd/ctfd
    echo "访问地址: https://${host_ip}:${host_port}"
}

# 卸载CTFd
remove_ctfd() {
    echo "开始卸载CTFd"
    docker rm ctfd -f
    if [ $? -ne 0 ]; then
        echo "删除容器失败，请检查容器是否启动"
        exit 1
    fi
    rm -rf /opt/CTFd
    read -p "是否要删除镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi ctfd/ctfd
    fi
    echo "卸载CTFd完成"
}

# 配置AWVS
config_awvs() {
    echo "请选择操作: "
    echo "1. 安装 AWVS"
    echo "2. 卸载 AWVS"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_awvs
            ;;
        2)
            remove_awvs
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装AWVS
install_awvs() {
    # 检查Docker是否安装
    check_docker
    echo "开始安装AWVS"
    read -p "输入启动AWVS的主机地址: " host_ip
    # 检查是否输入了IP地址
    if [ -z "${host_ip}" ]; then
        echo "请输入正确的IP地址"
        exit 1
    fi

    read -p "输入启动AWVS的主机端口: " host_port
    if [ -z "${host_port}" ]; then
        echo "请输入正确的端口号"
        exit 1
    fi
    docker pull registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
    if [ $? -ne 0 ]; then
        echo "拉取镜像失败，请检查网络连接"
        exit 1
    fi
    echo "正在启动AWVS"
    docker run -dit -p ${host_port}:3443 --name yijingsec-awvs --cap-add LINUX_IMMUTABLE registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
    while true; do
        sleep 3
        docker ps | grep "yijingsec-awvs" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "容器启动成功"
            break
        fi
    done
    echo "访问地址: https://${host_ip}:${host_port}"
    echo "默认用户: admin@admin.com"
    echo "默认密码: Admin123"
}

# 卸载AWVS
remove_awvs() {
    echo "开始卸载AWVS"
    docker rm yijingsec-awvs -f
    if [ $? -ne 0 ]; then
        echo "删除容器失败，请检查容器是否启动"
        exit 1
    fi
    read -p "是否要删除镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/awvs:latest
    fi
    echo "卸载AWVS完成"
}

# 检查输入是否是有效的IPv4地址
validate_ip() {
    local ip="$1"
    # 正则表达式匹配IPv4地址
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

    if [[ $ip =~ $regex ]]; then
        # 进一步检查每个八位组是否在0-255之间
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet > 255 || octet < 0)); then
                echo "错误: IP地址中的每个部分必须在0到255之间。"
                return 1
            fi
        done
        return 0
    else
        echo "错误: 请输入正确的IP地址格式。"
        return 1
    fi
}

# 配置ocr_api_server
config_ocr_api_server() {
    echo "请选择操作: "
    echo "1. 安装 ocr_api_server"
    echo "2. 卸载 ocr_api_server"
    echo "3. 返回主菜单"
    read -p "请输入选择(1-3): " choice

    case $choice in
        1)
            install_ocr_api_server
            ;;
        2)
            remove_ocr_api_server
            ;;
        3)
            echo "退出到主菜单"
            ;;
        *)
            echo "无效的选择"
            ;;
    esac
}

# 安装ocr_api_server
install_ocr_api_server() {
    # 接收用户输入作为host_ip
    echo "开始安装ocr_api_server"
    read -p "输入启动ocr_api_server的主机地址: " host_ip
    
    # 检查是否输入了IP地址
    if validate_ip $host_ip; then
        echo "你的IP地址为: $host_ip"
    else
        return 1
    fi

    # 检查Docker是否安装
    check_docker

    # 安装ocr_api_server
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/mingy123/ocr_api_server:latest
    sudo docker run -d -p 9898:9898 --name ocr_api_server registry.cn-hangzhou.aliyuncs.com/mingy123/ocr_api_server:latest
    sleep 5
    # 打印访问信息
    echo "ocr_api_server 服务已启动。"
    echo "访问地址: http://${host_ip}:9898/ping"
    echo "访问后响应 pong, 表明服务启动成功。"
}

# 卸载ocr_api_server
remove_ocr_api_server() {
    echo "开始卸载ocr_api_server"
    sudo docker rm -f ocr_api_server
    if [ $? -ne 0 ]; then
        echo "删除容器失败"
        exit 1
    fi

    read -p "是否要删除镜像? (y/n)" yn
    if [[ $yn == "y" || $yn == "Y" ]]; then
        docker rmi registry.cn-shanghai.aliyuncs.com/yijingsec/ocr_api_server:latest
    fi
    echo "卸载ocr_api_server完成"
}

# 显示菜单
show_menu() {
    clear
    YELLOW="\e[33m"
    NO_COLOR="\e[0m"

    echo -e "${GREEN_LINE}"
    echo '
    *************  LinuxEnvConfig  *************

    适配系统: Ubuntu / Debian / Kali (基于Debian)
    脚本作用: Linux 基础环境配置
    
                --- Made by mingy ---
    '
    echo -e "${GREEN_LINE}"
    echo ">>> 请选择操作 >>> "

    # 特殊处理的项数组
    special_items=("")
    for i in "${!menu_options[@]}"; do
        if [[ " ${special_items[*]} " =~ " ${menu_options[i]} " ]]; then
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

while true; do
    show_menu
    read -p ">>> 请输入选项的序号(输入q退出) >>> " choice
    if [[ $choice == 'q' || $choice == 'Q' ]]; then
        break
    fi
    handle_choice $choice
    echo ">>> 按任意键继续... <<<"
    read -n 1 # 等待用户按键
done