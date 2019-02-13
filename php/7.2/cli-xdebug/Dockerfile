FROM jellyfish/php-cli:7.2-dev

MAINTAINER Daniel Rose <daniel-rose@gmx.de>

RUN set -ex

# XDEBUG
RUN pecl install xdebug-2.6.1; \
    docker-php-ext-enable xdebug

COPY php.ini /usr/local/etc/php/php.ini
