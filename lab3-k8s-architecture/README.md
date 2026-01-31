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
Detailed node info
```bash
kubectl describe nodes
```
This shows CPU, memory, and system pods.

### Task 2 – Explore Control Plane
All control plane components run in:
```bash
kube-system
```
List control plane pods
```bash
kubectl get pods -n kube-system
```
Filter main components
```bash
kubectl get pods -n kube-system | grep -E "apiserver|etcd|scheduler|controller"
```
You should see:

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager

### Task 3 – Inspect API Server and etcd
API Server
```bash
kubectl get pods -n kube-system | grep apiserver
```
```bash
kubectl describe pod -n kube-system \
$(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')
```
etcd
```bash
kubectl get pods -n kube-system | grep etcd
```
```bash
kubectl exec -n kube-system \
$(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') \
-- etcdctl endpoint health
```
### Task 4 – View Control Plane Logs
API Server logs
```bash
kubectl logs -n kube-system \
$(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') \
--tail=50
```
Scheduler logs
```bash
kubectl logs -n kube-system \
$(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') \
--tail=20
```
Controller Manager logs
```bash
kubectl logs -n kube-system \
$(kubectl get pods -n kube-system | grep controller-manager | awk '{print $1}') \
--tail=20
```
### Task 5 – Create and Deploy Nginx Pod
You already have in the folder:
```bash
nginx-pod.yaml
```
Apply it:
```bash
kubectl apply -f nginx-pod.yaml
```
Check status:
```bash
kubectl get pods
kubectl describe pod nginx-demo
```
### Task 6 – Observe Component Interaction
Scheduler decision
```bash
kubectl logs -n kube-system \
$(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}') \
| grep nginx-demo
```
API server activity
```bash
kubectl logs -n kube-system \
$(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') \
| grep nginx-demo
```
Kubelet logs (node)
```bash
minikube ssh "sudo journalctl -u kubelet | grep nginx-demo | tail -5"
```
### Task 7 – Pod Lifecycle and Events
Pod events
```bash
kubectl get events --sort-by=.metadata.creationTimestamp | grep nginx-demo
```
Pod status
```bash
kubectl get pod nginx-demo -o yaml | grep -A 10 status
```
Container runtime ID
```bash
kubectl get pod nginx-demo \
-o jsonpath='{.status.containerStatuses[0].containerID}'
```
### Task 8 – Test Pod Networking
Execute inside Pod
```bash
kubectl exec nginx-demo -- nginx -v
```
Get Pod IP
```bash
kubectl get pod nginx-demo -o wide
```
Access Pod directly
```bash
POD_IP=$(kubectl get pod nginx-demo -o jsonpath='{.status.podIP}')
curl -I http://$POD_IP
```
Port forward
```bash
kubectl port-forward nginx-demo 8080:80
```
Open in browser or:
```bash
curl http://localhost:8080
```
Stop forwarding:
```bash
Ctrl + C
```
### Task 9 – Resource Monitoring
Node usage
```bash
kubectl top nodes
```
Pod usage
```bash
kubectl top pods
```
Resource allocation
```bash
kubectl describe node | grep -A 5 "Allocated resources"
```
### Task 10 – Component Health and RBAC
Component health
```bash
kubectl get componentstatuses
```
Service accounts
```bash
kubectl get serviceaccounts -n kube-system
```
RBAC roles
```bash
kubectl get clusterroles | head -10
kubectl get clusterrolebindings | head -10
```
### Troubleshooting Quick Guide
Pod stuck in Pending
```bash
kubectl describe pod nginx-demo
kubectl describe nodes
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}')
```
Network not working
```bash
kubectl exec nginx-demo -- nslookup kubernetes.default
```
### Cleanup
```bash
kubectl delete pod nginx-demo
```
## What This Lab Teaches You

After completing this lab, you should understand:

- How kubectl talks to the API server
- How state is stored in etcd
- How the scheduler selects a node
- How kubelet creates containers
- How logs help you debug clusters

This **README** is basically your mini Kubernetes runbook.



