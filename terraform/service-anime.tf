/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_anime" {
  name = "deploy-anime"
  path = "/deployment/"
  tags = var.default_tags
}

module "anime_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_anime.id
  service      = "anime"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
 * Deployment Role
 */
resource "aws_iam_role" "deploy_anime" {
  name               = "deploy-anime"
  description        = "Deployment role for 'anime' service"
  assume_role_policy = data.aws_iam_policy_document.anime_assume_role.json
}

data "aws_iam_policy_document" "anime_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_anime.arn]
    }
  }
}

/**
 * Modules
 */
module "anime_dynamodb" {
  source  = "./modules/dynamodb"
  service = "anime"
  role    = aws_iam_role.deploy_anime.id
  account = lookup(var.aws_accounts, local.environment)
}

module "anime_ssm" {
  source  = "./modules/ssm-params"
  service = "anime"
  role    = aws_iam_role.deploy_anime.id
  account = lookup(var.aws_accounts, local.environment)
}

