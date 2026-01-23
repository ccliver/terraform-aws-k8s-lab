output "aws_lbc_role_arn" {
  description = "The ARN of the IAM Role created for the AWS Load Balancer Controller"
  value       = try(aws_iam_role.aws_lbc[0].arn, null)
}
