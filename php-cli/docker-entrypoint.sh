#!/bin/sh
set -e

if [ -d "${PATH_TO_JELLYFISH}/public" ] && [ ! -L "/var/www/html" ]; then
  rm -Rf /var/www/html
  ln -s ${PATH_TO_JELLYFISH}/public /var/www/html
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"
