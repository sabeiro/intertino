docker build --tag runner-image .
docker run \
  --detach \
  --env ORGANIZATION=$ORGANIZATION \
  --env ACCESS_TOKEN=$ACCESS-TOKEN \
  --name runner \
  runner-image
