/**
 * User
 */
resource "aws_iam_user_policy" "push_image" {
  name   = "PushECRImage"
  user   = var.user
  policy = data.aws_iam_policy_document.push_image.json
}

/**
 * Role
 */
resource "aws_iam_role_policy" "repository" {
  name   = "ManageECR"
  role   = var.role
  policy = data.aws_iam_policy_document.ecs.json
}