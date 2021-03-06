ARG VERSION=1.18

FROM nginx:${VERSION} AS nginx-base

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

RUN sed -i 's/user  nginx;/user  www-data;/g' /etc/nginx/nginx.conf

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY conf.d/base.upstream.conf /etc/nginx/conf.d/upstream.conf

###############################
#     NGINX XDEBUG STAGE      #
###############################

FROM nginx-base AS nginx-xdebug

LABEL maintainer="Daniel Rose <daniel-rose@gmx.de>"

COPY conf.d/xdebug.conf /etc/nginx/conf.d/xdebug.conf
COPY conf.d/xdebug.upstream.conf /etc/nginx/conf.d/upstream.conf
