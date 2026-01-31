# Kubernetes Architecture Lab – README

Lab Objective

This lab helps you understand how Kubernetes works internally by:

- Inspecting cluster components
- Viewing control plane logs
- Creating and monitoring a Pod
- Observing how components communicate
- Practicing basic troubleshooting

By the end of this lab, you should clearly understand what happens when you run `kubectl apply`.

## Prerequisites

Your environment should already have:

- Ubuntu Linux
- kubectl installed
- Minikube running
- Internet access

Verify first:
```bash
kubectl version --client
minikube status
```

### Task 1 – Inspect Cluster and Nodes
Check cluster status
```bash
kubectl cluster-info
```
List nodes
```bash
kubectl get nodes -o wide
```
