#!/bin/bash
set -e

echo "🚀 Setting up Kubernetes Master Node"

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

# Install kubelet, kubeadm, kubectl
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

# Initialize cluster only if not already done
if [ ! -f /etc/kubernetes/admin.conf ]; then
  sudo kubeadm init \
    --apiserver-advertise-address=\$(hostname -I | awk '{print \$1}') \
    --pod-network-cidr=192.168.0.0/16
fi

# Setup kubectl for ec2-user
mkdir -p /home/ec2-user/.kube
sudo cp /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Install Calico CNI
if ! sudo -u ec2-user kubectl get pods -n kube-system | grep -q calico; then
  echo "📦 Installing Calico CNI..."
  sudo -u ec2-user kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/calico.yaml
fi

# Generate and save join command
JOIN_CMD=\$(sudo kubeadm token create --print-join-command)
echo "\$JOIN_CMD" > /home/ec2-user/kubeadm-join-command.sh
chmod +x /home/ec2-user/kubeadm-join-command.sh
sudo chown ec2-user:ec2-user /home/ec2-user/kubeadm-join-command.sh

echo "✅ Master setup complete!"