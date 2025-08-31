output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_instance.k8s_master.public_ip
}

output "worker_public_ip" {
  description = "Public IP of the worker node"
  value       = aws_instance.k8s_worker.public_ip
}


output "kubeadm_join_command" {
  description = "Use this command to join worker to master"
  value       = "kubeadm join ${aws_instance.k8s_master.private_ip}:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
}
