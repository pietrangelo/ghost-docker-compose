#!/usr/bin/env bash

if [ "$1" == "start" ]; then
    docker-compose start
fi

if [ "$1" == "stop" ]; then
    docker-compose stop
fi

if [ "$1" == "update" ]; then
    docker-compose down
    docker-compose pull && docker-compose up -d
fi

if [ "$1" == "setup" ]; then
  echo 'Updating system...' \
  && apt upgrade -y \
  && rm -rf ghost; git clone https://github.com/pietrangelo/ghost-docker-compose ghost \
  && cd ghost \
  && sed -e "s/<domain>/$2/g" docker-compose.yaml \
  && sed -e "s/<domain>/$2/g" nginx/default.conf \
  && sed -e "s/<domain>/$2/g" config.production.json \
  && echo 'Installing SSL...' \
  && sudo dnf install certbot python3-certbot-nginx \
  && sudo certbot certonly --standalone -d $2 \
  && echo 'Installing Docker Compose...' \
  && curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose \
  && echo 'Preparing Ghost...' \
  && mkdir ./content; mkdir ./mysql; mkdir -p /usr/share/nginx/html;
  echo 'Configuring cron...' \
  && echo "0 23 * * * certbot certonly -n --webroot -w /usr/share/nginx/html -d $2 --deploy-hook='docker exec ghost_nginx_1 nginx -s reload'" >> mycron \
  && crontab mycron; rm mycron \
  && echo 'Starting Docker...' \
  && docker-compose up -d \
  && echo 'Done! 🎉' \
  && echo 'Access your host: https://'; echo $2;
fi