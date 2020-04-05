locals {
  environment = "${lookup(var.environments, terraform.workspace, "dev")}"
}

variable "environments" {
  type = map(string)
  default = {
    development = "dev"
    production  = "prod"
  }
}

variable "default_tags" {
  type        = map(string)
  description = "Common resource tags for all resources"
  default = {
    Service = "aws-access"
  }
}

variable "domains" {
  type = map
  default = {
    dev  = "mediacodex.dev"
    prod = "mediacodex.net"
  }
}

variable "terraform_state" {
  type = map(string)
  default = {
    bucket = "arn:aws:s3:::terraform-state-mediacodex"
    dynamo = "arn:aws:dynamodb:eu-central-1:939514526661:table/terraform-state-lock"
  }
}
