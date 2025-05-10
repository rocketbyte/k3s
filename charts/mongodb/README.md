# MongoDB Helm Chart

This Helm chart deploys MongoDB in a Kubernetes cluster with options for both internal (VPC) access and external access via the internet.

## Features

- Configurable MongoDB deployment with authentication
- Dual network access:
  - Internal service for secure VPC access
  - External service for internet access (LoadBalancer or NodePort)
- Persistent storage with configurable size and storage class
- Security features including TLS support
- Configurable resource limits and requests
- Health monitoring with liveness and readiness probes

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistence)

## Installing the Chart

Add the repository and install the chart with the release name `my-mongodb`:

```bash
helm install my-mongodb ./charts/mongodb
```

## Configuration

The following table lists the configurable parameters of the MongoDB chart and their default values.

### MongoDB Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.auth.enabled` | Enable authentication | `true` |
| `mongodb.auth.rootPassword` | Root password for MongoDB | `""` (auto-generated) |
| `mongodb.auth.database` | Database name to create | `"rocketdb"` |
| `mongodb.auth.username` | Username for the created database | `"rocketuser"` |
| `mongodb.auth.password` | Password for the created user | `""` (auto-generated) |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.replicas` | Number of MongoDB replicas | `1` |
| `deployment.resources.requests.cpu` | CPU request for the MongoDB container | `100m` |
| `deployment.resources.requests.memory` | Memory request for the MongoDB container | `256Mi` |
| `deployment.resources.limits.cpu` | CPU limit for the MongoDB container | `500m` |
| `deployment.resources.limits.memory` | Memory limit for the MongoDB container | `512Mi` |
| `deployment.persistence.enabled` | Enable persistence using PVC | `true` |
| `deployment.persistence.size` | PVC Storage size | `8Gi` |
| `deployment.persistence.storageClass` | PVC Storage class | `""` |
| `deployment.persistence.accessModes` | PVC Access modes | `["ReadWriteOnce"]` |
| `deployment.nodeSelector` | Node labels for pod assignment | `{}` |
| `deployment.tolerations` | Tolerations for pod assignment | `[]` |
| `deployment.affinity` | Affinity for pod assignment | `{}` |

### Network Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `network.internal.enabled` | Enable internal service (VPC access) | `true` |
| `network.internal.port` | Port for internal service | `27017` |
| `network.internal.type` | Service type for internal access | `ClusterIP` |
| `network.external.enabled` | Enable external service (Internet access) | `true` |
| `network.external.port` | Port for external service | `27017` |
| `network.external.type` | Service type for external access | `LoadBalancer` |
| `network.external.nodePort` | Node port if using NodePort service type | `""` |
| `network.external.annotations` | Annotations for the external service | `{}` |
| `network.external.loadBalancerSourceRanges` | LoadBalancer source ranges | `[]` |
| `network.external.externalTrafficPolicy` | External traffic policy | `Cluster` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `security.tls.enabled` | Enable TLS for MongoDB connections | `false` |
| `security.tls.secretName` | Secret containing TLS certificates | `""` |
| `security.podSecurityContext.fsGroup` | Group ID for the pod | `1001` |
| `security.podSecurityContext.runAsUser` | User ID for the pod | `1001` |
| `security.containerSecurityContext.runAsNonRoot` | Run container as non-root | `true` |
| `security.containerSecurityContext.runAsUser` | User ID for the container | `1001` |
| `security.containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |

### Additional Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraEnvVars` | Extra environment variables | `[]` |
| `livenessProbe.enabled` | Enable liveness probe | `true` |
| `livenessProbe.initialDelaySeconds` | Initial delay for liveness probe | `30` |
| `livenessProbe.periodSeconds` | Period for liveness probe | `10` |
| `livenessProbe.timeoutSeconds` | Timeout for liveness probe | `5` |
| `livenessProbe.failureThreshold` | Failure threshold for liveness probe | `6` |
| `livenessProbe.successThreshold` | Success threshold for liveness probe | `1` |
| `readinessProbe.enabled` | Enable readiness probe | `true` |
| `readinessProbe.initialDelaySeconds` | Initial delay for readiness probe | `5` |
| `readinessProbe.periodSeconds` | Period for readiness probe | `10` |
| `readinessProbe.timeoutSeconds` | Timeout for readiness probe | `5` |
| `readinessProbe.failureThreshold` | Failure threshold for readiness probe | `6` |
| `readinessProbe.successThreshold` | Success threshold for readiness probe | `1` |
| `podAnnotations` | Pod annotations | `{}` |
| `serviceAnnotations` | Service annotations | `{}` |

## Example: Deploy MongoDB with External Access

1. Create a values.yaml file:

```yaml
mongodb:
  auth:
    enabled: true
    rootPassword: "secureRootPassword"
    password: "secureUserPassword"

network:
  internal:
    enabled: true
  external:
    enabled: true
    type: LoadBalancer
    loadBalancerSourceRanges:
      - "203.0.113.0/24"  # Restrict access to specific IP range
```

2. Install the chart:

```bash
helm install my-mongodb ./charts/mongodb -f values.yaml
```

## Connecting to MongoDB

### Internal VPC Access

Applications within the Kubernetes cluster can connect using:

```
mongodb://username:password@my-mongodb-mongodb-internal:27017/databaseName
```

### External Access

For LoadBalancer:
```
mongodb://username:password@EXTERNAL_IP:27017/databaseName
```

For NodePort:
```
mongodb://username:password@NODE_IP:NODE_PORT/databaseName
```

To get the external IP or NodePort:

```bash
kubectl get svc my-mongodb-mongodb-external
```

## Security Considerations

1. Change default passwords in production
2. Consider enabling TLS for encryption in transit
3. Restrict LoadBalancer source ranges to trusted IPs
4. Consider using a VPN or private endpoint for external access instead of public internet

## Persistence

By default, persistence is enabled. You can disable it by setting `deployment.persistence.enabled` to `false`.

When persistence is enabled, a PersistentVolumeClaim is created and mounted on the data directory. The data is preserved across pod restarts.

## Upgrading

To upgrade the chart:

```bash
helm upgrade my-mongodb ./charts/mongodb -f values.yaml
```