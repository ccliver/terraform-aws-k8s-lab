output "control_plane_id" {
  description = "The control plane's instance id"
  value       = try(module.kubeadm[0].control_plane_id, null)
}

output "control_plane_public_ip" {
  description = "The control plane's public IP"
  value       = try(module.kubeadm[0].control_plane_public_ip, null)
}

output "etcd_backup_bucket" {
  description = "S3 bucket to save ETCD backups to"
  value       = try(module.kubeadm[0].etcd_backup_bucket, null)
}

output "kubectl_cert_data_ssm_parameters" {
  description = "List of SSM Parameter ARNs containing cert data for kubectl config. This will only be populated if `var.use_kubeadm=true"
  value       = try(module.kubeadm[0].kubectl_cert_data_ssm_parameters, null)
}

output "aws_lbc_role_arn" {
  description = "The ARN of the IAM Role created for the AWS Load Balancer Controller"
  value       = try(module.eks[0].aws_lbc_role_arn, null)
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = try(module.eks[0].cluster_endpoint, null)
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  ephemeral   = true
  value       = try(module.eks[0].cluster_certificate_authority_data, null)
}
