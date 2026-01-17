// DEPLOYMENT_CHECKLIST.md

# 📋 Deployment Checklist & Quick Reference

## 🎯 Pre-Deployment Requirements

### Environment Setup
- [ ] Kubernetes cluster running (v1.19+)
- [ ] kubectl installed and configured
- [ ] Docker images built and pushed:
  - [ ] shefanny00/deepface-frontend:latest
  - [ ] shefanny00/deepface-backend:latest

### Files Ready
- [ ] deployment-backend.yaml
- [ ] deployment-frontend.yaml
- [ ] deployment-extras.yaml (optional)
- [ ] deploy.sh (optional but recommended)
- [ ] DEPLOYMENT_GUIDE.md (for reference)

---

## 🚀 Deployment Steps

### Step 1: Deploy Backend First
```bash
kubectl apply -f deployment-backend.yaml
```

**Verify Backend**
```bash
# Check deployment
kubectl get deployment deepface-backend

# Check pods
kubectl get pods -l app=deepface-backend

# Check service
kubectl get svc deepface-backend-service

# Wait for ready
kubectl rollout status deployment/deepface-backend
```

### Step 2: Deploy Frontend
```bash
kubectl apply -f deployment-frontend.yaml
```

**Verify Frontend**
```bash
# Check deployment
kubectl get deployment deepface-frontend

# Check pods
kubectl get pods -l app=deepface-frontend

# Get external IP
kubectl get svc deepface-frontend-service

# Wait for ready
kubectl rollout status deployment/deepface-frontend
```

### Step 3: Optional - Deploy Extras
```bash
kubectl apply -f deployment-extras.yaml
```

**Includes:**
- Ingress configuration
- Persistent volumes
- Network policies
- Resource quotas

---

## ✅ Post-Deployment Verification

### Check All Resources
```bash
kubectl get all
```

### Verify Pod Health
```bash
# Backend pods
kubectl get pods -l app=deepface-backend -o wide
kubectl describe pod <backend-pod-name>

# Frontend pods
kubectl get pods -l app=deepface-frontend -o wide
kubectl describe pod <frontend-pod-name>
```

### Test Backend Health
```bash
# Port forward
kubectl port-forward svc/deepface-backend-service 5000:5000

# In another terminal
curl http://localhost:5000/health
curl http://localhost:5000/readiness
```

### Test Frontend Access
```bash
# Get external IP
EXTERNAL_IP=$(kubectl get svc deepface-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Access via browser
echo "http://$EXTERNAL_IP"

# Or port forward
kubectl port-forward svc/deepface-frontend-service 3000:80
# Then access http://localhost:3000
```

### Check HPA Status
```bash
kubectl get hpa
kubectl describe hpa deepface-frontend-hpa
kubectl describe hpa deepface-backend-hpa
```

---

## 🔧 Common Operations

### View Logs
```bash
# Backend logs (follow)
kubectl logs -f deployment/deepface-backend

# Frontend logs (follow)
kubectl logs -f deployment/deepface-frontend

# Specific pod
kubectl logs -f <pod-name>

# Last N lines
kubectl logs --tail=100 deployment/deepface-backend
```

### Manual Scaling
```bash
# Scale backend
kubectl scale deployment deepface-backend --replicas=3

# Scale frontend
kubectl scale deployment deepface-frontend --replicas=4
```

### Update Image
```bash
# Backend
kubectl set image deployment/deepface-backend \
  backend=shefanny00/deepface-backend:latest

# Frontend
kubectl set image deployment/deepface-frontend \
  frontend=shefanny00/deepface-frontend:latest
```

### Restart Deployment
```bash
# Backend
kubectl rollout restart deployment/deepface-backend

# Frontend
kubectl rollout restart deployment/deepface-frontend
```

### Access Pod Shell
```bash
# Get pod name
POD=$(kubectl get pod -l app=deepface-backend -o jsonpath='{.items[0].metadata.name}')

# Access shell
kubectl exec -it $POD -- /bin/bash
```

---

## 🐛 Troubleshooting

### Pod Stuck in Pending
```bash
# Check events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
kubectl describe node <node-name>
```

### Pod Crashing
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs --previous <pod-name>

# Check event
kubectl describe pod <pod-name>
```

### Service Not Accessible
```bash
# Check service
kubectl get svc deepface-frontend-service -o wide

# Check endpoints
kubectl get endpoints deepface-frontend-service

