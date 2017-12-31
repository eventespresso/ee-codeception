#!/usr/bin/env bash
echo "This clears all dangling volumes so you start with a fresh volume"
docker stop $(docker ps -aq)
docker volume rm $(docker volume ls -f dangling=true -q)