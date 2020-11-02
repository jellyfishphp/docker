#!/bin/bash

BASE_DIRECTORY=$(dirname $(cd ${0%/*} && pwd -P))

function build() {
  DOCKER_IMAGE_NAME="${1}"

  declare -a STAGES=(${2})
  declare -a VERSIONS=(${3})
  
  for VERSION in "${VERSIONS[@]}"
  do
    for STAGE in "${STAGES[@]}"
    do
      IMAGE_TAG="${VERSION}"
      CONTEXT="${BASE_DIRECTORY}/${1}/"

      if [ "${1}" = "php-fpm" ]; then
        IMAGE_TAG="${VERSION}-fpm"
        DOCKER_IMAGE_NAME="php"
      fi

      if [ "${STAGE}" != "base" ]; then
        IMAGE_TAG="${IMAGE_TAG}-${STAGE}"
      fi

      DOCKER_BUILDKIT=1 docker build --build-arg VERSION=${VERSION} --target ${1}-${STAGE} -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${CONTEXT}
    done
  done
}

function push() {
  DOCKER_IMAGE_NAME="${1}"

  declare -a STAGES=(${2})
  declare -a VERSIONS=(${3})

  for VERSION in "${VERSIONS[@]}"
  do
    for STAGE in "${STAGES[@]}"
    do
      IMAGE_TAG="${VERSION}"

      if [ "${1}" = "php-fpm" ]; then
        IMAGE_TAG="${VERSION}-fpm"
        DOCKER_IMAGE_NAME="php"
      fi

      if [ "${STAGE})" != "base" ]; then
        IMAGE_TAG="${IMAGE_TAG}-${STAGE}"
      fi

      docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
    done
  done

}

function usage() {
    echo $"Usage: $0 {build image stage version|push image stage version}"
}

case "$1" in
    build)
        if [ $# != "4" ]; then
            usage
            exit 1
        fi
        build $2 "$3" "$4"
        ;;
    push)
        if [ $# != "4" ]; then
            usage
            exit 1
        fi
        push $2 "$3" "$4"
        ;;
    *)
        usage
        exit 1
esac
