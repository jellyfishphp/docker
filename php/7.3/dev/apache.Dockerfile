ARG REGISTRY
ARG IMAGE_NAME

FROM $REGISTRY/$IMAGE_NAME:7.3-apache

MAINTAINER Daniel Rose <daniel-rose@gmx.de>

USER root

RUN set -ex; \
    \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

COPY ./ini/dev.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-general.ini

USER www-data
