#!/bin/bash



if [ -z "$1" ]; then
    echo "Error: You must provide the kubeadm join command from the master node."
    echo "Usage: $0 \"<kubeadm-join-command>\""
    exit 1
fi

JOIN_COMMAND="$1"

# Connect as root
sudo su <<EOF

# Update the system
yum update -y

# Install Docker
yum install -y docker
systemctl enable --now docker
systemctl start docker

# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add Kubernetes repo
cat <<EOL | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOL

# Install Kubernetes components
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

# Join the cluster using the provided command
$JOIN_COMMAND

EOF
