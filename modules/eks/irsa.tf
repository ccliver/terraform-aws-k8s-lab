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
  from_port                    = 1024
  to_port                      = 65535
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.aws_lbc[0].id
  referenced_security_group_id = module.eks.node_security_group_id
}

data "aws_iam_policy_document" "cluster_autoscaler_trust" {
  count = var.deploy_cluster_autoscaler_role ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.deploy_cluster_autoscaler_role ? 1 : 0

  name               = "${var.name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_trust[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  count = var.deploy_cluster_autoscaler_role ? 1 : 0

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.name}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  count = var.deploy_cluster_autoscaler_role ? 1 : 0

  name   = "cluster-autoscaler-policy"
  role   = aws_iam_role.cluster_autoscaler[0].id
  policy = data.aws_iam_policy_document.cluster_autoscaler_policy[0].json
}

data "aws_iam_policy_document" "ebs_csi_trust" {
  count = var.deploy_ebs_csi_role ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  count = var.deploy_ebs_csi_role ? 1 : 0

  name               = "${var.name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "ebs_csi_policy" {
  count = var.deploy_ebs_csi_role ? 1 : 0

  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateVolume",
        "CreateSnapshot"
      ]
    }
  }

  statement {
    actions = [
      "ec2:DeleteTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
  }

  statement {
    actions = [
      "ec2:CreateVolume"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "ec2:DeleteVolume"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "ec2:DeleteSnapshot"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
      values   = ["*"]
    }
  }

  statement {
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = ["arn:aws:kms:*:*:key/*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]

    resources = ["arn:aws:kms:*:*:key/*"]
  }
}

resource "aws_iam_role_policy" "ebs_csi" {
  count = var.deploy_ebs_csi_role ? 1 : 0

  name   = "ebs-csi-policy"
  role   = aws_iam_role.ebs_csi[0].id
  policy = data.aws_iam_policy_document.ebs_csi_policy[0].json
}

data "aws_iam_policy_document" "efs_csi_trust" {
  count = var.deploy_efs_csi_role ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "efs_csi" {
  count = var.deploy_efs_csi_role ? 1 : 0

  name               = "${var.name}-efs-csi"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_trust[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "efs_csi_policy" {
  count = var.deploy_efs_csi_role ? 1 : 0

  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:DeleteAccessPoint",
      "elasticfilesystem:TagResource"
    ]
    resources = [
      "arn:aws:elasticfilesystem:${local.region}:${local.account_id}:file-system/${aws_efs_file_system.this[0].id}",
      "arn:aws:elasticfilesystem:${local.region}:${local.account_id}:access-point/*"
    ]
  }
}

resource "aws_iam_role_policy" "efs_csi" {
  count = var.deploy_efs_csi_role ? 1 : 0

  name   = "efs-csi-policy"
  role   = aws_iam_role.efs_csi[0].id
  policy = data.aws_iam_policy_document.efs_csi_policy[0].json
}

data "aws_iam_policy_document" "secrets_manager_csi_trust" {
  count = var.deploy_secrets_manager_csi_role ? 1 : 0

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
      values   = ["system:serviceaccount:kube-system:secrets-manager-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "secrets_manager_csi" {
  count = var.deploy_secrets_manager_csi_role ? 1 : 0

  name               = "${var.name}-secrets-manager-csi"
  assume_role_policy = data.aws_iam_policy_document.secrets_manager_csi_trust[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "secrets_manager_csi_policy" {
  for_each = toset(var.secret_arns)

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [each.value]
  }
}

resource "aws_iam_role_policy" "secrets_manager_csi" {
  count = var.deploy_secrets_manager_csi_role ? 1 : 0

  name   = "secrets-manager-csi-policy"
  role   = aws_iam_role.secrets_manager_csi[0].id
  policy = data.aws_iam_policy_document.secrets_manager_csi_policy[0].json
}
