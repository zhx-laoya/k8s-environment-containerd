#!/bin/bash
set -e

echo "========================================="
echo "Kubernetes Master 节点一键部署脚本"
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
echo "步骤 1/5: 配置基础环境"
bash "$SCRIPT_DIR/01-setup-base.sh" "$HOSTNAME"
echo ""

# 安装 containerd
echo "步骤 2/5: 安装 containerd"
bash "$SCRIPT_DIR/02-install-containerd.sh"
echo ""

# 安装 Kubernetes 组件
echo "步骤 3/5: 安装 Kubernetes 组件"
bash "$SCRIPT_DIR/03-install-kubernetes.sh"
echo ""

# 初始化集群
echo "步骤 4/5: 初始化 Kubernetes 集群"
bash "$SCRIPT_DIR/04-init-cluster.sh"
echo ""

# 部署 Calico 网络插件
echo "步骤 5/5: 部署 Calico 网络插件"
bash "$SCRIPT_DIR/05-deploy-calico.sh"
echo ""

echo "========================================="
echo "Master 节点部署完成!"
echo "========================================="
echo ""
echo "接下来:"
echo "1. 记录上面显示的 kubeadm join 命令"
echo "2. 在 worker 节点上运行该命令加入集群"
echo "3. 使用 'kubectl get nodes' 查看集群状态"
echo ""
