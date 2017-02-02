#!/bin/bash
set -e

export DOLLAR="$"

export NGINX_LISTEN=${NGINX_LISTEN:=80}
export NGINX_SERVER_NAME=${NGINX_SERVER_NAME:="_"}
export NGINX_LOCATION=${NGINX_LOCATION:="/"}
export NGINX_EXPIRES=${NGINX_EXPIRES:="1h"}
export NGINX_AUTH_BASIC=${NGINX_AUTH_BASIC:=0}
export NGINX_AUTH_BASIC_FILE=${NGINX_AUTH_BASIC_FILE:='/etc/nginx/.htpasswd'}
export NGINX_DNS_RESOLVER=${NGINX_DNS_RESOLVER:="127.0.0.1"}

if [ $NGINX_AUTH_BASIC = "1" ]
then
  export NGINX_AUTH_BASIC_content="
    auth_basic 'Restricted Content';
    auth_basic_user_file '${NGINX_AUTH_BASIC_FILE}';
    "
fi

envsubst < /default.conf > /etc/nginx/conf.d/default.conf

exit $?
