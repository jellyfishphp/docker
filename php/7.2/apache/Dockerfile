FROM php:7.2-apache

MAINTAINER Daniel Rose <daniel-rose@gmx.de>

ENV TERM xterm

RUN set -ex

RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99fixbadproxy; \
    echo 'Acquire::http::No-Cache=True;' >> /etc/apt/apt.conf.d/99fixbadproxy; \
    echo 'Acquire::BrokenProxy=true;' >> /etc/apt/apt.conf.d/99fixbadproxy

RUN apt-get clean; \
    apt-get update; \
    apt-get -o Acquire::BrokenProxy=true install -y \
        git \
        wget \
        vim \
        nano \
        zsh \
        zip \
        libzip-dev \
        curl \
        libcurl4-gnutls-dev \
        libxml2-dev

# required list of php ext
RUN docker-php-ext-configure zip --with-libzip

RUN docker-php-ext-install bcmath zip

# oh my zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true;

# composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O /tmp/installer; \
    php /tmp/installer --no-ansi --install-dir=/usr/bin --filename=composer --quiet; \
    rm /tmp/installer

RUN composer global require hirak/prestissimo

RUN a2enmod rewrite

COPY php.ini /usr/local/etc/php/php.ini

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]
