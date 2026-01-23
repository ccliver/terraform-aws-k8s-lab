variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet ids"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet ids"
}

variable "name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = null
}

variable "min_size" {
  type        = number
  description = "Minimum number of workers in EKS managed node group"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of workers in EKS managed node group"
  default     = 3
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = []
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types to use in the managed node group"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources created in the module"
  default     = {}
}

variable "capacity_type" {
  type        = string
  description = "The capacity type for the managed node group. Valid values are 'ON_DEMAND' and 'SPOT'"
  default     = "ON_DEMAND"
}

variable "eks_node_group_ami_type" {
  type        = string
  description = "The AMI type for the managed node group"
}

variable "deploy_aws_lbc_role" {
  type        = bool
  description = "Set to true to deploy the IAM role for the AWS Load Balancer Controller"
  default     = false
}
