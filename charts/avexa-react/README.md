# Avexa React Helm Chart

This Helm chart deploys the Avexa React application on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- A running Traefik ingress controller in the cluster
- Access to a container registry

## Getting Started

### Preparation

1. Build and push the Docker image:

```bash
cd /path/to/avexa-react
docker build -t registry.example.com/rocketbyte/avexa-react:latest .
docker push registry.example.com/rocketbyte/avexa-react:latest
```

2. Create the namespace (if not already created):

```bash
kubectl apply -f /path/to/k3s/namespaces/rocket.yaml
```

### Installing the Chart

To install the chart with the release name `avexa-react`:

```bash
helm install avexa-react /path/to/k3s/charts/avexa-react --namespace rocket
```

### Upgrading the Chart

To upgrade the existing installation:

```bash
helm upgrade avexa-react /path/to/k3s/charts/avexa-react --namespace rocket
```

### Uninstalling the Chart

To uninstall/delete the `avexa-react` deployment:

```bash
helm uninstall avexa-react --namespace rocket
```

## Configuration

The following table lists the configurable parameters of the avexa-react chart and their default values.

| Parameter                                | Description                                   | Default                               |
| ---------------------------------------- | --------------------------------------------- | ------------------------------------- |
| `app.name`                               | Application name                              | `avexa-react`                         |
| `app.image.repository`                   | Image repository                              | `registry.example.com/rocketbyte/avexa-react` |
| `app.image.tag`                          | Image tag                                     | `latest`                              |
| `app.image.pullPolicy`                   | Image pull policy                             | `Always`                              |
| `app.port`                               | Application port                              | `80`                                  |
| `deployment.replicas`                    | Number of replicas                            | `2`                                   |
| `deployment.resources.requests.cpu`      | CPU resource request                          | `100m`                                |
| `deployment.resources.requests.memory`   | Memory resource request                       | `128Mi`                               |
| `deployment.resources.limits.cpu`        | CPU resource limit                            | `300m`                                |
| `deployment.resources.limits.memory`     | Memory resource limit                         | `256Mi`                               |
| `deployment.strategy.type`               | Deployment strategy type                      | `RollingUpdate`                       |
| `deployment.nodeSelector`                | Node labels for pod assignment                | `{}`                                  |
| `deployment.tolerations`                 | Tolerations for pod assignment                | `[]`                                  |
| `deployment.affinity`                    | Affinity for pod assignment                   | `{}`                                  |
| `service.type`                           | Kubernetes Service type                       | `ClusterIP`                           |
| `service.port`                           | Service port                                  | `80`                                  |
| `ingress.enabled`                        | Enable ingress                                | `true`                                |
| `ingress.className`                      | Ingress class name                            | `traefik`                             |
| `ingress.hosts`                          | Hostnames for the ingress                     | `[{host: avexa.example.com, paths: [{path: /, pathType: Prefix}]}]` |
| `ingress.tls`                            | TLS configuration for ingress                 | See values.yaml                       |
| `ingress.annotations`                    | Ingress annotations                           | See values.yaml                       |
| `healthcheck.livenessProbe.enabled`      | Enable liveness probe                         | `true`                                |
| `healthcheck.readinessProbe.enabled`     | Enable readiness probe                        | `true`                                |
| `env`                                    | Environment variables                         | `[]`                                  |
| `secretEnv`                              | Secret environment variables                  | `[]`                                  |
| `podAnnotations`                         | Pod annotations                               | `{}`                                  |
| `additionalLabels`                       | Additional labels                             | `{}`                                  |
| `serviceAccount.create`                  | Create service account                        | `false`                               |
| `serviceAccount.name`                    | Service account name                          | `""`                                  |
| `securityContext.pod`                    | Pod security context                          | See values.yaml                       |
| `securityContext.container`              | Container security context                    | See values.yaml                       |

### Example Custom Values

Create a custom values file (`values-prod.yaml`) for production deployment:

```yaml
app:
  image:
    repository: registry.example.com/rocketbyte/avexa-react
    tag: 1.0.0

deployment:
  replicas: 3
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

ingress:
  hosts:
    - host: avexa.rocketbyte.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: avexa-tls
      hosts:
        - avexa.rocketbyte.com

env:
  - name: NODE_ENV
    value: production
```

Apply with:

```bash
helm install avexa-react /path/to/k3s/charts/avexa-react -f values-prod.yaml --namespace rocket
```

## CI/CD Integration

This chart can be integrated with CI/CD pipelines. Here's a sample workflow:

1. Build and push the Docker image on code changes
2. Update the image tag in the Helm values
3. Deploy/upgrade the application using Helm

## Security Considerations

- The chart uses secure defaults for pod and container security contexts
- TLS is enabled by default for ingress
- Secrets should be managed securely using a secret management solution

## Troubleshooting

Common issues:

1. **Pod fails to start**:
   - Check image repository and tag in values.yaml
   - Verify that the container registry is accessible

2. **Ingress not working**:
   - Check if Traefik ingress controller is running
   - Verify hostname configuration
   - Check TLS secret exists

3. **View logs**:
   ```bash
   kubectl logs -l app=avexa-react -n rocket
   ```

## Maintenance

### Upgrading the Application

To update to a new application version:

1. Build and push the new Docker image with the new tag
2. Update the `app.image.tag` in your values file
3. Run `helm upgrade` to deploy the new version