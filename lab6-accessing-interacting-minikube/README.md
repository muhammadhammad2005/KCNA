# Lab 6: Accessing and Interacting with Minikube

## Overview

In this lab, you will learn how to interact with a local Minikube Kubernetes cluster. You will use `kubectl` to explore cluster components, deploy and manage pods, retrieve logs, test networking, and troubleshoot common issues.

## Objectives

By the end of this lab, you will be able to:

* Start and verify a Minikube cluster
* List and examine nodes, namespaces, and pods
* Deploy pods using `kubectl` and YAML manifests
* Retrieve and analyze pod logs
* Execute commands inside pods
* Test pod connectivity and services
* Diagnose and resolve common Kubernetes issues
* Clean up resources after lab exercises

## Prerequisites

* Basic understanding of Docker and containerization
* Familiarity with Linux command-line interface
* Basic knowledge of YAML structure
* Understanding of networking fundamentals

## Lab Environment

* Pre-configured Linux-based cloud machine
* Minikube and kubectl installed
* Docker runtime environment ready

## Tasks

### Task 1: Understanding Your Kubernetes Environment

1. Start Minikube and verify status:

```bash
minikube start --driver=docker
minikube status
kubectl cluster-info
```

2. List and describe nodes:

```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node minikube
```

3. Explore namespaces:

```bash
kubectl get namespaces
kubectl get namespaces -o wide
kubectl describe namespace default
kubectl get ns --show-labels
```

4. List and examine pods:

```bash
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide --all-namespaces
kubectl get pods -n kube-system
```

### Task 2: Deploy a Simple Pod and Manage Its Lifecycle

1. Create a pod using `kubectl run`:

```bash
kubectl run my-nginx-pod --image=nginx:latest --port=80
kubectl get pods
kubectl get pod my-nginx-pod -o wide
kubectl describe pod my-nginx-pod
```

2. Create a pod using a YAML manifest:

```bash
cat > test-pod.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-app-pod
  labels:
    app: test-app
    environment: lab
spec:
  containers:
  - name: test-container
    image: busybox:latest
    command: ['sh', '-c', 'echo "Hello from Kubernetes Pod!" && sleep 3600']
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF

kubectl apply -f test-pod.yaml
kubectl get pods
```

3. Retrieve and analyze pod logs:

```bash
kubectl logs my-nginx-pod
kubectl logs test-app-pod
kubectl logs -f test-app-pod
kubectl logs test-app-pod --timestamps
kubectl logs test-app-pod --tail=10
```

4. Execute commands inside pods:

```bash
kubectl exec test-app-pod -- ls -la
kubectl exec -it test-app-pod -- sh
# Inside pod: hostname, ip addr, ps aux, exit
```

### Task 3: Diagnose and Resolve Connectivity Issues

1. Expose nginx pod as a service:

```bash
kubectl expose pod my-nginx-pod --port=80 --target-port=80 --name=nginx-service
kubectl get services
kubectl describe service nginx-service
```

2. Test connectivity between pods:

```bash
kubectl run debug-pod --image=busybox:latest --rm -it --restart=Never -- sh
# Inside pod: nslookup nginx-service, wget -qO- nginx-service
# Direct pod access: wget -qO- <POD_IP>
exit
```

3. Simulate and fix a pod with incorrect image:

```bash
kubectl run broken-pod --image=nginx:nonexistent-tag
kubectl get pods
kubectl describe pod broken-pod
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl delete pod broken-pod
kubectl run fixed-pod --image=nginx:latest
kubectl get pods
kubectl describe pod fixed-pod
```

4. Advanced troubleshooting:

```bash
kubectl top nodes
kubectl top pods
kubectl get all
kubectl get pods -o yaml my-nginx-pod
kubectl get pods -w
```

5. Optional network policy testing:

```bash
cat > deny-all-policy.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
kubectl apply -f deny-all-policy.yaml
kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service
kubectl delete networkpolicy deny-all
kubectl run test-connectivity --image=busybox:latest --rm -it --restart=Never -- wget -qO- nginx-service
```

### Task 4: Clean Up Resources

```bash
kubectl delete pod my-nginx-pod
kubectl delete pod test-app-pod
kubectl delete pod fixed-pod
kubectl delete service nginx-service
rm test-pod.yaml deny-all-policy.yaml
kubectl get pods
kubectl get services
# Optional: stop Minikube
minikube stop
```

## Troubleshooting

* **Pod Pending:** check `kubectl describe pod` and `kubectl get events`. Common causes: insufficient resources, image pull issues.
* **Service connection issues:** check `kubectl get endpoints` and service selectors.
* **Image pull errors:** verify image name/tag and network connectivity.

## Key Commands Reference

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Pods
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- <command>

# Services
kubectl get services
kubectl describe service <service-name>
kubectl expose pod <pod-name> --port=<port>

# Troubleshooting
kubectl get events
kubectl top nodes
kubectl top pods
```

## Conclusion

You have learned to:

* Start and manage Minikube clusters
* Deploy pods using CLI and YAML
* Access logs and execute commands inside pods
* Expose services and test pod connectivity
* Troubleshoot common Kubernetes issues

These skills provide a solid foundation for Kubernetes administration and preparation for KCNA certification.
