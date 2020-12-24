/**
 * Deployment User
 */
resource "aws_iam_user" "deploy_search" {
  name = "deploy-search"
  path = "/deployment/"
  tags = var.default_tags
}

module "search_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_search.id
  service      = "search"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
 * Deployment Role
 */
resource "aws_iam_role" "deploy_search" {
  name               = "deploy-search"
  description        = "Deployment role for 'search' service"
  assume_role_policy = data.aws_iam_policy_document.search_assume_role.json
}

data "aws_iam_policy_document" "search_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_search.arn]
    }
  }
}

