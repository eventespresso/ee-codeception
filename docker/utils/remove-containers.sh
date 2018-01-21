#!/usr/bin/env bash
echo "Removes all containers"
docker stop $(docker ps -aq)
docker rm $(docker ps -qa --no-trunc --filter "status=exited")