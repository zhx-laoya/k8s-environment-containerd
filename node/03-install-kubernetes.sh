#!/bin/bash
set -e

echo "========================================="
echo "开始安装 Kubernetes 组件..."
echo "========================================="

# 安装依赖
apt-get update && apt-get install -y apt-transport-https

# 添加 Kubernetes 仓库
echo "正在添加 Kubernetes 仓库..."
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/deb/ /" | \
    tee /etc/apt/sources.list.d/kubernetes.list

# 安装 kubelet、kubeadm、kubectl
echo "正在安装 kubelet、kubeadm、kubectl..."
apt-get update
apt-get install -y kubelet kubeadm kubectl

# 设置开机启动
systemctl enable kubelet

# 禁止自动更新
apt-mark hold kubelet kubectl kubeadm

echo "========================================="
echo "Kubernetes 组件安装完成!"
echo "========================================="
