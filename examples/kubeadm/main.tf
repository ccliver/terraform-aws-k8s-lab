provider "aws" {
  region = "us-east-1"
}

module "k8s_lab" {
  source = "../.."

  use_kubeadm                = true
  app_name                   = var.app_name
  project_name               = "${var.app_name}-kubeadm-example"
  create_etcd_backups_bucket = var.create_etcd_backups_bucket
  api_allowed_cidrs          = var.api_allowed_cidrs
  min_node_instances         = 2
  max_node_instances         = 4
  ubuntu_version             = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-2025*"
  kubernetes_version         = "1.33.0-1.1"
}
