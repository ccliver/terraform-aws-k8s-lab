data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
  efs_subnets = var.deploy_efs_csi_role ? toset(var.private_subnets) : toset([])
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.private_subnets
  control_plane_subnet_ids                 = var.public_subnets
  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = var.endpoint_public_access_cidrs
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types

      min_size = var.min_size
      max_size = var.max_size
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size  = var.min_size
      capacity_type = var.capacity_type
      ami_type      = var.eks_node_group_ami_type
    }

  }
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_alb = {
      description              = "Allow ALB to node all ports/protocols"
      protocol                 = "tcp"
      from_port                = 1024
      to_port                  = 65535
      type                     = "ingress"
      source_security_group_id = aws_security_group.aws_lbc[0].id
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = var.tags
}

resource "aws_efs_file_system" "this" {
  count = var.deploy_efs_csi_role ? 1 : 0

  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = var.tags
}

resource "aws_security_group" "efs" {
  count = var.deploy_efs_csi_role ? 1 : 0

  name        = "${var.name}-efs"
  description = "EFS NFS access from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = local.efs_subnets

  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs[0].id]
}
