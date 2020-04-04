resource "aws_iam_user_policy" "terraform_state" {
  name   = "TerraformRemoteState"
  user   = var.user
  policy = data.aws_iam_policy_document.terraform_state.json
}

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid = "S3State"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["${var.bucket}/${var.object}"]
  }

    statement {
    sid = "S3ListObjects"
    actions = [
      "s3:ListBucket"
    ]
    resources = [var.bucket]
  }

  statement {
    sid = "DynamoLock"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [var.table]
  }
}