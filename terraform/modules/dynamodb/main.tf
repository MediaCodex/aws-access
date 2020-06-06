resource "aws_iam_role_policy" "policy" {
  name   = "DynamoDB"
  role   = var.role
  policy = data.aws_iam_policy_document.document.json
}

data "aws_iam_policy_document" "document" {
  statement {
    sid = "Table"
    actions = [
      "dynamodb:*"
    ]
    not_actions = [
      "dynamodb:DeleteBackup",
      "dynamodb:RestoreTableFromBackup",
      "dynamodb:RestoreTableToPointInTime"
    ]
    resources = [
      "arn:aws:dynamodb:*:${var.account}:table/${var.service}-*",
      "arn:aws:dynamodb:*:${var.account}:table/${var.service}-*/index/*",
      "arn:aws:dynamodb:*:${var.account}:table/${var.service}-*/stream/*",
      "arn:aws:dynamodb:*:${var.account}:table/${var.service}-*/backups/*",
      "arn:aws:dynamodb:*:${var.account}:global-table/${var.service}-*"
    ]
  }

  statement {
    sid = "Global"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:PurchaseReservedCapacityOfferings"
    ]
    resources = [
      "arn:aws:dynamodb:region:${var.account}:*"
    ]
  }
}