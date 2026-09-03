# 🎓 Student Registration — Azure DevSecOps

A full-stack **Student Registration** application (React + Spring Boot + MariaDB) built primarily as an end-to-end **DevSecOps reference project** on Microsoft Azure — covering Infrastructure as Code, containerization, CI with security gates, GitOps continuous delivery to Kubernetes, and full observability.

> Infra → CI → Security Scan → Registry → GitOps CD → AKS → Monitoring, all wired together.

<p align="left">
  <img alt="Java" src="https://img.shields.io/badge/Java-17-orange?logo=openjdk&logoColor=white">
  <img alt="Spring Boot" src="https://img.shields.io/badge/Spring%20Boot-3.5.16-brightgreen?logo=springboot&logoColor=white">
  <img alt="React" src="https://img.shields.io/badge/React-18.3-61DAFB?logo=react&logoColor=black">
  <img alt="Vite" src="https://img.shields.io/badge/Vite-5.4-646CFF?logo=vite&logoColor=white">
  <img alt="MariaDB" src="https://img.shields.io/badge/MariaDB-11.8-003545?logo=mariadb&logoColor=white">
  <img alt="Docker" src="https://img.shields.io/badge/Docker-multi--stage-2496ED?logo=docker&logoColor=white">
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-AKS-326CE5?logo=kubernetes&logoColor=white">
  <img alt="Helm" src="https://img.shields.io/badge/Helm-Chart-0F1689?logo=helm&logoColor=white">
  <img alt="ArgoCD" src="https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?logo=argo&logoColor=white">
  <img alt="Jenkins" src="https://img.shields.io/badge/Jenkins-CI-D24939?logo=jenkins&logoColor=white">
  <img alt="Trivy" src="https://img.shields.io/badge/Trivy-Vuln%20Scan-1904DA">
  <img alt="Terraform" src="https://img.shields.io/badge/Terraform-Azure-7B42BC?logo=terraform&logoColor=white">
  <img alt="Grafana" src="https://img.shields.io/badge/Grafana-Managed-F46800?logo=grafana&logoColor=white">
  <img alt="Prometheus" src="https://img.shields.io/badge/Prometheus-Managed-E6522C?logo=prometheus&logoColor=white">
