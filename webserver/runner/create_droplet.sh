docker-machine create \
    --driver digitalocean \
    --digitalocean-access-token $DIGITAL_OCEAN_ACCESS_TOKEN \
    --digitalocean-region "nyc1" \
    --digitalocean-image "debian-10-x64" \
    --digitalocean-size "s-4vcpu-8gb" \
    --engine-install-url "https://releases.rancher.com/install-docker/19.03.9.sh" \
    runner-node;
