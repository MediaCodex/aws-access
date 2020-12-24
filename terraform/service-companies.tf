/**
 * Deployment User
 */
resource "aws_iam_user" "deploy_companies" {
  name = "deploy-companies"
  path = "/deployment/"
  tags = var.default_tags
}

module "companies_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_companies.id
  service      = "companies"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
 * Deployment Role
 */
resource "aws_iam_role" "deploy_companies" {
  name               = "deploy-companies"
  description        = "Deployment role for 'companies' service"
  assume_role_policy = data.aws_iam_policy_document.companies_assume_role.json
}

data "aws_iam_policy_document" "companies_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_companies.arn]
    }
  }
}

/**
 * Modules
 */
module "companies_dynamodb" {
  source  = "./modules/dynamodb"
  service = "companies"
  role    = aws_iam_role.deploy_companies.id
  account = lookup(var.aws_accounts, local.environment)
}

/**
 * AWS Policies
 */

/**
 * IAM Policy
 */