# Test from another pod
kubectl exec -it <pod-name> -- curl deepface-backend-service:5000/health
```

### High Resource Usage
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check pod requests/limits
kubectl describe pod <pod-name>
```

---

## 📊 Monitoring Commands

### Quick Status Check
```bash
# All in one
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get hpa
```

### Detailed Analysis
```bash
# Events
kubectl get events --sort-by='.lastTimestamp'

# Resource usage
kubectl top nodes --containers=true
kubectl top pods -l app=deepface-backend

# Pod status details
kubectl get pods -o wide
kubectl get pods -o yaml
```

### Watch Real-time
```bash
# Watch pods
kubectl get pods -w

# Watch deployments
kubectl get deployment -w

# Watch specific deployment
kubectl get pod -l app=deepface-backend -w
```

---

## 🔒 Security Checks

### Verify Security Policies
```bash
# Network policies
kubectl get networkpolicy

# RBAC roles
kubectl get roles,rolebindings

# Pod security policies
kubectl get psp
```

### Resource Quotas
```bash
# Check quotas
kubectl get resourcequota

# Check usage
kubectl describe resourcequota deepface-quota
```

---

## 📈 Performance Tuning

### Check Current Configuration
```bash
# CPU/Memory allocation
kubectl get deployment -o wide
kubectl describe deployment deepface-backend

# View resource limits
kubectl describe pod <pod-name> | grep -A 5 "Limits"
```

### Adjust Resources
```bash
# Edit deployment
kubectl edit deployment deepface-backend

# Patch deployment
kubectl patch deployment deepface-backend \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","resources":{"limits":{"memory":"2Gi","cpu":"1"}}}]}}}}'
```

---

## 🧹 Cleanup Operations

### Delete Single Component
```bash
# Delete backend only
kubectl delete deployment deepface-backend

# Delete frontend only
kubectl delete deployment deepface-frontend

# Delete services
kubectl delete svc deepface-backend-service deepface-frontend-service
```

### Delete Everything
```bash
# Delete all at once
kubectl delete -f deployment-backend.yaml
kubectl delete -f deployment-frontend.yaml
kubectl delete -f deployment-extras.yaml

# Or via labels
kubectl delete all -l app=deepface-backend
kubectl delete all -l app=deepface-frontend
```

### Backup Before Delete
```bash
# Export current state
kubectl get all -o yaml > backup.yaml
kubectl get deployment -o yaml > deployments-backup.yaml
```

---

## 🚨 Emergency Commands

### Force Delete Stuck Pod
```bash
kubectl delete pod <pod-name> --grace-period=0 --force
```

### Drain Node (for maintenance)
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Re-enable Node
```bash
kubectl uncordon <node-name>
```

---

## 📝 Important Notes

1. **Backend First**: Always deploy backend before frontend
2. **Service Names**: Backend service accessible as `deepface-backend-service:5000` from within cluster
3. **Health Checks**: Configured probes run every 10 seconds by default
4. **Auto-scaling**: HPA will automatically scale pods based on resource usage
5. **Rolling Updates**: Zero-downtime deployments are configured
6. **Persistent Data**: Models are cached in emptyDir (non-persistent)

---

## 🎯 Success Criteria

- [ ] All pods are Running
- [ ] No pods in CrashLoopBackOff
- [ ] Services have endpoints assigned
- [ ] Frontend can communicate with backend
- [ ] Health checks passing
- [ ] External IP assigned to frontend service
- [ ] Can access application from browser
- [ ] HPA showing ready/active status

---

## 📞 Quick Support

**Problem**: Pod won't start
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Problem**: Can't access frontend
```bash
kubectl get svc deepface-frontend-service
# Copy EXTERNAL-IP and access via browser
```

**Problem**: Backend health check failing
```bash
kubectl port-forward svc/deepface-backend-service 5000:5000
curl http://localhost:5000/health
```

**Problem**: Out of resources
```bash
kubectl top nodes
kubectl top pods
# May need to scale down or add more nodes
```

---

## 📚 Documentation Links

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Full detailed guide
- [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) - Overview
- [deployment-backend.yaml](deployment-backend.yaml) - Backend config
- [deployment-frontend.yaml](deployment-frontend.yaml) - Frontend config
- [deployment-extras.yaml](deployment-extras.yaml) - Advanced configs
- [deploy.sh](deploy.sh) - Automation script

---

**Last Updated**: January 11, 2026
**Status**: ✅ Ready for Production
