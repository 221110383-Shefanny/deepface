# 🚀 Autoscaling Load Testing Guide

## Overview
This guide shows how to generate load and test the Horizontal Pod Autoscaler (HPA) in your Deepface deployment.

---

## 📋 Prerequisites

✅ Kubernetes cluster running with:
- Deepface backend & frontend deployments
- HPA configured for both services
- metrics-server enabled
- kubectl installed

---

## 🔥 Quick Start (1 minute)

### Option 1: Using Interactive Menu (Recommended)
```bash
# Windows PowerShell
bash load-test.sh

# Or make it executable first
chmod +x load-test.sh
./load-test.sh
```

### Option 2: Direct Commands

#### Start Frontend Load Test
```bash
kubectl apply -f load-test-frontend.yaml
```

#### Start Backend Load Test
```bash
kubectl apply -f load-test-backend.yaml
```

#### Watch HPA Scaling
```bash
kubectl get hpa -A --watch
```

---

## 📊 What You'll See

### Before Load Test
```
NAMESPACE   NAME                    REFERENCE                      TARGETS              MINPODS   MAXPODS   REPLICAS
default     deepface-backend-hpa    Deployment/deepface-backend    cpu: 3%/60%...       2         4         2
default     deepface-frontend-hpa   Deployment/deepface-frontend   cpu: 1%/70%...       2         5         2
```

### During Load Test (Watch the numbers change!)
```
NAMESPACE   NAME                    REFERENCE                      TARGETS                MINPODS   MAXPODS   REPLICAS
default     deepface-backend-hpa    Deployment/deepface-backend    cpu: 65%/60%...        2         4         3 ⬆️
default     deepface-frontend-hpa   Deployment/deepface-frontend   cpu: 72%/70%...        2         5         3 ⬆️
```

### After Load Test (Scale back down)
```
NAMESPACE   NAME                    REFERENCE                      TARGETS              MINPODS   MAXPODS   REPLICAS
default     deepface-backend-hpa    Deployment/deepface-backend    cpu: 5%/60%...       2         4         2 ⬇️
default     deepface-frontend-hpa   Deployment/deepface-frontend   cpu: 2%/70%...       2         5         2 ⬇️
```

---

## 🧪 Load Test Options

