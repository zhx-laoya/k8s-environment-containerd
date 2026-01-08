#!/bin/bash
set -e

echo "========================================="
echo "开始配置基础环境..."
echo "========================================="

# 获取主机名参数,默认为 master
HOSTNAME=${1:-master}

# 设置主机名
echo "正在设置主机名为: $HOSTNAME"
hostnamectl set-hostname "$HOSTNAME"
sudo systemctl restart sshd


# 1. 配置阿里云 apt 源
echo "正在配置阿里云 apt 源..."
# 备份原有源
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 获取系统版本代号
CODENAME=$(lsb_release -cs)

# 配置阿里云源
cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ ${CODENAME} main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ ${CODENAME}-backports main restricted universe multiverse
EOF

# 2. 在线安装基础软件包
echo "正在安装基础软件包..."
apt update -y
apt install -y gcc gcc+ make apt-transport-https ca-certificates curl gnupg-agent gnupg lsb-release make software-properties-common net-tools git curl ntpdate

# 3. 关闭swap和关闭防火墙
echo "正在关闭 swap 和防火墙..."
sed -i '/swap/d' /etc/fstab
swapoff -a
systemctl stop swap.target 2>/dev/null || true
systemctl disable swap.target 2>/dev/null || true
 
systemctl stop ufw 2>/dev/null || true
systemctl disable ufw 2>/dev/null || true

# 4. 优化内核参数
echo "正在优化内核参数..."
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF
sysctl --system

# 5. 开启内核转发
echo "正在开启内核转发..."
echo "1" > /proc/sys/net/ipv4/ip_forward

# 6. 加载内核模块
echo "正在加载内核模块..."
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe br_netfilter
modprobe overlay
lsmod | grep -iE 'br_netfilter|overlay'

# 7. 修改时区同步时间
echo "正在同步时间..."
timedatectl set-timezone Asia/Shanghai
ntpdate time.windows.com || true

echo "========================================="
echo "基础环境配置完成!"
echo "========================================="
