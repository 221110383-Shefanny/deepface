# 📊 HPA (Horizontal Pod Autoscaler) Configuration Guide

Panduan lengkap untuk menggunakan HPA dengan DeepFace deployment.

## 📋 File Included

File `hpa.yaml` berisi:
1. **HPA Backend** - Autoscale DeepFace backend pods
2. **HPA Frontend** - Autoscale React frontend pods
3. **PodDisruptionBudget (PDB)** - Backend dan Frontend
4. **Optional configs** - VPA, Custom Metrics (commented)

---

## 🚀 Deployment

### Deploy HPA
```bash
kubectl apply -f hpa.yaml
```

### Verify HPA
```bash
# Check HPA status
kubectl get hpa

# Detailed HPA info
kubectl describe hpa deepface-backend-hpa
kubectl describe hpa deepface-frontend-hpa

# Watch HPA in action
kubectl get hpa -w
```

---

## ⚙️ Configuration Details

### Backend HPA
```yaml
minReplicas: 2        # Minimum 2 pods selalu berjalan
maxReplicas: 4        # Maximum scale to 4 pods
CPU Trigger: 60%      # Scale up saat CPU > 60%
Memory Trigger: 75%   # Scale up saat Memory > 75%
```

**Scale Up Behavior:**
- Instant response (stabilization window 0 detik)
- Naik 100% replicas atau +2 pods (whichever is more)
- Every 15 seconds

**Scale Down Behavior:**
- Wait 5 minutes stabilization
- Turun 100% replicas atau -1 pod (whichever is less)
- Every 15 seconds

### Frontend HPA
```yaml
minReplicas: 2        # Minimum 2 pods
maxReplicas: 5        # Maximum 5 pods
CPU Trigger: 70%      # Scale up saat CPU > 70%
Memory Trigger: 80%   # Scale up saat Memory > 80%
```

**Behavior:** Same as backend (instant scale up, 5 min stabilization for scale down)

---

## 🔍 Monitoring HPA

### View Current Status
```bash
# All HPA
kubectl get hpa

# Output contoh:
# NAME                    REFERENCE                    TARGETS              MINPODS MAXPODS REPLICAS AGE
# deepface-backend-hpa    Deployment/deepface-backend  45%/60%, 30%/75%     2       4       2        5m
# deepface-frontend-hpa   Deployment/deepface-frontend 60%/70%, 50%/80%     2       5       3        5m
```

### Watch Scaling Events
```bash
# Real-time monitoring
kubectl get hpa -w

# Check events
kubectl get events --field-selector involvedObject.name=deepface-backend-hpa

# View HPA decisions
kubectl describe hpa deepface-backend-hpa
```

### Check Metrics
```bash
# Requires metrics-server installed
kubectl top pods -l app=deepface-backend
kubectl top pods -l app=deepface-frontend

# CPU dan Memory usage per pod
kubectl top pods -l app=deepface-backend --containers=true
```

---

## 📈 Scaling Behavior Explained

### Scale UP Example (Backend)
```
Time 0:00  → CPU usage 65% (> 60% threshold)
            → HPA detects high CPU immediately
            → Initiates scale up
            
Time 0:15  → New pod starting (replicas: 3)
            → Wait for readiness probe
            
Time 0:30  → New pod ready
            → Service starts routing traffic
            → CPU drops to 45%
```

### Scale DOWN Example
```
Time 0:00  → CPU usage drops to 20% (< 60%)
            → HPA notices but WAITS (stabilization)
            
Time 5:00  → Still at 20% after 5 minutes
            → Scale down decision made
            → Remove 1 pod (replicas: 2)
            
Time 5:15  → Pod terminating gracefully
            → Remaining pods handle traffic
```

---

## ⚠️ Prerequisites

### Required
- ✅ Kubernetes cluster v1.18+
- ✅ `metrics-server` installed
  ```bash
  # Check if metrics-server is running
  kubectl get deployment metrics-server -n kube-system
  
  # Install if missing (minikube)
  minikube addons enable metrics-server
  
  # Install if missing (other clusters)
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
  ```

### Deployment with Resource Requests
```bash
# HPA needs resource requests configured in deployment
# Already included in deployment-backend.yaml dan deployment-frontend.yaml

# Verify resource requests
kubectl describe deployment deepface-backend | grep -A 5 "Requests"
```

---

## 🔧 Customization

### Change Threshold
Edit `hpa.yaml` sebelum apply:
```yaml
# Backend CPU threshold (default 60%)
averageUtilization: 75  # Change from 60 to 75

# Frontend Memory threshold (default 80%)
averageUtilization: 90  # Change from 80 to 90
```

### Change Min/Max Replicas
```yaml
minReplicas: 3  # Change from 2 to 3
maxReplicas: 6  # Change from 4 to 6
```

### Change Scaling Behavior
```yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 60  # Wait 60 sec before scale up
    policies:
    - type: Percent
      value: 50              # Scale by 50%
      periodSeconds: 15
```

---

## 🎯 Scaling Strategies

### Aggressive Scaling (for spiky traffic)
```yaml
minReplicas: 1
maxReplicas: 10
scaleUp:
  stabilizationWindowSeconds: 0      # Immediate
  policies:
  - value: 200                       # Double replicas
    periodSeconds: 15
scaleDown:
  stabilizationWindowSeconds: 600    # Wait 10 minutes
```

### Conservative Scaling (for stable workloads)
```yaml
minReplicas: 3
maxReplicas: 5
scaleUp:
  stabilizationWindowSeconds: 120    # Wait 2 minutes
  policies:
  - value: 50                        # Add 50%
    periodSeconds: 30
scaleDown:
  stabilizationWindowSeconds: 900    # Wait 15 minutes
```

