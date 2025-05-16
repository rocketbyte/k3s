# K3s Deployment for Raspberry Pi

This repository contains Kubernetes manifests, Helm charts, and Terraform configurations for deploying applications on a Raspberry Pi K3s cluster. It follows best practices for resource-constrained environments and provides a complete solution for running web applications with proper ingress, SSL, and database support.

## Repository Structure

```
.
├── charts/                 # Helm charts
│   ├── avexa-react/        # Frontend application chart
│   ├── ingress-controller/ # Traefik ingress controller chart
│   └── mongodb/            # MongoDB database chart
├── namespaces/             # Kubernetes namespace definitions
├── terraform/              # Infrastructure as Code
│   ├── environments/       # Environment-specific configurations
│   └── modules/            # Reusable Terraform modules
└── kubeconfig.yaml         # Kubernetes configuration
```

## Terraform Deployment

The recommended way to deploy all components is using Terraform:

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

This will deploy:
1. Namespaces
2. Traefik Ingress Controller
3. MongoDB (if enabled)
4. Avexa React application

## Manual Installation

If you prefer manual installation:

1. Create the namespace first:

```bash
kubectl apply -f namespaces/rocket.yaml
```

2. Install the Traefik ingress controller:

```bash
helm install ingress-controller ./charts/ingress-controller -n rocket
```

3. Install MongoDB:

```bash
helm install mongodb ./charts/mongodb -n rocket
```

4. Install the Avexa React application:

```bash
helm install avexa-react ./charts/avexa-react -n rocket
```

## Traefik Ingress Controller Configuration

The Traefik ingress controller is optimized for Raspberry Pi deployments:

### Features

- **HTTP/HTTPS Support**: Listens on ports 80 and 443
- **Automatic TLS**: Integrated Let's Encrypt support for automatic certificate issuance
- **Dashboard**: Web UI for monitoring and troubleshooting (accessible at traefik.cluster.local)
- **Resource Efficiency**: Optimized resource usage for ARM devices
- **Persistent Storage**: Certificates are stored persistently using PVCs

### Accessing the Dashboard

The Traefik dashboard is available at:

1. External access through http://[YOUR_PI_IP]:7000/
2. Or through the Ingress at http://traefik.cluster.local if you've configured your hosts file

For local access, you can port-forward:

```bash
kubectl port-forward -n rocket service/traefik 7000:7000
```

Then access the dashboard at http://localhost:7000/

> **Note for Raspberry Pi Users**: For detailed troubleshooting steps specific to Raspberry Pi deployments, refer to the [Troubleshooting Guide](./docs/TROUBLESHOOTING.md). The guide includes solutions for common issues like port conflicts and ARM compatibility.

### SSL Configuration

SSL is enabled by default with Let's Encrypt. To use it effectively:

1. Ensure your domain points to your Raspberry Pi's IP address
2. Update the `ingress_ssl_email` variable with your email for Let's Encrypt
3. For local testing, you may want to disable SSL by setting `ingress_ssl_enabled` to `false`

## Performance Optimization for Raspberry Pi

This deployment is optimized for Raspberry Pi:

- Reduced CPU and memory requirements
- Single-replica deployments by default
- ARM-specific node selectors
- Disabled autoscaling to conserve resources
- Appropriate security context for containerized applications

## Troubleshooting

If you encounter issues:

1. Check Traefik logs:
```bash
kubectl logs -n rocket -l app=traefik
```

2. Verify services are running:
```bash
kubectl get pods,svc -n rocket
```

3. For SSL issues, check the Let's Encrypt certificate status:
```bash
kubectl exec -n rocket -it $(kubectl get pods -n rocket -l app=traefik -o name | head -n 1) -- cat /data/acme.json
```

## Best Practices Implemented

- **Infrastructure as Code**: All configurations managed through Terraform
- **Modularity**: Separation of concerns through Helm charts and Terraform modules
- **Resource Management**: Appropriate resource requests and limits
- **Security**: Proper RBAC, non-root containers, and TLS support
- **Persistence**: Stateful workloads use persistent volumes
- **Observability**: Prometheus metrics and logging