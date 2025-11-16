# Temporal.io Deployment Guide - K3s Raspberry Pi Cluster

## Overview

This document provides complete information about the Temporal.io deployment on your K3s Raspberry Pi cluster.

**Deployment Date:** November 15, 2025
**Namespace:** rocket
**Cluster:** K3s on Raspberry Pi (10.0.0.21)

## Architecture

### Components

- **Temporal Server**: v1.25.0 (temporalio/auto-setup)
- **Temporal UI**: latest (temporalio/ui)
- **PostgreSQL**: 14-alpine with 10Gi persistent storage
- **Ingress Controller**: Nginx
- **Storage Class**: local-path (K3s default)

### Services Deployed

| Component | Type | Port | Purpose |
|-----------|------|------|---------|
| temporal-server | ClusterIP | 7233 (frontend), 7234 (history), 7235 (matching), 7239 (worker) | Temporal core services |
| temporal-ui | ClusterIP | 8080 | Web UI |
| temporal-frontend-external | NodePort | 30733 | External gRPC access |
| temporal-postgresql | ClusterIP | 5432 | Database |

## Access Information

### Web UI

**URL:** http://temporal-rocketbyte.duckdns.org

The web interface provides:
- Workflow monitoring
- Namespace management
- Task queue visibility
- Event history viewing

### gRPC Endpoint (CLI & SDK)

**Local Network Access:**
```
10.0.0.21:30733
```

**External Access (requires router port forwarding):**
```
temporal-rocketbyte.duckdns.org:7233 → 10.0.0.21:30733
```

## CLI Installation & Usage

### Install Temporal CLI

**macOS:**
```bash
brew install temporal
```

**Linux:**
```bash
curl -sSf https://temporal.download/cli.sh | sh
```

### Connect to Your Server

```bash
# List namespaces
temporal operator namespace list --address 10.0.0.21:30733

# Create a new namespace
temporal operator namespace create my-namespace --address 10.0.0.21:30733

# Describe a namespace
temporal operator namespace describe default --address 10.0.0.21:30733

# Set as default (add to ~/.bashrc or ~/.zshrc)
export TEMPORAL_ADDRESS=10.0.0.21:30733
```

## SDK Integration

### Go

**Installation:**
```bash
go get go.temporal.io/sdk
```

**Connection Code:**
```go
package main

import (
    "log"
    "go.temporal.io/sdk/client"
)

func main() {
    c, err := client.Dial(client.Options{
        HostPort: "10.0.0.21:30733",
        Namespace: "default",
    })
    if err != nil {
        log.Fatalln("Unable to create Temporal client:", err)
    }
    defer c.Close()

    // Use client for workflows and activities
}
```

### Python

**Installation:**
```bash
pip install temporalio
```

**Connection Code:**
```python
import asyncio
from temporalio.client import Client

async def main():
    client = await Client.connect(
        "10.0.0.21:30733",
        namespace="default"
    )
    # Use client for workflows and activities

if __name__ == "__main__":
    asyncio.run(main())
```

### TypeScript/Node.js

**Installation:**
```bash
npm install @temporalio/client @temporalio/worker @temporalio/workflow
```

**Connection Code:**
```typescript
import { Client } from '@temporalio/client';

async function main() {
  const client = new Client({
    connection: {
      address: '10.0.0.21:30733',
    },
    namespace: 'default',
  });
  // Use client for workflows and activities
}

main().catch(console.error);
```

### Java

**Maven Dependency:**
```xml
<dependency>
    <groupId>io.temporal</groupId>
    <artifactId>temporal-sdk</artifactId>
    <version>1.25.0</version>
</dependency>
```