### 1. Frontend Load Test
Sends HTTP requests to the frontend service (http://deepface-frontend-service:80)
```bash
kubectl apply -f load-test-frontend.yaml
```

**Duration**: 5 minutes  
**Request Rate**: 1 request/sec  
**Total Requests**: ~300  
**Target**: HTML page requests

---

### 2. Backend Load Test
Sends requests to backend health endpoint (http://deepface-backend-service:5000/health)
```bash
kubectl apply -f load-test-backend.yaml
```

**Duration**: 5 minutes  
**Request Rate**: 1 request/sec  
**Total Requests**: ~300  
**Target**: Health check endpoint

---

### 3. Light Load Test (Gentle)
For testing with low stress
```bash
kubectl run -it load-light --image=curlimages/curl --restart=Never -- sh -c \
"for i in {1..180}; do 
  curl -s http://deepface-frontend-service/ > /dev/null &
  [ \$((i % 30)) -eq 0 ] && echo \"[Load: \$i]\"; 
  sleep 1
done"
```

**Duration**: 3 minutes  
**Request Rate**: 1 request/sec  
**Expected Behavior**: Minimal scaling, stay near min replicas

---

### 4. Heavy Load Test (Aggressive Stress)
For maximum scaling
```bash
kubectl run -it load-heavy --image=curlimages/curl --restart=Never -- sh -c \
"for i in {1..300}; do 
  for j in {1..10}; do
    curl -s http://deepface-frontend-service/ > /dev/null &
  done
  sleep 1
done"
```

**Duration**: 5 minutes  
**Request Rate**: 10 requests/sec (concurrent)  
**Total Requests**: ~3000  
**Expected Behavior**: Aggressive scale-up to max replicas, then scale-down

---

## 👁️ Monitoring Autoscaling

### Real-Time HPA Watch
```bash
kubectl get hpa -A --watch
```

### Get Detailed HPA Status
```bash
# Backend HPA
kubectl describe hpa deepface-backend-hpa

# Frontend HPA
kubectl describe hpa deepface-frontend-hpa
```

### Watch Pod Replicas Change
```bash
# Monitor backend pods
kubectl get pods -l app=deepface-backend --watch

# Monitor frontend pods
kubectl get pods -l app=deepface-frontend --watch
```

### Monitor Resource Usage
```bash
# Real-time metrics
kubectl top pods

# Watch metrics over time
watch kubectl top pods
```

---

## 📈 HPA Configuration Details

### Backend HPA
```yaml
minReplicas: 2
maxReplicas: 4
CPU Target: 60%
Memory Target: 75%
```

### Frontend HPA
```yaml
minReplicas: 2
maxReplicas: 5
CPU Target: 70%
Memory Target: 80%
```

---

## 🔄 Scale-Up Timeline

Typically, you'll see this sequence:

| Time | Event |
|------|-------|
| T+0s | Load test starts |
| T+30s | CPU/Memory metrics start climbing |
| T+60s | HPA detects high utilization |
| T+90s | **First scale-up event** (replica count increases) |
| T+120s | New pods become ready |
| T+150s-300s | May scale up further if load continues |
| T+300s | Load test ends |
| T+360s | CPU metrics drop |
| T+420s | HPA initiates scale-down |
| T+480s | **Pods terminated**, back to minimum replicas |

---

## 🛑 Stopping Load Tests

### Delete All Load Test Pods
```bash
kubectl delete pod load-test-frontend load-test-backend load-light load-heavy --ignore-not-found=true
```

### Force Stop (if hung)
```bash
kubectl delete pod load-test-frontend load-test-backend load-light load-heavy --grace-period=0 --force
```

---

## 📊 Metrics to Watch

### CPU Metrics
- **Request**: `100m` (backend), `100m` (frontend)
- **Limit**: `500m` (backend), `500m` (frontend)
- **HPA Trigger**: Backend 60%, Frontend 70%

### Memory Metrics
- **Request**: `512Mi` (backend), `128Mi` (frontend)
- **Limit**: `2Gi` (backend), `512Mi` (frontend)
- **HPA Trigger**: Backend 75%, Frontend 80%

### Expected Behavior During Load
```
Light Load (3 min):
  → CPU: 20-40%
  → Status: Usually stays at min replicas
  → Scaling: Minimal or none

Normal Load (5 min):
  → CPU: 50-70%
  → Status: Scale up to 3-4 replicas
  → Scaling: 1-2 scale-up events

Heavy Load (5 min):
  → CPU: 80-100%
  → Status: Scale up to max replicas (4-5)
  → Scaling: Multiple scale-up events
```

---

## 🔍 Troubleshooting

### Issue: Pods not scaling
**Solutions**:
```bash
# Check HPA status
kubectl describe hpa deepface-frontend-hpa

# Verify metrics-server is running
kubectl get deployment metrics-server -n kube-system

# Check if pods have resource requests
kubectl get pods -o json | grep -A 5 "resources:"

# View HPA events
kubectl get events --sort-by='.lastTimestamp'
```

### Issue: Load test pods stuck
**Solutions**:
```bash
# View pod logs
kubectl logs load-test-frontend

# Delete and recreate
kubectl delete pod load-test-frontend --grace-period=0 --force
kubectl apply -f load-test-frontend.yaml
```

### Issue: No CPU metrics showing
**Solutions**:
```bash
# Verify metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server

# Restart metrics-server
kubectl rollout restart deployment metrics-server -n kube-system

# Wait for metrics to populate (takes ~1 min)
sleep 60
kubectl top pods
```

---

## 🎓 Learning Path

1. **First Run**: Use Light Load to see if autoscaling works
2. **Second Run**: Use Normal Load to see typical behavior
3. **Third Run**: Use Heavy Load to see maximum scaling
4. **Advanced**: Monitor logs and events during scaling

---

## 🚀 Advanced: Custom Load Tests

### Using Apache Bench (ab)
```bash
kubectl run -it load-ab --image=httpd --restart=Never -- sh -c \
"ab -n 10000 -c 50 http://deepface-frontend-service/"
```

### Using wrk (Load Testing Tool)
```bash
kubectl run -it load-wrk --image=williamyeh/wrk --restart=Never -- sh -c \
"wrk -t4 -c100 -d5m http://deepface-frontend-service/"
```

### Custom Python Load Generator
```bash
kubectl run -it load-python --image=python:3.9 --restart=Never -- sh -c \
"pip install requests && python -c \"
import requests
import concurrent.futures

def make_request():
    requests.get('http://deepface-frontend-service/')

with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    executor.map(make_request, range(1000))
\""
```

---

## ✅ Success Criteria

You've successfully tested autoscaling when:
- ✅ HPA replicas increase during load test
- ✅ CPU/Memory usage climbs above thresholds
- ✅ New pods transition from Pending → Running → Ready
- ✅ After load stops, replicas scale back down
- ✅ All pods return to Ready state

---

## 📝 Quick Reference

```bash
# Start load tests
kubectl apply -f load-test-frontend.yaml
kubectl apply -f load-test-backend.yaml

# Watch scaling
kubectl get hpa -A --watch

# Monitor pods
kubectl get pods -l app=deepface-frontend --watch

# Monitor metrics
kubectl top pods

# Stop tests
kubectl delete pod load-test-frontend load-test-backend

# Check HPA details
kubectl describe hpa deepface-frontend-hpa
```

---

**Happy scaling!** 🎉

For more help: See [MONITORING_SETUP.md](../MONITORING_SETUP.md)
