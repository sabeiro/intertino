#!/bin/bash

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="dockerNode-${RUNNER_SUFFIX}"

#REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GIT_TOKEN}" https://api.github.com/repos/${GIT_OWNER}/${GIT_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
REG_TOKEN=$GIT_TOKEN
GIT_URL=https://github.com/${GIT_OWNER}/${GIT_REPOSITORY}
GIT_URL="https://github.com/sabeiro/intertino"

cd /home/docker/

./config.sh --unattended --url ${GIT_URL} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!


