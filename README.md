# 🚀 Microservices Infrastructure Deployment on AWS ECS with Terraform

This project automates the deployment of a **microservices-based application** on **Amazon Web Services (AWS)** using **Terraform**.

It demonstrates how to:

- Design secure and scalable cloud infrastructure
- Use external and internal load balancers properly
- Set up private networking for backend services
- Configure autoscaling based on CPU metrics
- Keep infrastructure maintainable and version-controlled via Infrastructure as Code (IaC)

> ✨ Built with startups in mind — simple, scalable, secure.

---

## 📌 Project Overview

This architecture hosts a **frontend** and **two backend services**:

- `frontend`: The user interface (listens on port `3000`)
- `backend-a`: A core backend service (listens on port `5000`)
- `backend-b`: Another backend service (listens on port `6000`)

All three are Dockerized and deployed to **Amazon ECS (Fargate)**.

### 🌐 Traffic Routing

- **Public traffic** goes through an **external ALB** (Application Load Balancer) to the **frontend**
- **Internal traffic** goes through an **internal ALB** to the backend services
- Each backend has its own port-based routing

---

## 🧱 Architecture

```
Users
|
v
[External ALB]
|
v
[Frontend Service - ECS]
|
v
[Internal ALB]
|           |
v           v
Backend A  Backend B

```

- **VPC** with public and private subnets
- **Security groups** for strict ingress/egress rules
- **Internal ALB** to isolate backend access
- **Autoscaling** configured for all ECS services
- **Terraform state locking** using S3 and DynamoDB

---

## 🛠 Tech Stack

| Component          | Tool/Service                        |
| ------------------ | ----------------------------------- |
| Cloud Provider     | AWS                                 |
| Infrastructure     | Terraform                           |
| Container Runtime  | Docker + ECS (Fargate)              |
| Load Balancers     | AWS Application Load Balancer (ALB) |
| Secrers management | AWS Secret Manager                  |
| CI/CD              | Jenkins                             |
| Networking         | VPC, Subnets, Security Groups       |
| State Backend      | S3 + DynamoDB (state locking)       |

---

## 🔐 Security Highlights

- **Private subnets** for backend services
- **Internal ALBs** to limit access to internal services only
- **Minimal access rules** via Security Groups
- **Secure secret injection** (e.g., GitHub Container Registry token) via Terraform variables and AWS Secret Manager

---

## ⚙️ Usage

### 🧩 Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- AWS credentials (with access to create IAM, VPC, ECS, ALB, etc.)
- GitHub Container Registry (GHCR) token

### 📁 Clone the Repo

```bash
git clone https://github.com/onukwilip/cloudsania-ecs-task.git
cd cloudsania-ecs-task
```

### 🔧 Configure Variables

Create a `terraform.tfvars` file or pass the variables manually:

```hcl
ghcr_token = "your-ghcr-token"
```

Or export via CLI:

```bash
export GHCR_TOKEN=your-ghcr-token
```

### 🚀 Deploy Infrastructure

```bash
terraform init
terraform apply --var="ghcr_token=$GHCR_TOKEN" --auto-approve
```

Terraform will:

- Create a secure VPC with subnets
- Deploy ECS services
- Configure internal and external ALBs
- Set up autoscaling and target groups

---

## 📈 Autoscaling Configuration

Each ECS service is set to scale based on CPU usage.
You can customize thresholds and capacity in the Terraform autoscaling policies.

---

## 📦 Container Image Assumptions

- Services must be pushed to **GitHub Container Registry (GHCR)**
- Terraform uses your `ghcr_token` to pull the images securely

---

## 🔄 CI/CD with Jenkins

To automate deployments, I set up a **Jenkins-powered CI/CD pipeline** that runs Terraform and deploys all services with a single push.

Here’s what it does:

### 🛠️ What I Built

- I **ran Jenkins locally inside Docker**, no cloud hosting needed
- Then, I **connected Jenkins to my local Docker engine**, so pipeline jobs could launch their own lightweight containers
- I set up **Docker-based Jenkins cloud agents**, so each pipeline stage runs in a clean, isolated container (instead of running inside the Jenkins server itself)
- Finally, I built a Jenkins pipeline that **runs Terraform automatically** with my GitHub Container Registry (GHCR) token, deploying all ECS services whenever needed

### ⚙️ Pipeline Flow (Simplified)

1. **Start Jenkins** locally in Docker
2. **Pull credentials securely** (e.g. GHCR token, and AWS creds via environment variables)
3. **Spin up a container** to run Terraform
4. **Run Terraform plan/apply** to update infrastructure
5. ✅ Done! Your ECS services are deployed or updated with the latest containers

### 🧠 Result

- The whole deployment process is now **automated and reproducible**
- No more manual `terraform apply`
- Each Jenkins job runs in its **own container**, so everything is clean, fast, and isolated

---

## 🤝 Contributions

This repo is open for feedback, improvements, and collaboration!
Feel free to fork and customize it for your team or startup's infrastructure.

---

## 📫 Connect with Me

Follow along or reach out for questions and insights!

- 🔗 [LinkedIn Post](https://www.linkedin.com/in/prince-onukwili-a82143233/)
- 🧑‍💻 Author: [Prince](https://github.com/onukwilip)

---

## 📄 License

MIT License. Use it, break it, improve it!
