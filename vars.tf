variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Credential key id"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Credential key secret"
}