###  Kubernetes Cluster Deployment on AWS with Terraform and GitHub Actions
This project demonstrates how to automate Kubernetes cluster deployment using Terraform and GitHub Actions in a GitOps-driven workflow. It brings together Infrastructure as Code (IaC) and CI/CD to provision, configure, and manage Kubernetes environments seamlessly.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
  - [Terraform Deployment](#terraform-deployment)
  - [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
  - [Application Deployment](#application-deployment)
  - [Monitoring Setup](#monitoring-setup)
- [Monitoring and Logging](#monitoring-and-logging)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

This project provides an automated solution to set up a Kubernetes cluster on AWS. It leverages Terraform for infrastructure provisioning, GitHub Actions for continuous integration and continuous deployment (CI/CD), and custom Bash scripts for Kubernetes and Docker installation. The cluster consists of three EC2 instances: one master node and two worker nodes. A sample web application is deployed, and the cluster is monitored using CloudWatch, Prometheus, and Grafana.

## Architecture
![k8CLUSTER]

The architecture comprises the following components:

-   **AWS EC2 Instances:** Three instances (one master, two workers) to host the Kubernetes cluster.
-   **Terraform:** Used to provision the EC2 instances, security groups, VPC, and other necessary AWS resources.
-   **GitHub Actions:** Automates the entire deployment process, from infrastructure provisioning to application deployment and monitoring setup.
-   **Kubernetes:** Orchestrates containerized applications across the EC2 instances.
-   **Docker:** Container runtime used by Kubernetes.
-   **CloudWatch:** Installed on the master node for basic instance-level monitoring.
-   **Prometheus:** Deployed on worker nodes to collect metrics from the Kubernetes cluster.
-   **Grafana:** Deployed on worker nodes for visualizing the metrics collected by Prometheus.
-   **Bash Scripts:** Custom scripts for installing Docker and Kubernetes components on the EC2 instances.

Here's a high-level diagram of the architecture:
![Kubernetes Cluster on AWS: Architecture Diagram](https://github.com/rukevweubioworo912/Gitaction-Terrafrom-k8sCluster-deployment/blob/main/k8Cluster/PICTURE/Generated%20Image%20September%2004%2C%202025%20-%208_49AM.jpeg)

## Features

-   **Automated Infrastructure Provisioning:** Uses Terraform to create all required AWS resources.
-   **CI/CD Pipeline:** GitHub Actions automates deployment, ensuring consistency and efficiency.
-   **Kubernetes Cluster Setup:** Automated installation of Kubernetes and Docker on EC2 instances.
-   **Web Application Deployment:** Seamless deployment of a sample web application to the Kubernetes cluster.
-   **Comprehensive Monitoring:** Integration with CloudWatch, Prometheus, and Grafana for robust cluster and application monitoring.
-   **Scalable:** The architecture can be extended to include more worker nodes if needed.
-   **Idempotent Deployments:** Terraform ensures that subsequent deployments result in the same infrastructure state.

## Prerequisites

Before you begin, ensure you have the following:

1.  **AWS Account:** With appropriate permissions to create EC2 instances, VPCs, security groups, etc.
2.  **AWS CLI Configured:** Ensure your local machine or GitHub Actions environment has AWS credentials configured.
3.  **GitHub Repository:** This project should be hosted in a GitHub repository.
4.  **GitHub Actions Secrets:**
    *   `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
    *   `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
    *   `AWS_REGION`: The AWS region where you want to deploy (e.g., `us-east-1`).
    *   `SSH_PRIVATE_KEY`: A base64 encoded SSH private key that will be used by GitHub Actions to connect to the EC2 instances. This key must correspond to a public key added to the EC2 instances during provisioning.
5.  **Terraform Installed (for local testing):** If you plan to run Terraform locally.
6.  **`kubectl` Installed (for local interaction with the cluster):** If you plan to interact with the Kubernetes cluster directly from your local machine.

## Deployment Steps

The entire deployment is automated via GitHub Actions. A push to the `main` branch (or a specified branch) will trigger the workflow.
![Gitaction: Architecture Diagram](https://github.com/rukevweubioworo912/Gitaction-Terrafrom-k8sCluster-deployment/blob/main/k8Cluster/PICTURE/Screenshot%20(2102).png)

### Terraform Deployment

Terraform is responsible for provisioning the AWS infrastructure. This includes:

-   **VPC and Subnets:** A dedicated Virtual Private Cloud for the cluster.
-   **Security Groups:** To control inbound and outbound traffic for the EC2 instances.
-   **EC2 Instances:** One master node and two worker nodes, each with a specified AMI and instance type.
-   **SSH Key Pair:** For secure access to the EC2 instances.

The `terraform` directory contains the `.tf` files defining the AWS resources.

### Kubernetes Cluster Setup

Once the EC2 instances are provisioned, GitHub Actions executes Bash scripts on each instance to:

1.  **Install Docker:** The container runtime for Kubernetes.
2.  **Install `kubeadm`, `kubelet`, and `kubectl`:** The essential Kubernetes components.
3.  **Initialize Kubernetes Master:** The master node is initialized using `kubeadm init`.
4.  **Join Worker Nodes:** Worker nodes join the cluster using the `kubeadm join` command provided by the master.

![kubernetes cluster setup](https://github.com/rukevweubioworo912/Gitaction-Terrafrom-k8sCluster-deployment/blob/main/k8Cluster/PICTURE/Screenshot%20(2108).png)

These scripts are typically located in the `scripts` directory of the project.

### Application Deployment

After the Kubernetes cluster is healthy, a sample web application is deployed. This usually involves:

1.  **Building Docker Images:** If your application needs to be containerized, GitHub Actions will build the Docker image.
2.  **Pushing Images to a Registry:** The Docker image is pushed to a container registry (e.g., Docker Hub, Amazon ECR).
3.  **Applying Kubernetes Manifests:** Kubernetes deployment and service YAML files (e.g., `app/deployment.yaml`, `app/service.yaml`) are applied to the cluster using `kubectl`.

### Monitoring Setup

Monitoring is crucial for understanding the health and performance of the cluster and application.

-   **CloudWatch Agent (Master Node):** A CloudWatch agent is installed on the master node to collect logs and metrics from the instance itself.
-   **Prometheus (Worker Nodes):** Prometheus is deployed on the worker nodes to scrape metrics from the Kubernetes API server, Kubelet, Node Exporter, and other Kubernetes components.
-   **Grafana (Worker Nodes):** Grafana is deployed on the worker nodes and configured to visualize the data collected by Prometheus. Dashboards will be pre-configured to display key cluster metrics.

## Monitoring and Logging

-   **CloudWatch:** Provides basic infrastructure-level monitoring for the master EC2 instance. Logs can be streamed to CloudWatch Logs.
-   **Prometheus:** Collects time-series data from various Kubernetes components. Accessible via a NodePort or Load Balancer.
-   **Grafana:** Provides rich dashboards for visualizing Prometheus data. Accessible via a NodePort or Load Balancer.

You will need to access the public IP of one of your worker nodes (and the configured NodePort) to access the Grafana dashboard.



1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/rukevweubioworo912/Gitaction-Terrafrom-k8sCluster-deployment
    cd K8cLUSTER
    ```

2.  **Configure AWS Credentials and SSH Key in GitHub Secrets:**
    Go to your GitHub repository -> Settings -> Secrets and variables -> Actions. Add the following secrets:
    *   `AWS_ACCESS_KEY_ID`
    *   `AWS_SECRET_ACCESS_KEY`
    *   `AWS_REGION`
    *   `SSH_PRIVATE_KEY` (Base64 encoded private key that matches the public key used by Terraform).

    To base64 encode your private key:
    ```bash
    cat ~/.ssh/your_private_key | base64
    ```

3.  **Push to `main` Branch:**
    Once the secrets are configured, pushing any changes to the `main` branch will trigger the GitHub Actions workflow to deploy the infrastructure and applications.

4.  **Access the Cluster and Applications:**
    *   **Kubernetes Dashboard/API:** After deployment, you can configure `kubectl` locally to connect to your cluster.
    *   **Web Application:** Check the Kubernetes service of your web application for its exposed IP/DNS and port.
    *   **Grafana Dashboard:** Access Grafana via the public IP of one of your worker nodes and the configured NodePort (e.g., `http://<worker-node-public-ip>:<grafana-nodeport>`).

## Contributing

Contributions are welcome! Please feel free to:

-   Fork the repository.
-   Create a new branch for your features or bug fixes.
-   Submit a pull request with a clear description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
