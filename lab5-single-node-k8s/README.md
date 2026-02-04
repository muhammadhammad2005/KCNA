# Lab 5: Setting Up a Single-Node Kubernetes Cluster with Minikube

## Overview

This lab guides you through installing and configuring Minikube to create a single-node Kubernetes cluster on a Linux system. You will deploy and test applications, manage cluster lifecycle, and explore Minikube features.

## Objectives

By completing this lab, you will be able to:

* Install and configure Minikube and kubectl
* Start, stop, and restart a single-node Kubernetes cluster
* Verify cluster health and inspect resources using kubectl
* Deploy and expose a test application
* Explore Minikube addons and configuration options
* Troubleshoot common Minikube and cluster issues

## Prerequisites

* Linux command-line knowledge
* Basic Docker/containerization understanding
* Familiarity with Kubernetes concepts
* Access to a terminal

## Lab Environment

* Ubuntu 20.04 LTS or newer
* Docker runtime installed
* Internet access for downloading packages
* Minimum 2 CPU cores and 4GB RAM

## Tasks

### 1. Install Minikube

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

### 2. Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### 3. Start Minikube Cluster (real-world version)

```bash
# Make sure Docker is running
sudo systemctl status docker

# Start with explicit resources (common practice)
minikube start --driver=docker --memory=4096 --cpus=2
minikube status
kubectl config current-context
```

### 4. Verify Cluster Health (add readiness)

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -n kube-system

# Wait until all system pods are ready
kubectl wait --for=condition=Ready pod --all -n kube-system --timeout=300s
```

### 5. Deploy Test Application (more realistic)

```bash
kubectl create deployment hello-minikube --image=nginx:latest
kubectl wait --for=condition=Available deployment/hello-minikube --timeout=120s

kubectl expose deployment hello-minikube --type=NodePort --port=80
kubectl get services

minikube service hello-minikube --url
curl $(minikube service hello-minikube --url)
```

Clean up:

```bash
kubectl delete deployment hello-minikube
kubectl delete service hello-minikube
```

### 6. Stop and Restart Cluster

```bash
minikube stop
minikube status
minikube start
kubectl get nodes
kubectl get pods -n kube-system
```

### 7. Explore Minikube Features

```bash
minikube addons enable dashboard
minikube dashboard --url
minikube addons list
minikube addons enable ingress
kubectl get pods -n ingress-nginx
minikube config view
minikube ip
```

## Troubleshooting

* **Minikube won't start**: Check Docker status and start it if needed.
* **kubectl commands fail**: Verify context with `kubectl config use-context minikube`.
* **Insufficient resources**: Start Minikube with more memory/CPU.
* **Network issues**: Restart Minikube with different network settings.

**Pods stuck in ContainerCreating:**
- Check images: kubectl describe pod <pod>
- Check Docker: sudo systemctl status docker

## Lab Cleanup

```bash
minikube stop
minikube delete
sudo rm /usr/local/bin/minikube
sudo rm /usr/local/bin/kubectl
```

## Conclusion

This lab equips you with the skills to:

* Set up a local Kubernetes cluster
* Deploy and test applications
* Manage cluster lifecycle
* Explore Minikube features and addons
* Troubleshoot basic issues

These skills form a foundation for advanced Kubernetes operations and local development practice.
