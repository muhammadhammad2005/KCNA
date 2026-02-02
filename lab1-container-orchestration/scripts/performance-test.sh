#!/bin/bash
echo "Performance Impact Analysis"
for port in {9001..9005}; do
    echo "Testing port $port:"; time curl -s http://localhost:$port > /dev/null
done
echo "Concurrent requests test"
time for i in {1..50}; do curl -s http://localhost > /dev/null & done
wait
docker stats --no-stream | grep web-app-instance
