PHP_VERSIONS ?= "7.3 7.4"
PHP_STAGES ?= "base dev xdebug"

NGINX_VERSIONS ?= "1.18"
NGINX_STAGES ?= "base xdebug"

DOCKER_REGISTRY ?= jellyfishphp

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build-php-fpm
build-php-fpm:
	DOCKER_REGISTRY="$(DOCKER_REGISTRY)" ./Makefile.d/docker.sh build php-fpm $(PHP_STAGES) $(PHP_VERSIONS)

.PHONY: build-nginx
build-nginx:
	DOCKER_REGISTRY="$(DOCKER_REGISTRY)" ./Makefile.d/docker.sh build nginx $(NGINX_STAGES) $(NGINX_VERSIONS)

.PHONY: build-all
build-all: build-nginx build-php-fpm ## Build all docker images

.PHONY: push-php-fpm
push-php-fpm:
	DOCKER_REGISTRY="$(DOCKER_REGISTRY)" ./Makefile.d/docker.sh push php-fpm $(PHP_STAGES) $(PHP_VERSIONS)

.PHONY: push-nginx
push-nginx:
	DOCKER_REGISTRY="$(DOCKER_REGISTRY)" ./Makefile.d/docker.sh push nginx $(NGINX_STAGES) $(NGINX_VERSIONS)

.PHONY: push-all
push-all: push-nginx push-php-fpm ## Push all docker images

.PHONY: login
login:
	echo "$(DOCKER_HUB_PASSWORD)" | docker login -u "$(DOCKER_HUB_USERNAME)" --password-stdin
