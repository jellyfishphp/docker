#!/bin/sh
set -e

promptYN () {
    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

docker build -t jellyfish/php-apache:7.2 php/7.2/apache --no-cache
docker build -t jellyfish/php-apache:7.2-dev php/7.2/apache-dev --no-cache

docker build -t jellyfish/php-cli:7.2 php/7.2/cli --no-cache
docker build -t jellyfish/php-cli:7.2-dev php/7.2/cli-dev --no-cache