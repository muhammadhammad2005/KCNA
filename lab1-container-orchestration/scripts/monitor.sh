#!/bin/bash
echo "Container Resource Monitoring"
echo "============================="
while true; do
    clear
    echo "$(date)"
    echo "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    sleep 5
done
