data "aws_iam_policy_document" "ecs" {
  statement {
    sid = "ManageRepositories"

    actions = [
      // repo
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:*RepositoryPolicy",
      "ecr:*LifecyclePolicy",
      // tags
      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    // NOTE: this actually allows you to fuck with the tags on the images too, but that's probably fine
    //       since this should be assigned to the same user/role that made the images anyway.
    resources = [
      "arn:aws:ecr:*:${var.account}:repository/${var.service}-*"
    ]
  }

  statement {
    sid = "ManageServices"

    actions = [
      // service
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:UpdateService",
      "ecs:DescribeServices",

      // tasks
      "ecs:RunTask",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:ListTasks",
      "ecs:DescribeTasks",

      // task-definitions
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:ListTaskDefinitionFamilies",

      // tags
      "ecs:ListTagsForResource",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]

    resources = [
      "arn:aws:ecs:*:${var.account}:service/${var.service}*",
      "arn:aws:ecs:*:${var.account}:task/${var.service}*",
      "arn:aws:ecs:*:${var.account}:task-definition/${var.service}*"
    ]
  }
}