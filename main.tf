data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = data.aws_availability_zones.available.names
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"
  name    = var.project
  cidr    = var.vpc_cidr
  azs = [
    local.azs[0],
    local.azs[1],
    local.azs[2]
  ]
  public_subnets             = var.public_subnet_cidrs
  private_subnets            = var.private_subnet_cidrs
  manage_default_network_acl = false
  enable_nat_gateway         = true
  single_nat_gateway         = false

  tags = {
    Project = var.project
  }
}

module "kubeadm" {
  count = var.use_kubeadm ? 1 : 0

  source = "./modules/kubeadm"

  project                     = var.project
  vpc_id                      = module.vpc.vpc_id
  vpc_cidr                    = var.vpc_cidr
  control_plane_instance_type = var.control_plane_instance_type
  node_instance_type          = var.node_instance_type
  max_node_instances          = var.max_node_instances
  min_node_instances          = var.min_node_instances
  api_allowed_cidrs           = var.api_allowed_cidrs
  kubernetes_version          = var.kubernetes_version
  public_subnets              = module.vpc.public_subnets
  private_subnets             = module.vpc.private_subnets
  create_etcd_backups_bucket  = var.create_etcd_backups_bucket
  ubuntu_version              = var.ubuntu_version

  tags = {
    Project = var.project
  }
}

module "eks" {
  count = var.use_eks ? 1 : 0

  source = "./modules/eks"

  name                         = var.project
  kubernetes_version           = substr(var.kubernetes_version, 0, 4)
  vpc_id                       = module.vpc.vpc_id
  public_subnets               = module.vpc.public_subnets
  private_subnets              = module.vpc.private_subnets
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  min_size                     = var.eks_min_size
  max_size                     = var.eks_max_size
  instance_types               = var.instance_types
  capacity_type                = var.eks_capacity_type
  eks_node_group_ami_type      = var.eks_node_group_ami_type

  tags = {
    Project = var.project
  }
}
