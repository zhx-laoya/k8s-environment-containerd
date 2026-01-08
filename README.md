# Kubernetes 集群一键部署方案

本方案提供了完整的 Kubernetes 集群自动化部署脚本，支持 master 和 worker 节点的快速部署。

## 📁 目录结构

```
论文环境配置/
├── package/                              # 离线安装包目录
│   ├── cri-containerd-1.7.27-linux-amd64.tar.gz
│   ├── calico_cni.tar
│   ├── calico_node.tar
│   └── calico_controll.tar
├── master/                               # Master 节点部署脚本
│   ├── deploy-all.sh                    # 一键部署（推荐）
│   ├── 01-setup-base.sh
│   ├── 02-install-containerd.sh
│   ├── 03-install-kubernetes.sh
│   ├── 04-init-cluster.sh
│   ├── 05-deploy-calico.sh
│   └── README.md
├── node/                                 # Worker 节点部署脚本
│   ├── deploy-all.sh                    # 一键部署（推荐）
│   ├── 01-setup-base.sh
│   ├── 02-install-containerd.sh
│   ├── 03-install-kubernetes.sh
│   ├── 04-import-calico-images.sh
│   └── README.md
└── README.md                             # 本文件
```

## 🚀 快速开始

### 准备工作

1. **准备服务器**
   - Master 节点：Ubuntu 22.04，2核2G以上
   - Worker 节点：Ubuntu 22.04，1核1G以上

2. **准备安装包**
   - 确保 `package/` 目录下有所有必需的文件
   - 安装包约500MB，在百度网盘上，包括了containerd以及calico的镜像
   - 链接: https://pan.baidu.com/s/10hK_fNnsynV2iVXf1r_UuQ?pwd=j1fg 提取码: j1fg

3. **配置主机名和 hosts**
   
   在所有节点上执行：
   ```bash
   # Master 节点
   hostnamectl set-hostname master
   
   # Worker 节点
   hostnamectl set-hostname node1
   
   # 所有节点配置 hosts
   cat >> /etc/hosts << EOF
   <master-ip> master
   <node1-ip> node1
   EOF
   ```

### 部署 Master 节点

```bash
# 1. 进入 master 目录
cd master

# 2. 赋予执行权限
chmod +x *.sh

# 3. 执行一键部署
sudo bash deploy-all.sh master 

# 4. 记录输出的 join 命令
```

### 部署 Worker 节点

```bash
# 1. 进入 node 目录
cd node

# 2. 赋予执行权限
chmod +x *.sh

# 3. 执行一键部署
sudo bash deploy-all.sh {hostname}

# 4. 使用 master 节点的 join 命令加入集群
```

### 验证部署

在 master 节点上执行：

```bash
# 查看节点状态
kubectl get nodes

# 期望输出：
# NAME     STATUS   ROLES           AGE   VERSION
# master   Ready    control-plane   10m   v1.30.x
# node1    Ready    <none>          5m    v1.30.x

# 查看所有 Pod
kubectl get pods -A

# 查看集群信息
kubectl cluster-info
```

