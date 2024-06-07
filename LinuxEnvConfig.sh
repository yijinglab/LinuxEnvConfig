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
    "启用root用户"
    "启用SSH服务"
    "设置nameserver"
    "允许root用户SSH登录"
    "获取当前主机网卡及IP地址信息"
    "配置APT镜像源"
    "安装OracleJDK"
    "安装OpenJDK"
    "删除当前JDK环境"
    # "安装Python3.8"
    # "卸载Python3.8"
    "安装Miniconda3"
    "卸载Miniconda3"
    "安装Docker"
    "卸载Docker"
    "配置Docker为国内镜像"
    "安装Docker-compose"
    "卸载Docker-compose"
    "安装vulfocus"
    "卸载vulfocus"
    "安装灯塔ARL"
    "卸载灯塔ARL"
    "安装Metasploit-framework"
    "卸载Metasploit-framework"
    "安装Viper"
    "卸载Viper"
    "安装CTFd"
    "卸载CTFd"
    "安装AWVS"
    "卸载AWVS"
)

commands=(
    ["启用root用户"]="enable_root_user"
    ["启用SSH服务"]="enable_ssh"
    ["设置nameserver"]="config_nameserver"
    ["允许root用户SSH登录"]="root_ssh_login"
    ["获取当前主机网卡及IP地址信息"]="get_ip_addr"
    ["配置APT镜像源"]="config_apt_source"
    ["安装OracleJDK"]="install_oracle_jdk"
    ["安装OpenJDK"]="install_openjdk"
    ["删除当前JDK环境"]="remove_jdk"
    # ["安装Python3.8"]="install_python38"
    # ["卸载Python3.8"]="remove_python38"
    ["安装Miniconda3"]="install_miniconda3"
    ["卸载Miniconda3"]="remove_miniconda3"
    ["安装Docker"]="install_docker"
    ["卸载Docker"]="remove_docker"
    ["配置Docker为国内镜像"]="configure_docker_mirror"
    ["安装Docker-compose"]="install_docker_compose"
    ["卸载Docker-compose"]="remove_docker_compose"
    ["安装vulfocus"]="install_vulfocus"
    ["卸载vulfocus"]="remove_vulfocus"
    ["安装灯塔ARL"]="install_arl"
    ["卸载灯塔ARL"]="remove_arl"
    ["安装Metasploit-framework"]="install_metasploit"
    ["卸载Metasploit-framework"]="remove_metasploit"
    ["安装Viper"]="install_viper"
    ["卸载Viper"]="remove_viper"
    ["安装CTFd"]="install_ctfd"
    ["卸载CTFd"]="remove_ctfd"
    ["安装AWVS"]="install_awvs"
    ["卸载AWVS"]="remove_awvs"
)

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

# 安装Oracle JDK
install_oracle_jdk() {
    echo "安装Oracle JDK"
    echo "选择想要安装的OracleJDK版本: "
    echo "1. Oracle JDK 8 LTS"
    echo "2. Oracle JDK 11 LTS"
    echo "3. Oracle JDK 17 LTS"
    echo "4. Oracle JDK 21 LTS"
    echo "4. 退出"
    read -p "请输入序号: " version
    case $version in
        1)
            echo "安装Oracle JDK 8 LTS"
            JDK_VER="jdk1.8.0_381"
            JDK_NAME="jdk-8u381-linux-x64.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/8/jdk-8u381-linux-x64.tar.gz"
            ;;
        2)
            echo "安装Oracle JDK 11 LTS"
            JDK_VER="jdk-11.0.21"
            JDK_NAME="jdk-11.0.21_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/11/jdk-11.0.21_linux-x64_bin.tar.gz"
            ;;
        3)
            echo "安装Oracle JDK 17 LTS"
            JDK_VER="jdk-17.0.9"
            JDK_NAME="jdk-17.0.9_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/17/jdk-17_linux-x64_bin.tar.gz"
            ;;
        4)
            echo "安装Oracle JDK 21 LTS"
            JDK_VER="jdk-21.0.1"
            JDK_NAME="jdk-21.0.1_linux-x64_bin.tar.gz"
            JDK_URL="https://d6.injdk.cn/oraclejdk/21/jdk-21_linux-x64_bin.tar.gz"
            ;;
        5)
            echo "退出"
            exit 0
            ;;
        *)
            echo "输入的序号无效"
            exit 1
            ;;
    esac

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
    echo "4. 退出"
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
            ;;
        2)
            echo "安装OpenJDK 17 LTS"
            JDK_VER="17.0.2"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            ;;
        3)
            echo "安装OpenJDK 21 LTS"
            JDK_VER="21.0.1"
            JDK_URL="https://mirrors.huaweicloud.com/openjdk/${JDK_VER}/openjdk-${JDK_VER}_linux-x64_bin.tar.gz"
            ;;
        4)
            echo "退出"
            exit 0
            ;;
        *)
            echo "输入的序号无效"
            exit 1
            ;;
    esac

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

        # 配置默认的Java和Javac版本
        echo 0 | sudo update-alternatives --config java 2>&1 >/dev/null
        echo 0 | sudo update-alternatives --config javac 2>&1 >/dev/null

        # 删除JDK目录
        sudo rm -rf "$JDK_DIR"
        echo "JDK已被卸载。"
    else
        echo "找不到JDK, 或者无法确定JDK安装路径。"
        exit 1
    fi
}

