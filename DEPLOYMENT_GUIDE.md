# DeepFace Kubernetes Deployment Guide

Panduan deployment aplikasi DeepFace Face Recognition ke Kubernetes cluster.

## Prerequisites

1. Kubernetes cluster sudah berjalan (minimal v1.19+)
2. kubectl sudah terinstall dan terkonfigurasi
3. Docker images sudah di-push ke registry:
   - `shefanny00/deepface-frontend:latest`
   - `shefanny00/deepface-backend:latest`

## File Deployment

### 1. Frontend Deployment (`deployment-frontend.yaml`)
- **Replicas**: 2 pods (auto-scale hingga 5)
- **Image**: shefanny00/deepface-frontend:latest
- **Port**: 3000 (expose via Service port 80)
- **Type**: LoadBalancer (akses dari luar cluster)
- **Resources**:
  - CPU: 100m-500m
  - Memory: 128Mi-512Mi

### 2. Backend Deployment (`deployment-backend.yaml`)
- **Replicas**: 2 pods (auto-scale hingga 4)
- **Image**: shefanny00/deepface-backend:latest
- **Port**: 5000
- **Type**: ClusterIP (internal service only)
- **Resources**:
  - CPU: 200m-1000m
  - Memory: 512Mi-2Gi

## Deployment Steps

### Step 1: Deploy Backend (harus pertama karena frontend depend on backend)
```bash
kubectl apply -f deployment-backend.yaml
```

Verifikasi backend deployment:
```bash
kubectl get deployments deepface-backend
kubectl get pods -l app=deepface-backend
kubectl get svc deepface-backend-service
```

### Step 2: Deploy Frontend
```bash
kubectl apply -f deployment-frontend.yaml
```

Verifikasi frontend deployment:
```bash
kubectl get deployments deepface-frontend
kubectl get pods -l app=deepface-frontend
kubectl get svc deepface-frontend-service
```

### Step 3: Check All Resources
```bash
kubectl get all -l app=deepface-backend
kubectl get all -l app=deepface-frontend
```

## Akses Aplikasi

### Frontend (dari luar cluster)
```bash
# Dapatkan external IP
kubectl get svc deepface-frontend-service

# Akses via browser
http://<EXTERNAL-IP>
```

### Backend (internal cluster)
Backend hanya dapat diakses dari dalam cluster melalui:
```
http://deepface-backend-service:5000
```

## Monitoring & Troubleshooting

### Check Deployment Status
```bash
# Lihat deployment status
kubectl describe deployment deepface-frontend
kubectl describe deployment deepface-backend

# Lihat pod logs
kubectl logs -f deployment/deepface-frontend
kubectl logs -f deployment/deepface-backend

# Lihat pod details
kubectl describe pod <POD-NAME>
```

### Check Health
```bash
# Port forward ke backend untuk testing
kubectl port-forward svc/deepface-backend-service 5000:5000

# Test health endpoint
curl http://localhost:5000/health
```

## Scaling

### Manual Scale
```bash
# Scale frontend
kubectl scale deployment deepface-frontend --replicas=3

# Scale backend
kubectl scale deployment deepface-backend --replicas=3
```

### Auto Scaling
HPA sudah dikonfigurasi dan akan auto-scale berdasarkan:
- Frontend: 70% CPU atau 80% Memory
- Backend: 60% CPU atau 75% Memory

Check HPA status:
```bash
kubectl get hpa
kubectl describe hpa deepface-frontend-hpa
kubectl describe hpa deepface-backend-hpa
```

## Environment Variables

### Frontend
- `REACT_APP_API_URL`: Backend API URL (default: http://deepface-backend-service:5000)

### Backend
- `PYTHONUNBUFFERED`: 1 (untuk real-time logging)
- `FLASK_ENV`: production
- `HOST`: 0.0.0.0
- `PORT`: 5000

## Volume & Storage

### Frontend
- `/app/node_modules`: EmptyDir (temporary cache)

### Backend
- `/root/.deepface`: EmptyDir (model cache)
- `/tmp`: EmptyDir (temporary uploads)

## Helm Alternative

Jika ingin menggunakan Helm, buat `helm/values.yaml`:
```yaml
frontend:
  replicas: 2
  image: shefanny00/deepface-frontend:latest
  
backend:
  replicas: 2
  image: shefanny00/deepface-backend:latest
```

## Cleanup

### Delete Deployment
```bash
# Delete frontend
kubectl delete -f deployment-frontend.yaml

# Delete backend
kubectl delete -f deployment-backend.yaml

# Or delete all at once
kubectl delete -f deployment-*.yaml
```

## Security Best Practices

1. **Image Registry**: Gunakan private registry dengan authentication
2. **Network Policy**: Implement NetworkPolicy untuk restrict traffic
3. **RBAC**: Implement Role-Based Access Control
4. **Secrets**: Gunakan Kubernetes Secrets untuk sensitive data
5. **Resource Quotas**: Set namespace resource quotas
6. **Pod Security Policy**: Implement PSP untuk security

## Production Checklist

- [ ] Backend deployment sudah running dan healthy
- [ ] Frontend dapat terhubung ke backend
- [ ] Health checks sudah responsive
- [ ] Auto-scaling sudah berjalan
- [ ] Logs dapat di-monitor
- [ ] Persistent storage untuk models (jika diperlukan)
- [ ] Ingress controller sudah configured
- [ ] SSL/TLS certificate sudah setup (untuk production)

## Next Steps

1. Setup Ingress untuk routing yang lebih advanced
2. Configure Persistent Volumes untuk model caching
3. Setup monitoring dengan Prometheus & Grafana
4. Configure logging dengan ELK atau Loki
5. Setup CI/CD pipeline untuk auto-deployment

---

**Last Updated**: January 11, 2026
