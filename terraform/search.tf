/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_search" {
  name = "deploy-search"
  path = "/deployment/"
  tags = var.default_tags
}
module "search_remote_state" {
  source = "./modules/remote-backend"
  user   = aws_iam_user.deploy_search.id
  role   = "arn:aws:iam::939514526661:role/remotestate/search"
}

/*
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

/*
 * Modules
 */

/*
 * AWS Policies
 */

/*
 * IAM Policy
 */

