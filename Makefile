PHP_VERSIONS ?= 7.3
DOCKER_REGISTRY ?= jellyfishphp
DOCKER_IMAGE_NAME ?= php
BASE_DIRECTORY ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

define buildDockerImage
	$(shell sh -c '\
		BUILD_ARGUMENTS="--build-arg REGISTRY=$(DOCKER_REGISTRY) --build-arg IMAGE_NAME=$(DOCKER_IMAGE_NAME) ";\
		IMAGE_TAG="$(3)-$(1)";\
		DOCKER_FILE="$(BASE_DIRECTORY)/php/$(3)/$(2)/$(1).Dockerfile";\
		\
		if [ "$(2)" == "base" ] && [ "$(1)" == "apache" ]; then\
			BUILD_ARGUMENTS="";\
		fi;\
		\
		if [ "$(2)" != "base" ]; then\
			IMAGE_TAG="$${IMAGE_TAG}-$(2)";\
		fi;\
		\
		docker build $$BUILD_ARGUMENTS-t $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$$IMAGE_TAG -f $$DOCKER_FILE $(BASE_DIRECTORY)/php/ > x.log; \
	')
endef

define pushDockerImage
	$(shell sh -c '\
		IMAGE_TAG="$(3)-$(1)";\
		\
		if [ "$(2)" != "base" ]; then\
			IMAGE_TAG="$${IMAGE_TAG}-$(2)";\
		fi;\
		\
		docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$$IMAGE_TAG;\
	')
endef

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: buildDockerApacheBaseImages
buildDockerApacheBaseImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call buildDockerImage,apache,base,$(PHP_VERSION)))

.PHONY: buildDockerApacheDevImages
buildDockerApacheDevImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call buildDockerImage,apache,dev,$(PHP_VERSION)))

.PHONY: buildDockerApacheXdebugImages
buildDockerApacheXdebugImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call buildDockerImage,apache,xdebug,$(PHP_VERSION)))

.PHONY: buildDockerImages
buildDockerImages: buildDockerApacheBaseImages buildDockerApacheDevImages buildDockerApacheXdebugImages ## Build docker images

.PHONY: pushDockerApacheBaseImages
pushDockerApacheBaseImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call pushDockerImage,apache,base,$(PHP_VERSION)))

.PHONY: pushDockerApacheDevImages
pushDockerApacheDevImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call pushDockerImage,apache,dev,$(PHP_VERSION)))

.PHONY: pushDockerApacheXdebugImages
pushDockerApacheXdebugImages:
	$(foreach PHP_VERSION,$(PHP_VERSIONS),$(call pushDockerImage,apache,xdebug,$(PHP_VERSION)))

.PHONY: pushDockerImages
pushDockerImages: pushDockerApacheBaseImages pushDockerApacheDevImages pushDockerApacheXdebugImages ## Push docker images

.PHONY: login
login:
	echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
