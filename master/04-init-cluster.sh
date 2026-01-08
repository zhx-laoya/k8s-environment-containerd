#!/bin/bash
set -e

echo "========================================="
echo "开始初始化 Kubernetes Master 节点..."
echo "========================================="

# 创建初始化配置文件
echo "正在生成初始化配置文件..."
kubeadm config print init-defaults > /etc/kubernetes/default.yaml

# 修改配置
sed -i "s/1.2.3.4/0.0.0.0/" /etc/kubernetes/default.yaml
sed -i "s#registry.k8s.io#registry.cn-hangzhou.aliyuncs.com/google_containers#" /etc/kubernetes/default.yaml
sed -i '/10.96.0.0\/12/a\  podSubnet: 10.244.0.0\/16' /etc/kubernetes/default.yaml
sed -i "s/name: node/name: $HOSTNAME/g" /etc/kubernetes/default.yaml

echo "配置文件已生成: /etc/kubernetes/default.yaml"
echo ""

# 初始化集群
echo "正在初始化集群..."
kubeadm init --config=/etc/kubernetes/default.yaml

# 配置 kubectl
echo "正在配置 kubectl..."
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo ""
echo "========================================="
echo "Kubernetes Master 节点初始化完成!"
echo "========================================="
echo ""
echo "请记录以下 join 命令,用于 worker 节点加入集群:"
echo ""
kubeadm token create --print-join-command
echo ""
echo "========================================="
