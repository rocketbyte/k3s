# k3s
Kubernetes manifests and configs for deploying and managing the projects on a local K3s development cluster.

## Repository Structure

```
.
├── charts/                 # Helm charts
│   └── ingress-controller/ # Traefik ingress controller chart
├── namespaces/             # Kubernetes namespace definitions
│   └── rocket.yaml         # Rocket namespace
```

## Installation

1. Create the namespace first:

```bash
kubectl apply -f namespaces/rocket.yaml
```

2. Install the Traefik ingress controller:

```bash
helm install ingress-controller ./charts/ingress-controller -n rocket
```

## Configuration

### Ingress Controller

The ingress controller is configured to:
- Listen on port 80 for HTTP traffic
- Support TLS termination
- Redirect HTTP to HTTPS when SSL is enabled
- Deploy in the 'rocket' namespace

You can customize the configuration by modifying the `values.yaml` file in the chart directory.
