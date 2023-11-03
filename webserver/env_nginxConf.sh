#!/bin/bash
export DOLLAR="$"
. env.sh
envsubst < pre_nginx_env.conf > nginx/conf.d/default.conf 
