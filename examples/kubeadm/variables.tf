variable "create_etcd_backups_bucket" {
  type        = bool
  description = "Set this to true to create a versioned and encrypted private bucket to store ETCD backups."
  default     = false
}

variable "api_allowed_cidrs" {
  type        = list(any)
  description = "A list of CIDRs granted access to the control plane API"
  default     = []
}
