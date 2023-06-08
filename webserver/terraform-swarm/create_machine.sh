# Create some docker machine nodes
docker-machine create manager1 worker1 worker2
# Initialize the manager node
docker-machine ssh manager1 "docker swarm init"
# Join the worker nodes
docker-machine ssh worker1 "docker swarm join"
docker-machine ssh worker2 "docker swarm join"
