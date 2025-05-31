# OpenCart Kubernetes Setup Guide

This document outlines the steps to deploy OpenCart on Kubernetes and troubleshoot common issues.

## Prerequisites
- Kubernetes cluster
- kubectl configured to access your cluster
- Basic understanding of Kubernetes concepts

## Deployment Steps

1. Create the namespace:
```bash
kubectl apply -f manifest/namespace.yaml
```

2. Create ConfigMap and Secret:
```bash
kubectl apply -f manifest/configmap.yaml
kubectl apply -f manifest/secret.yaml
```

3. Create Persistent Volume for the database:
```bash
# Create the directory for the PV hostPath
sudo mkdir -p /data/opencart-db

# Apply the PV configuration
kubectl apply -f manifest/db-pv.yaml
```

4. Create Persistent Volume Claim:
```bash
kubectl apply -f manifest/db-pvc.yaml
```

5. Deploy the database:
```bash
kubectl apply -f manifest/db-deployment.yaml
kubectl apply -f manifest/db-service.yaml
```

6. Deploy OpenCart:
```bash
kubectl apply -f manifest/opencart-deployment.yaml
kubectl apply -f manifest/opencart-service.yaml
```

7. Create Ingress (if needed):
```bash
kubectl apply -f manifest/opencart-ingress.yaml
```

## Common Issues and Solutions

### Issue 1: Database Pod Not Creating

**Symptoms:**
- Database pod stays in `Pending` state
- Error message: `pod has unbound immediate PersistentVolumeClaims`

**Solution:**
1. Create a Persistent Volume (PV) that matches the PVC requirements:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: opencart-db-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/opencart-db
```

2. Create the directory for the PV hostPath:
```bash
sudo mkdir -p /data/opencart-db
```

3. Apply the PV configuration:
```bash
kubectl apply -f manifest/db-pv.yaml
```

### Issue 2: OpenCart Pod CrashLoopBackOff

**Symptoms:**
- OpenCart pod repeatedly crashes and restarts
- Status shows `CrashLoopBackOff`

**Possible Causes and Solutions:**

1. **Database Connection Issues:**
   - Ensure the database pod is running before starting the OpenCart pod
   - Verify the database service name matches the DB_HOST environment variable
   - Check that database credentials in the secret match what OpenCart expects

2. **Resource Constraints:**
   - If the pod is being terminated due to OOM (Out of Memory), increase the memory limits
   - Adjust CPU limits if necessary

3. **Configuration Issues:**
   - Ensure all required environment variables are properly set
   - Check for typos in ConfigMap and Secret keys

4. **Image Issues:**
   - Verify the image is compatible with your Kubernetes environment
   - Try using a different tag or version of the image

## Verification Steps

1. Check if all pods are running:
```bash
kubectl get pods -n opencart
```

2. Check pod logs for errors:
```bash
kubectl logs -n opencart <pod-name>
```

3. Describe pods for detailed information:
```bash
kubectl describe pod -n opencart <pod-name>
```

4. Access the application:
```bash
# If using NodePort
kubectl get svc -n opencart

# If using Ingress
kubectl get ingress -n opencart
```

## Maintenance

### Scaling
```bash
kubectl scale deployment opencart -n opencart --replicas=3
```

### Updating
```bash
kubectl set image deployment/opencart opencart=new-image:tag -n opencart
```

### Backup
Backup the database data by creating a snapshot of the PV or using database backup tools.
