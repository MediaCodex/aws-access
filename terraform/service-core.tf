/**
 * Deployment User
 */
resource "aws_iam_user" "deploy_core" {
  name = "deploy-core"
  path = "/deployment/"
  tags = var.default_tags
}

module "core_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_core.id
  service      = "core"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
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

/**
 * Modules
 */
module "core_ssm" {
  source  = "./modules/ssm-params"
  service = "core"
  role    = aws_iam_role.deploy_core.id
  account = lookup(var.aws_accounts, local.environment)
}

/**
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

/**
 * IAM Policy
 */

