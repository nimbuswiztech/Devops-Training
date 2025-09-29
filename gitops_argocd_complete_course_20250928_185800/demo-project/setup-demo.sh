#!/bin/bash

# GitOps ArgoCD Demo Setup Script
# This script sets up a complete ArgoCD demo environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is required but not installed"
        exit 1
    fi

    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi

    # Check kubectl cluster access
    if ! kubectl cluster-info &> /dev/null; then
        print_error "kubectl cannot access the cluster"
        exit 1
    fi

    print_success "All prerequisites met"
}

# Function to install ArgoCD
install_argocd() {
    print_info "Installing ArgoCD..."

    # Create ArgoCD namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    print_info "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=ready --timeout=300s pod -l app.kubernetes.io/name=argocd-server -n argocd

    print_success "ArgoCD installed successfully"
}

# Function to get ArgoCD admin password
get_admin_password() {
    print_info "Getting ArgoCD admin password..."

    # Wait for secret to be created
    local timeout=60
    local count=0
    while ! kubectl -n argocd get secret argocd-initial-admin-secret &> /dev/null; do
        if [ $count -ge $timeout ]; then
            print_error "Timeout waiting for admin secret"
            exit 1
        fi
        sleep 1
        ((count++))
    done

    ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    print_success "ArgoCD admin password retrieved"
    echo -e "${GREEN}Admin Username:${NC} admin"
    echo -e "${GREEN}Admin Password:${NC} $ADMIN_PASSWORD"
}

# Function to setup port forwarding
setup_port_forward() {
    print_info "Setting up port forwarding..."

    # Kill any existing port forwards on 8080
    pkill -f "kubectl port-forward.*8080:443" || true

    # Start port forward
    kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
    PORT_FORWARD_PID=$!

    # Wait a moment for port forward to establish
    sleep 3

    print_success "Port forwarding established on PID: $PORT_FORWARD_PID"
    print_info "ArgoCD UI available at: https://localhost:8080"
}

# Function to deploy demo applications
deploy_demo_apps() {
    print_info "Deploying demo applications..."

    # Create demo applications
    cat <<EOF | kubectl apply -f -
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
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-guestbook
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
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
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-guestbook
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: helm-guestbook
    helm:
      parameters:
      - name: service.type
        value: LoadBalancer
  destination:
    server: https://kubernetes.default.svc
    namespace: helm-guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

    print_success "Demo applications deployed"
}

# Function to show access information
show_access_info() {
    echo ""
    print_success "Demo Setup Complete!"
    echo ""
    echo -e "${GREEN}ArgoCD Access:${NC}"
    echo -e "  URL: https://localhost:8080"
    echo -e "  Username: admin"
    echo -e "  Password: $ADMIN_PASSWORD"
    echo ""
    echo -e "${GREEN}Demo Applications:${NC}"
    echo -e "  • guestbook (Basic YAML)"
    echo -e "  • kustomize-guestbook (Kustomize)"
    echo -e "  • helm-guestbook (Helm Chart)"
    echo ""
    echo -e "${GREEN}Next Steps:${NC}"
    echo -e "  1. Open https://localhost:8080 in your browser"
    echo -e "  2. Login with admin credentials above"
    echo -e "  3. Explore the deployed applications"
    echo -e "  4. Try making changes to the Git repository"
    echo ""
    echo -e "${YELLOW}To access application UIs:${NC}"
    echo -e "  kubectl port-forward -n guestbook svc/guestbook-ui 8081:80"
    echo -e "  kubectl port-forward -n kustomize-guestbook svc/guestbook-ui 8082:80"
    echo -e "  kubectl port-forward -n helm-guestbook svc/helm-guestbook 8083:80"
}

# Main execution
main() {
    echo -e "${BLUE}===========================================${NC}"
    echo -e "${BLUE}    GitOps ArgoCD Demo Setup Script      ${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo ""

    check_prerequisites

    # Check if ArgoCD is already installed
    if kubectl get namespace argocd &> /dev/null; then
        print_warning "ArgoCD namespace already exists"
        read -p "Do you want to continue with existing ArgoCD? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Exiting..."
            exit 0
        fi
    else
        install_argocd
    fi

    get_admin_password
    setup_port_forward
    deploy_demo_apps

    show_access_info
}

# Handle script interruption
trap 'print_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
