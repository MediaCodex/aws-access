resource "aws_iam_user_policy" "assume_remote_role" {
  name   = "AssumeRemoteBackendRole"
  user   = var.user
  policy = data.aws_iam_policy_document.assume_remote_role.json
}

data "aws_iam_policy_document" "assume_remote_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.role]
  }
}