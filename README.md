# Quote-app
End-to-end DevOps project using Terraform, Jenkins, Docker, and KIND on Azure. Automatically builds, tests, and deploys a Flask app that serves random motivational quotes via a Kubernetes cluster.

## 🚀 How It Works

### 1. Infrastructure Setup (Terraform)
- Provisions 3 Azure VMs:
  - `jenkins-master`
  - `jenkins-agent-1`
  - `k8s-vm`
- Configures:
  - NSG rules for SSH (22) and App (8080)
  - NICs, Public IPs, and subnet

### 2. Jenkins Pipeline Flow

**Stages in Jenkinsfile:**
1. **Clone Repo** – Pulls latest code from GitHub
2. **Build Docker Image** – Builds image from `quote-api/Dockerfile`
3. **Push to DockerHub** – Authenticates and pushes the image
4. **Run Kubernetes Cluster** – SSH into `k8s-vm`, run `kind`, clone repo, apply Kubernetes manifests

---

## ⚙️ Prerequisites

- Azure CLI & Terraform installed
- Jenkins installed on master VM
- Jenkins agent node configured
- SSH key pair (`jenkins-key`, `jenkins-key.pub`) for VM access
- Docker Hub credentials configured in Jenkins
- `kind`, `kubectl`, and `docker` installed on `k8s-vm`

---
