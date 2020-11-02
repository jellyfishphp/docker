#!/bin/sh
set -e

if [ -d "${PATH_TO_JELLYFISH}/public" ] && [ ! -L "/var/www/html" ]; then
    rm -Rf /var/www/html
    ln -s ${PATH_TO_JELLYFISH}/public /var/www/html
fi

if [ ! -f "/usr/local/etc/php/conf.d/zzz-docker-php-ext-xdebug.ini" ]; then
  pm2 start /var/www/pm2/ecosystem.config.yml
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

exec "$@"
