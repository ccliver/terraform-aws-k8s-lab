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

variable "alb_allowed_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to access the ALB provisioned by the AWS Load Balancer Controller"
  default     = []
}

variable "deploy_cluster_autoscaler_role" {
  type        = bool
  description = "Set to true to deploy the IAM role for the Cluster Autoscaler"
  default     = false
}

variable "deploy_ebs_csi_role" {
  type        = bool
  description = "Set to true to deploy the IAM role for the EBS CSI Driver"
  default     = false
}

variable "deploy_efs_csi_role" {
  type        = bool
  description = "Set to true to deploy the IAM role for the EFS CSI Driver"
  default     = false
}

variable "use_pod_identity" {
  type        = bool
  description = "Set to true to deploy the IAM role and service account for pod identity"
  default     = false
}

variable "aws_lbc_service_account" {
  type        = string
  description = "The name of the Kubernetes service account to associate with the AWS Load Balancer Controller IAM role"
  default     = "aws-load-balancer-controller"
}

variable "cluster_autoscaler_service_account" {
  type        = string
  description = "The name of the Kubernetes service account to associate with the Cluster Autoscaler IAM role"
  default     = "cluster-autoscaler"
}

variable "ebs_csi_service_account" {
  type        = string
  description = "The name of the Kubernetes service account to associate with the EBS CSI Driver IAM role"
  default     = "ebs-csi-controller-sa"
}

variable "efs_csi_service_account" {
  type        = string
  description = "The name of the Kubernetes service account to associate with the EFS CSI Driver IAM role"
  default     = "efs-csi-controller-sa"
}

variable "eks_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type = map(object({
    name                 = optional(string) # will fall back to map key
    before_compute       = optional(bool, false)
    most_recent          = optional(bool, true)
    addon_version        = optional(string)
    configuration_values = optional(string)
    pod_identity_association = optional(list(object({
      role_arn        = string
      service_account = string
    })))
    preserve                    = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "NONE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }), {})
    tags = optional(map(string), {})
  }))
  default = null
}
