/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_companies" {
  name = "deploy-companies"
  path = "/deployment/"
  tags = var.default_tags
}
module "companies_remote_state" {
  source = "./modules/remote-backend"
  user   = aws_iam_user.deploy_companies.id
  role   = "arn:aws:iam::939514526661:role/remotestate/companies"
}

/*
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

/*
 * Modules
 */
module "companies_dynamodb" {
  source  = "./modules/dynamodb"
  service = "companies"
  role    = aws_iam_role.deploy_companies.id
  account = lookup(var.aws_accounts, local.environment)
}

/*
 * AWS Policies
 */

/*
 * IAM Policy
 */

