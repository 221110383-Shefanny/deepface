# 📦 Kubernetes Deployment Files

Kumpulan lengkap file deployment untuk menjalankan DeepFace Face Recognition System di Kubernetes.

## 📂 File Structure

```
deepface/
├── deployment-frontend.yaml          # Frontend React Deployment + Service + HPA
├── deployment-backend.yaml           # Backend FastAPI Deployment + Service + HPA
├── deployment-extras.yaml            # Ingress, PVC, NetworkPolicy, ResourceQuota
├── deploy.sh                         # Automated deployment script (bash)
├── DEPLOYMENT_GUIDE.md              # Detailed deployment guide
├── DEPLOYMENT_SUMMARY.md            # Quick summary and overview
├── DEPLOYMENT_CHECKLIST.md          # Step-by-step checklist & troubleshooting
├── README_DEPLOYMENT.md             # This file
├── backend/health_check.py          # Health check endpoints for backend
└── docker-compose.yml               # Local development environment
```

## 🚀 Quick Start (3 Langkah)

### 1. Deploy Backend
```bash
kubectl apply -f deployment-backend.yaml
kubectl rollout status deployment/deepface-backend
```

### 2. Deploy Frontend
```bash
kubectl apply -f deployment-frontend.yaml
kubectl rollout status deployment/deepface-frontend
```

### 3. Access Application
```bash
# Get external IP
kubectl get svc deepface-frontend-service
# Buka di browser: http://<EXTERNAL-IP>
```

## 📖 Dokumentasi

| File | Deskripsi |
|------|-----------|
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Panduan lengkap, setup, monitoring, troubleshooting |
| [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) | Ringkasan komponen, features, scaling behavior |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Checklist lengkap, common commands, emergency procedures |

## ⚙️ File Deployment Explained

### deployment-backend.yaml
**Includes:**
- Deployment manifest dengan 2 replicas
- Service ClusterIP (internal access only)
- HorizontalPodAutoscaler (2-4 replicas)
- ConfigMap untuk konfigurasi

**Key Settings:**
- Image: `shefanny00/deepface-backend:latest`
- Port: 5000
- CPU: 200m-1000m
- Memory: 512Mi-2Gi
- Health Check: `/health` endpoint

### deployment-frontend.yaml
**Includes:**
- Deployment manifest dengan 2 replicas
- Service LoadBalancer (public access)
- HorizontalPodAutoscaler (2-5 replicas)
- Environment variables

**Key Settings:**
- Image: `shefanny00/deepface-frontend:latest`
- Port: 3000 (exposed as port 80)
- CPU: 100m-500m
- Memory: 128Mi-512Mi
- Health Check: HTTP GET / endpoint

### deployment-extras.yaml
**Optional Advanced Configuration:**
- Ingress untuk routing berbasis hostname
- Namespace isolation
- PersistentVolume & PersistentVolumeClaim
- NetworkPolicy untuk security
- ResourceQuota untuk resource limiting
- StorageClass untuk model caching

## 🛠️ Automation Script (deploy.sh)

Script bash untuk simplify deployment operations:

```bash
# Deploy
./deploy.sh deploy

# Check status
./deploy.sh status

# View logs
./deploy.sh logs backend
./deploy.sh logs frontend

# Scale deployment
./deploy.sh scale frontend 5

# Update image
./deploy.sh update backend

# Port forward
./deploy.sh port-forward backend

# SSH ke pod
./deploy.sh shell backend

# Delete deployment
./deploy.sh delete
```

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│          Kubernetes Cluster                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐        ┌─────────────────┐   │
│  │  Frontend Pods   │        │  Backend Pods   │   │
│  │  ┌────────────┐  │        │  ┌───────────┐  │   │
│  │  │ React App  │  │        │  │ FastAPI   │  │   │
│  │  │ Port 3000  │  │        │  │ Port 5000 │  │   │
│  │  └────────────┘  │        │  └───────────┘  │   │
│  │  Replicas: 2-5   │        │  Replicas: 2-4  │   │
│  └──────────────────┘        └─────────────────┘   │
│          │                             │            │
│          │                             │            │
│  ┌──────▼────────────┐        ┌──────▼──────────┐  │
│  │ LoadBalancer      │        │ ClusterIP       │  │
│  │ Service           │        │ Service         │  │
│  │ Port 80           │        │ Port 5000       │  │
│  │ EXTERNAL-IP:80    │        │ (Internal Only) │  │
│  └───────────────────┘        └─────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
         │
         ▼
    [External Users]
