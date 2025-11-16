# Temporal Quick Start Guide

This guide will help you quickly deploy Temporal.io with PostgreSQL to your K3s cluster.

## Prerequisites

- K3s cluster running
- kubectl configured to access your cluster
- Helm 3 installed
- At least 2GB RAM available on your cluster

## Quick Installation

### 1. Review and Customize Values

Before installing, review the default configuration:

```bash
cat charts/temporal/values.yaml
```

**Important**: Update these values for your environment:

```yaml
# Create a custom values file
cat > temporal-custom-values.yaml <<EOF
namespace:
  name: rocket

postgresql:
  database:
    password: "ChangeThisPassword123!"  # Change this!
  persistence:
    size: 10Gi

ingress:
  ui:
    host: temporal.your-domain.com      # Change this!
  grpc:
    host: temporal-grpc.your-domain.com # Change this!
EOF
```

### 2. Install the Chart

```bash
# Install with custom values
helm install temporal charts/temporal -f temporal-custom-values.yaml

# Or install with defaults (not recommended for production)
helm install temporal charts/temporal
```

### 3. Wait for Deployment

```bash
# Watch the pods come up
kubectl get pods -n rocket -w

# You should see:
# - temporal-postgresql-xxx (PostgreSQL database)
# - temporal-server-xxx (Temporal server)
# - temporal-ui-xxx (Temporal Web UI)
```

This may take 2-3 minutes as PostgreSQL initializes and Temporal sets up the schema.

### 4. Verify Installation

```bash
# Check all pods are running
kubectl get pods -n rocket

# Check services
kubectl get svc -n rocket

# Check ingress
kubectl get ingress -n rocket
```

Expected output:
```
NAME                       READY   STATUS    RESTARTS   AGE
temporal-postgresql-xxx    1/1     Running   0          2m
temporal-server-xxx        1/1     Running   0          1m
temporal-ui-xxx            1/1     Running   0          1m
```

## Accessing Temporal

### Option 1: Via Ingress (Recommended)

Update your DNS or `/etc/hosts`:

```bash
# Get your cluster IP
kubectl get nodes -o wide

# Add to /etc/hosts
echo "<cluster-ip> temporal.your-domain.com temporal-grpc.your-domain.com" | sudo tee -a /etc/hosts
```

Access:
- **Web UI**: https://temporal.your-domain.com
- **gRPC**: temporal-grpc.your-domain.com:7233

### Option 2: Port Forwarding (Development)

```bash
# Terminal 1: Forward Web UI
kubectl port-forward -n rocket svc/temporal-ui 8080:8080

# Terminal 2: Forward gRPC
kubectl port-forward -n rocket svc/temporal-frontend 7233:7233
```

Access:
- **Web UI**: http://localhost:8080
- **gRPC**: localhost:7233

## Testing Your Deployment

### Install Temporal CLI

```bash
# macOS
brew install temporal

# Linux
curl -sSf https://temporal.download/cli.sh | sh

# Or download from: https://github.com/temporalio/cli/releases
```

### Test Connection

```bash
# List workflows (should be empty initially)
temporal workflow list --address localhost:7233

# Create a test namespace
temporal operator namespace create test --address localhost:7233
```

### Run a Sample Workflow

```bash
# Clone Temporal samples
git clone https://github.com/temporalio/samples-go.git
cd samples-go/helloworld

# Run the worker
go run worker/main.go &

# Execute a workflow
go run starter/main.go
```

Check the Web UI to see your workflow execution!

## Next Steps

### 1. Configure Your Domain

Update the ingress hosts in `values.yaml` or your custom values file:

```yaml
ingress:
  ui:
    host: temporal.yourdomain.com
  grpc:
    host: temporal-grpc.yourdomain.com
```

Then upgrade:

```bash
helm upgrade temporal charts/temporal -f temporal-custom-values.yaml
```

### 2. Set Up TLS Certificates

For production, configure TLS:

```bash
# Using cert-manager
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: temporal-ui-tls
  namespace: rocket
spec:
  secretName: temporal-ui-tls
  dnsNames:
  - temporal.yourdomain.com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOF
```

### 3. Secure PostgreSQL

Create a Kubernetes secret for the database password:

```bash
kubectl create secret generic temporal-postgresql-secret \
  -n rocket \
  --from-literal=password='YourSecurePassword'
```

Update values to use the secret:

```yaml
postgresql:
  existingSecret: temporal-postgresql-secret
```

### 4. Scale for Production

```yaml
temporal:
  replicas: 3
  resources:
    requests:
      cpu: 1000m
      memory: 2Gi
    limits:
      cpu: 2000m
      memory: 4Gi

postgresql:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

## Common Operations

### View Logs

```bash
# Temporal server logs
kubectl logs -n rocket -l app.kubernetes.io/component=server --tail=100

# PostgreSQL logs
kubectl logs -n rocket -l app.kubernetes.io/component=database --tail=100

# UI logs
kubectl logs -n rocket -l app.kubernetes.io/component=ui --tail=100
```

### Restart Components

```bash
# Restart Temporal server
kubectl rollout restart deployment temporal-server -n rocket

# Restart PostgreSQL (careful - this will disconnect clients)
kubectl rollout restart deployment temporal-postgresql -n rocket

# Restart UI
kubectl rollout restart deployment temporal-ui -n rocket
```

### Backup Database

```bash
# Get PostgreSQL pod name
POD=$(kubectl get pod -n rocket -l app.kubernetes.io/component=database -o jsonpath='{.items[0].metadata.name}')

# Create backup
kubectl exec -n rocket $POD -- pg_dump -U temporal temporal > temporal-backup-$(date +%Y%m%d).sql

# Restore from backup
cat temporal-backup-20250515.sql | kubectl exec -i -n rocket $POD -- psql -U temporal temporal
```

## Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod -n rocket <pod-name>

# Check resource constraints
kubectl top nodes
kubectl top pods -n rocket
```

### Database Connection Issues

```bash
# Test PostgreSQL connectivity
kubectl run -it --rm debug --image=postgres:14-alpine --restart=Never -n rocket -- \
  psql -h temporal-postgresql -U temporal -d temporal

# Check PostgreSQL service
kubectl get svc temporal-postgresql -n rocket
```

### Temporal Server Not Ready

```bash
# Wait for auto-setup to complete (may take 2-3 minutes)
kubectl logs -n rocket -l app.kubernetes.io/component=server --follow

# Check if database schema is initialized
kubectl exec -n rocket <temporal-pod> -- temporal-sql-tool \
  --ep temporal-postgresql --port 5432 --db temporal \
  --plugin postgres --user temporal --password temporal123 \
  validate-schema
```

## Uninstalling

```bash
# Uninstall the Helm release
helm uninstall temporal -n rocket

# Optionally, delete the namespace and PVCs
kubectl delete namespace rocket
kubectl delete pvc -n rocket temporal-postgresql
```

## Resources

- [Temporal Documentation](https://docs.temporal.io/)
- [Temporal CLI Guide](https://docs.temporal.io/cli)
- [SDKs and Samples](https://docs.temporal.io/dev-guide)
- [Community Forum](https://community.temporal.io/)

## Support

For issues with this chart, check the main README.md or review the Temporal documentation.
