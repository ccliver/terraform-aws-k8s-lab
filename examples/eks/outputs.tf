output "kubeconfig_command" {
  description = "AWS CLI command to update local kubeconfig for EKS"
  value       = "aws eks update-kubeconfig --name k8s-lab-eks-example --alias k8s-lab-eks-example --region us-east-1"
}
