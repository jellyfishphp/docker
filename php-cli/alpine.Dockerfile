ARG VERSION=7.4

# PHP BASE STAGE
FROM php:${VERSION}-cli-alpine AS php-cli-base

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

ARG VERSION

ENV TERM xterm
ENV COMPOSER_MEMORY_LIMIT -1
ENV PATH_TO_JELLYFISH /var/www/jellyfish/releases/current

RUN set -ex; \
    \
    apk --no-cache add curl \
        vim \
        wget \
        zsh \
        make

# composer
RUN set -ex; \
    \
    apk --no-cache add git \
        zip \
        unzip \
        libzip-dev; \
    \
    docker-php-ext-configure zip; \
    docker-php-ext-install zip; \
    \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O /tmp/installer; \
    php /tmp/installer --no-ansi --install-dir=/usr/bin --filename=composer --quiet; \
    rm /tmp/installer; \
    composer self-update

# nodejs
RUN set -ex; \
    \
    apk --no-cache add npm

# pm2
RUN set -ex; \
    npm install pm2 -g
COPY ./pm2/* /var/www/pm2/

# yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# required php libs & config
RUN set -ex; \
    \
    if [ "${VERSION}" = "7.4" ]; then \
        docker-php-ext-install bcmath opcache sockets json; \
    else \
        docker-php-ext-install bcmath opcache sockets; \
    fi; \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY ./ini/base.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-general.ini

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN set -ex; \
    mkdir -p ${PATH_TO_JELLYFISH}; \
    chown -R www-data:www-data /var/www

WORKDIR ${PATH_TO_JELLYFISH}

USER www-data

RUN set -ex; \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php", "-a"]

# PHP DEV STAGE
FROM php-cli-base AS php-cli-dev

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

USER root

RUN set -ex; \
    \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

COPY ./ini/dev.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-general.ini

USER www-data

# PHP XDEBUG STAGE
FROM php-cli-dev AS php-cli-xdebug

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

USER root

RUN set -ex; \
    \
    apk add --no-cache $PHPIZE_DEPS; \
    pecl install xdebug; \
    docker-php-ext-enable xdebug

COPY ./ini/xdebug.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-xdebug.ini

USER www-data

