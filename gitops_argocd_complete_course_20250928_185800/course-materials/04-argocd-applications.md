# ArgoCD Application Management

## Application Basics

An ArgoCD Application is a Kubernetes Custom Resource that represents a deployed application instance in an environment. It defines the relationship between a source (Git repository) and a destination (Kubernetes cluster).

## Creating Applications

### 1. Using ArgoCD CLI
```bash
# Basic application creation
argocd app create guestbook \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --project default

# Advanced application creation with sync policy
argocd app create my-app \
  --repo https://github.com/myorg/my-app-config.git \
  --path overlays/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-app \
  --project production \
  --sync-policy automated \
  --auto-prune \
  --self-heal \
  --sync-option CreateNamespace=true
```

### 2. Using YAML Manifest
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default

  # Source configuration
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook

  # Destination configuration
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook

  # Sync policy
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m0s
```

## Sync Strategies

### 1. Manual Sync
Default behavior - applications must be manually synchronized:
```bash
# Sync application
argocd app sync guestbook

# Sync with options
argocd app sync guestbook --prune --strategy=hook

# Dry run sync
argocd app sync guestbook --dry-run
```

### 2. Automated Sync
Automatically synchronizes when changes are detected:
```yaml
syncPolicy:
  automated:
    prune: true        # Delete resources not in Git
    selfHeal: true     # Revert manual changes
    allowEmpty: false  # Prevent sync if no resources
```

### 3. Sync Options
```yaml
syncPolicy:
  syncOptions:
  # Create namespace if it doesn't exist
  - CreateNamespace=true

  # Validate resources before applying
  - Validate=false

  # Skip dry-run for resources
  - SkipDryRunOnMissingResource=true

  # Pruning propagation policy
  - PrunePropagationPolicy=foreground

  # Prune resources last
  - PruneLast=true
```

## Application Projects

AppProjects provide multi-tenancy and access control for applications.

```yaml
# project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: "Production applications"

  # Source repositories
  sourceRepos:
  - 'https://github.com/myorg/prod-apps.git'
  - 'https://github.com/myorg/helm-charts.git'

  # Destination clusters and namespaces
  destinations:
  - namespace: 'prod-*'
    server: https://kubernetes.default.svc

  # Allowed Kubernetes resources
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  - group: 'rbac.authorization.k8s.io'
    kind: ClusterRole

  # RBAC roles
  roles:
  - name: developer
    description: "Developer access"
    policies:
    - p, proj:production:developer, applications, get, production/*, allow
    - p, proj:production:developer, applications, sync, production/*, allow
    groups:
    - myorg:developers
```

## ApplicationSets

ApplicationSets enable managing multiple ArgoCD Applications as a single unit.

### Git Generator
```yaml
# applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-apps
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/myorg/cluster-config.git
      revision: HEAD
      directories:
      - path: clusters/*

  template:
    metadata:
      name: '{{path.basename}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/cluster-config.git
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## Application Operations

```bash
# View application details
argocd app get guestbook

# List all applications
argocd app list

# Delete application
argocd app delete guestbook

# View application history
argocd app history guestbook

# Rollback to previous version
argocd app rollback guestbook

# View application resources
argocd app resources guestbook

# View application logs
argocd app logs guestbook
```

## Monitoring and Troubleshooting

### Application Status
```bash
# Check sync status
argocd app get guestbook --output wide

# Watch application status
argocd app wait guestbook --health

# Check for out-of-sync resources
argocd app diff guestbook
```

### Common Issues
```bash
# Force refresh from Git
argocd app get guestbook --refresh

# Hard refresh (ignore cache)
argocd app get guestbook --hard-refresh

# Sync with force
argocd app sync guestbook --force

# Terminate running sync
argocd app terminate-op guestbook
```

---

**Key Management Principles:**
- Use Projects for multi-tenancy and access control
- Implement proper sync strategies based on requirements
- Monitor application health and sync status regularly
- Use ApplicationSets for managing multiple similar applications
