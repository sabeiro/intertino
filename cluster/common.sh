#!/bin/sh

set -o pipefail
set -e

function die() {
  echo $@
  exit 1
}

[ -f "$MAILSERVER_ID_RSA" ] || die "Missing private key MAILSERVER_ID_RSA from gitlab CI setup"
[ -n "$MAILSERVER_SERVER_USER" ] || die "MAILSERVER_SERVER_USER environment variable missing"
[ -n "$MAILSERVER_SERVER_PORT" ] || die "MAILSERVER_SERVER_PORT environment variable missing"

WORKDIR=/home/admin/

function execute_remote() {
  echo "Executing $@"
  ssh -o StrictHostKeyChecking=no -i "$MAILSERVER_ID_RSA" -p $MAILSERVER_SERVER_PORT $MAILSERVER_SERVER_USER@$MAILSERVER_SERVER_IP "$@"
}

function copy_to_workspace_with_dst() {
  echo "Copying file $1 to $2..."
  scp -o StrictHostKeyChecking=no -i "$MAILSERVER_ID_RSA" -P $MAILSERVER_SERVER_PORT "$1" "$MAILSERVER_SERVER_USER@$MAILSERVER_SERVER_IP:$WORKDIR/$2"
}

function copy_to_workspace() {
  copy_to_workspace_with_dst "$1" "$1"
}

chmod og= $MAILSERVER_ID_RSA

cat > intel_env << EOF
EOF

# Authenticate to use docker
execute_remote docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
