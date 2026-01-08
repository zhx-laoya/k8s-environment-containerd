# Kubernetes Master 节点部署脚本

## 目录结构

```
maste如果需要分步执行或调试,可以按顺序运行各个脚本：

```bash
# 1. 配置基础环境（可选指定主机名，默认为 master）
sudo bash 01-setup-base.sh
# 或指定主机名
sudo bash 01-setup-base.sh k8s-master

# 2. 安装 containerd
sudo bash 02-install-containerd.shdeploy-all.sh              # 一键部署脚本（推荐使用）
├── 01-setup-base.sh          # 基础环境配置
├── 02-install-containerd.sh  # containerd 容器运行时安装
├── 03-install-kubernetes.sh  # Kubernetes 组件安装
├── 04-init-cluster.sh        # 集群初始化
├── 05-deploy-calico.sh       # Calico 网络插件部署
└── README.md                 # 说明文档
```

## 前置要求

1. **操作系统**: Ubuntu 22.04
2. **权限**: root 或 sudo 权限
3. **网络**: 能够访问外网（用于下载软件包）
4. **资源**: 
   - 至少 2 CPU 核心
   - 至少 2GB 内存
   - 至少 20GB 磁盘空间

## 使用方法

### 方式一：一键部署（推荐）

```bash
# 切换到 master 目录
cd master

# 赋予执行权限
chmod +x *.sh

# 执行一键部署脚本（使用默认主机名 master）
sudo bash deploy-all.sh

# 或者指定自定义主机名
sudo bash deploy-all.sh k8s-master
```

部署完成后，会显示 `kubeadm join` 命令，请记录下来用于 worker 节点加入集群。

**参数说明：**
- 不带参数：主机名默认为 `master`
- 带参数：使用指定的主机名，例如 `k8s-master`、`node1` 等

### 方式二：分步执行

如果需要分步执行或调试，可以按顺序运行各个脚本：

```bash
# 1. 配置基础环境
sudo bash 01-setup-base.sh

# 2. 安装 containerd
sudo bash 02-install-containerd.sh

# 3. 安装 Kubernetes 组件
sudo bash 03-install-kubernetes.sh

# 4. 初始化集群
sudo bash 04-init-cluster.sh

# 5. 部署 Calico 网络插件
sudo bash 05-deploy-calico.sh
```

## 部署后检查

```bash
# 查看节点状态
kubectl get nodes

# 查看所有 Pod 状态
kubectl get pods -A

# 查看集群信息
kubectl cluster-info
```

## 常见问题

### 1. 如何获取 join 命令？

如果忘记记录 join 命令，可以在 master 节点运行：

```bash
kubeadm token create --print-join-command
```

### 2. Calico Pod 一直处于 Pending 状态

等待几分钟，Calico 需要一些时间来初始化。可以查看详细信息：

```bash
kubectl describe pod <pod-name> -n kube-system
```

### 3. 如何重置集群？

如果需要重新初始化集群：

```bash
kubeadm reset -f
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube/config
```

然后重新运行 `04-init-cluster.sh` 和 `05-deploy-calico.sh`

## 后续扩展

此脚本框架支持后续添加更多组件，只需：

1. 创建新的脚本文件，如 `06-install-xxx.sh`
2. 在 `deploy-all.sh` 中添加调用
3. 保持脚本的模块化和独立性

## 注意事项

- 所有脚本都使用 `set -e`，遇到错误会自动停止
- 脚本会自动从 `../package/` 目录读取离线安装包
- 确保 package 目录包含所需的所有文件
- 建议在虚拟机中先测试部署流程
