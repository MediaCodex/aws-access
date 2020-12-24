locals {
  environment = "${lookup(var.environments, terraform.workspace, "dev")}"
  domain      = lookup(var.domains, local.environment)
  
  backend_state_bucket = "arn:aws:s3:::mediacodex-${local.environment}-terraform-state"
  backend_lock_table   = "arn:aws:dynamodb:us-east-1:${lookup(var.aws_accounts, local.environment)}:table/${local.environment}-terraform-lock"
}

variable "environments" {
  type = map(string)
  default = {
    development = "dev"
    production  = "prod"
  }
}

variable "aws_accounts" {
  type = map(string)
  default = {
    dev = "949257948165"
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

variable "first_deploy" {
  type        = bool
  description = "Disables some resources that depend on other services being deployed"
  default     = false
}
