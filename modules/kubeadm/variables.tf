variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "app_name" {
  type        = string
  description = "A name for various resources"
}

variable "control_plane_instance_type" {
  type        = string
  description = "The instance type to use for control plane"
}

variable "node_instance_type" {
  type        = string
  description = "The instance type to use for nodes"
}

variable "max_node_instances" {
  type        = number
  description = "The maximum number of nodes to launch"
}

variable "min_node_instances" {
  type        = number
  description = "The minimum number of nodes to launch"
}

variable "api_allowed_cidrs" {
  type        = list(any)
  description = "A list of CIDRs granted access to the control plane API"
  default     = []
}

variable "kubernetes_version" {
  type        = string
  description = "The version of kubernets and associated tools to deploy"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP range. This should not overlap with the default for Weavenet, 10.32.0.0/12."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet ids"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet ids"
}

variable "create_etcd_backups_bucket" {
  type        = bool
  description = "Set this to true to create a versioned and encrypted private bucket to store ETCD backups."
  default     = false
}

variable "ubuntu_version" {
  type        = string
  description = "Image location: `aws ec2 describe-images --region us-east-1 --owners 099720109477`"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources created in the module"
  default     = {}
}
