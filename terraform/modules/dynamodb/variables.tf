variable "role" {
  type        = string
  description = "IAM Role ARN to attach the policy to"
}

variable "service" {
  type        = string
  description = "Service name, used for resource prefixes"
}

variable "account" {
  type        = string
  description = "AWS Account ID"
}