

variable "master_instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  default =    mykeyname
}

variable "vpc_id" {
  description = "VPC ID where instances will be launched"
  default= "10.0.0.0/16"
}

