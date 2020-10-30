FROM php:7.3-apache-buster

MAINTAINER Daniel Rose <daniel-rose@gmx.de>

ENV TERM xterm
ENV COMPOSER_MEMORY_LIMIT -1
ENV PATH_TO_JELLYFISH /var/www/jellyfish/releases/current

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        vim \
        nano \
        curl \
        wget \
        locales \
        zsh; \
    rm -rf /var/lib/apt/lists/*; \
    \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen

# composer
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        zip \
        libzip-dev; \
    rm -rf /var/lib/apt/lists/*; \
    \
    docker-php-ext-configure zip --with-libzip; \
    docker-php-ext-install zip; \
    \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O /tmp/installer; \
    php /tmp/installer --no-ansi --install-dir=/usr/bin --filename=composer --quiet; \
    rm /tmp/installer; \
    composer self-update

# nodejs (lts)
RUN set -ex; \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        nodejs; \
    rm -rf /var/lib/apt/lists/*

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

COPY ./docker-entrypoint/base.sh /usr/local/bin/docker-entrypoint.sh

RUN a2enmod rewrite

RUN set -ex; \
    mkdir -p ${PATH_TO_JELLYFISH}; \
    chown -R www-data:www-data /var/www

USER www-data

WORKDIR ${PATH_TO_JELLYFISH}

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/bin/pm2-runtime", "/var/www/pm2/ecosystem.config.yml"]
