variable "user" {
  type        = string
  description = "ARN of the IAM user to apply the policy to"
}

variable "service" {
  type        = string
  description = "Service name"
}

variable "state_bucket" {
  type        = string
  description = "ARN of the bucket for storing TF state"
}

variable "lock_table" {
  type        = string
  description = "ARN of the table for TF locking"
}