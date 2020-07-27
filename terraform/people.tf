/*
 * Deployment User
 */
resource "aws_iam_user" "deploy_people" {
  name = "deploy-people"
  path = "/deployment/"
  tags = var.default_tags
}
module "people_remote_state" {
  source = "./modules/remote-backend"
  user   = aws_iam_user.deploy_people.id
  role   = "arn:aws:iam::939514526661:role/remotestate/people"
}

/*
 * Deployment Role
 */
resource "aws_iam_role" "deploy_people" {
  name               = "deploy-people"
  description        = "Deployment role for 'people' service"
  assume_role_policy = data.aws_iam_policy_document.people_assume_role.json
}
data "aws_iam_policy_document" "people_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_people.arn]
    }
  }
}

/*
 * Modules
 */
module "people_dynamodb" {
  source  = "./modules/dynamodb"
  service = "people"
  role    = aws_iam_role.deploy_people.id
  account = lookup(var.aws_accounts, local.environment)
}

/*
 * AWS Policies
 */

/*
 * IAM Policy
 */

