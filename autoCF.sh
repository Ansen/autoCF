#!/bin/bash

. /etc/profile

# IPV4: 1, IPV6: 2
menu=1
# 优选带宽
bandwidth=60
# 线程数
tasknum=20


function download_better_cloudflare_script() {
    local download_url='https://ghproxy.com/https://raw.githubusercontent.com/badafans/better-cloudflare-ip/master/shell/cf.sh'
    curl -sq -o ${tmp_script_path} ${download_url}
    [[ $? -ne 0 ]] && echo "脚本下载失败" && exit 1
}

function modify_better_cloudflare_script() {
    [[ ! -f ${tmp_script_path} ]] && echo "找不到 ${tmp_script_path}" && exit 1
    # 设置带宽
    sed -i "s/^read.*bandwidth\$/bandwidth=${bandwidth}/g" ${tmp_script_path}
    # 设置线程数
    sed -i "s/^read.*tasknum\$/tasknum=${tasknum}/g" ${tmp_script_path}
    # 设置IPV4/IPV6
    sed -i "s/read.*menu\$/menu=${menu}/g" ${tmp_script_path}
    # 优选IP写入文件
    sed -i "/^echo 总计用时/a echo \$anycast > ${tmp_better_ip}" ${tmp_script_path}

}

function handle_gost(){
    echo "正在处理 gost..."
    [[ ! -f ${tmp_better_ip} ]] && echo "找不到 ${tmp_better_ip}" && exit 1

    local anycast=$(cat ${tmp_better_ip})
    # 备份原有gost配置
    [[ -f /etc/gost/gost.yaml ]] && \cp -f /etc/gost/conf.json /tmp/gost.conf.json.bak.$(date "+%F-%H%M%S")
    \cp -f /etc/gost/conf.json.example /etc/gost/conf.json
    sed -i "s/CLOUDFLAREIP/${anycast}/g" /etc/gost/conf.json
    [[ $? -ne 0 ]] && echo "gost配置文件修改失败" && exit 1
    echo "gost配置文件修改成功"
    systemctl restart gost
    [[ $? -ne 0 ]] && echo "gost重启失败" && exit 1
    echo "gost已重启"

}

function install_gost(){
    local gost_install_path=/usr/local/bin
    local tmp_file="gost.gz"
    local version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/ginuerzh/gost/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'| cut -b 2-)
    if [[ -z ${version} ]]
    then
        local version=$(cat version)
        echo "gost版本获取失败, 使用默认版本: ${version}"
    fi
    echo "gost版本: v${version}"
    local machine=$(uname -m)
    case ${machine} in
        x86_64)
            local bit="amd64"
            ;;
        aarch64)
            local bit="armv8"
            ;;
        armv7l)
            local bit="armv7"
            ;;
        armv6l)
            local bit="armv6"
            ;;
        armv8l)
            local bit="armv8"
            ;;
        *)
            echo "未知机器类型"
            exit 1
            ;;
    esac
    #local os=$(uname -s)
    #wget -q --show-progress -O "${tmp_file}" https://github.com/ginuerzh/gost/releases/download/v${version}/gost-${os}-${bit}-${version}.gz
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    wget -q --show-progress -O "${tmp_file}" https://github.com/ginuerzh/gost/releases/download/v${version}/gost_${version}_${os}_${bit}.tar.gz
    [[ $? -ne 0 ]] && echo "gost下载失败" && exit 1
    [[ ! -f ${tmp_file} ]] && echo "gost下载失败" && exit 1
    gzip -d ${tmp_file}
    [[ $? -ne 0 ]] && echo "gost解压失败" && exit 1
    chmod +x gost
    mv gost "${gost_install_path}/"
    [[ $? -ne 0 ]] && echo "gost安装失败" && exit 1
    
    mkdir -p /etc/gost
    \cp -f conf.json.example /etc/gost/conf.json.example

    \cp -f gost.service /lib/systemd/system/gost.service
    systemctl daemon-reload
    systemctl enable gost
}

function uninstall_gost(){
    systemctl disable gost
    systemctl stop gost
    rm -rf /etc/gost
    rm -f /usr/local/bin/gost
    rm -f /lib/systemd/system/gost.service
}

function is_root(){
    if [[ $EUID -ne 0 ]]; then
        echo "需要使用root用户运行"
        exit 1
    fi
}

function main(){
    is_root
    local param="$1"
    tmp_script_path='/tmp/cf.sh'
    tmp_better_ip='/tmp/better_ip.txt'

    # 安装 gost
    if [[ "x${param}" == "xinstall" ]]
    then
        install_gost
    # 卸载 gost
    elif [[ "x${param}" == "xuninstall" ]]
    then
        uninstall_gost
    # 更新优选IP
    elif [[ "x${param}" == "xupdate" ]]
    then
        download_better_cloudflare_script
        modify_better_cloudflare_script
        chmod +x ${tmp_script_path}
        cd /tmp && /bin/bash ${tmp_script_path}
        handle_gost
    else
        echo "Usage: $0 [install|uninstall|update]"
        exit 1
    fi

}

main "$@"
