#!/usr/bin/env bash
set -e

PROJECT_NAME=terraform-s3-backend

DOCKER_TERRAFORM_IMAGE_NAME=hashicorp/terraform:0.10.2
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
  [[ -z "${AWS_ACCESS_KEY_ID}" ]] && { echo "\$AWS_ACCESS_KEY_ID environment variable is empty" ; return 1; }
  [[ -z "${AWS_SECRET_ACCESS_KEY}" ]] && { echo "\$AWS_SECRET_ACCESS_KEY environment variable is empty" ; return 1; }
  [[ -z "${AWS_DEFAULT_REGION}" ]] && { echo "\$AWS_DEFAULT_REGION environment variable is empty" ; return 1; }

  local volume_option="-v "$PWD":${DOCKER_TERRAFORM_WORKING_DIR}"
  if [[ "${CI}" == "true" ]]; then
    create_container_volume ${PROJECT_NAME} . ${DOCKER_TERRAFORM_WORKING_DIR}
    volume_option="--volumes-from ${PROJECT_NAME}"
  fi 

  docker run --rm -t $(tty &>/dev/null && echo "-i") \
             -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
             -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
             -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
             ${volume_option} \
             -w ${DOCKER_TERRAFORM_WORKING_DIR} \
             ${DOCKER_TERRAFORM_IMAGE_NAME} "$@"
}

function setup_infrastructure() {
  terraform init
  terraform plan
  terraform apply
}

setup_infrastructure
