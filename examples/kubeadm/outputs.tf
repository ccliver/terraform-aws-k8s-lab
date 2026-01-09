output "control_plane_id" {
  description = "The control plane's instance id"
  value       = module.k8s_lab.control_plane_id
}

output "control_plane_public_endpoint" {
  description = "The control plane's endpoint"
  value       = "https://${module.k8s_lab.control_plane_public_ip}:6443"
}

output "etcd_backup_bucket" {
  description = "S3 bucket to save ETCD backups to"
  value       = module.k8s_lab.etcd_backup_bucket
}

output "kubectl_cert_data_ssm_parameters" {
  description = "List of SSM Parameter ARNs containing cert data for kubectl config"
  value       = module.k8s_lab.kubectl_cert_data_ssm_parameters
}
