variable "user" {
  type        = string
  description = "ARN of IAM user"
}

variable "role" {
  type        = string
  description = "ARN of IAM role"
}

variable "account" {
  type        = string
  description = "AWS Account ID"
}

variable "service" {
  type        = string
  description = "Service name"
}