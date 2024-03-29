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

        docker buildx build \
        --push \
        --platform="linux/amd64,linux/arm64" \
        --build-arg VERSION="${VERSION}" \
        --target "${1}-${STAGE}" \
        -t "${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}-${LINUX_DISTRIBUTION}" \
        -f "${CONTEXT}${LINUX_DISTRIBUTION}.Dockerfile" "${CONTEXT}"
      done
    done
  done
}

function test_build() {
  declare -a STAGES=(${2})
  declare -a VERSIONS=(${3})
  declare -a LINUX_DISTRIBUTIONS=(${4})

  for LINUX_DISTRIBUTION in "${LINUX_DISTRIBUTIONS[@]}"
  do
    for VERSION in "${VERSIONS[@]}"
    do
      for STAGE in "${STAGES[@]}"
      do
        CONTEXT="${BASE_DIRECTORY}/${1}/"

        docker buildx build \
        --platform="linux/amd64,linux/arm64" \
        --build-arg VERSION="${VERSION}" \
        --target "${1}-${STAGE}" \
        -f "${CONTEXT}${LINUX_DISTRIBUTION}.Dockerfile" "${CONTEXT}"
      done
    done
  done
}

function usage() {
    echo $"Usage: $0 {build image stage version|test_build image stage version}"
}

case "$1" in
    build)
        if [ $# != "5" ]; then
            usage
            exit 1
        fi
        build "$2" "$3" "$4" "$5"
        ;;
    test_build)
        if [ $# != "5" ]; then
            usage
            exit 1
        fi
        test_build "$2" "$3" "$4" "$5"
        ;;
    *)
        usage
        exit 1
esac
