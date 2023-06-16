#!/bin/bash
. $HOME/credenza/database.env
. $HOME/credenza/webserver.sh
export DOLLAR="$"
cd $HOME/intertino/webserver
envsubst < pre_nginx_env.conf > nginx/conf.d/default.conf
docker-compose exec nginx nginx -s reload

