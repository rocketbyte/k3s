# Terraform Deployment for RocketByte K3s

This directory contains Terraform configurations for deploying the RocketByte application stack on a Raspberry Pi K3s cluster using Helm charts. The infrastructure is designed to be modular, customizable, and independent with selectable components.

## Architecture

The infrastructure follows these design principles:
- **Modularity**: Each component is a separate module
- **Independence**: Components can be deployed independently
- **Customization**: All aspects are configurable via variables
- **Security**: Sensitive values are marked as sensitive
- **Resource Management**: Proper resource limits for all components
- **Scalability**: Replica counts can be adjusted for each component

## Prerequisites

- Terraform v1.0.0 or higher
- kubectl configured with access to your Raspberry Pi K3s cluster
- Helm v3

## Structure

```
terraform/
├── modules/                  # Reusable Terraform modules
│   ├── namespaces/           # Kubernetes namespaces
│   ├── mongodb/              # MongoDB database
│   ├── ingress_controller/   # Traefik ingress controller
│   └── avexa_react/          # Avexa React frontend
├── environments/             # Environment-specific configurations
│   └── dev/                  # Development environment
├── main.tf                   # Root module configuration
├── variables.tf              # Root module variables
├── outputs.tf                # Root module outputs
└── README.md                 # This file
```

## Raspberry Pi K3s Cluster Configuration

1. Set up your Raspberry Pi K3s cluster context in your kubeconfig:

```bash
# Example: Import the k3s config from your Raspberry Pi
scp pi@raspberry:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config
# Set the server address and rename the context
sed -i '' 's/127.0.0.1/raspberry.local/g' ~/.kube/k3s-config
export KUBECONFIG=$KUBECONFIG:~/.kube/k3s-config
kubectl config use-context default --kubeconfig ~/.kube/k3s-config
kubectl config rename-context default raspberry-k3s --kubeconfig ~/.kube/k3s-config
```

## Usage

### Quick Start

You can either deploy from the root module or use environment-specific configurations:

#### Root Module Deployment

```bash
cd terraform
terraform init
terraform apply
```

#### Environment-specific Deployment

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

### Selective Component Deployment

You can selectively enable or disable components by setting variables:

```bash
# Deploy only MongoDB and Avexa React
terraform apply -var="deploy_namespaces=true" -var="deploy_mongodb=true" -var="deploy_ingress=false" -var="deploy_avexa_react=true"
```

Or create a `terraform.tfvars` file:

```hcl
deploy_namespaces = true
deploy_mongodb = true
deploy_ingress = false
deploy_avexa_react = true
```

## Customization

All components are highly customizable through variables:

### Kubernetes Configuration

- `kube_config_path`: Path to kubeconfig
- `kube_context`: Kubernetes context for Raspberry Pi cluster
- `use_kube_exec`: Whether to use the Kubernetes exec auth plugin for the Raspberry Pi

### Deployment Toggles

- `deploy_namespaces`: Enable/disable namespace creation
- `deploy_mongodb`: Enable/disable MongoDB deployment
- `deploy_ingress`: Enable/disable ingress controller
- `deploy_avexa_react`: Enable/disable React app deployment

### Namespace Configuration

- `namespaces`: List of namespaces to create

### MongoDB Configuration

- `mongodb_namespace`: Namespace for MongoDB
- `mongodb_storage_size`: Persistent storage size
- `mongodb_enable_auth`: Enable/disable authentication
- `mongodb_replicas`: Number of MongoDB replicas
- `mongodb_resource_limits`: CPU and memory limits

### Ingress Controller Configuration

- `ingress_namespace`: Namespace for ingress controller
- `ingress_replicas`: Number of ingress controller replicas
- `ingress_enable_dashboard`: Enable/disable Traefik dashboard
- `ingress_ssl_enabled`: Enable/disable SSL
- `ingress_resource_limits`: CPU and memory limits

### Avexa React Configuration

- `avexa_namespace`: Namespace for Avexa React
- `avexa_replicas`: Number of Avexa React replicas
- `avexa_image_repository`: Docker image repository
- `avexa_image_tag`: Docker image tag
- `avexa_ingress_host`: Hostname for ingress
- `avexa_resource_limits`: CPU and memory limits

## Outputs

After deployment, useful information is available in the Terraform outputs:

- `application_url`: URL to access the Avexa React application
- `mongodb_connection_string`: MongoDB connection details (sensitive)
- `ingress_controller_dashboard`: Ingress controller dashboard status
- `deployed_namespaces`: List of deployed namespaces
- `cluster_info`: Kubernetes cluster information

## Cleanup

To remove all resources created by Terraform:

```bash
terraform destroy
```