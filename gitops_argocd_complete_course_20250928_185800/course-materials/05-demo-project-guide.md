# Demo Project: GitOps with ArgoCD

## Project Overview

This demo project showcases GitOps principles using ArgoCD to deploy and manage a sample guestbook application. The project demonstrates the complete GitOps workflow from code changes to automated deployment.

## Demo Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │  Git Repository │    │    ArgoCD       │
│                 │    │  (Source Code)  │    │   (GitOps)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         │ 1. Code Changes        │                        │
         │───────────────────────►│                        │
         │                        │                        │
         │                        │ 2. Detect Changes     │
         │                        │◄───────────────────────│
         │                        │                        │
         │                        │ 3. Pull & Deploy      │
         │                        │                        ▼
         │                        │              ┌─────────────────┐
         │                        │              │  Kubernetes     │
         │                        │              │  Cluster        │
         │                        │              └─────────────────┘
```

## Demo Setup Instructions

### Prerequisites
1. **Kubernetes Cluster** (kind, minikube, or cloud)
2. **kubectl** configured
3. **ArgoCD** installed
4. **Git** client
5. **curl** or web browser

### Step 1: Setup Demo Environment
```bash
# Clone the demo repository
git clone https://github.com/argoproj/argocd-example-apps.git
cd argocd-example-apps

# Create demo namespace
kubectl create namespace demo

# Verify cluster access
kubectl cluster-info
```

### Step 2: Deploy ArgoCD (if not already installed)
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### Step 3: Access ArgoCD UI
```bash
# Port forward to ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Access UI at https://localhost:8080
# Username: admin
# Password: (from previous step)
```

## Demo Scenarios

### Scenario 1: Basic Guestbook Deployment

#### Create Application via CLI
```bash
# Login to ArgoCD CLI
argocd login localhost:8080 --username admin --insecure

# Create guestbook application
argocd app create guestbook \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --project default

# Sync the application
argocd app sync guestbook

# Check application status
argocd app get guestbook
```

#### Create Application via YAML
```yaml
# guestbook-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### Scenario 2: Kustomize-based Deployment
```yaml
# kustomize-guestbook-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: kustomize-guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: kustomize-guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### Scenario 3: Helm Chart Deployment
```yaml
# helm-guestbook-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: helm-guestbook
    helm:
      valueFiles:
      - values.yaml
      parameters:
      - name: service.type
        value: LoadBalancer
      - name: replicaCount
        value: "2"
  destination:
    server: https://kubernetes.default.svc
    namespace: helm-guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Testing the Demo

### 1. Verify Applications
```bash
# List all applications
kubectl get applications -n argocd

# Check application status
kubectl get applications -n argocd -o wide

# Check deployed resources
kubectl get all -n guestbook
kubectl get all -n kustomize-guestbook
kubectl get all -n helm-guestbook
```

### 2. Access Applications
```bash
# Port forward to guestbook UI
kubectl port-forward -n guestbook svc/guestbook-ui 8081:80

# Access application at http://localhost:8081
```

### 3. Demonstrate GitOps Workflow
1. **Make a change** in the Git repository
2. **Commit and push** the change
3. **Observe ArgoCD** detecting the change
4. **Watch automatic sync** (if enabled)
5. **Verify changes** in the cluster

### 4. Demonstrate Rollback
```bash
# View application history
argocd app history guestbook

# Rollback to previous version
argocd app rollback guestbook <revision>

# Verify rollback
kubectl get pods -n guestbook
```

## Key Demo Points

1. **GitOps Principles**: Demonstrate declarative, Git-based configuration
2. **Automated Sync**: Show how changes in Git trigger deployments
3. **Self-Healing**: Modify resources directly and show ArgoCD correcting them
4. **Multi-Environment**: Use ApplicationSets for environment promotion
5. **Rollback**: Demonstrate easy rollback using Git history
6. **Monitoring**: Show application health and sync status

## Troubleshooting Tips

- **Sync Issues**: Check application events and logs
- **Network Problems**: Verify cluster connectivity and DNS
- **Permission Errors**: Check RBAC and service accounts
- **Resource Conflicts**: Use kubectl describe to identify issues

---

This demo provides a comprehensive hands-on experience with GitOps and ArgoCD, showcasing real-world scenarios and best practices.
