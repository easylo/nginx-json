FROM alpine:3.6

MAINTAINER Laurent RICHARD "easylo@gmail.com"

ENV NGINX_VERSION 1.13.3

COPY nginx-json-log-module /nginx-json-log-module

RUN apk add --no-cache --virtual .build-deps \
      gcc \
      libc-dev \
      make \
      openssl-dev \
      pcre-dev \
      zlib-dev \
      linux-headers \
      curl \
      gnupg \
      libxslt-dev \
      gd-dev \
      geoip-dev \
      perl-dev \
      curl \
      git \
      jansson-dev \
      gettext \
      supervisor \
      openssh \
      gzip \
      bash

RUN mkdir -p /usr/src && \
    curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar zxC /usr/src -f nginx.tar.gz && \
    rm nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    mv  /nginx-json-log-module . && \
    ./configure --with-http_ssl_module \
        --with-http_v2_module \
        --add-module=nginx-json-log-module \
        --prefix=/etc/nginx \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --conf-path=/var/log/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --sbin-path=/usr/sbin/nginx && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    rm -rf /etc/nginx/html/ && \
    mkdir -p /etc/nginx/conf.d/ && \
    mkdir -p /usr/share/nginx/html/ && \
    ln -s ../../usr/lib/nginx/modules /etc/nginx/modules && \
    install -m755 objs/nginx /usr/sbin/nginx && \
    strip /usr/sbin/nginx* && \
    rm -rf /usr/src/nginx-$NGINX_VERSION && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
# 	&& ln -sf /dev/stderr /var/log/nginx/error.log

# COPY supervisor conf
# RUN mkdir -p /data/logs/supervisor
# RUN touch /data/logs/supervisor/ngnix.log
COPY supervisor/ /etc/supervisor/conf.d/
RUN chmod a+x -R /etc/supervisor/conf.d/scripts/

COPY default.conf /default.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html /etc/nginx/sites-enabled

# Define mountable directories.
# VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log"]

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
