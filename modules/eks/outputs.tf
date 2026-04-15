output "aws_lbc_role_arn" {
  description = "The ARN of the IAM Role created for the AWS Load Balancer Controller"
  value       = try(aws_iam_role.aws_lbc[0].arn, null)
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "alb_security_group_id" {
  description = "The ID of the security group created for the AWS Load Balancer Controller"
  value       = try(aws_security_group.aws_lbc[0].id, null)
}

output "cluster_autoscaler_role_arn" {
  description = "The ARN of the IAM Role created for the Cluster Autoscaler"
  value       = try(aws_iam_role.cluster_autoscaler[0].arn, null)
}

output "ebs_csi_role_arn" {
  description = "The ARN of the IAM Role created for the EBS CSI Driver"
  value       = try(aws_iam_role.ebs_csi[0].arn, null)
}

output "efs_csi_role_arn" {
  description = "The ARN of the IAM Role created for the EFS CSI Driver"
  value       = try(aws_iam_role.efs_csi[0].arn, null)
}

output "efs_file_system_id" {
  description = "The ID of the EFS file system created for the EFS CSI Driver"
  value       = try(aws_efs_file_system.this[0].id, null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(module.eks.oidc_provider_arn, null)
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(module.eks.oidc_provider, null)
}
