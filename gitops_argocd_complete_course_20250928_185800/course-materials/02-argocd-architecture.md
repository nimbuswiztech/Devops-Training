# ArgoCD Architecture and Components

## ArgoCD Overview

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state.

## Architecture Components

### 1. API Server
The API Server is the central component that exposes ArgoCD's gRPC/REST API.

**Responsibilities:**
- Application Management: Create, read, update, delete applications
- Status Reporting: Provide application and sync status
- Authentication: Handle user authentication and SSO integration
- Authorization: Enforce RBAC policies

### 2. Application Controller
The Application Controller is a Kubernetes controller that continuously monitors applications.

**Responsibilities:**
- Continuous Reconciliation: Compare desired state (Git) with live state (cluster)
- Sync Operations: Apply changes to bring cluster in sync with Git
- Health Assessment: Monitor application health and status
- Resource Management: Manage Kubernetes resources lifecycle

### 3. Repository Server
The Repository Server is an internal service that manages Git repository interactions.

**Responsibilities:**
- Git Operations: Clone, fetch, and cache Git repositories
- Manifest Generation: Process templates and generate Kubernetes manifests
- Template Processing: Handle Helm, Kustomize, Jsonnet templates
- Caching: Maintain local cache of repository content

### 4. ApplicationSet Controller
The ApplicationSet Controller automates the creation and management of ArgoCD Applications.

**Responsibilities:**
- Application Generation: Create Applications based on templates
- Multi-cluster Management: Deploy to multiple clusters
- Dynamic Configuration: Generate applications from various sources

## ArgoCD CRDs

### 1. Application CRD
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
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
```

### 2. AppProject CRD
```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-project
  namespace: argocd
spec:
  description: "My Project"
  sourceRepos:
  - 'https://github.com/myorg/*'
  destinations:
  - namespace: 'my-app-*'
    server: https://kubernetes.default.svc
```

---

**Key Architecture Benefits:**
- Modularity: Components can be replaced or scaled independently
- Scalability: Horizontal scaling of stateless components
- Security: Clear separation of concerns and RBAC
- Reliability: Built-in redundancy and failure handling
