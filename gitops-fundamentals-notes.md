# GitOps Fundamentals - Detailed Notes

## Introduction
**Presenter:** Abhishek  
**Course:** GitOps and Argo CD Crash Course  
**Video Topic:** GitOps Fundamentals

---

## What is GitOps?

### Definition
GitOps uses **Git as a single source of truth** to deliver applications and infrastructure.

### Key Concept
GitOps extends beyond just application deployment - it encompasses both:
- **Application delivery**
- **Infrastructure management**

---

## Why GitOps? (Problem Statement)

### Traditional Deployment Issues

#### Without GitOps:
- **No tracking mechanism** for changes made to Kubernetes clusters
- **No versioning** for infrastructure modifications
- **No auditing** capabilities
- **No visibility** into who made what changes
- Changes made directly to clusters with no record

#### Example Scenario:
- Person X updates node configuration (adds taint, increases resources)
- After 10 days, no way to track what changes were made
- No mechanism to identify who made the changes
- No versioning for Kubernetes cluster state

### Source Code vs Infrastructure Management Gap

#### Source Code (CI) - Well Managed:
- Proper Git repository tracking
- Pull request workflow
- Verification mechanisms
- Clear audit trail
- Jenkins/CI platform integration

#### Infrastructure/Deployment (CD) - Poorly Managed:
- Shell scripts or Python scripts with kubectl/Helm
- Direct cluster modifications
- No tracking mechanism
- No standardized process

### GitOps Solution
**Core Principle:** If source code has tracking mechanisms, why shouldn't deployments have the same?

---

## GitOps Workflow

### Standard GitOps Process:

1. **DevOps Engineer** updates Kubernetes YAML manifest
2. **Submits Pull Request** to Git repository
3. **Code Review** by another team member
4. **Merge** after approval
5. **GitOps Controller** (Argo CD/Flux) detects changes
6. **Automatic deployment** to Kubernetes cluster

### YAML Manifest Types:
- pod.yaml
- deployment.yaml
- node.yaml (node configurations)
- admission controller configurations
- Any Kubernetes resource manifest

---

## GitOps Principles

### 1. Declarative
- System's desired state must be expressed declaratively
- YAML manifests are declarative
- **"What you see is what you have"**
- Git repository state matches cluster state

### 2. Versioned and Immutable
- All changes tracked in version control
- Immutable change history
- **Note:** GitOps not limited to Git only
  - Can use S3 buckets (versioned storage)
  - Any versioned, declarative storage system

### 3. Pulled Automatically
- GitOps controller actively watches for changes
- Can be **pull mechanism** (controller polls) or **push mechanism** (webhooks)
- Automatic change detection and deployment

### 4. Continuously Reconciled
- **Biggest advantage of GitOps**
- Controller maintains cluster state matching Git repository
- **Prevents unauthorized changes**
- Git remains single source of truth

---

## Continuous Reconciliation Deep Dive

### How It Works:
1. **GitOps controller** has read access to all cluster resources
2. **Maintains cache** of current cluster state
3. **Maintains cache** of Git repository state
4. **Continuously compares** both states
5. **Overrides cluster changes** that don't match Git

### Security Benefits:
- **Prevents unauthorized modifications**
- **Auto-healing** from unwanted changes
- **Hacker protection** - malicious changes automatically reverted
- **Only GitOps controller** manages cluster resources

### Important Note:
- GitOps blindly trusts Git repository
- **Proper Git repository security essential**
- Malicious changes in Git will be deployed

---

## GitOps Scope

### Is GitOps Only for Kubernetes?

#### By Principle: **NO**
- GitOps concepts apply to various systems
- Not limited to container orchestration

#### In Practice: **Mostly YES**
- Popular tools (Argo CD, Flux) target Kubernetes
- Current market focus on Kubernetes clusters
- Future tools may target:
  - Docker Swarm
  - AWS infrastructure
  - Other platforms

---

## GitOps Advantages

### 1. Security
- Continuous reconciliation prevents unauthorized changes
- Automatic override of unwanted modifications
- Protection against malicious changes

### 2. Versioning
- Complete change history
- Based on Git principles
- Can use other versioned storage (S3 buckets)
- Not tightly coupled to Git specifically

### 3. Auto Upgrades
- Pull or push mechanism support
- Automatic deployment of approved changes
- Standardized upgrade process

### 4. Auto Healing
- Infrastructure self-healing capabilities
- Automatic correction of configuration drift
- Maintains desired state continuously

### 5. Continuous Reconciliation
- Real-time state monitoring
- Immediate drift correction
- Consistent cluster state maintenance

---

## Infrastructure vs Application GitOps

### Equal Adoption:
- **Application delivery** GitOps adoption
- **Infrastructure management** GitOps adoption
- Similar usage patterns for both use cases

### Infrastructure GitOps Importance:
- Managing hundreds of Kubernetes clusters
- Thousands of resources across clusters
- More critical than application management at scale
- Complex infrastructure requires proper tracking

---

## Learning Resources

### Vendor-Neutral Information:
**GitHub Repository:** `github.com/open-gitops`
- Vendor-neutral GitOps principles
- Not biased toward specific tools
- Pure GitOps definitions and concepts
- Independent of Argo CD, Flux, or Spinnaker

---

## Course Preview

### Next Video Topics:
1. **Argo CD fundamentals**
2. **Practical implementation**
3. **Installation procedures**
4. **Upgrade processes**
5. **Removal procedures**
6. **Sample application deployment**
7. **Infrastructure change deployment**
8. **Argo CD vs Flux CD comparison**

### Practical Components:
- Hands-on Argo CD implementation
- Real-world deployment scenarios
- Complete GitOps workflow demonstration

---

## Key Takeaways

1. **GitOps solves deployment tracking problems**
2. **Works for both applications and infrastructure**
3. **Security through continuous reconciliation**
4. **Git as single source of truth principle**
5. **Automatic healing and upgrade capabilities**
6. **Currently focused on Kubernetes but not limited to it**
7. **Proper Git security essential for GitOps success**

---

## Related Technologies Mentioned
- **Argo CD** - Popular GitOps controller
- **Flux CD** - Alternative GitOps controller
- **Jenkins** - CI platform integration
- **Kubernetes** - Primary target platform
- **Helm** - Package manager integration
- **kubectl** - Kubernetes CLI tool