</p>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [API Reference](#-api-reference)
- [Repository Structure](#-repository-structure)
- [Getting Started (Local Development)](#-getting-started-local-development)
- [Running with Docker](#-running-with-docker)
- [Infrastructure as Code — Terraform](#1%EF%B8%8F%E2%83%A3-infrastructure-as-code--terraform)
- [CI Pipeline — Jenkins + Trivy](#2%EF%B8%8F%E2%83%A3-ci-pipeline--jenkins--trivy)
- [Container Registry — Docker Hub](#3%EF%B8%8F%E2%83%A3-container-registry--docker-hub)
- [Deployment — Helm on AKS](#4%EF%B8%8F%E2%83%A3-deployment--helm-on-aks)
- [GitOps CD — Argo CD](#5%EF%B8%8F%E2%83%A3-gitops-cd--argo-cd)
- [Observability — Azure Monitor, Managed Prometheus & Grafana](#6%EF%B8%8F%E2%83%A3-observability--azure-monitor-managed-prometheus--grafana)
- [Security Practices](#-security-practices)
- [Roadmap](#-roadmap)
- [Author](#-author)

---

## 🧭 Overview

This project simulates a real production workflow for a small internal web application:

1. A **React** frontend lets a user register students and view/delete records in a table.
2. A **Spring Boot** REST API persists data to **MariaDB**.
3. Every push to `main` runs through a **Jenkins** pipeline that tests, builds, **scans images with Trivy**, and publishes to **Docker Hub**.
4. Jenkins then updates image tags on a dedicated `gitops` branch (Helm `values.yaml`), which **Argo CD** picks up automatically and syncs to an **Azure Kubernetes Service (AKS)** cluster.
5. The cluster is provisioned with **Terraform** (VMs) and Azure CLI (AKS), and is fully observable through **Azure Monitor's managed Prometheus** and **Azure Managed Grafana** dashboards.

In short: this repo is less about the CRUD app itself, and more a demonstration of a secure, automated, GitOps-driven delivery pipeline on Azure.

---

## 🏗 Architecture

```mermaid
flowchart TB
    subgraph Client
        U[Browser]
    end

    subgraph AKS["Azure Kubernetes Service (AKS)"]
        ING["Ingress — webapprouting.kubernetes.azure.com"]
        FE["Frontend Pod — React build served by Apache httpd"]
        BE["Backend Pod — Spring Boot REST API :8080"]
        DB[("MariaDB Pod + PVC (5Gi)")]
    end

    subgraph Observability["Azure Monitor Workspace"]
        PROM["Managed Prometheus"]
        GRAF["Azure Managed Grafana"]
    end

    U -->|HTTPS| ING
    ING -->|"/"| FE
    ING -->|"/api"| BE
    FE -->|"axios → VITE_API_URL"| BE
    BE --> DB
    BE -->|"/actuator/prometheus"| PROM
    PROM --> GRAF
```

### Delivery pipeline

```mermaid
flowchart LR
    DEV[Developer Commit] --> GH["GitHub (main branch)"]
    GH --> JK["Jenkins Pipeline"]
    JK --> T1["Backend: mvn test"]
    JK --> T2["Frontend: npm lint"]
    T1 --> BLD["Docker build: frontend + backend"]
    T2 --> BLD
    BLD --> SCAN["Trivy scan (vuln + secret, HIGH/CRITICAL)"]
    SCAN -->|pass| PUSH["Push images to Docker Hub"]
    PUSH --> GITOPS["Update helm/values.yaml on 'gitops' branch"]
    GITOPS --> ARGO["Argo CD auto-detects change"]
    ARGO --> SYNC["Sync to AKS via Helm chart"]
    SYNC --> MON["Azure Managed Prometheus + Grafana"]
```

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | React 18, Vite, Axios, React Router DOM |
| **Backend** | Java 17, Spring Boot 3.5, Spring Data JPA, Spring Actuator, Micrometer (Prometheus registry), Lombok |
| **Database** | MariaDB 11.8 |
| **Containers** | Docker (multi-stage builds), non-root runtime users |
| **CI** | Jenkins Declarative Pipeline |
| **Security scanning** | Trivy (vulnerability + secret scanning), SonarQube Maven plugin |
| **IaC** | Terraform (`azurerm` provider) for Azure VM infrastructure |
| **Container Orchestration** | Kubernetes on Azure Kubernetes Service (AKS) |
| **Packaging** | Helm chart (`helm/student-registration`) |
| **GitOps CD** | Argo CD |
| **Observability** | Azure Monitor Workspace, Azure Managed Prometheus, Azure Managed Grafana, Spring Boot Actuator |
| **Registry** | Docker Hub |

---

## ✨ Features

- 📝 Register a student with name, email, course, highest education, percentage, branch/stream, and mobile number
- 📋 View all registered students in a live table
- 🗑 Delete a student record
- ❤️ Health checks via Spring Boot Actuator (`/actuator/health`, `/actuator/prometheus`)
- 🔐 Every image is vulnerability- and secret-scanned before it is allowed to ship
- 🔁 Fully automated GitOps delivery — no manual `kubectl apply` to production
- 📊 Real-time application and infrastructure metrics on Grafana

---

## 🔌 API Reference

Base path: `/api` (proxied by the ingress to the backend service on port `8080`)

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/register` | Register a new student |
| `GET` | `/api/users` | List all registered students |
| `DELETE` | `/api/users/{id}` | Delete a student by ID |
| `GET` | `/actuator/health` | Liveness / readiness probe target |
| `GET` | `/actuator/prometheus` | Prometheus scrape endpoint |

---

## 📁 Repository Structure

```
Student_Registration-Azure-DevSecOps/
├── backend/                       # Spring Boot REST API
│   ├── src/main/java/.../controller/UserController.java
│   ├── src/main/java/.../model/User.java
│   ├── src/main/java/.../repository/UserRepository.java
│   ├── src/main/resources/application.properties
│   ├── Dockerfile                 # Multi-stage: maven build -> eclipse-temurin JRE (alpine)
│   └── pom.xml
├── frontend/                      # React + Vite SPA
│   ├── src/components/RegistrationForm.jsx
│   ├── src/hooks/useRegistrationForm.js
│   ├── src/api/userService.js
│   ├── Dockerfile                 # Multi-stage: node build -> httpd:alpine
│   └── package.json
├── helm/student-registration/     # Helm chart deployed to AKS by Argo CD
│   ├── Chart.yaml
│   ├── values.yaml                # Image tags updated automatically by Jenkins
│   └── templates/
│       ├── backend.yaml
│       ├── frontend.yaml
│       ├── mariadb.yaml
│       ├── ingress.yaml
│       └── servicemonitor.yaml    # Scraped by Azure Managed Prometheus
├── terraform/vm1_terraform_setup/ # Provisions the DevOps + K8s VMs on Azure
│   ├── provider.tf / versions.tf
│   ├── resource-group.tf / network.tf
│   ├── vm-devops.tf / vm-k8s.tf
│   └── variables.tf / outputs.tf
├── Jenkinsfile                    # Full CI pipeline definition
└── Screenshots/                   # Evidence captures used in this README
```

---

## 💻 Getting Started (Local Development)

### Prerequisites
- Java 17 (JDK) & Maven
- Node.js & npm
- A running MariaDB instance

### Backend

```bash
cd backend

# Configure your database in src/main/resources/application.properties
# (or export as environment variables consumed by the properties file)
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=student_registration
export DB_USER=root
export DB_PASSWORD=yourpassword

mvn clean package
java -jar target/student-registration-backend-0.0.1-SNAPSHOT.jar
```
The API starts on **http://localhost:8080**.

### Frontend

```bash
cd frontend
npm install

# point the SPA at your backend
echo 'VITE_API_URL="http://localhost:8080/api"' > .env

npm run dev       # development server
# or
npm run build     # production build -> dist/
```

---

## 🐳 Running with Docker

```bash
# Backend
docker build -t student-registration-backend ./backend
docker run -p 8080:8080 \
  -e DB_HOST=<db-host> -e DB_PORT=3306 \
  -e DB_NAME=student_registration -e DB_USER=<user> -e DB_PASSWORD=<pass> \
  student-registration-backend

# Frontend
docker build --build-arg VITE_API_URL=/api -t student-registration-frontend ./frontend
docker run -p 80:80 student-registration-frontend
```

---

## 1️⃣ Infrastructure as Code — Terraform

Two Ubuntu 24.04 LTS VMs (a **DevOps VM** for Jenkins/Docker/Trivy, and a **Kubernetes VM** with `k3s`, `kubectl`, `helm`, and the Azure CLI pre-validated) are provisioned in a dedicated VNet/Subnet with per-role NSGs (SSH, Jenkins `8080`, HTTP/HTTPS, Grafana `3000`). The production-facing workload itself runs on a separately provisioned **AKS** cluster.

<table>
<tr>
<td width="33%"><img src="screenshots/01-terraform-apply-complete.png" alt="terraform apply complete"/><br/><sub align="center">Terraform <code>apply</code> — 13 resources created (VNet, NSGs, NICs, both VMs)</sub></td>
<td width="33%"><img src="screenshots/03-devops-vm-ready.png" alt="devops vm ready"/><br/><sub>DevOps VM provisioned and reachable</sub></td>
<td width="33%"><img src="screenshots/04-k8s-vm-toolchain.png" alt="k8s vm toolchain"/><br/><sub>K8s VM toolchain validated: Azure CLI, Terraform, kubectl, Helm, Git</sub></td>
</tr>
</table>

<table>
<tr>
<td width="50%"><img src="screenshots/05-aks-cluster-created.png" alt="aks cluster created"/><br/><sub>AKS cluster <code>studentreg-aks-ci</code> created</sub></td>
<td width="50%"><img src="screenshots/02-azure-resource-groups.png" alt="azure resource groups"/><br/><sub>Resulting Azure resource groups: infra VMs, AKS cluster, and its managed node RG</sub></td>
</tr>
</table>

---

## 2️⃣ CI Pipeline — Jenkins + Trivy

The [`Jenkinsfile`](./Jenkinsfile) defines a declarative pipeline with these stages:

`Checkout` → `Backend Test (mvn test)` → `Frontend Lint (npm lint)` → `Prepare Image Tags` → `Build Backend Image` → `Build Frontend Image` → `Trivy Backend Scan` → `Trivy Frontend Scan` → `Docker Hub Push` → `Update GitOps Image Tags` → `Image Metadata`

Images are tagged with `<git-sha>-<build-number>` for full traceability, and the pipeline **fails the build (`exit-code 1`) on any `HIGH`/`CRITICAL` Trivy finding**, so a vulnerable image never reaches Docker Hub.

<p align="center">
  <img src="screenshots/06-jenkins-pipeline-run.png" alt="jenkins pipeline all green" width="85%"/>
  <br/><sub>A completed pipeline run — every stage, including both Trivy scans, passing</sub>
</p>

---

## 3️⃣ Container Registry — Docker Hub

On a successful `main` build, both images are pushed with two tags (`<sha>-<build>` and `<sha>`) to Docker Hub.

<p align="center">
  <img src="screenshots/07-dockerhub-images.png" alt="docker hub images" width="85%"/>
  <br/><sub><code>student-registration-frontend</code> and <code>student-registration-backend</code> freshly published</sub>
</p>

---

## 4️⃣ Deployment — Helm on AKS

The [`helm/student-registration`](./helm/student-registration) chart deploys the frontend, backend, and MariaDB (with a `PersistentVolumeClaim`), an `Ingress` using AKS's built-in **Web Application Routing** add-on, and a `ServiceMonitor` for Prometheus scraping — all templated from a single [`values.yaml`](./helm/student-registration/values.yaml).

<p align="center">
  <img src="screenshots/11-app-verified-on-aks.png" alt="application verified on aks" width="85%"/>
  <br/><sub>Pods <code>Running</code> on AKS; ingress reachable; <code>/actuator/health</code> reporting <code>UP</code> for DB, disk space, liveness & readiness</sub>
</p>

---

## 5️⃣ GitOps CD — Argo CD

Jenkins never talks to the cluster directly. Instead, its final stage commits the new image tags to `helm/values.yaml` on a dedicated **`gitops`** branch. An Argo CD `Application` watches that branch/path and **auto-syncs** the cluster to match — a clean separation between "build" (Jenkins/CI) and "release" (Argo CD/CD).

<table>
<tr>
<td width="50%"><img src="screenshots/08-argocd-application.png" alt="argocd application"/><br/><sub>The <code>student-registration</code> Argo CD Application, tracking the <code>gitops</code> branch</sub></td>
<td width="50%"><img src="screenshots/10-argocd-auto-sync.png" alt="argocd auto sync enabled"/><br/><sub>Automated sync policy enabled — no manual promotion step</sub></td>
</tr>
</table>

<p align="center">
  <img src="screenshots/09-argocd-resource-tree.png" alt="argocd resource tree" width="85%"/>
  <br/><sub>Full resource tree: Deployments → ReplicaSets → Pods for frontend, backend, and MariaDB, all <code>Synced</code></sub>
</p>

---

## 6️⃣ Observability — Azure Monitor, Managed Prometheus & Grafana

An **Azure Monitor Workspace** collects cluster and application metrics via **Azure Managed Prometheus** (enabled with `az aks update --enable-azure-monitor-metrics`), which is then wired into **Azure Managed Grafana** as a data source, with RBAC access granted via Azure role assignment.

<table>
<tr>
<td width="33%"><img src="screenshots/12-azure-monitor-workspace.png" alt="azure monitor workspace"/><br/><sub>Azure Monitor Workspace created</sub></td>
<td width="33%"><img src="screenshots/13-managed-prometheus-enabled.png" alt="managed prometheus enabled"/><br/><sub>Managed Prometheus enabled on the AKS cluster</sub></td>
<td width="33%"><img src="screenshots/15-grafana-rbac-role.png" alt="grafana rbac role"/><br/><sub>Role assignment granted to Azure Managed Grafana</sub></td>
</tr>
<tr>
<td width="33%"><img src="screenshots/14-prometheus-datasource-grafana.png" alt="prometheus datasource in grafana"/><br/><sub>Managed Prometheus wired in as a Grafana data source</sub></td>
<td width="33%"><img src="screenshots/16-grafana-home.png" alt="grafana home"/><br/><sub>Azure Managed Grafana workspace, ready for dashboards</sub></td>
<td width="33%"><img src="screenshots/25-metric-node-cpu-usage.png" alt="node cpu usage"/><br/><sub>Cluster-level node CPU (<code>node_cpu_seconds_total</code>)</sub></td>
</tr>
</table>

**Application & infrastructure metrics dashboarded (PromQL shown in each panel):**

<table>
<tr>
<td width="33%"><img src="screenshots/17-metric-http-request-rate.png" alt="http request rate"/><br/><sub>HTTP request rate<br/><code>sum(rate(http_server_requests_seconds_count[5m]))</code></sub></td>
<td width="33%"><img src="screenshots/18-metric-http-status-distribution.png" alt="http status distribution"/><br/><sub>HTTP status code distribution</sub></td>
<td width="33%"><img src="screenshots/19-metric-http-5xx-errors.png" alt="http 5xx error rate"/><br/><sub>HTTP 5xx error rate (clean — zero server errors)</sub></td>
</tr>
<tr>
<td width="33%"><img src="screenshots/20-metric-jvm-cpu-usage.png" alt="jvm cpu usage"/><br/><sub>Backend JVM process CPU usage</sub></td>
<td width="33%"><img src="screenshots/21-metric-jvm-memory-used.png" alt="jvm memory used"/><br/><sub>JVM memory used (<code>jvm_memory_used_bytes</code>)</sub></td>
<td width="33%"><img src="screenshots/24-metric-application-ready-time.png" alt="application ready time"/><br/><sub>Spring Boot application ready time</sub></td>
</tr>
<tr>
<td width="33%"><img src="screenshots/22-metric-backend-pod-cpu.png" alt="backend pod cpu"/><br/><sub>Backend pod CPU (<code>container_cpu_usage_seconds_total</code>)</sub></td>
<td width="33%"><img src="screenshots/23-metric-backend-pod-memory.png" alt="backend pod memory"/><br/><sub>Backend pod memory (<code>container_memory_working_set_bytes</code>)</sub></td>
<td width="33%"></td>
</tr>
</table>

---

## 🔐 Security Practices

- **Least-trust runtime images** — backend runs as a non-root `spring` user on `eclipse-temurin-jre-alpine`; frontend serves static assets from `httpd:alpine` with Alpine packages patched at build time.
- **Shift-left scanning** — Trivy scans both application images for OS/library vulnerabilities *and* leaked secrets on every build, gated at `HIGH`/`CRITICAL` severity with a hard pipeline failure.
- **Static analysis** — SonarQube Maven plugin wired into the backend build.
- **No direct cluster access from CI** — Jenkins can only push a Git commit; Argo CD is the only actor that talks to the Kubernetes API, reducing the CI system's blast radius.
- **Secrets via Kubernetes Secrets** — DB credentials are injected into the backend via `secretKeyRef`, never baked into images or Helm values.

---

## 🗺 Roadmap

- [ ] Add automated frontend/backend unit test coverage reporting
- [ ] Promote the SonarQube stage into the active Jenkins pipeline
- [ ] TLS termination on the ingress (cert-manager / Let's Encrypt)
- [ ] Horizontal Pod Autoscaling based on the custom Prometheus metrics already collected
- [ ] Multi-environment GitOps (`staging` / `production` overlays)

---

## 👤 Author

**Anurag Patil**
GitHub: [@AnuragPatil-cloud](https://github.com/AnuragPatil-cloud) · Docker Hub: [anuragpatilcloud](https://hub.docker.com/u/anuragpatilcloud)
