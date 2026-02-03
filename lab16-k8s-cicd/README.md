# Kubernetes CI/CD Lab (Cloud-Based)

This project demonstrates a complete **CI/CD pipeline for deploying a Node.js application to Kubernetes using GitHub Actions**.

The main goal of this lab is to show how a real-world CI/CD workflow deploys to a **cloud Kubernetes cluster** (not local clusters like Minikube or Kind).

---

## Important Note (Read This First)

This CI/CD workflow **will NOT work on local Kubernetes clusters** such as:

- Minikube  
- Kind  
- MicroK8s  

Because GitHub Actions runs in the cloud, it cannot access your local machine.

This lab is designed to work only with a **cloud Kubernetes cluster**, for example:

- AWS EKS  
- DigitalOcean Kubernetes  
- GKE  
- Azure AKS  

---

## How This Lab Works

1. You push code to GitHub.
2. GitHub Actions:
   - Builds a Docker image.
   - Pushes it to a container registry.
   - Deploys it to your cloud Kubernetes cluster using `kubectl`.

All communication with the cluster happens using a **kubeconfig file stored as a GitHub secret**.

---

## How to Use This Project

### Step 1: Clone or Download the Project

```bash
git clone https://github.com/muhammadhammad2005/KCNA.git
cd KCNA
cd lab16-k8s-cicd
```
### Step 2: Prepare a Cloud Kubernetes Cluster

Create a Kubernetes cluster using any cloud provider.

You must have a working `kubeconfig` file on your local system.

Test it:
```bash
kubectl get nodes
```

**Add all the files in your repo**

### Step 3: Add Kubeconfig as GitHub Secret

On GitHub:

- Go to your repository
- Settings → Secrets and variables → Actions
- Click New repository secret

Add:

- Name: KUBECONFIG_DATA
- Value: content of your kubeconfig file

Get kubeconfig content:
```bash
cat ~/.kube/config
```
### Step 4: Push Code to Trigger CI/CD
```bash
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main
```
GitHub Actions will now:

- Build the image
- Deploy to your cloud cluster
- Apply Kubernetes manifests from k8s-manifests/

## Verifying Deployment
After pipeline completes:
```bash
kubectl get pods
kubectl get svc
```
Open the service URL in browser to see the running app.
