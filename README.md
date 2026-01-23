# Setup a Kubernetes lab in AWS using kubeadm or EKS

[![CI](https://github.com/ccliver/terraform-aws-k8s-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/ccliver/terraform-aws-k8s-lab/actions/workflows/ci.yml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | ./modules/eks | n/a |
| <a name="module_kubeadm"></a> [kubeadm](#module\_kubeadm) | ./modules/kubeadm | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_allowed_cidrs"></a> [api\_allowed\_cidrs](#input\_api\_allowed\_cidrs) | A list of CIDRs granted access to the control plane API | `list(any)` | `[]` | no |
| <a name="input_control_plane_instance_type"></a> [control\_plane\_instance\_type](#input\_control\_plane\_instance\_type) | The instance type to use for control plane | `string` | `"t3a.small"` | no |
| <a name="input_create_etcd_backups_bucket"></a> [create\_etcd\_backups\_bucket](#input\_create\_etcd\_backups\_bucket) | Set this to true to create a versioned and encrypted private bucket to store ETCD backups. | `bool` | `false` | no |
| <a name="input_deploy_aws_lbc_role"></a> [deploy\_aws\_lbc\_role](#input\_deploy\_aws\_lbc\_role) | Set to true to deploy the IAM role for the AWS Load Balancer Controller | `bool` | `false` | no |
| <a name="input_eks_capacity_type"></a> [eks\_capacity\_type](#input\_eks\_capacity\_type) | The capacity type for the managed node group. Valid values are 'ON\_DEMAND' and 'SPOT' | `string` | `"ON_DEMAND"` | no |
| <a name="input_eks_max_size"></a> [eks\_max\_size](#input\_eks\_max\_size) | Maximum number of nodes in EKS managed node group | `number` | `3` | no |
| <a name="input_eks_min_size"></a> [eks\_min\_size](#input\_eks\_min\_size) | Minimum number of nodes in EKS managed node group | `number` | `1` | no |
| <a name="input_eks_node_group_ami_type"></a> [eks\_node\_group\_ami\_type](#input\_eks\_node\_group\_ami\_type) | The AMI type for the managed node group. See https://github.com/awslabs/amazon-eks-ami/releases for valid values | `string` | `"AL2023_x86_64_STANDARD"` | no |
| <a name="input_endpoint_public_access_cidrs"></a> [endpoint\_public\_access\_cidrs](#input\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | `[]` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | List of instance types to use in the managed node group | `list(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version of Kubernetes and associated tools to deploy | `string` | `"1.33.0-1.1"` | no |
| <a name="input_max_node_instances"></a> [max\_node\_instances](#input\_max\_node\_instances) | The maximum number of nodes to launch | `number` | `3` | no |
| <a name="input_min_node_instances"></a> [min\_node\_instances](#input\_min\_node\_instances) | The minimum number of nodes to launch | `number` | `1` | no |
| <a name="input_node_instance_type"></a> [node\_instance\_type](#input\_node\_instance\_type) | The instance type to use for nodes | `string` | `"t3a.small"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | Private subnet IP ranges. | `list(any)` | <pre>[<br/>  "172.31.48.0/20",<br/>  "172.31.64.0/20",<br/>  "172.31.80.0/20"<br/>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the project | `string` | `"k8s-lab"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | Public subnet IP ranges. | `list(any)` | <pre>[<br/>  "172.31.0.0/20",<br/>  "172.31.16.0/20",<br/>  "172.31.32.0/20"<br/>]</pre> | no |
| <a name="input_ubuntu_version"></a> [ubuntu\_version](#input\_ubuntu\_version) | Image location: `aws ec2 describe-images --region us-east-1 --owners 099720109477` | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-202*"` | no |
| <a name="input_use_eks"></a> [use\_eks](#input\_use\_eks) | Create a managed EKS control plane and managed node group | `bool` | `false` | no |
| <a name="input_use_kubeadm"></a> [use\_kubeadm](#input\_use\_kubeadm) | Build cluster with kubeadm on EC2 instances | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP range. This should not overlap with the default for Weavenet, 10.32.0.0/12. | `string` | `"172.31.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane_id"></a> [control\_plane\_id](#output\_control\_plane\_id) | The control plane's instance id |
| <a name="output_control_plane_public_ip"></a> [control\_plane\_public\_ip](#output\_control\_plane\_public\_ip) | The control plane's public IP |
| <a name="output_eks_outputs"></a> [eks\_outputs](#output\_eks\_outputs) | The ARN of the IAM Role created for the AWS Load Balancer Controller |
| <a name="output_etcd_backup_bucket"></a> [etcd\_backup\_bucket](#output\_etcd\_backup\_bucket) | S3 bucket to save ETCD backups to |
| <a name="output_kubectl_cert_data_ssm_parameters"></a> [kubectl\_cert\_data\_ssm\_parameters](#output\_kubectl\_cert\_data\_ssm\_parameters) | List of SSM Parameter ARNs containing cert data for kubectl config. This will only be populated if `var.use_kubeadm=true` |
<!-- END_TF_DOCS -->