**Connection Code:**
```java
import io.temporal.client.WorkflowClient;
import io.temporal.serviceclient.WorkflowServiceStubs;
import io.temporal.serviceclient.WorkflowServiceStubsOptions;

public class TemporalClient {
    public static void main(String[] args) {
        WorkflowServiceStubs service = WorkflowServiceStubs.newInstance(
            WorkflowServiceStubsOptions.newBuilder()
                .setTarget("10.0.0.21:30733")
                .build()
        );

        WorkflowClient client = WorkflowClient.newInstance(service);
        // Use client for workflows and activities
    }
}
```

## Helm Chart Configuration

### Chart Location
```
charts/temporal/
```

### Key Configuration Files

**values.yaml:**
- Namespace: rocket
- PostgreSQL credentials: temporal/temporal123
- Persistence: 10Gi local-path storage
- UI enabled with all required environment variables
- Nginx ingress configured

**Deployment Commands:**

```bash
# Install/Upgrade
helm upgrade --install temporal charts/temporal --namespace rocket

# Uninstall
helm uninstall temporal --namespace rocket

# Check status
helm status temporal --namespace rocket
```

## Database Configuration

**PostgreSQL Details:**
- **Host:** temporal-postgresql.rocket.svc.cluster.local
- **Port:** 5432
- **Database:** temporal
- **Username:** temporal
- **Password:** temporal123 (⚠️ Change for production!)

**Storage:**
- PersistentVolumeClaim: temporal-postgresql
- Size: 10Gi
- StorageClass: local-path

## Kubernetes Resources

### Check Deployment Status

```bash
# All Temporal pods
kubectl get pods -n rocket -l app.kubernetes.io/instance=temporal

# Temporal server
kubectl get pods -n rocket -l app.kubernetes.io/component=server

# Temporal UI
kubectl get pods -n rocket -l app.kubernetes.io/component=ui

# PostgreSQL
kubectl get pods -n rocket -l app.kubernetes.io/name=postgresql

# All services
kubectl get svc -n rocket

# Ingress
kubectl get ingress -n rocket
```

### View Logs

```bash
# Server logs
kubectl logs -n rocket -l app.kubernetes.io/component=server --tail=100 -f

# UI logs
kubectl logs -n rocket -l app.kubernetes.io/component=ui --tail=100 -f

# PostgreSQL logs
kubectl logs -n rocket -l app.kubernetes.io/name=postgresql --tail=100 -f
```

## Router Configuration (Optional)

To access your Temporal server from outside your local network:

### Port Forwarding Setup

1. Log into your router admin panel
2. Navigate to Port Forwarding settings
3. Add a new rule:
   - **Service Name:** Temporal gRPC
   - **External Port:** 7233
   - **Internal IP:** 10.0.0.21
   - **Internal Port:** 30733
   - **Protocol:** TCP
4. Save and apply

### Update DuckDNS

Your DuckDNS domain (temporal-rocketbyte.duckdns.org) should already point to your public IP. After port forwarding, you can connect using:

```bash
temporal operator namespace list --address temporal-rocketbyte.duckdns.org:7233
```

## Troubleshooting

### UI Not Loading

```bash
# Check UI pod status
kubectl get pods -n rocket -l app.kubernetes.io/component=ui

# Check UI logs
kubectl logs -n rocket -l app.kubernetes.io/component=ui

# Restart UI
kubectl rollout restart deployment/temporal-ui -n rocket
```

### gRPC Connection Refused

```bash
# Check if service has endpoints
kubectl get endpoints -n rocket temporal-frontend-external

# Test from within cluster
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n rocket -- \
  grpcurl -plaintext temporal-frontend:7233 list

# Check NodePort service
kubectl get svc -n rocket temporal-frontend-external
```

### Database Connection Issues

```bash
# Check PostgreSQL pod
kubectl get pods -n rocket -l app.kubernetes.io/name=postgresql

# Check PostgreSQL logs
kubectl logs -n rocket -l app.kubernetes.io/name=postgresql

# Connect to PostgreSQL
kubectl exec -it -n rocket $(kubectl get pod -n rocket -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}') -- psql -U temporal -d temporal
```

