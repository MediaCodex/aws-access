resource "aws_iam_user_policy" "backend" {
  name   = "AccessTerraformBackend"
  user   = var.user
  policy = data.aws_iam_policy_document.backend.json
}

data "aws_iam_policy_document" "backend" {
  statement {
    sid = "DynamoLock"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [var.lock_table]
  }

  statement {
    sid = "S3ListObjects"

    actions = [
      "s3:ListBucket"
    ]

    resources = [var.state_bucket]
  }

  statement {
    sid  = "S3GetAndPutObjects"

    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]

    resources = [
      "${var.state_bucket}/state/${terraform.workspace}/${var.service}.tfstate",
      "${var.state_bucket}/plan/${var.service}/*.tfplan"
    ]
  }
}
