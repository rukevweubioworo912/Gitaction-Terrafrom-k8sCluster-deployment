#!/bin/bash

sudo su

yum update -y

yum install -y docker
systemctl enable --now docker
systemctl start docker

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

kubeadm init --apiserver-advertise-address=<private-ip-of-control-plane> --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/calico.yaml
kubectl apply -f calico.yaml

kubeadm token create --print-join-command
