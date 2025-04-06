variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "xayn-terraform-state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform locks"
  type        = string
  default     = "xayn-terraform-locks"
}