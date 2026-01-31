# Lab 4 – Installing Kubernetes with kubeadm

This lab teaches you to:

- Install a Kubernetes cluster from scratch using kubeadm
- Configure the cluster networking (Flannel CNI)
- Verify nodes, pods, and cluster components
- Deploy and test a simple application
- Troubleshoot common installation issues

## Prerequisites

- Linux system with at least 2 GB RAM and 2 CPU cores
- Root or sudo access
- Docker/container runtime installed
- Internet connection
- Basic text editor skills

Verify environment:
```bash
docker --version
sudo systemctl status docker
```
### Task 1 – Prepare System
Update packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```
Disable swap
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
free -h
```
Load kernel modules
```bash
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```
Configure sysctl
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```
### Task 2 – Install containerd
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y containerd.io
```
Configure containerd
```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status containerd
```
### Task 3 – Install Kubernetes Components
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
kubectl version --client
```
### Task 4 – Initialize Kubernetes Cluster
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')
```
Configure kubectl for regular user
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl cluster-info
```
### Task 5 – Install Flannel Network
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl wait --for=condition=ready pod -l app=flannel -n kube-flannel --timeout=300s
```
Allow scheduling on master (single-node)
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl describe nodes | grep -i taint
```
### Task 6 – Verify Cluster
```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get componentstatuses
kubectl cluster-info
kubectl get --raw='/readyz?verbose'
```
### Task 7 – Deploy Test Application

```bash
kubectl create deployment nginx-test --image=nginx:latest
kubectl expose deployment nginx-test --port=80 --type=NodePort

kubectl get deployments
kubectl get pods
kubectl get services
```
Access the application
```bash
NODE_PORT=$(kubectl get service nginx-test -o jsonpath='{.spec.ports[0].nodePort}')
curl http://localhost:$NODE_PORT
```
Clean up test resources
```bash
kubectl delete deployment nginx-test
kubectl delete service nginx-test
```
### Task 8 – Additional Checks
Metrics
```bash
kubectl top nodes
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s
```
Explore API
```bash
kubectl api-resources
kubectl api-versions
kubectl get events --sort-by=.metadata.creationTimestamp
```
DNS check
```bash
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default
```
### Troubleshooting Quick Commands
- Pods stuck in Pending:
```bash
kubectl describe pod <pod-name>
kubectl describe nodes
kubectl get pods -n kube-flannel
```
- kubelet not starting:
```bash
sudo systemctl status kubelet
sudo journalctl -xeu kubelet
sudo systemctl restart kubelet
```
- Network issues:
```bash
sudo systemctl status containerd
ip route show
sudo iptables -L
```

## Verification Checklist

- All system pods Running
- Node status Ready
- kubectl commands work
- Test app accessible
- Flannel network operational
- Cluster components healthy

This **README** is your quick reference guide for installing Kubernetes with kubeadm and verifying that everything works.
