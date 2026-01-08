#!/bin/bash
set -e

echo "========================================="
echo "开始部署 cri-containerd 容器..."
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")/package"

# 检查 cri-containerd 安装包是否存在
if [ ! -f "$PACKAGE_DIR/cri-containerd-1.7.27-linux-amd64.tar.gz" ]; then
    echo "错误: 找不到 cri-containerd-1.7.27-linux-amd64.tar.gz"
    echo "请确保文件存在于 $PACKAGE_DIR 目录下"
    exit 1
fi

# 解压并安装 containerd
echo "正在解压 cri-containerd..."
tar -zxvf "$PACKAGE_DIR/cri-containerd-1.7.27-linux-amd64.tar.gz" -C /

# 创建配置目录
echo "正在配置 containerd..."
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# 修改 containerd 配置
sed -i 's|^\s*root\s*=.*|root = "/data/containerd"|' /etc/containerd/config.toml
sed -i 's|^\s*SystemdCgroup\s*=.*|SystemdCgroup = true|' /etc/containerd/config.toml
sed -i 's|^\s*sandbox_image\s*=.*|sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9"|' /etc/containerd/config.toml

# 创建数据目录
mkdir -p /data/containerd

# 启动 containerd 服务
echo "正在启动 containerd 服务..."
systemctl daemon-reload
systemctl enable --now containerd
systemctl restart containerd

# 等待服务启动
sleep 3

# 检查服务状态
if systemctl is-active --quiet containerd; then
    echo "containerd 服务启动成功!"
else
    echo "错误: containerd 服务启动失败"
    systemctl status containerd
    exit 1
fi

# 配置 crictl
echo "正在配置 crictl..."
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10 
debug: false
EOF

echo "========================================="
echo "cri-containerd 部署完成!"
echo "========================================="
