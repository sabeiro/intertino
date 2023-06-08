docker-machine ssh runner-node-1 -- docker swarm init --advertise-addr $(docker-machine ip runner-node-1)
