# Temporal Quick Reference Card

## Connection Details

| Access Point | Address |
|--------------|---------|
| Web UI | http://temporal-rocketbyte.duckdns.org |
| gRPC (Local) | 10.0.0.21:30733 |
| gRPC (External) | temporal-rocketbyte.duckdns.org:7233 (requires port forwarding) |

## Quick Commands

```bash
# Set default address
export TEMPORAL_ADDRESS=10.0.0.21:30733

# List namespaces
temporal operator namespace list

# Create namespace
temporal operator namespace create <name>

# List workflows
temporal workflow list

# Check deployment
kubectl get pods -n rocket -l app.kubernetes.io/instance=temporal

# View logs
kubectl logs -n rocket -l app.kubernetes.io/component=server -f
kubectl logs -n rocket -l app.kubernetes.io/component=ui -f

# Restart services
kubectl rollout restart deployment/temporal-ui -n rocket
kubectl rollout restart deployment/temporal-server -n rocket

# Helm upgrade
helm upgrade temporal charts/temporal --namespace rocket
```

## SDK Connection Snippets

**Go:**
```go
client.Dial(client.Options{HostPort: "10.0.0.21:30733"})
```

**Python:**
```python
await Client.connect("10.0.0.21:30733")
```

**TypeScript:**
```typescript
new Client({connection: {address: '10.0.0.21:30733'}})
```

**Java:**
```java
WorkflowServiceStubsOptions.newBuilder()
    .setTarget("10.0.0.21:30733")
    .build()
```

## Database Access

```bash
# Connect to PostgreSQL
kubectl exec -it -n rocket \
  $(kubectl get pod -n rocket -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}') \
  -- psql -U temporal -d temporal

# Credentials
User: temporal
Pass: temporal123
DB: temporal
```

## Troubleshooting

```bash
# Check service endpoints
kubectl get endpoints -n rocket temporal-frontend-external

# Test gRPC from within cluster
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n rocket -- \
  nc -zv temporal-frontend 7233

# Port forward for local testing
kubectl port-forward -n rocket svc/temporal-frontend 7233:7233
```

## Files Location

- Helm Chart: `charts/temporal/`
- Values: `charts/temporal/values.yaml`
- Full Guide: `docs/temporal-deployment-guide.md`
