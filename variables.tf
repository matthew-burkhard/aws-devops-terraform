variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "aws_region" {
  description = "AWS region where the resources will be provisioned."
  type        = string
  default     = "us-west-2"
}