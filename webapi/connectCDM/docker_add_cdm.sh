#!/usr/bin/env bash

# Use this if you have docker installed locally and not psql
# Remember if using this you can't use localhost for prompts

set -e

DOCKER_IMAGE=postgres:10-alpine
IMAGE_LOCAL=false

# See if DOCKER_IMAGE exists, If not RMI it later
if [[ "$(docker images -q myimage:mytag 2> /dev/null)" == "" ]]; then
  IMAGE_LOCAL=true
fi

docker run --rm -it -v ${PWD}/add_cdm.sh:/add_cdm.sh -v ${PWD}/cdm_config.sql:/cdm_config.sql $DOCKER_IMAGE /add_cdm.sh

# Remove image if it wasn't already downloaded
if [ "$IMAGE_LOCAL" = false ] ; then
  docker rmi $DOCKER_IMAGE
fi