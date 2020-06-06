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
 */

/*
 * IAM Policy
 */
