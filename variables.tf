variable "app_name" {
  type        = string
  description = "A name for various resources"
  default     = "k8s-lab"
}

variable "project_name" {
  type        = string
  description = "The name of the overall project"
  default     = "k8s-lab"
}

variable "control_plane_instance_type" {
  type        = string
  description = "The instance type to use for control plane"
  default     = "t3a.small"
}

variable "node_instance_type" {
  type        = string
  description = "The instance type to use for nodes"
  default     = "t3a.small"
}

variable "max_node_instances" {
  type        = number
  description = "The maximum number of nodes to launch"
  default     = 3
}

variable "min_node_instances" {
  type        = number
  description = "The minimum number of nodes to launch"
  default     = 1
}

variable "api_allowed_cidrs" {
  type        = list(any)
  description = "A list of CIDRs granted access to the control plane API"
  default     = []
}

variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes and associated tools to deploy"
  default     = "1.33.0-1.1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP range. This should not overlap with the default for Weavenet, 10.32.0.0/12."
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(any)
  description = "Public subnet IP ranges."
  default     = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
}

variable "private_subnet_cidrs" {
  type        = list(any)
  description = "Private subnet IP ranges."
  default     = ["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"]
}

variable "create_etcd_backups_bucket" {
  type        = bool
  description = "Set this to true to create a versioned and encrypted private bucket to store ETCD backups."
  default     = false
}

variable "use_kubeadm" {
  type        = bool
  description = "Build cluster with kubeadm on EC2 instances"
  default     = false
}

variable "use_eks" {
  type        = bool
  description = "Create a managed EKS control plane and managed node group"
  default     = false
}

variable "eks_min_size" {
  type        = number
  description = "Minimum number of nodes in EKS managed node group"
  default     = 1
}

variable "eks_max_size" {
  type        = number
  description = "Maximum number of nodes in EKS managed node group"
  default     = 3
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = []
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types to use in the managed node group"
  default     = []
}

variable "ubuntu_version" {
  type        = string
  description = "Image location: `aws ec2 describe-images --region us-east-1 --owners 099720109477`"
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-202*"
}
