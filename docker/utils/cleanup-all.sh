#!/usr/bin/env bash
echo "Completely resets all containers and deletes all images so you start from scratch"
docker-compose down
./clear-volumes.sh
./remove-containers.sh
docker rmi $(docker images -q)