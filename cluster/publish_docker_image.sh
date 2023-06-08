#!/bin/sh

set -o pipefail
set -e
set -vx

cat > /kaniko/.docker/config.json << EOF
{
  "auths": {
    "$CI_REGISTRY":{
      "username":"$CI_REGISTRY_USER",
      "password":"$CI_REGISTRY_PASSWORD"
    }
  }
}"
EOF

mkdir -p .docker-cache

/kaniko/executor \
  --context $CI_PROJECT_DIR/mailserver \
  --dockerfile $CI_PROJECT_DIR/mailserver/Dockerfile \
  --destination "$CI_REGISTRY_IMAGE/mailserver:latest" \
  --destination "$CI_REGISTRY_IMAGE/mailserver:$(date '+%Y%m%d-%H%M%S')" \
  --cache-dir .docker-cache
