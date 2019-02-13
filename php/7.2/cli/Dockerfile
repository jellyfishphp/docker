FROM jellyfishphp/php-apache:7.2

MAINTAINER Daniel Rose <daniel-rose@gmx.de>

RUN set -ex

RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99fixbadproxy; \
    echo 'Acquire::http::No-Cache=True;' >> /etc/apt/apt.conf.d/99fixbadproxy; \
    echo 'Acquire::BrokenProxy=true;' >> /etc/apt/apt.conf.d/99fixbadproxy

RUN apt-get clean; \
    apt-get update; \
    apt-get -o Acquire::BrokenProxy=true install -y \
        cron \
        python-pip \
        gettext-base

RUN mkdir -p /var/log/supervisor/program

# supervisor
RUN easy_install supervisor; \
    mkdir -p /etc/supervisor/conf.d; \
    echo_supervisord_conf > /etc/supervisor/supervisord.conf; \
    echo "" >> /etc/supervisor/supervisord.conf; \
    echo "[include]" >> /etc/supervisor/supervisord.conf; \
    echo "files = /etc/supervisor/conf.d/*.conf" >> /etc/supervisor/supervisord.conf;

COPY supervisor/conf.d/*.conf /etc/supervisor/conf.d/
COPY supervisor/conf.d/*.conf.template /etc/supervisor/conf.d/

RUN echo "* * * * * root php /var/www/jellyfish/release/current/vendor/bin/console scheduler:run >/dev/null 2>&1" >> /etc/cron.d/scheduler

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
