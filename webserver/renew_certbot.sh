#!/bin/bash
docker-compose exec certbot certbot certonly -w /var/www/certbot -d viudi.it
docker-compose exec nginx nginx -s reload
