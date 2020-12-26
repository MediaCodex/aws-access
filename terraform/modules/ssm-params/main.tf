resource "aws_iam_role_policy" "ssm" {
  name   = "SSMParams"
  role   = var.role
  policy = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "ssm" {
  // Read shared
  dynamic "statement" {
    for_each = var.read_all == true ? ["ReadSharedParams"] : []
    content {
      sid = "ReadSharedParams"

      actions = [
        "ssm:GetParameter*",
        "ssm:DescribeParameters"
      ]

      resources = [
        "arn:aws:ssm:*:${var.account}:parameter/shared/*"
      ]
    }
  }

  // Write shared
  statement {
    sid = "WriteSharedParams"

    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter*"
    ]

    resources = [
      "arn:aws:ssm:*:${var.account}:parameter/shared/*"
    ]

    condition {
      test     = "StringLike"
      variable = "ssm:ResourceTag/Service"
      values   = [var.service]
    }
  }

  // Read/Write own params
  statement {
    sid = "ManageNamespacedParams"

    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter*",
      "ssm:DeleteParameter*",
      "ssm:DescribeParameters"
    ]

    resources = [ 
      "arn:aws:ssm:*:${var.account}:parameter/${var.service}/*"
    ]
  }
}