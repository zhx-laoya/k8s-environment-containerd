#!/bin/bash
set -e

echo "========================================="
echo "Kubernetes Worker 节点一键部署脚本"
echo "========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查是否提供主机名参数
if [ -z "$1" ]; then
    echo "错误: 请提供主机名参数"
    echo "使用命令: sudo bash deploy-all.sh <hostname>"
    exit 1
fi

HOSTNAME=$1

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "错误: 请使用 root 权限运行此脚本"
    echo "使用命令: sudo bash deploy-all.sh <hostname>"
    exit 1
fi

echo "主机名将被设置为: $HOSTNAME"
echo ""

# 执行基础环境配置
echo "步骤 1/4: 配置基础环境"
bash "$SCRIPT_DIR/01-setup-base.sh" "$HOSTNAME"
echo ""

# 安装 containerd
echo "步骤 2/4: 安装 containerd"
bash "$SCRIPT_DIR/02-install-containerd.sh"
echo ""

# 安装 Kubernetes 组件
echo "步骤 3/4: 安装 Kubernetes 组件"
bash "$SCRIPT_DIR/03-install-kubernetes.sh"
echo ""

# 导入 Calico 镜像
echo "步骤 4/4: 导入 Calico 镜像"
bash "$SCRIPT_DIR/04-import-calico-images.sh"
echo ""

echo "========================================="
echo "Worker 节点准备完成!"
echo "========================================="
echo ""
echo "接下来:"
echo "1. 在 master 节点运行: kubeadm token create --print-join-command"
echo "2. 复制输出的 join 命令"
echo "3. 在本节点运行: bash 05-join-cluster.sh <join命令参数>"
echo ""
echo "示例:"
echo "  bash 05-join-cluster.sh 192.168.31.200:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx"
echo ""
