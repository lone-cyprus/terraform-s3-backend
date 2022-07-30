#!/usr/bin/env bash
set -e

PROJECT_NAME=terraform-s3-backend

DOCKER_TERRAFORM_VERSION=0.11.3
DOCKER_TERRAFORM_WORKING_DIR=/data

function create_container_volume() {
  local volume=$1
  local local_source_dir=$2
  local remote_target_dir=$3
  if [[ ! "$(docker ps -a | grep ${volume})" ]]; then
    # creating dummy container which will hold a volume with config
    docker create -v ${remote_target_dir} --name ${volume} alpine:3.4 /bin/true 
    # copying config file into this volume
    docker cp ${local_source_dir} ${volume}:${remote_target_dir}
  fi
}

function terraform() {
  local url="https://raw.githubusercontent.com/lone-cyprus/docker-bin/master/terraform"
  if [[ "${CI}" == "true" ]]; then
    local volume=${PROJECT_NAME}-terraform
    create_container_volume ${volume} . ${DOCKER_TERRAFORM_WORKING_DIR}
    curl -s $url | VERSION=${DOCKER_TERRAFORM_VERSION} SHARED_VOLUME=${volume} bash -s -- "$@"
  else
    curl -s $url | VERSION=${DOCKER_TERRAFORM_VERSION} bash -s -- "$@"
  fi
}

function import_repository_into_terraform_state() {
  terraform import $1 $2
}

function setup_infrastructure() {
  terraform init -verify-plugins=false
  terraform plan
  terraform apply -auto-approve
}

if [[ "$1" == "--setup" ]]; then
  echo "Setting up infrastructure . . ."
  setup_infrastructure
elif [[ "$1" == "--import" ]]; then
  echo "Importing . . ."
  # NOTE: following requires a (default) github provider to be specified in the root before running
  #import_repository_into_terraform_state "aws_dynamodb_table.state_lock" "terraform_state_locks"
  #import_repository_into_terraform_state "aws_iam_group.state" "TerraformStateFullAccess"
  #import_repository_into_terraform_state "aws_iam_group_policy_attachment.state_bucket" "TerraformStateFullAccess/arn:aws:iam::295989730825:policy/production/S3TerraformStateFullAccess"
  #import_repository_into_terraform_state "aws_iam_group_policy_attachment.state_lock_table" "TerraformStateFullAccess/arn:aws:iam::295989730825:policy/production/DynamoDBTerraformStateLockFullAccess"
  #terraform state rm 'aws_iam_policy.state_bucket'
  #import_repository_into_terraform_state "aws_iam_policy.state_bucket" "arn:aws:iam::295989730825:policy/production/S3TerraformStateFullAccess"
  #import_repository_into_terraform_state "aws_iam_policy.state_lock_table" "arn:aws:iam::295989730825:policy/production/DynamoDBTerraformStateLockFullAccess"

  # NOTE: the following returns "Forbidden"
  #import_repository_into_terraform_state "aws_s3_bucket.state" "lonecyprus-terraform-state"
fi
