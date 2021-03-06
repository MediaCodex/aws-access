/**
 * Deployment User
 */
resource "aws_iam_user" "deploy_aws_access" {
  name = "deploy-aws-access"
  path = "/deployment/"
  tags = var.default_tags
}

module "aws_access_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_aws_access.id
  service      = "aws-access"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
 * Deployment Role
 */
resource "aws_iam_role" "deploy_aws_access" {
  name               = "deploy-aws-access"
  description        = "Deployment role for 'aws-access' service"
  assume_role_policy = data.aws_iam_policy_document.aws_access_assume_role.json
}

data "aws_iam_policy_document" "aws_access_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_aws_access.arn]
    }
  }
}

/**
 * IAM Policy
 */
resource "aws_iam_role_policy" "aws_access_iam" {
  name   = "ManageDeployIam"
  role   = aws_iam_role.deploy_aws_access.id
  policy = data.aws_iam_policy_document.aws_access_iam.json
}

data "aws_iam_policy_document" "aws_access_iam" {
  statement {
    sid = "ModifyUsers"
    actions = [
      "iam:*User",
      "iam:*UserPolicy",
      "iam:*UserPermissionsBoundary",
      "iam:ListUserPolicies",
      "iam:ListUserTags"
    ]
    resources = ["arn:aws:iam::*:user/deployment/*"]
    condition {
      test     = "ArnNotEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:iam::*:user/deployment/deploy-aws-access"]
    }
  }

  statement {
    sid = "ModifyRoles"
    actions = [
      "iam:*Role",
      "iam:*RolePolicy",
      "iam:*RolePermissionsBoundary",
      "iam:UpdateRoleDescription",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
    ]
    resources = ["arn:aws:iam::*:role/deploy-*"]
    condition {
      test     = "ArnNotEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:iam::*:role/deploy-aws-access"]
    }
  }

  statement {
    sid = "ReadOwnState"
    actions = [
      "iam:GetRole*",
      "iam:ListRole*",
      "iam:GetUser*",
      "iam:ListUser*"
    ]
    resources = [
      "arn:aws:iam::*:user/deployment/deploy-aws-access",
      "arn:aws:iam::*:role/deploy-aws-access"
    ]
  }

  statement {
    sid = "ListAll"
    actions = [
      "iam:ListUsers",
      "iam:ListRoles"
    ]
    resources = ["*"]
  }
}
