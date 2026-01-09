# Module to setup a Kubernetes lab on AWS

[![pre-commit-terraform](https://github.com/ccliver/terraform-aws-k8s-lab/actions/workflows/pr-check.yml/badge.svg)](https://github.com/ccliver/terraform-aws-k8s-lab/actions/workflows/pr-check.yml)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k8s_lab"></a> [k8s\_lab](#module\_k8s\_lab) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_allowed_cidrs"></a> [api\_allowed\_cidrs](#input\_api\_allowed\_cidrs) | A list of CIDRs granted access to the control plane API | `list(any)` | `[]` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | A name for various resources | `string` | `"k8s-lab"` | no |
| <a name="input_create_etcd_backups_bucket"></a> [create\_etcd\_backups\_bucket](#input\_create\_etcd\_backups\_bucket) | Set this to true to create a versioned and encrypted private bucket to store ETCD backups. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane_id"></a> [control\_plane\_id](#output\_control\_plane\_id) | The control plane's instance id |
| <a name="output_control_plane_public_endpoint"></a> [control\_plane\_public\_endpoint](#output\_control\_plane\_public\_endpoint) | The control plane's endpoint |
| <a name="output_etcd_backup_bucket"></a> [etcd\_backup\_bucket](#output\_etcd\_backup\_bucket) | S3 bucket to save ETCD backups to |
| <a name="output_kubectl_cert_data_ssm_parameters"></a> [kubectl\_cert\_data\_ssm\_parameters](#output\_kubectl\_cert\_data\_ssm\_parameters) | List of SSM Parameter ARNs containing cert data for kubectl config |
<!-- END_TF_DOCS -->
