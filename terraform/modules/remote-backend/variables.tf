variable "user" {
  type        = string
  description = "ARN of the IAM user to apply the policy to"
}

variable "role" {
  type        = string
  description = "ARN of the IAM role that needs to be assumed"
}