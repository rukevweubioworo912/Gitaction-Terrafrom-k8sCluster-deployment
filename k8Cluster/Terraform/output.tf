output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_instance.k8s_master.public_ip
}


output "worker_public_ips" {
  description = "Public IPs of the worker nodes"
  value       = [for w in aws_instance.k8s_worker : w.public_ip]
}


output "worker_private_ips" {
  description = "Private IPs of the worker nodes"
  value       = [for w in aws_instance.k8s_worker : w.private_ip]

}

output "kubeadm_join_command" {
  description = "Use this command to join worker to master"
  value       = "kubeadm join ${aws_instance.k8s_master.private_ip}:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
}