# 安装Python3.8
install_python38() {
    # 设置Python版本
    PYTHON_VERSION="Python-3.8.10"

    # 设置下载链接（以Python 3.8.10为例）
    PYTHON_URL="https://www.python.org/ftp/python/3.8.10/$PYTHON_VERSION.tar.xz"

    # 设置解压目录
    PYTHON_DIR="/usr/local"

    # 下载Python源码
    echo "Downloading $PYTHON_VERSION..."
    wget $PYTHON_URL -O $PYTHON_VERSION.tar.xz

    # 检查是否下载成功
    if [ $? -ne 0 ]; then
        echo "Failed to download $PYTHON_VERSION."
        exit 1
    fi

    # 解压Python源码
    echo "Unpacking $PYTHON_VERSION..."
    tar -xJf $PYTHON_VERSION.tar.xz

    # 检查解压是否成功
    if [ $? -ne 0 ]; then
        echo "Failed to unpack $PYTHON_VERSION."
        exit 1
    fi

    # 编译和安装Python
    echo "Installing $PYTHON_VERSION..."
    cd $PYTHON_VERSION
    ./configure --enable-optimizations
    make -j 8
    sudo make altinstall

    # 检查安装是否成功
    if [ $? -ne 0 ]; then
        echo "Failed to install $PYTHON_VERSION."
        exit 1
    fi

    cd ..

    # 配置Python和pip
    echo "Configuring $PYTHON_VERSION and pip..."

    # 设置Python和pip的替代选项
    sudo update-alternatives --install /usr/bin/python python $PYTHON_DIR/$PYTHON_VERSION 1
    sudo update-alternatives --install /usr/bin/pip pip $PYTHON_DIR/$PYTHON_VERSION/bin/pip 1

    # 设置默认的Python和pip版本
    sudo update-alternatives --set python /usr/bin/python
    sudo update-alternatives --set pip /usr/bin/pip

    # 清理下载的源码压缩包
    rm -f $PYTHON_VERSION.tar.xz
    rm -rf $PYTHON_VERSION

    echo "Python $PYTHON_VERSION has been successfully installed and configured."
}

# 卸载Python3.8
remove_python38() {
    echo "卸载Python3.8"
    # 检查Python版本，这里以Python 3.8为例
    PYTHON_VERSION="3.8"

    # 定位Python安装目录，这里假设是标准的安装路径
    PYTHON_DIR="/usr/local/lib/python$PYTHON_VERSION"

    # 检查Python目录是否存在
    if [ -d "$PYTHON_DIR" ]; then
        echo "Python $PYTHON_VERSION found at $PYTHON_DIR."

        # 删除Python目录和内容
        sudo rm -rf "$PYTHON_DIR"
        echo "Python $PYTHON_VERSION has been uninstalled."
    else
        echo "Python $PYTHON_VERSION not found at $PYTHON_DIR."
        exit 1
    fi

    # 检查并删除Python可执行文件
    for cmd in python$PYTHON_VERSION python3.8; do
        if [ -x "$(command -v $cmd)" ]; then
            sudo rm "$(command -v $cmd)"
            echo "Removed $cmd executable."
        fi
    done

    # 检查并删除pip可执行文件
    for cmd in pip$PYTHON_VERSION pip3.8; do
        if [ -x "$(command -v $cmd)" ]; then
            sudo rm "$(command -v $cmd)"
            echo "Removed $cmd executable."
        fi
    done

    # 更新alternatives，移除Python和pip的配置
    sudo update-alternatives --remove python /usr/local/bin/python$PYTHON_VERSION
    sudo update-alternatives --remove pip /usr/local/bin/pip$PYTHON_VERSION

    # 清理系统配置文件（如果有）
    sudo rm -f /etc/python$PYTHON_VERSION/*
    sudo rm -f /etc/alternatives/python$PYTHON_VERSION

    echo "Python $PYTHON_VERSION uninstallation process completed."
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

# 安装Docker
install_docker() {
    echo "开始安装 docker"
    # 更新软件包列表
    sudo apt-get update
    # 安装依赖包
    sudo apt-get install apt-transport-https ca-certificates curl gnupg -y
    if [[ "$(lsb_release -is)" == "Ubuntu" ]] || [[ "$(lsb_release -is)" == "Debian" ]]; then
        local repo_name=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
        # 设置 Docker 软件源
        sudo install -d /etc/apt/keyrings
        sudo curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${repo_name}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/${repo_name} "$(. /etc/os-release && echo "${VERSION_CODENAME}")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        # 更新软件包列表并安装 Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [[ "$(lsb_release -cs)" == "kali-rolling" ]]; then
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
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

    # 等待 ARL 服务启动
    echo "等待 ARL 服务启动..."
    sleep 5

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

# 卸载灯塔ARL
remove_arl() {
    echo "开始卸载ARL"
    cd /opt/docker_arl
    check_docker_compose
    echo "停止 ARL 服务..."
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

# 安装Viper
install_viper() {
    # 检查Docker是否安装
    echo "开始安装灯塔ARL"
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
      - ${PWD}/loot:/root/.msf4/loot
      - ${PWD}/db:/root/viper/Docker/db
      - ${PWD}/module:/root/viper/Docker/module
      - ${PWD}/log:/root/viper/Docker/log
      - ${PWD}/nginxconfig:/root/viper/Docker/nginxconfig
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

# 卸载Viper
remove_viper() {
    echo "开始卸载Viper"
    cd /root/VIPER
    check_docker_compose
    sudo $COMPOSE_CMD down
    cd ~ && sudo rm -rf /root/VIPER
    echo "卸载Viper完成"
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

# 安装AWVS
install_avws() {
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
    if [[ $choice == 'q' ]]; then
        break
    fi
    handle_choice $choice
    echo ">>> 按任意键继续... <<<"
    read -n 1 # 等待用户按键
done