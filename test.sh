
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

action() {
    if [ $? -eq 0 ]; then
		Show 0 "$1"
	else
		Show 1 "$2"
	fi
}

# 创建通用安装函数
install_package() {
    local package_name=$1
    local install_cmd=$2
    local success_msg=$3
    local fail_msg=$4

    if command -v $package_name &> /dev/null; then
        Show 0 "$package_name 已安装"
        return 0
    fi

    Show 2 "安装 $package_name"
    if eval $install_cmd; then
        Show 0 "$success_msg"
        return 0
    else
        Show 1 "$fail_msg"
        return 1
    fi
}

# 使用示例
check_wget() {
    install_package "wget1" "sudo apt-get install -y wget" "wget 安装成功" "wget 安装失败"
}

check_curl() {
    install_package "curl" "sudo apt-get install -y curl" "curl 安装成功" "curl 安装失败"
}

check_wget