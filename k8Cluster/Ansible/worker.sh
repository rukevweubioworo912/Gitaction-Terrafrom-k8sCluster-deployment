#!/bin/bash
set -e

echo "🚀 Setting up Kubernetes Worker Node"

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl enable docker --now

# Disable SELinux
sudo setenforce 0 || true
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add Kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install kubelet and kubeadm
sudo yum install -y kubelet kubeadm --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

# Get join command from argument
JOIN_CMD="\$1"
if [ -z "\$JOIN_CMD" ]; then
  echo "❌ No join command provided!"
  exit 1
fi

# Join only if not already joined
if [ ! -f /etc/kubernetes/kubelet.conf ]; then
  echo "👉 Joining cluster with: \$JOIN_CMD"
  eval "\$JOIN_CMD"
else
  echo "ℹ️ Already joined to the cluster."
fi

echo "✅ Worker node joined successfully!"