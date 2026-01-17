<!-- deployment-summary.md -->
# Deployment Summary - DeepFace Face Recognition System

## 📦 Struktur Deployment

```
deepface/
├── deployment-frontend.yaml      # Frontend React app deployment
├── deployment-backend.yaml       # Backend FastAPI deployment
├── deployment-extras.yaml        # Ingress, PVC, NetworkPolicy, ResourceQuota
├── deploy.sh                     # Quick deployment script
├── DEPLOYMENT_GUIDE.md           # Detailed deployment guide
└── docker-compose.yml            # Development environment
```

## 🚀 Quick Start

### Opsi 1: Menggunakan Script
```bash
# Deploy kedua aplikasi
./deploy.sh deploy

# Check status
./deploy.sh status

# Lihat logs
./deploy.sh logs backend
./deploy.sh logs frontend
```

### Opsi 2: Manual dengan kubectl
```bash
# Deploy backend terlebih dahulu
kubectl apply -f deployment-backend.yaml

# Deploy frontend
kubectl apply -f deployment-frontend.yaml

# Optional: Deploy extras (Ingress, PVC, dll)
kubectl apply -f deployment-extras.yaml
```

## 📋 Komponen Deployment

### Frontend (React)
- **Image**: shefanny00/deepface-frontend:latest
- **Port**: 3000 (expose via port 80)
- **Replicas**: 2 (auto-scale to 5)
- **Service**: LoadBalancer (public access)
- **Health Check**: HTTP GET / (every 10s)
- **Resources**: 100m-500m CPU, 128Mi-512Mi Memory

### Backend (FastAPI)
- **Image**: shefanny00/deepface-backend:latest
- **Port**: 5000
- **Replicas**: 2 (auto-scale to 4)
- **Service**: ClusterIP (internal only)
- **Health Check**: HTTP GET /health (every 10s)
- **Resources**: 200m-1000m CPU, 512Mi-2Gi Memory
- **Volumes**: Model cache, temp storage

## 🔍 Monitoring & Management

### Check Status
```bash
# All resources
kubectl get all

# Specific deployments
kubectl get deployment deepface-backend deepface-frontend

# Pods detail
kubectl describe pod <POD-NAME>

# Logs
kubectl logs -f deployment/deepface-backend
```

### Port Forwarding
```bash
# Frontend
kubectl port-forward svc/deepface-frontend-service 3000:80

# Backend
kubectl port-forward svc/deepface-backend-service 5000:5000
```

### Scaling
```bash
# Auto-scaling via HPA
kubectl get hpa

# Manual scaling
kubectl scale deployment deepface-frontend --replicas=3
kubectl scale deployment deepface-backend --replicas=3
```

## 🔧 Konfigurasi

### Frontend Environment
- `REACT_APP_API_URL=http://deepface-backend-service:5000`

### Backend Environment
- `PYTHONUNBUFFERED=1`
- `FLASK_ENV=production`
- `HOST=0.0.0.0`
- `PORT=5000`

### Backend ConfigMap
Tersedia di `deployment-backend.yaml` dengan model dan performance settings

## 📊 Features

### Deployment Features
✅ Rolling updates (zero downtime)
✅ Health checks (liveness & readiness probes)
✅ Resource limits & requests
✅ Horizontal Pod Autoscaling (HPA)
✅ Pod disruption budgets (PDB)

### Backend Features (dari deployment-extras.yaml)
✅ Ingress controller support
✅ Namespace isolation
✅ Resource quotas
✅ Network policies
✅ Persistent volumes
✅ Storage classes

## 🎯 Access Points

| Service | Type | Access |
|---------|------|--------|
| Frontend | LoadBalancer | External IP:80 |
| Backend | ClusterIP | deepface-backend-service:5000 (internal) |
| API via Ingress | Ingress | https://deepface.example.com/api |

## 🔒 Security

- Network policies implemented
- Resource quotas configured
- RBAC ready (needs manual setup)
- TLS/SSL ready (via cert-manager)
- Image pull policy: Always

## 📈 Scaling Behavior

**Frontend HPA**
- Min: 2 replicas
- Max: 5 replicas
- Trigger: 70% CPU atau 80% Memory

**Backend HPA**
- Min: 2 replicas
- Max: 4 replicas
- Trigger: 60% CPU atau 75% Memory

## 🛠️ Troubleshooting

### Pod not starting?
```bash
kubectl describe pod <POD-NAME>
kubectl logs <POD-NAME>
```

### Service not accessible?
```bash
kubectl get svc
kubectl describe svc deepface-frontend-service
```

### Health check failing?
```bash
# Test manually
kubectl port-forward svc/deepface-backend-service 5000:5000
curl http://localhost:5000/health
```

## 📝 Deployment Checklist

- [ ] Kubernetes cluster ready
- [ ] Docker images pushed to registry
- [ ] kubectl configured
- [ ] Backend deployment successful
- [ ] Backend health check passing
- [ ] Frontend deployment successful
- [ ] Frontend can reach backend
- [ ] Services exposed correctly
- [ ] HPA working (check with `kubectl get hpa`)
- [ ] Load testing completed

## 🔄 Update Workflow

### Update Backend
```bash
./deploy.sh update backend
# or manually
kubectl set image deployment/deepface-backend backend=shefanny00/deepface-backend:latest
```

### Update Frontend
```bash
./deploy.sh update frontend
# or manually
kubectl set image deployment/deepface-frontend frontend=shefanny00/deepface-frontend:latest
```

## 🧹 Cleanup

```bash
# Delete all
kubectl delete -f deployment-*.yaml

# Or selective delete
kubectl delete deployment deepface-frontend
kubectl delete deployment deepface-backend
kubectl delete svc deepface-frontend-service deepface-backend-service
```

## 📚 Additional Resources

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed guide
- [deployment-frontend.yaml](deployment-frontend.yaml) - Frontend manifest
- [deployment-backend.yaml](deployment-backend.yaml) - Backend manifest
- [deployment-extras.yaml](deployment-extras.yaml) - Extras (Ingress, PVC, etc)
- [deploy.sh](deploy.sh) - Deployment automation script

## 🆘 Support Commands

```bash
# Full deployment info
kubectl get all -o wide

# Export current deployments
kubectl get deployment -o yaml > backup.yaml

# Namespace info
kubectl describe namespace default

# Resource usage
kubectl top pods
kubectl top nodes
```

---

**Last Updated**: January 11, 2026
**Version**: 1.0
**Status**: Production Ready ✅
