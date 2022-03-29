
#!/usr/bin/env bash

function set_hosts() {
    ipaddr=$1
    domain=$2
    echo "正在设置hosts"
    if ! grep $domain /etc/hosts; then
        echo "$ipaddr $domain" >> /etc/hosts
    else
        sed -i "s#[0-9\.]\+[ ]\+$domain#$ipaddr $domain#g" /etc/hosts
    fi
}

function write_hosts() {
    set_hosts "192.168.111.103" "mirrors.kmpp.io"
    set_hosts "192.168.111.103" "helm.kmpp.io"
    set_hosts "192.168.111.103" "images.kmpp.io"
    set_hosts "192.168.111.103" "files.kmpp.io"
}


function set_yum_source() {
    if [ ! -d "/etc/yum.repos.d/backup" ]; then
        echo "正在备份Yum源"
        mkdir -p /etc/yum.repos.d/backup
    fi
    find /etc/yum.repos.d/ -maxdepth 1 -type f -name *.repo | xargs -I {} mv {} /etc/yum.repos.d/backup/
    echo "正在设置Yum源"
    cp /etc/kubernetes/addons/pre_install/nexus.repo /etc/yum.repos.d/
    echo "yum源设置成功"
}

function close_firewalld() {
    if [ Disabled == "Enforcing" ];then
        echo "正在关闭 SELINUX"
        setenforce 0
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
        sed -i "s/SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
    fi
    echo "正在停止防火墙"
    firewalld_result=
    if [ -n "" ]; then
        systemctl stop firewalld
        if [ 1 == 0 ]; then
            echo "firewalld已关闭"
        else
            echo "firewalld关闭失败"
        fi
        systemctl disable firewalld
        if [ 1 == 0 ]; then
            echo "停止firewalld完成"
        else
            echo "firewalld停止失败"
        fi
    else
        echo "firewalld已关闭"
    fi
}

function flush_yum_source() {
    yum clean all
    yum makecache
}

write_hosts
close_firewalld
set_yum_source
flush_yum_source
