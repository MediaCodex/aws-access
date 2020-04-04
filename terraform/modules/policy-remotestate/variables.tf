variable "user" {
  type = string
  description = "IAM User to attach the policy to"
}

variable "object" {
  type = string
  description = "S3 remote state object key, e.g. myservice.tfstate"
}

variable "bucket" {
  type = string
  description = "S3 remote state bucket ARN"
}

variable "table" {
  type = string
  description = "DynamoDB lock table ARN"
}