variable "environment" {
  default = "production"
}


# AWS

variable "aws_account_id" {
}

# DynamoDB

variable "state_lock_table_name" {
  type    = "string"
  default = "terraform_state_locks"
}

variable "state_lock_table_read_capacity" {
  default = 1
}

variable "state_lock_table_write_capacity" {
  default = 1
}

variable "state_lock_region" {
  type    = "string"
  default = "us-east-1"
}

# S3

variable "state_bucket_name" {
  type    = "string"
  default = "terraform_state"
}

variable "state_bucket_region" {
  type    = "string"
  default = "us-east-1"
}

# IAM

variable "state_lock_policy_name" {
  type    = "string"
  default = "DynamoDBTerraformStateLockFullAccess"
}

variable "state_bucket_policy_name" {
  type    = "string"
  default = "S3TerraformStateFullAccess"
}

variable "state_group_name" {
  type    = "string"
  default = "TerraformStateFullAccess"
}
