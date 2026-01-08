# Kubernetes Worker 节点部署脚本

## 目录结构

```
node/
├── deploy-all.sh                # 一键部署脚本（推荐使用）
├── 01-setup-base.sh            # 基础环境配置
├── 02-install-containerd.sh    # containerd 容器运行时安装
├── 03-install-kubernetes.sh    # Kubernetes 组件安装
├── 04-import-calico-images.sh  # Calico 镜像导入
├── 05-join-cluster.sh          # 加入集群
└── README.md                   # 说明文档
```

## 前置要求

1. **操作系统**: Ubuntu 22.04
2. **权限**: root 或 sudo 权限
3. **网络**: 能够访问外网（用于下载软件包）
4. **Master 节点**: 确保 master 节点已经部署完成
5. **资源**: 
   - 至少 1 CPU 核心
   - 至少 1GB 内存
   - 至少 10GB 磁盘空间

## 使用方法

### 方式一：一键部署（推荐）

```bash
# 切换到 node 目录
cd node

# 赋予执行权限
chmod +x *.sh

# 执行一键部署脚本
sudo bash deploy-all.sh
```

部署完成后，按照提示获取并执行 join 命令。

### 方式二：分步执行

如果需要分步执行或调试，可以按顺序运行各个脚本：

```bash
# 1. 配置基础环境
sudo bash 01-setup-base.sh

# 2. 安装 containerd
sudo bash 02-install-containerd.sh

# 3. 安装 Kubernetes 组件
sudo bash 03-install-kubernetes.sh

# 4. 导入 Calico 镜像
sudo bash 04-import-calico-images.sh

# 5. 加入集群
# 首先在 master 节点获取 join 命令：
# kubeadm token create --print-join-command
# 然后在 worker 节点执行：
sudo bash 05-join-cluster.sh <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 加入集群

### 获取 join 命令

在 **master 节点**上运行：

```bash
kubeadm token create --print-join-command
```

输出示例：
```
kubeadm join 192.168.31.200:6443 --token abc123.xyz789 --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

### 执行 join 命令

在 **worker 节点**上运行：

```bash
sudo bash 05-join-cluster.sh 192.168.31.200:6443 --token abc123.xyz789 --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

## 部署后检查

在 **master 节点**上检查：

```bash
# 查看节点状态
kubectl get nodes

# 查看所有 Pod 状态
kubectl get pods -A

# 查看节点详细信息
kubectl describe node <node-name>
```

## 常见问题

### 1. 加入集群失败

检查以下几点：
- master 节点是否正常运行
- 网络连通性（ping master 节点）
- token 是否过期（默认 24 小时）
- 端口 6443 是否开放

### 2. 节点状态为 NotReady

等待几分钟让 Calico 初始化完成。如果持续 NotReady：

```bash
# 在 worker 节点查看日志
journalctl -u kubelet -f

# 在 master 节点查看节点详情
kubectl describe node <node-name>
```

### 3. 如何重置节点？

如果需要重新加入集群：

```bash
kubeadm reset -f
rm -rf /etc/cni/net.d
```

然后重新运行 `05-join-cluster.sh`

### 4. Token 过期怎么办？

在 master 节点重新生成：

```bash
kubeadm token create --print-join-command
```

## 多节点部署

如果要添加多个 worker 节点：

1. 在每个节点上复制 node 目录和 package 目录
2. 分别运行 `deploy-all.sh`
3. 使用相同的 join 命令加入集群

## 后续扩展

此脚本框架支持后续添加更多组件，只需：

1. 创建新的脚本文件，如 `06-install-xxx.sh`
2. 在 `deploy-all.sh` 中添加调用
3. 保持脚本的模块化和独立性

## 注意事项

- 所有脚本都使用 `set -e`，遇到错误会自动停止
- 脚本会自动从 `../package/` 目录读取离线安装包
- 确保 package 目录包含所需的所有文件
- Worker 节点不需要部署 Calico yaml，只需要导入镜像
- 建议在虚拟机中先测试部署流程
