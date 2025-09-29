# ArgoCD Installation Guide

## Prerequisites

### System Requirements
- **Kubernetes Cluster**: Version 1.20 or later
- **kubectl**: Configured to access your cluster
- **Sufficient Resources**: 
  - CPU: 500m minimum, 1 CPU recommended
  - Memory: 512Mi minimum, 1Gi recommended
  - Storage: 1Gi for basic installation

## Basic Installation

### 1. Create Namespace
```bash
# Create dedicated namespace for ArgoCD
kubectl create namespace argocd
```

### 2. Install ArgoCD (Non-HA)
```bash
# Install ArgoCD non-HA version (suitable for testing)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Verify Installation
```bash
# Check all pods are running
kubectl get pods -n argocd

# Expected output:
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          5m
argocd-applicationset-controller-7c7b5f5d5f-x9k4j   1/1     Running   0          5m
argocd-dex-server-6f8b4f4d4f-abc123                1/1     Running   0          5m
argocd-notifications-controller-5f7f8f8f8f-def456   1/1     Running   0          5m
argocd-redis-74cb89f466-ghi789                     1/1     Running   0          5m
argocd-repo-server-65f9fdcbcf-jkl012               1/1     Running   0          5m
argocd-server-5ddc8c7f57-mno345                    1/1     Running   0          5m
```

## CLI Installation

### Linux/WSL Installation
```bash
# Download latest version
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

# Install binary
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Remove downloaded file
rm argocd-linux-amd64

# Verify installation
argocd version --client
```

### macOS Installation
```bash
# Install using Homebrew
brew install argocd

# Verify installation
argocd version --client
```

## Initial Configuration

### 1. Get Admin Password
```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Save password for login
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"
```

### 2. Access Methods

#### Port Forwarding (Development)
```bash
# Port forward to local machine
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access via browser
# https://localhost:8080
```

#### LoadBalancer Service (Cloud)
```bash
# Patch service to use LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get external IP
kubectl get svc argocd-server -n argocd
```

### 3. First Application
```bash
# Login to ArgoCD
argocd login localhost:8080 --username admin --insecure

# Create application using CLI
argocd app create guestbook \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Sync application
argocd app sync guestbook

# Check application status
argocd app get guestbook
```

## Troubleshooting Installation

### Common Issues
1. **Image Pull Failures**: Check if cluster has internet access
2. **CRD Installation Issues**: Manually install CRDs if needed
3. **RBAC Issues**: Check cluster admin permissions

---

**Installation Summary:**
1. Create namespace and apply manifests
2. Verify all pods are running
3. Install and configure CLI
4. Change default admin password
5. Configure access method
6. Create first application to test functionality
