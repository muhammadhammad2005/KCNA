#!/bin/bash
APP_NAME="web-app"
BASE_PORT=9000
INSTANCES=5
echo "Manually scaling $APP_NAME to $INSTANCES instances..."
for i in $(seq 1 $INSTANCES); do
    PORT=$((BASE_PORT + i))
    CONTAINER_NAME="${APP_NAME}-instance-${i}"
    echo "Deploying $CONTAINER_NAME on port $PORT"
    docker run -d --name $CONTAINER_NAME -p $PORT:80 nginx:latest
    sleep 2
done