```

## 🔍 Key Features

### High Availability
- ✅ Multiple replicas (2+ pods per service)
- ✅ Auto-healing (pod replacement)
- ✅ Rolling updates (zero downtime)
- ✅ Load balancing

### Auto-Scaling
- ✅ Frontend: 2-5 replicas (70% CPU, 80% Memory)
- ✅ Backend: 2-4 replicas (60% CPU, 75% Memory)

### Health Management
- ✅ Liveness probes (restart unhealthy pods)
- ✅ Readiness probes (traffic only to ready pods)
- ✅ Health check endpoints

### Resource Management
- ✅ CPU & Memory requests/limits
- ✅ Resource quotas (namespace level)
- ✅ Network policies (traffic control)

## 📋 Prerequisites

- Kubernetes cluster v1.19+
- kubectl CLI configured
- Docker images pushed to registry:
  - `shefanny00/deepface-frontend:latest`
  - `shefanny00/deepface-backend:latest`
- (Optional) Ingress controller untuk deployment-extras.yaml

## 🚀 Deployment Workflow

```
1. Verify Prerequisites
   ├─ kubectl access
   ├─ Docker images available
   └─ Cluster resources available

2. Deploy Backend
   ├─ kubectl apply -f deployment-backend.yaml
   ├─ Wait for rollout
   └─ Verify health checks

3. Deploy Frontend
   ├─ kubectl apply -f deployment-frontend.yaml
   ├─ Wait for rollout
   └─ Get external IP

4. Optional: Deploy Extras
   ├─ Ingress
   ├─ Persistent Volumes
   └─ Network Policies

5. Verification
   ├─ Check all pods running
   ├─ Test health endpoints
   ├─ Access via browser
   └─ Monitor metrics
```

## ⚡ Performance Tips

1. **Resource Allocation**: Adjust CPU/Memory sesuai kebutuhan
2. **Replica Count**: Increase min replicas untuk lebih stabil
3. **Model Caching**: Gunakan PersistentVolume untuk caching
4. **Network**: Colocate frontend dan backend di satu zone
5. **Monitoring**: Setup Prometheus untuk tracking metrics

## 🔐 Security Considerations

1. **Image Registry**: Gunakan private registry dengan auth
2. **Network Policies**: Restrict inter-pod communication
3. **RBAC**: Configure role-based access control
4. **Secrets**: Store sensitive data di Kubernetes Secrets
5. **TLS/SSL**: Enable untuk production environments

## 📈 Monitoring & Observability

**Built-in:**
- Health checks via probes
- Rollout status tracking
- Event logging

**Recommended:**
- Prometheus untuk metrics
- Grafana untuk visualization
- ELK/Loki untuk log aggregation
- Jaeger untuk distributed tracing

## 🆘 Quick Troubleshooting

**Pod won't start?**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Can't access frontend?**
```bash
kubectl get svc deepface-frontend-service
kubectl port-forward svc/deepface-frontend-service 3000:80
```

**Backend health check failing?**
```bash
kubectl port-forward svc/deepface-backend-service 5000:5000
curl http://localhost:5000/health
```

Lihat [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) untuk troubleshooting lengkap.

## 🎯 Production Readiness

- [x] Deployment manifests tested
- [x] Health checks configured
- [x] Resource limits set
- [x] Auto-scaling enabled
- [x] Rolling updates configured
- [x] Network policies optional
- [ ] Persistent storage for models (optional)
- [ ] Ingress controller setup (optional)
- [ ] Monitoring stack (optional)
- [ ] Backup/restore procedure

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [React in Docker](https://create-react-app.dev/deployment/)
- [DeepFace GitHub](https://github.com/serengp/deepface)

## 🤝 Support

Untuk issues atau questions:
1. Check [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
2. Review pod logs: `kubectl logs deployment/deepface-backend`
3. Check pod events: `kubectl describe pod <pod-name>`
4. Review resource usage: `kubectl top pods`

## 📝 Version Info

- **Kubernetes**: 1.19+
- **Frontend Image**: shefanny00/deepface-frontend:latest
- **Backend Image**: shefanny00/deepface-backend:latest
- **Created**: January 11, 2026
- **Status**: ✅ Production Ready

---

**Ready to deploy? Start with:**
```bash
kubectl apply -f deployment-backend.yaml
kubectl apply -f deployment-frontend.yaml
```

**Then check status:**
```bash
kubectl get all
./deploy.sh status
```
