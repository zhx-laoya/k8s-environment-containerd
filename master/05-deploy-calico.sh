#!/bin/bash
set -e

echo "========================================="
echo "开始部署 Calico 网络插件..."
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")/package"

# 检查镜像文件是否存在
if [ ! -f "$PACKAGE_DIR/calico_cni.tar" ]; then
    echo "错误: 找不到 calico_cni.tar"
    exit 1
fi

if [ ! -f "$PACKAGE_DIR/calico_node.tar" ]; then
    echo "错误: 找不到 calico_node.tar"
    exit 1
fi

if [ ! -f "$PACKAGE_DIR/calico_controll.tar" ]; then
    echo "错误: 找不到 calico_controll.tar"
    exit 1
fi

# 导入 Calico 镜像
echo "正在导入 Calico CNI 镜像..."
ctr -n k8s.io images import "$PACKAGE_DIR/calico_cni.tar"

echo "正在导入 Calico Node 镜像..."
ctr -n k8s.io images import "$PACKAGE_DIR/calico_node.tar"

echo "正在导入 Calico Controller 镜像..."
ctr -n k8s.io images import "$PACKAGE_DIR/calico_controll.tar"

# 检查镜像是否导入成功
echo "检查已导入的镜像..."
crictl images | grep calico

# 应用 Calico 网络插件
echo "正在应用 Calico 网络插件..."
kubectl apply -f calico.yaml

echo ""
echo "========================================="
echo "Calico 网络插件部署完成!"
echo "========================================="
echo ""
echo "请等待所有 Pod 运行正常,可以使用以下命令查看状态:"
echo "kubectl get pods -n kube-system"
echo ""