### Server Not Starting

```bash
# Check server logs
kubectl logs -n rocket -l app.kubernetes.io/component=server

# Common issues:
# - Database not ready: Check PostgreSQL status
# - Port conflicts: Verify no other services on ports 7233-7239
# - Resource limits: Check node resources with 'kubectl top nodes'
```

## Performance Tuning

### Resource Limits

Current configuration:
- **Server:** 500m CPU, 1Gi memory (requests), 1 CPU, 2Gi memory (limits)
- **UI:** 100m CPU, 256Mi memory (requests), 200m CPU, 512Mi memory (limits)
- **PostgreSQL:** 100m CPU, 256Mi memory (requests), 500m CPU, 512Mi memory (limits)

To adjust resources, edit `charts/temporal/values.yaml` and run:
```bash
helm upgrade temporal charts/temporal --namespace rocket
```

### Scaling

```bash
# Scale UI replicas
kubectl scale deployment/temporal-ui --replicas=2 -n rocket

# Scale server (update values.yaml for persistence)
# temporal.replicas: 2
helm upgrade temporal charts/temporal --namespace rocket
```

## Security Considerations

### For Production Use:

1. **Change PostgreSQL Password:**
   - Update `postgresql.database.password` in values.yaml
   - Use Kubernetes secrets instead of plain text

2. **Enable TLS:**
   - Configure cert-manager for automatic certificates
   - Enable TLS in ingress configuration
   - Update `ingress.ui.tls.enabled: true` in values.yaml

3. **Network Policies:**
   - Restrict pod-to-pod communication
   - Limit external access

4. **RBAC:**
   - Review and restrict service account permissions
   - Implement namespace isolation

5. **Backup Strategy:**
   - Regular PostgreSQL backups
   - Persistent volume snapshots

## Maintenance

### Backup PostgreSQL

```bash
# Create backup
kubectl exec -n rocket $(kubectl get pod -n rocket -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}') -- \
  pg_dump -U temporal temporal > temporal_backup_$(date +%Y%m%d).sql

# Restore from backup
kubectl exec -i -n rocket $(kubectl get pod -n rocket -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}') -- \
  psql -U temporal temporal < temporal_backup_20251115.sql
```

### Update Temporal Server

```bash
# Update image tag in values.yaml
# temporal.image.tag: "1.26.0"

# Apply update
helm upgrade temporal charts/temporal --namespace rocket

# Verify update
kubectl get pods -n rocket -l app.kubernetes.io/component=server -o jsonpath='{.items[0].spec.containers[0].image}'
```

## Useful Links

- **Temporal Documentation:** https://docs.temporal.io/
- **Temporal GitHub:** https://github.com/temporalio/temporal
- **Temporal UI GitHub:** https://github.com/temporalio/ui
- **Temporal CLI GitHub:** https://github.com/temporalio/cli
- **K3s Documentation:** https://docs.k3s.io/

## Quick Reference

### Environment Variables for SDKs

```bash
export TEMPORAL_ADDRESS=10.0.0.21:30733
export TEMPORAL_NAMESPACE=default
```

### Common CLI Commands

```bash
# List namespaces
temporal operator namespace list

# Create namespace
temporal operator namespace create my-namespace

# List workflows in namespace
temporal workflow list -n my-namespace

# Describe workflow
temporal workflow describe -w <workflow-id> -n my-namespace

# Terminate workflow
temporal workflow terminate -w <workflow-id> -n my-namespace
```

## Support

For issues specific to this deployment:
1. Check logs using kubectl commands above
2. Review Temporal server documentation
3. Check K3s cluster health: `kubectl get nodes`
4. Verify network connectivity to Raspberry Pi

---

**Last Updated:** November 15, 2025
**Maintained By:** Starlin Gil Cruz
**Cluster:** K3s on Raspberry Pi (raspberrypi - 10.0.0.21)