### Balanced (current config)
```yaml
minReplicas: 2
maxReplicas: 4-5
scaleUp:
  stabilizationWindowSeconds: 0      # Immediate
scaleDown:
  stabilizationWindowSeconds: 300    # Wait 5 minutes
```

---

## 📊 PodDisruptionBudget (PDB)

### What is PDB?
Memastikan minimal jumlah pods tetap running selama:
- Node maintenance
- Cluster upgrade
- Manual disruptions

### Current Config
```yaml
minAvailable: 1    # Minimal 1 pod harus tetap running
                   # Untuk backend: minimal 1 dari 2-4 pods
                   # Untuk frontend: minimal 1 dari 2-5 pods
```

### Verify PDB
```bash
kubectl get pdb
kubectl describe pdb deepface-backend-pdb
```

---

## 🔄 Manual Scaling (Override HPA)

### Temporarily disable HPA
```bash
# Delete HPA (pods stay at current replicas)
kubectl delete hpa deepface-backend-hpa

# Or patch HPA to disable
kubectl patch hpa deepface-backend-hpa -p '{"spec":{"minReplicas":3,"maxReplicas":3}}'
```

### Manual scale (HPA akan re-adjust)
```bash
# Scale manually
kubectl scale deployment deepface-backend --replicas=5

# HPA akan notice dan adjust sesuai metrics
# Jika CPU turun, HPA akan scale down
```

### Re-enable HPA
```bash
# Apply HPA lagi
kubectl apply -f hpa.yaml
```

---

## 📈 Performance Tuning

### Optimize for Latency
- Increase minReplicas untuk always-on capacity
- Reduce scaleUp stabilization time
- Example:
  ```yaml
  minReplicas: 3
  scaleUp:
    stabilizationWindowSeconds: 0
  ```

### Optimize for Cost
- Decrease maxReplicas
- Increase scaleDown stabilization time
- Example:
  ```yaml
  maxReplicas: 3
  scaleDown:
    stabilizationWindowSeconds: 600
  ```

### Optimize for Availability
- Increase minAvailable in PDB
- Keep higher minReplicas
- Example:
  ```yaml
  minReplicas: 3
  minAvailable: 2  (in PDB)
  ```

---

## 🐛 Troubleshooting

### HPA not scaling
```bash
# 1. Check metrics-server
kubectl get deployment metrics-server -n kube-system

# 2. Check if metrics available
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes

# 3. Check HPA status
kubectl describe hpa deepface-backend-hpa

# 4. Check events
kubectl get events --field-selector involvedObject.name=deepface-backend-hpa
```

### HPA stuck at max replicas
```bash
# Check if workload really needs that much
kubectl top pods -l app=deepface-backend

# Check for resource requests/limits issues
kubectl describe pod <pod-name>

# Increase maxReplicas if needed
kubectl patch hpa deepface-backend-hpa -p '{"spec":{"maxReplicas":6}}'
```

### Pods keep restarting after scale
```bash
# Check pod logs
kubectl logs -f <pod-name>

# Check resource limits
kubectl describe pod <pod-name> | grep -A 5 "Limits"

# May need to adjust resource limits in deployment
```

---

## 🎓 Advanced: Custom Metrics

### VPA (Vertical Pod Autoscaler)
Uncommented di hpa.yaml. Berguna untuk:
- Right-sizing resource requests/limits
- Vertical scaling (increase CPU/Memory per pod)
- Recommendations

### Custom Metrics
Via Prometheus atau custom metrics API:
```yaml
# Example: scale based on http_requests_per_second
- type: Pods
  pods:
    metric:
      name: http_requests_per_second
    target:
      type: AverageValue
      averageValue: "1000"
```

---

## 📋 Best Practices

✅ **DO:**
- Set resource requests/limits in deployment
- Use minAvailable in PDB > 0
- Monitor HPA events regularly
- Test scaling behavior under load
- Use appropriate thresholds for workload

❌ **DON'T:**
- Set HPA without resource requests
- Set maxReplicas too high (waste resources)
- Ignore metrics-server installation
- Manually scale without planning
- Change HPA during active traffic

---

## 🔄 Update HPA

### Apply changes
```bash
# Edit hpa.yaml and apply
kubectl apply -f hpa.yaml

# Or patch specific value
kubectl patch hpa deepface-backend-hpa -p '{"spec":{"maxReplicas":6}}'
```

### Verify changes
```bash
kubectl get hpa deepface-backend-hpa -o yaml
```

---

## 📊 Example Monitoring

### Watch scaling in action
```bash
# Terminal 1: Watch HPA
kubectl get hpa -w

# Terminal 2: Watch pods
kubectl get pods -w

# Terminal 3: Monitor metrics
watch kubectl top pods -l app=deepface-backend
```

### Generate load (testing)
```bash
# In frontend pod
kubectl exec -it <frontend-pod> -- \
  ab -n 10000 -c 100 http://localhost:3000

# Monitor HPA response
kubectl get hpa -w
```

---

## 📚 Related Files

- [deployment-backend.yaml](deployment-backend.yaml) - Backend deployment
- [deployment-frontend.yaml](deployment-frontend.yaml) - Frontend deployment
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Full guide
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Troubleshooting

---

## 🚀 Quick Start

```bash
# 1. Deploy HPA
kubectl apply -f hpa.yaml

# 2. Check status
kubectl get hpa

# 3. Monitor
kubectl get hpa -w

# 4. View details
kubectl describe hpa deepface-backend-hpa

# 5. Check metrics
kubectl top pods
```

---

**Last Updated**: January 11, 2026
**Status**: ✅ Production Ready
