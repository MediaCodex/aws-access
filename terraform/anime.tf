/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_anime" {
  name = "deploy-anime"
  path = "/deployment/"
  tags = var.default_tags
}
module "anime_remote_state" {
  source = "./modules/remote-backend"
  user   = aws_iam_user.deploy_anime.id
  role   = "arn:aws:iam::939514526661:role/remotestate/anime"
}

/*
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

/*
 * Modules
 */
module "anime_dynamodb" {
  source  = "./modules/dynamodb"
  service = "anime"
  role    = aws_iam_role.deploy_anime.id
  account = lookup(var.aws_accounts, local.environment)
}

/*
 * AWS Policies
 */

/*
 * IAM Policy
 */

