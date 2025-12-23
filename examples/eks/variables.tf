variable "app_name" {
  type        = string
  description = "A name for various resources"
  default     = "k8s-lab"
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = []
}
