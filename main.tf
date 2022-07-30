#######################################################################################
# S3 - Bucket for storing Terraform state
#######################################################################################

# After Terraform successfully runs this file, you can then use the S3 backend in other
# Terraform projects as follows:
#
#     terraform {
#       backend "s3" {
#         bucket         = "STATE_BUCKET_NAME"
#         key            = "..."
#         dynamodb_table = "STATE_LOCK_TABLE_NAME"
#       }
#     }

resource "aws_s3_bucket" "state" {
  bucket = "${var.state_bucket_name}"
  region = "${var.state_bucket_region}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

data "template_file" "state_bucket" {
  template = "${file("policies/state_bucket.json")}"
  vars {
    bucket_name = "${var.state_bucket_name}"
  }
}

resource "aws_iam_policy" "state_bucket" {
  name        = "${var.state_bucket_policy_name}"
  path        = "/${var.environment}/"
  description = "Privileges that Terraform requires to use the S3 state bucket"

  policy = "${data.template_file.state_bucket.rendered}"
}

#######################################################################################
# Dynamo DB - Table for managing locks (to avoid issues with concurrent Terraforming)
#######################################################################################

# NOTE: the LockID attribute/hash_key name is important and should not be changed!

resource "aws_dynamodb_table" "state_lock" {
  name           = "${var.state_lock_table_name}"
  read_capacity  = "${var.state_lock_table_read_capacity}"
  write_capacity = "${var.state_lock_table_write_capacity}"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "template_file" "state_lock_table" {
  template = "${file("policies/state_lock_table.json")}"
  vars {
    account_id = "${var.aws_account_id}"
    region     = "${var.state_lock_region}"
    table_name = "${var.state_lock_table_name}"
  }
}

resource "aws_iam_policy" "state_lock_table" {
  name        = "${var.state_lock_policy_name}"
  path        = "/${var.environment}/"
  description = "Privileges that Terraform requires to use the DynamoDB state lock table"

  policy = "${data.template_file.state_lock_table.rendered}"
}

#######################################################################################
# Terraform State Full Access Group
#######################################################################################

resource "aws_iam_group" "state" {
  name = "${var.state_group_name}"
  path = "/${var.environment}/"
}

resource "aws_iam_group_policy_attachment" "state_bucket" {
  group      = "${aws_iam_group.state.name}"
  policy_arn = "${aws_iam_policy.state_bucket.arn}"
}

resource "aws_iam_group_policy_attachment" "state_lock_table" {
  group      = "${aws_iam_group.state.name}"
  policy_arn = "${aws_iam_policy.state_lock_table.arn}"
}
