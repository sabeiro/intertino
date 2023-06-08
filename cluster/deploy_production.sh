#!/bin/sh

set -o pipefail
set -e

[ -n "$MAILSERVER_SERVER_IP" ] || die "Missing server IP address"

source ./common.sh

echo "Deploying on ${MAILSERVER_SERVER_IP}..."

execute_remote docker pull $CI_REGISTRY_IMAGE/mailserver:latest

copy_to_workspace intel_env
copy_to_workspace docker-compose.yml

execute_remote docker compose -f $WORKDIR/docker-compose.yml up --remove-orphans -d
