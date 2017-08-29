# terraform-s3-backend

This [Terraform](https://www.terraform.io/) project performs a *one time setup* of the S3 backend for Terraform's state.  After Terraform runs, you will have the following assets on [AWS](https://aws.amazon.com/):

* An S3 bucket -- where the Terraform state goes
* A DynamoDB table to manage the Terraform state locks (to avoid problems with concurrent Terraforming)
* Relevant policies required by a user/system account if they need to use the S3 bucket and DynamoDB table

Once you have your S3 backend setup, you can then start using it in other Terraform projects by including the following:

```terraform
terraform {
  backend "s3" {
    bucket         = "<STATE_BUCKET_NAME>"
    key            = "..."
    dynamodb_table = "<STATE_LOCK_TABLE_NAME>"
  }
}
```

## Motivation

There are a couple of reasons why you may wish to use this:

* You no longer want to keep local Terraform state on your computer
* You don't have the cash reserves to use [Terraform - Enterprise](https://atlas.hashicorp.com/terraform/start)

## Getting Started

### Dependencies

Assuming that you are running an operating system that can execute bash scripts, all you need to have installed is [Docker](https://www.docker.com/).

### Variables

Review the `variables.tf` file to see what values you'll need to provide.  You can either type them at the command line when you run the build or in a `terraform.tfvars` file using the [appropriate syntax](https://www.terraform.io/intro/getting-started/variables.html).

At a minimum, your `terraform.tfvars` file should look something like this:

```terraform
aws_account_id=<AWS_ACCOUNT_ID_FROM_THE_SUPPORT_PAGE>
state_bucket_name="<A_UNIQUE_BUCKET_NAME_ACROSS_REGION_AND_ACCOUNT>"
```

## Usage
Providing that you have completed the steps under "Getting Started", all you need to do now is execute the following from the command line:

```bash
> git clone git@github.com:lone-cyprus/terraform-s3-backend.git
> cd terraform-s3-backend
> ./build.sh
```

## License
See [LICENSE](LICENSE).
