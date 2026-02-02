#!/bin/bash
docker ps | grep web-app | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep web-app | awk '{print $1}' | xargs -r docker rm
docker image prune -f
sudo systemctl stop nginx
docker ps
