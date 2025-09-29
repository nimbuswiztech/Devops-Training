# GitOps Best Practices and Advanced Topics

## Security Best Practices

### 1. RBAC (Role-Based Access Control)

#### ArgoCD Projects for Multi-Tenancy
```yaml
# dev-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: development
  namespace: argocd
spec:
  description: "Development team project"

  # Restrict source repositories
  sourceRepos:
  - 'https://github.com/myorg/dev-apps.git'
  - 'https://github.com/myorg/shared-charts.git'

  # Restrict destination namespaces
  destinations:
  - namespace: 'dev-*'
    server: https://kubernetes.default.svc

  # Define allowed Kubernetes resources
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace

  namespaceResourceWhitelist:
  - group: ''
    kind: Service
  - group: 'apps'
    kind: Deployment

  # RBAC roles
  roles:
  - name: developer
    description: "Developer access to dev apps"
    policies:
    - p, proj:development:developer, applications, get, development/*, allow
    - p, proj:development:developer, applications, sync, development/*, allow
    groups:
    - myorg:developers
```

#### Global RBAC Configuration
```yaml
# argocd-rbac-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    # Global admin role
    p, role:admin, applications, *, */*, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow

    # Read-only role
    p, role:readonly, applications, get, */*, allow
    p, role:readonly, logs, get, */*, allow

    # Developer role - limited access
    p, role:developer, applications, get, */*, allow
    p, role:developer, applications, sync, */*, allow

    # Group bindings
    g, myorg:admins, role:admin
    g, myorg:developers, role:developer
    g, myorg:viewers, role:readonly
```

## Multi-Environment Management

### Environment Promotion Strategy
```yaml
# multi-env-applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-env-app
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - env: dev
        cluster: https://dev-cluster.example.com
        namespace: myapp-dev
        replicas: "1"
        branch: develop
      - env: staging
        cluster: https://staging-cluster.example.com
        namespace: myapp-staging
        replicas: "2"
        branch: release
      - env: prod
        cluster: https://prod-cluster.example.com
        namespace: myapp-prod
        replicas: "3"
        branch: main
  template:
    metadata:
      name: 'myapp-{{env}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/myorg/myapp-config.git
        targetRevision: '{{branch}}'
        path: 'environments/{{env}}'
        helm:
          parameters:
          - name: replicaCount
            value: '{{replicas}}'
          - name: environment
            value: '{{env}}'
      destination:
        server: '{{cluster}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
```

## Secrets Management

### Sealed Secrets Integration
```bash
# Install Sealed Secrets Controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

# Install kubeseal CLI
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/kubeseal-0.18.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.18.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal

# Seal a secret
kubeseal -f secret.yaml -w sealed-secret.yaml
```

## Monitoring and Observability

### ArgoCD Metrics and Monitoring
```yaml
# ServiceMonitor for Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
```

### Notification System
```yaml
# ArgoCD Notifications ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  service.slack: |
    token: $slack-token
  template.app-deployed: |
    message: |
      Application {{.app.metadata.name}} is now running new version.
  trigger.on-deployed: |
    - description: Application is synced and healthy
      send:
      - app-deployed
      when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
```

## CI/CD Integration

### Jenkins Integration
```groovy
// Jenkinsfile
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp:${BUILD_NUMBER} .'
                sh 'docker push myapp:${BUILD_NUMBER}'
            }
        }

        stage('Update GitOps Repo') {
            steps {
                script {
                    sh '''
                        git clone https://github.com/myorg/gitops-repo.git
                        cd gitops-repo
                        sed -i 's|image: myapp:.*|image: myapp:${BUILD_NUMBER}|' overlays/staging/kustomization.yaml
                        git add .
                        git commit -m 'Update image to ${BUILD_NUMBER}'
                        git push origin main
                    '''
                }
            }
        }

        stage('Sync ArgoCD') {
            steps {
                sh '''
                    argocd login ${ARGOCD_SERVER} --username ${ARGOCD_USER} --password ${ARGOCD_PASS} --insecure
                    argocd app sync myapp-staging
                    argocd app wait myapp-staging --health
                '''
            }
        }
    }
}
```

### GitHub Actions Integration
```yaml
# .github/workflows/deploy.yml
name: Deploy to Staging

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Build and push image
      run: |
        docker build -t myapp:${{ github.sha }} .
        docker push myapp:${{ github.sha }}

    - name: Update GitOps repository
      run: |
        git clone https://github.com/myorg/gitops-repo.git
        cd gitops-repo
        sed -i 's|image: myapp:.*|image: myapp:${{ github.sha }}|' overlays/staging/kustomization.yaml
        git add .
        git commit -m "Update image to ${{ github.sha }}"
        git push origin main
      env:
        GITHUB_TOKEN: ${{ secrets.GITOPS_TOKEN }}
```

## Advanced ArgoCD Features

### Application of Applications Pattern
```yaml
# root-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myorg/argocd-apps.git
    targetRevision: HEAD
    path: applications
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Progressive Sync with Waves
```yaml
# Database migration (Wave -1)
apiVersion: batch/v1
kind: Job
metadata:
  name: database-migration
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
    argocd.argoproj.io/hook: PreSync
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: migrate/migrate
        command: ["migrate", "-path", "/migrations", "-database", "postgres://...", "up"]
      restartPolicy: Never
---
# Application deployment (Wave 0)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  # deployment spec
---
# Post-deployment tests (Wave 1)
apiVersion: batch/v1
kind: Job
metadata:
  name: integration-tests
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    argocd.argoproj.io/hook: PostSync
spec:
  # test job spec
```

## Performance Optimization

### Repository Server Optimization
```yaml
# ArgoCD ConfigMap optimization
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  # Increase timeout for large repositories
  timeout.reconciliation: 300s
  timeout.hard.reconciliation: 600s

  # Enable concurrent processing
  application.instanceLabelKey: argocd.argoproj.io/instance
  server.rbac.log.enforce.enable: "false"

  # Repository cache settings
  reposerver.parallelism.limit: "10"
```

---

**Key Best Practices Summary:**
- Implement proper RBAC and security controls
- Use Projects for multi-tenancy
- Manage secrets securely with external tools
- Monitor ArgoCD and applications comprehensively
- Follow GitOps principles for all configuration changes
- Optimize performance based on scale requirements
