FROM debian:8

MAINTAINER Laurent RICHARD "easylo@gmail.com"

ENV NGINX_VERSION 1.11.9

COPY nginx-json-log-module /nginx-json-log-module

RUN apt-get update --fix-missing
RUN apt-get upgrade -y
RUN apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev libssl-dev tar unzip wget curl libjansson-dev gettext supervisor

RUN mkdir -p /usr/src && \
    curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar zxC /usr/src -f nginx.tar.gz && \
    rm nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    mv  /nginx-json-log-module . && \
    ./configure --with-http_ssl_module \
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
    rm -rf /tmp/* /var/tmp/*

COPY supervisor/ /etc/supervisor/conf.d/
RUN chmod a+x -R /etc/supervisor/conf.d/scripts/

COPY default.conf /default.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html /etc/nginx/sites-enabled

EXPOSE 80

RUN echo Europe/London >/etc/timezone && \
    ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
