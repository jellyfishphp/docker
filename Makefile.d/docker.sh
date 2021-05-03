#!/bin/bash

BASE_DIRECTORY=$(dirname $(cd ${0%/*} && pwd -P))

function build() {
  DOCKER_IMAGE_NAME="${1}"

  declare -a STAGES=(${2})
  declare -a VERSIONS=(${3})
  declare -a LINUX_DISTRIBUTIONS=(${4})

  for LINUX_DISTRIBUTION in "${LINUX_DISTRIBUTIONS[@]}"
  do
    for VERSION in "${VERSIONS[@]}"
    do
      for STAGE in "${STAGES[@]}"
      do
        IMAGE_TAG="${VERSION}"
        CONTEXT="${BASE_DIRECTORY}/${1}/"

        if echo "${1}" | grep -q "php\-"; then
          IMAGE_TAG="${VERSION}-${1/php-/}"
          DOCKER_IMAGE_NAME="php"
        fi

        if [ "${STAGE}" != "base" ]; then
          IMAGE_TAG="${IMAGE_TAG}-${STAGE}"
        fi

        DOCKER_BUILDKIT=1 docker build --build-arg VERSION=${VERSION} --target ${1}-${STAGE} -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}-${LINUX_DISTRIBUTION} -f ${CONTEXT}${LINUX_DISTRIBUTION}.Dockerfile ${CONTEXT}
      done
    done
  done
}

function push() {
  DOCKER_IMAGE_NAME="${1}"

  declare -a STAGES=(${2})
  declare -a VERSIONS=(${3})
  declare -a LINUX_DISTRIBUTIONS=(${4})

  for LINUX_DISTRIBUTION in "${LINUX_DISTRIBUTIONS[@]}"
  do
    for VERSION in "${VERSIONS[@]}"
    do
      for STAGE in "${STAGES[@]}"
      do
        IMAGE_TAG="${VERSION}"

        if echo "${1}" | grep -q "php\-"; then
          IMAGE_TAG="${VERSION}-${1/php-/}"
          DOCKER_IMAGE_NAME="php"
        fi

        if [ "${STAGE}" != "base" ]; then
          IMAGE_TAG="${IMAGE_TAG}-${STAGE}"
        fi

        docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}-${LINUX_DISTRIBUTION}
      done
    done
  done
}

function usage() {
    echo $"Usage: $0 {build image stage version|push image stage version}"
}

case "$1" in
    build)
        if [ $# != "5" ]; then
            usage
            exit 1
        fi
        build $2 "$3" "$4" "$5"
        ;;
    push)
        if [ $# != "5" ]; then
            usage
            exit 1
        fi
        push $2 "$3" "$4" "$5"
        ;;
    *)
        usage
        exit 1
esac
