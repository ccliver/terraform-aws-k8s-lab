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

data "aws_iam_policy_document" "aws_lbc_trust" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  statement {
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "aws_lbc" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  name               = "${var.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc_trust[0].json

  tags = var.tags
}

resource "aws_iam_role_policy" "aws_lbc" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  name = "aws-lbc-policy"
  role = aws_iam_role.aws_lbc[0].id
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.17.0/docs/install/iam_policy.json
  policy = templatefile("${path.module}/policies/aws-lbc-policy.json", {
    vpc_id = var.vpc_id
  })
}

resource "aws_security_group" "aws_lbc" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  name        = "${var.name}-aws-lbc-sg"
  description = "Security group for AWS Load Balancer Controller"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-aws-lbc-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "aws_lbc_allow_from_nodes" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  description                  = "Allow AWS Load Balancer Controller to receive traffic from EKS nodes"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.aws_lbc[0].id
  referenced_security_group_id = module.eks.node_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "aws_lbc_allow_from_alb_allowed_cidrs_80" {
  count = var.deploy_aws_lbc_role && length(var.alb_allowed_cidrs) > 0 ? length(var.alb_allowed_cidrs) : 0

  description       = "Allow AWS Load Balancer Controller to receive traffic from ALB allowed CIDRs"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.aws_lbc[0].id
  cidr_ipv4         = var.alb_allowed_cidrs[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "aws_lbc_allow_from_alb_allowed_cidrs_443" {
  count = var.deploy_aws_lbc_role && length(var.alb_allowed_cidrs) > 0 ? length(var.alb_allowed_cidrs) : 0

  description       = "Allow AWS Load Balancer Controller to receive traffic from ALB allowed CIDRs"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.aws_lbc[0].id
  cidr_ipv4         = var.alb_allowed_cidrs[count.index]
}

resource "aws_vpc_security_group_egress_rule" "aws_lbc_allow_to_nodes" {
  count = var.deploy_aws_lbc_role ? 1 : 0

  description                  = "Allow AWS Load Balancer Controller to send traffic to EKS nodes"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.aws_lbc[0].id
  referenced_security_group_id = module.eks.node_security_group_id
}
