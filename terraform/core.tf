/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_core" {
  name = "deploy-core"
  path = "/deployment/"
  tags = var.default_tags
}
module "remote_state_core" {
  source = "./modules/remote-backend"
  user   = aws_iam_user.deploy_core.id
  role   = "arn:aws:iam::939514526661:role/remotestate/core"
}

/*
 * Deployment Role
 */
resource "aws_iam_role" "deploy_core" {
  name               = "deploy-core"
  description        = "Deployment role for 'core' service"
  assume_role_policy = data.aws_iam_policy_document.core_assume_role.json
}
data "aws_iam_policy_document" "core_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_core.arn]
    }
  }
}

/*
 * AWS Policies
 * TODO: limit to specific resources or prefixes
 */
resource "aws_iam_role_policy_attachment" "core_gateway" {
  role       = aws_iam_role.deploy_core.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
resource "aws_iam_role_policy_attachment" "core_ses" {
  role       = aws_iam_role.deploy_core.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

/*
 * IAM Policy
 */
resource "aws_iam_role_policy" "core_cognito" {
  name   = "Cognito"
  role   = aws_iam_role.deploy_core.id
  policy = data.aws_iam_policy_document.core_cognito.json
}
data "aws_iam_policy_document" "core_cognito" {
  statement {
    sid = "UserPool"
    actions = [
      "cognito-idp:TagResource",
      "cognito-idp:DeleteGroup",
      "cognito-idp:UpdateUserPoolDomain",
      "cognito-idp:DeleteUserPool",
      "cognito-idp:CreateGroup",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:UpdateUserPoolClient",
      "cognito-idp:ListTagsForResource",
      "cognito-idp:GetUserPoolMfaConfig",
      "cognito-idp:DeleteUserPoolDomain",
      "cognito-idp:ListUserPoolClients",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:CreateUserPoolDomain",
      "cognito-idp:UntagResource",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:UpdateGroup",
      "cognito-idp:SetUserPoolMfaConfig",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:DescribeUserPoolClient"
    ]
    resources = ["arn:aws:cognito-idp:*:*:userpool/*"]
  }

  statement {
    sid = "Global"
    actions = [
      "cognito-idp:DescribeUserPoolDomain",
      "cognito-idp:CreateUserPool",
      "cognito-idp:ListUserPools"
    ]
    resources = ["*"]
  }
}
