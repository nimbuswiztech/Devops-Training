# GitOps with ArgoCD - Complete Course

## Course Overview

Welcome to the comprehensive GitOps with ArgoCD course! This course is designed to take you from GitOps fundamentals to advanced ArgoCD implementations in production environments.

## Course Structure

### Module 1: GitOps Fundamentals
**File**: `01-gitops-fundamentals.md`
- Introduction to GitOps principles
- GitOps vs Traditional DevOps
- Benefits and use cases
- GitOps workflow and best practices

### Module 2: ArgoCD Architecture and Components
**File**: `02-argocd-architecture.md`
- ArgoCD architecture deep dive
- Component interactions and responsibilities
- Custom Resource Definitions (CRDs)
- High availability setup

### Module 3: ArgoCD Installation and Setup
**File**: `03-argocd-installation.md`
- Prerequisites and system requirements
- Installation methods (Basic, HA, Helm)
- CLI installation and configuration
- Initial setup and access methods

### Module 4: Application Management
**File**: `04-argocd-applications.md`
- Creating and managing applications
- Sync strategies and policies
- Application Projects and RBAC
- ApplicationSets for scale

### Module 5: Hands-on Demo Project
**File**: `05-demo-project-guide.md`
- Complete demo setup with real applications
- Multiple deployment scenarios
- Practical GitOps workflows
- Troubleshooting exercises

### Module 6: Advanced Topics and Best Practices
**File**: `06-advanced-topics.md`
- Security best practices
- Multi-environment management
- Secrets management
- Monitoring and observability
- CI/CD integration

## Course Prerequisites

### Technical Requirements
- **Kubernetes Knowledge**: Basic understanding of Kubernetes concepts
- **Container Technology**: Familiarity with Docker and containerization
- **Git**: Basic Git operations and workflows
- **YAML**: Understanding of YAML syntax and structure
- **Command Line**: Comfortable with terminal/command line operations

### Software Requirements
- **Kubernetes Cluster**: Local (kind, minikube) or cloud-based
- **kubectl**: Kubernetes command-line tool
- **Git Client**: For repository operations
- **Web Browser**: For accessing ArgoCD UI
- **Text Editor**: For editing configuration files

## Learning Objectives

By the end of this course, you will be able to:

1. **Understand GitOps Principles**
   - Explain the core principles of GitOps
   - Compare GitOps with traditional deployment methods
   - Identify appropriate use cases for GitOps

2. **Master ArgoCD Architecture**
   - Understand ArgoCD components and their roles
   - Design high-availability ArgoCD setups
   - Troubleshoot common architectural issues

3. **Install and Configure ArgoCD**
   - Perform various ArgoCD installation methods
   - Configure ArgoCD for different environments
   - Set up proper access controls and security

4. **Manage Applications with ArgoCD**
   - Create and manage ArgoCD applications
   - Implement various sync strategies
   - Use ApplicationSets for multi-application management

5. **Implement Production-Ready Solutions**
   - Apply security best practices
   - Set up multi-environment pipelines
   - Integrate with existing CI/CD systems
   - Monitor and troubleshoot ArgoCD deployments

## Getting Started

### Quick Start Guide

1. **Clone the Course Repository**
   ```bash
   # Extract the course ZIP file
   unzip gitops_argocd_complete_course.zip
   cd gitops_argocd_complete_course
   ```

2. **Set Up Environment**
   ```bash
   # Make setup script executable
   chmod +x demo-project/setup-demo.sh

   # Run the setup script
   ./demo-project/setup-demo.sh
   ```

3. **Access Course Materials**
   - Start with `course-materials/01-gitops-fundamentals.md`
   - Follow the modules in sequence
   - Complete hands-on labs as you progress

## Course Timeline

### Week 1: Foundations (Modules 1-2)
- **Day 1-2**: GitOps fundamentals and principles
- **Day 3-4**: ArgoCD architecture deep dive
- **Day 5**: Architecture review and Q&A

### Week 2: Implementation (Modules 3-4)
- **Day 1-2**: ArgoCD installation and setup
- **Day 3-4**: Application management
- **Day 5**: Hands-on practice and troubleshooting

### Week 3: Advanced Topics (Modules 5-6)
- **Day 1-2**: Demo project and practical scenarios
- **Day 3-4**: Advanced features and best practices
- **Day 5**: Final project and assessment

## Hands-on Labs

### Lab 1: Basic ArgoCD Setup
- Install ArgoCD on local cluster
- Access ArgoCD UI and CLI
- Create first application

### Lab 2: GitOps Workflow
- Set up Git repository structure
- Create ArgoCD application
- Demonstrate automated sync

### Lab 3: Multi-Environment Deployment
- Configure multiple environments
- Use ApplicationSets for environment management
- Implement promotion workflows

### Lab 4: Security and RBAC
- Configure ArgoCD Projects
- Set up user authentication
- Implement role-based access control

### Lab 5: Production Deployment
- High-availability ArgoCD setup
- Monitoring and alerting configuration
- Disaster recovery procedures

## Support Resources

### Essential Files in This Package
- **Demo Scripts**: `demo-project/setup-demo.sh` - Automated demo environment setup
- **Sample Applications**: `demo-project/guestbook-manifests.yaml` - Kubernetes manifests
- **ArgoCD Configurations**: `demo-project/argocd-applications.yaml` - Application definitions

### Additional Resources
- [Official ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Example Applications](https://github.com/argoproj/argocd-example-apps)
- [GitOps Principles](https://www.gitops.tech/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Ready to start your GitOps journey?** Begin with Module 1: [GitOps Fundamentals](01-gitops-fundamentals.md)

Happy Learning! 🚀
