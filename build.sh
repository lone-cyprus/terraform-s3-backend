#!/usr/bin/env bash
set -e

PROJECT_NAME=terraform-s3-backend

DOCKER_TERRAFORM_VERSION=0.10.2
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

function setup_infrastructure() {
  terraform init
  terraform plan
  terraform apply
}

setup_infrastructure
