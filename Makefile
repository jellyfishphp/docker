PHP_VERSIONS ?= "7.4 8.0 8.1"
PHP_STAGES ?= "base dev xdebug"

LINUX_DISTRIBUTIONS = "alpine debian"
DOCKER_REGISTRY ?= jellyfishphp

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: build-all
build-all: build-php-cli ## Build all docker images

.PHONY: build-php-cli
build-php-cli:
	DOCKER_REGISTRY="$(DOCKER_REGISTRY)" ./Makefile.d/docker.sh build php-cli $(PHP_STAGES) $(PHP_VERSIONS) $(LINUX_DISTRIBUTIONS)

.PHONY: test-php-cli
test-php-cli:
	./Makefile.d/docker.sh test_build php-cli $(PHP_STAGES) $(PHP_VERSIONS) $(LINUX_DISTRIBUTIONS)

.PHONY: test-all
test-all: test-php-cli ## Push all docker images

.PHONY: login
login: ## Login
	echo "$(DOCKER_HUB_PASSWORD)" | docker login -u "$(DOCKER_HUB_USERNAME)" --password-stdin
