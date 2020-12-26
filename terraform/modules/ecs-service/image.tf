data "aws_iam_policy_document" "push_image" {
  // docker auth
  statement {
    sid = "GetAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  // list images
  statement {
    sid = "ListImagesInRepository"
    
    actions = [
      "ecr:ListImages"
    ]

    resources = [
      "arn:aws:ecr:*:${var.account}:repository/my-repo"
    ]
  }

  // upload image
  statement {
    sid = "ManageRepositoryContents"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      "arn:aws:ecr:*:${var.account}:repository/${var.service}-*"
    ]
  }
}