# Temporal Helm Chart

This Helm chart deploys Temporal.io with PostgreSQL on Kubernetes, specifically designed for the RocketByte K3s cluster.

## Overview

[Temporal](https://temporal.io/) is a microservice orchestration platform that enables developers to build scalable and reliable applications. This chart includes:

- **Temporal Server**: The core Temporal services (frontend, history, matching, worker)
- **PostgreSQL**: Database for Temporal persistence
- **Temporal Web UI**: Web-based interface for monitoring and managing workflows
- **Ingress**: Traefik-based ingress for external access

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume support (for PostgreSQL data persistence)
- Traefik ingress controller (or modify ingress configuration)

## Installation

### Basic Installation

```bash
# Install with default values
helm install temporal ./charts/temporal -n rocket --create-namespace

# Install with custom values
helm install temporal ./charts/temporal -n rocket --create-namespace -f custom-values.yaml
```

### Upgrade

```bash
helm upgrade temporal ./charts/temporal -n rocket
```

### Uninstall

```bash
helm uninstall temporal -n rocket
```

## Configuration

### Key Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace.name` | Kubernetes namespace | `rocket` |
| `namespace.create` | Create namespace if it doesn't exist | `true` |
| `postgresql.enabled` | Enable PostgreSQL deployment | `true` |
| `postgresql.database.name` | Database name | `temporal` |
| `postgresql.database.user` | Database user | `temporal` |
| `postgresql.database.password` | Database password | `temporal123` |
| `postgresql.persistence.enabled` | Enable persistent storage | `true` |
| `postgresql.persistence.size` | Storage size | `10Gi` |
| `temporal.image.tag` | Temporal server version | `1.25.0` |
| `temporal.replicas` | Number of Temporal server replicas | `1` |
| `temporalUI.enabled` | Enable Temporal Web UI | `true` |
| `temporalUI.image.tag` | Temporal UI version | `2.31.2` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.ui.host` | Hostname for UI | `temporal.example.com` |
| `ingress.grpc.host` | Hostname for gRPC | `temporal-grpc.example.com` |

### Example: Custom Values

Create a `custom-values.yaml` file:

```yaml
namespace:
  name: rocket

postgresql:
  database:
    password: "your-secure-password-here"
  persistence:
    size: 20Gi
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

temporal:
  replicas: 2
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 2000m
      memory: 4Gi

ingress:
  ui:
    host: temporal.yourdomain.com
  grpc:
    host: temporal-grpc.yourdomain.com
```

Then install:

```bash
helm install temporal ./charts/temporal -n rocket -f custom-values.yaml
```

## Architecture for Raspberry Pi

This chart is optimized for ARM64 architecture (Raspberry Pi):

- Uses Alpine-based PostgreSQL images for smaller footprint
- Conservative resource limits suitable for Raspberry Pi hardware
- Single replica configuration by default (can be scaled up)
- Persistent storage for data durability

### Resource Requirements

Minimum recommended resources for the complete stack:

- **PostgreSQL**: 250m CPU, 512Mi RAM
- **Temporal Server**: 500m CPU, 1Gi RAM
- **Temporal UI**: 100m CPU, 256Mi RAM

**Total**: ~850m CPU, ~1.75Gi RAM minimum

## Accessing Temporal

### Via Ingress (Production)

Update your DNS or `/etc/hosts` to point to your cluster:

```
<your-cluster-ip> temporal.example.com
<your-cluster-ip> temporal-grpc.example.com
```

Access:
- UI: https://temporal.example.com
- gRPC: temporal-grpc.example.com:7233

### Via Port Forwarding (Development)

**Temporal Web UI:**
```bash
kubectl port-forward -n rocket svc/temporal-ui 8080:8080
# Visit: http://localhost:8080
```

**Temporal gRPC:**
```bash
kubectl port-forward -n rocket svc/temporal-frontend 7233:7233
# Connect to: localhost:7233
```

## Connecting Your Applications

### Using Temporal CLI

```bash
# Install Temporal CLI
curl -sSf https://temporal.download/cli.sh | sh

# Connect to your Temporal cluster
temporal workflow list --address temporal-grpc.example.com:7233
```

### Using SDKs

**Go Example:**
```go
import (
    "go.temporal.io/sdk/client"
)

c, err := client.Dial(client.Options{
    HostPort: "temporal-grpc.example.com:7233",
})
```

**Node.js Example:**
```javascript
import { Connection, WorkflowClient } from '@temporalio/client';

const connection = await Connection.connect({
  address: 'temporal-grpc.example.com:7233',
});

const client = new WorkflowClient({ connection });
```

## Database Management

### Connecting to PostgreSQL

```bash
# Get PostgreSQL pod name
kubectl get pods -n rocket | grep postgresql

# Connect to PostgreSQL
kubectl exec -it -n rocket <postgresql-pod-name> -- psql -U temporal -d temporal
```

### Backup PostgreSQL Data

```bash
# Backup
kubectl exec -n rocket <postgresql-pod-name> -- pg_dump -U temporal temporal > temporal_backup.sql

# Restore
cat temporal_backup.sql | kubectl exec -i -n rocket <postgresql-pod-name> -- psql -U temporal temporal
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n rocket
kubectl describe pod -n rocket <pod-name>
kubectl logs -n rocket <pod-name>
```

### Common Issues

1. **PostgreSQL not ready**: Wait for PostgreSQL to be fully initialized (30-60 seconds)
2. **Temporal server connection errors**: Ensure PostgreSQL is running and accessible
3. **Ingress not working**: Verify Traefik is installed and running
4. **Out of memory**: Increase resource limits or reduce replicas

### Debug Mode

Enable verbose logging:

```yaml
temporal:
  env:
    - name: LOG_LEVEL
      value: debug
```

## Security Considerations

### Production Recommendations

1. **Database Password**: Use Kubernetes secrets instead of plaintext
   ```yaml
   postgresql:
     existingSecret: temporal-postgresql-secret
   ```

2. **TLS Certificates**: Use cert-manager or provide your own certificates

3. **Network Policies**: Restrict traffic between pods

4. **RBAC**: Configure proper service account permissions

5. **Resource Limits**: Set appropriate CPU and memory limits

## Monitoring

### Temporal Metrics

Temporal exposes Prometheus metrics on port 9090. Add ServiceMonitor for Prometheus:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: temporal-metrics
  namespace: rocket
spec:
  ports:
  - name: metrics
    port: 9090
  selector:
    app.kubernetes.io/name: temporal-server
```

## Scaling

### Horizontal Scaling

```bash
# Scale Temporal server
kubectl scale deployment temporal-server -n rocket --replicas=3

# Or update values.yaml
temporal:
  replicas: 3
```

### Vertical Scaling

Adjust resource limits in `values.yaml`:

```yaml
temporal:
  resources:
    requests:
      cpu: 2000m
      memory: 4Gi
    limits:
      cpu: 4000m
      memory: 8Gi
```

## Upgrading Temporal

To upgrade to a new Temporal version:

1. Update `values.yaml`:
   ```yaml
   temporal:
     image:
       tag: "1.26.0"  # New version
   ```

2. Run Helm upgrade:
   ```bash
   helm upgrade temporal ./charts/temporal -n rocket
   ```

## Support

- **Temporal Documentation**: https://docs.temporal.io/
- **Temporal Community**: https://community.temporal.io/
- **GitHub Issues**: https://github.com/temporalio/temporal/issues

## License

This chart is provided as-is for the RocketByte project.

## Maintainers

- RocketByte Team
