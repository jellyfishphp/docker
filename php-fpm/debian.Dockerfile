ARG VERSION=7.3

# PHP BASE STAGE
FROM php:${VERSION}-fpm-buster AS php-fpm-base

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

ENV TERM xterm
ENV COMPOSER_MEMORY_LIMIT -1
ENV PATH_TO_JELLYFISH /var/www/jellyfish/releases/current

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        vim \
        wget \
        zsh; \
    \
    rm -rf /var/lib/apt/lists/*; \
    wget https://github.com/mikefarah/yq/releases/download/latest/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# composer
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        zip \
        unzip \
        libzip-dev; \
    \
    rm -rf /var/lib/apt/lists/*; \
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
    wget https://deb.nodesource.com/setup_lts.x -O - | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \

# pm2
RUN set -ex; \
    npm install pm2 -g
COPY ./pm2/* /var/www/pm2/

# required php libs & config
RUN set -ex; \
    \
    docker-php-ext-install bcmath opcache sockets json; \
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

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]

# PHP DEV STAGE
FROM php-fpm-base AS php-fpm-dev

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

USER root

RUN set -ex; \
    \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

COPY ./ini/dev.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-general.ini

USER www-data

# PHP XDEBUG STAGE
FROM php-fpm-dev AS php-fpm-xdebug

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

USER root

RUN set -ex; \
    \
    pecl install xdebug; \
    docker-php-ext-enable xdebug

COPY ./ini/xdebug.ini /usr/local/etc/php/conf.d/zzz-docker-php-ext-xdebug.ini

USER www-data

