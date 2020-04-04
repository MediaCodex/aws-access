/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_infrastructure" {
  name = "deploy-infrastructure"
  path = "/deployment/"
  tags = var.default_tags
}
module "tfstate_infrastructure" {
  source = "../modules/policy-remotestate"
  user   = aws_iam_user.deploy_infrastructure.id
  object = "infrastructure.tfstate"
  table  = aws_dynamodb_table.terraform_lock.arn
  bucket = aws_s3_bucket.terraform_state.arn
}

/*
 * Deployment Role
 */
resource "aws_iam_role" "deploy_infrastructure" {
  name               = "deploy-infrastructure"
  description        = "Deployment role for 'Infrastructure' service"
  assume_role_policy = data.aws_iam_policy_document.infrastructure_assume_role.json
}
data "aws_iam_policy_document" "infrastructure_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_infrastructure.arn]
    }
  }
}

/*
 * AWS Policies
 */
resource "aws_iam_role_policy_attachment" "infrastructure_ses" {
  role       = aws_iam_role.deploy_infrastructure.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}
resource "aws_iam_role_policy_attachment" "infrastructure_cognito" {
  role       = aws_iam_role.deploy_infrastructure.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

/*
 * IAM Policy
 */
resource "aws_iam_role_policy" "infrastructure_iam" {
  name   = "ManageDeployIam"
  role   = aws_iam_role.deploy_infrastructure.id
  policy = data.aws_iam_policy_document.infrastructure_iam.json
}
data "aws_iam_policy_document" "infrastructure_iam" {
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
      values   = ["arn:aws:iam::*:user/deployment/deploy-infrastructure"]
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
      values   = ["arn:aws:iam::*:role/deploy-infrastructure"]
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
      "arn:aws:iam::*:user/deployment/deploy-infrastructure",
      "arn:aws:iam::*:role/deploy-infrastructure"
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

/*
 * DynamoDB Policy
 */
resource "aws_iam_role_policy" "infrastructure_dynamodb" {
  name   = "DynamoDB"
  role   = aws_iam_role.deploy_infrastructure.id
  policy = data.aws_iam_policy_document.infrastructure_dynamodb.json
}
data "aws_iam_policy_document" "infrastructure_dynamodb" {
  statement {
    sid = "AdminTable"
    actions = [
      "dynamodb:Describe*",
      "dynamodb:CreateTable",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:UpdateTable",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:DeleteTable",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UnTagResource"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/terraform-lock"]
  }

  statement {
    sid = "ListTables"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeLimits"
    ]
    resources = ["*"]
  }
}

/*
 * S3 Policy
 */
resource "aws_iam_role_policy" "infrastructure_s3" {
  name   = "S3"
  role   = aws_iam_role.deploy_infrastructure.id
  policy = data.aws_iam_policy_document.infrastructure_s3.json
}
data "aws_iam_policy_document" "infrastructure_s3" {
  statement {
    sid = "AdminTable"
    actions = [
      "s3:ListBucket*",
      "s3:CreateBucket",
      "s3:DeleteBucket*",
      "s3:PutBucket*",
      "s3:Get*Configuration",
      "s3:Put*Configuration",
      "s3:GetBucket*"
    ]
    resources = ["arn:aws:s3:::terraform-state*"]
  }

  statement {
    sid = "ListBucket"
    actions = [
      "s3:HeadBucket"
    ]
    resources = ["*"]
  }
}
