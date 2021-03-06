

/**
 * Deployment User
 */
resource "aws_iam_user" "deploy_website" {
  name = "deploy-website"
  path = "/deployment/"
  tags = var.default_tags
}

module "website_tf_backend" {
  source       = "./modules/tf-backend"
  user         = aws_iam_user.deploy_website.id
  service      = "website"
  state_bucket = local.backend_state_bucket
  lock_table   = local.backend_lock_table
}

/**
 * Deployment Role
 */
resource "aws_iam_role" "deploy_website" {
  name               = "deploy-website"
  description        = "Deployment role for main website"
  assume_role_policy = data.aws_iam_policy_document.website_assume_role.json
}

data "aws_iam_policy_document" "website_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.deploy_website.arn]
    }
  }
}

/**
 * IAM Policy (deploy)
 */
data "aws_ssm_parameter" "website_distribution_arn" {
  count = var.first_deploy == true ? 0 : 1
  name  = "/website/distribution-arn"
}

resource "aws_iam_user_policy" "website_objects" {
  name   = "StaticWebHosting"
  user   = aws_iam_user.deploy_website.id
  policy = data.aws_iam_policy_document.website_objects.json
}

data "aws_iam_policy_document" "website_objects" {
  statement {
    sid = "Object"
    actions = [
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${local.domain}/*"
    ]
  }

  statement {
    sid = "Bucket"
    actions = [
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions"
    ]
    resources = [
      "arn:aws:s3:::${local.domain}"
    ]
  }

  dynamic "statement" {
    for_each = var.first_deploy ? [] : ["cloudfront"]
    content {
      sid = "Cloudfront"
      actions = [
        "cloudfront:CreateInvalidation"
      ]
      resources = [
        data.aws_ssm_parameter.website_distribution_arn.0.value
      ]
    }
  }
}

/**
 * IAM Policy (static)
 */
resource "aws_iam_role_policy" "website_static" {
  name   = "StaticWebHosting"
  role   = aws_iam_role.deploy_website.id
  policy = data.aws_iam_policy_document.website_static.json
}

data "aws_iam_policy_document" "website_static" {
  statement {
    sid = "Bucket"
    actions = [
      "s3:GetBucketTagging",
      "s3:DeleteObjectVersion",
      "s3:ListBucketVersions",
      "s3:RestoreObject",
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetObjectAcl",
      "s3:GetEncryptionConfiguration",
      "s3:DeleteBucketWebsite",
      "s3:AbortMultipartUpload",
      "s3:PutBucketTagging",
      "s3:GetObjectVersionAcl",
      "s3:PutBucketAcl",
      "s3:GetObjectTagging",
      "s3:GetMetricsConfiguration",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteBucket",
      "s3:PutBucketVersioning",
      "s3:PutObjectAcl",
      "s3:DeleteObjectTagging",
      "s3:GetBucketPublicAccessBlock",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketWebsite",
      "s3:PutObjectVersionTagging",
      "s3:DeleteObjectVersionTagging",
      "s3:GetBucketVersioning",
      "s3:PutBucketCORS",
      "s3:GetBucketAcl",
      "s3:DeleteBucketPolicy",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutBucketWebsite",
      "s3:PutObjectVersionAcl",
      "s3:GetBucketCORS",
      "s3:PutBucketPolicy",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${local.domain}",
      "arn:aws:s3:::${local.domain}/*"
    ]
  }
  statement {
    sid       = "global"
    actions   = ["s3:HeadBucket"]
    resources = ["*"]
  }
}
