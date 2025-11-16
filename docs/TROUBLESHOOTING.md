# Traefik Ingress Controller Troubleshooting Guide for Raspberry Pi

This document contains detailed instructions for troubleshooting and debugging the Traefik ingress controller deployment on Raspberry Pi. All commands and configurations are documented for reference.

## Checking Current State

```bash
# List all pods in the rocket namespace
kubectl get pods -n rocket

# Show all services in the rocket namespace
kubectl get svc -n rocket

# Show detailed information about a pod
kubectl describe pod -n rocket [pod-name]

# Check logs from the Traefik pod
kubectl logs -n rocket -l app=traefik

# Check what ports are listening inside the container
kubectl exec -n rocket $(kubectl get pods -n rocket -l app=traefik -o jsonpath='{.items[0].metadata.name}') -- netstat -tulpn

# Check the Traefik configuration file
kubectl exec -n rocket $(kubectl get pods -n rocket -l app=traefik -o jsonpath='{.items[0].metadata.name}') -- cat /config/traefik.toml
```

## Common Issues and Solutions

### 1. Port 8080 Already in Use

The default Traefik dashboard port (8080) might be in use on Raspberry Pi by other services:

```bash
# Error in logs:
# error while building entryPoint traefik: error preparing server: error opening listener: listen tcp :8080: bind: address already in use

# Solution: Use a different port for the dashboard (e.g., 7000)
# In your Traefik configuration:
--entrypoints.dashboard.address=:7000
```

### 2. Dashboard 404 Not Found

If you see "404 page not found" when accessing the dashboard:

```bash
# Check if the dashboard is enabled in the configuration
kubectl exec -n rocket [pod-name] -- grep -i dashboard /config/traefik.toml

# Ensure you're using the correct URL:
# - For Traefik v2.x, try: http://localhost:[dashboard-port]/dashboard/
# - Direct API access: http://localhost:[dashboard-port]/api
```

### 3. CRD Installation Issues

```bash
# Install Traefik CRDs manually:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
```

### 4. MongoDB ARM Compatibility Issue

```bash
# Error from MongoDB:
# MongoDB requires ARMv8.2-A or higher, and your current system does not appear to implement any of the common features for that!

# Solution: Disable MongoDB in your configuration as it's not fully compatible with Raspberry Pi
# Update your Terraform variables:
deploy_mongodb = false
```

## Working Traefik Configuration for Raspberry Pi

### Direct Kubernetes Deployment

```bash
# This configuration works reliably on Raspberry Pi:
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: traefik
  namespace: rocket
spec:
  type: LoadBalancer
  ports:
    - port: 80
      name: web
      targetPort: 80
    - port: 443
      name: websecure
      targetPort: 443
    - port: 7000
      name: dashboard
      targetPort: 7000
  selector:
    app: traefik
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: traefik
  namespace: rocket
  labels:
    app: traefik
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traefik
  template:
    metadata:
      labels:
        app: traefik
    spec:
      serviceAccountName: traefik-ingress-controller
      containers:
        - name: traefik
          image: traefik:v2.9.8
          ports:
            - name: web
              containerPort: 80
            - name: websecure
              containerPort: 443
            - name: dashboard
              containerPort: 7000
          args:
            - --api=true
            - --api.dashboard=true
            - --api.insecure=true
            - --entrypoints.web.address=:80
            - --entrypoints.websecure.address=:443
            - --entrypoints.dashboard.address=:7000
            - --providers.kubernetesingress=true
            - --accesslog=true
          resources:
            requests:
              cpu: 100m
              memory: 50Mi
            limits:
              cpu: 300m
              memory: 150Mi
EOF
```

### Terraform Configuration

The equivalent configuration has been implemented in Terraform:

- `/terraform/modules/ingress_controller/main.tf` has been updated with native Kubernetes resources
- Key improvements include:
  - Using direct command-line arguments instead of complex TOML config
  - Choosing Traefik v2.9.8 which is more reliable on ARM
  - Using port 7000 for the dashboard to avoid conflicts
  - Setting appropriate resource limits for Raspberry Pi

## Accessing the Dashboard

```bash
# Port-forward to access the dashboard locally
kubectl port-forward svc/traefik -n rocket 7000:7000

# The dashboard should be accessible at:
# http://localhost:7000/

# If using external IP:
# http://[YOUR_PI_IP]:7000/
```

## Cleaning Up Resources

```bash
# Delete Traefik resources
kubectl delete deployment traefik -n rocket
kubectl delete service traefik -n rocket
kubectl delete serviceaccount traefik-ingress-controller -n rocket
kubectl delete clusterrole traefik-ingress-controller
kubectl delete clusterrolebinding traefik-ingress-controller

# Delete namespace (if needed)
kubectl delete namespace rocket
```