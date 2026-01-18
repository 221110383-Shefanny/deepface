# ✅ Autoscaling Load Testing - Setup Complete

## 🎉 What's Been Added

Your Deepface deployment now includes **complete autoscaling testing tools** to verify HPA (Horizontal Pod Autoscaler) functionality.

---

## 📦 Files Created

### 1. **load-test-frontend.yaml** - Kubernetes Load Test Pods
Contains two simple load generator pods:
- `load-test-frontend` - Sends requests to frontend service
- `load-test-backend` - Sends requests to backend health endpoint

**Duration**: 5 minutes each  
**Request Rate**: 1 request/second per pod  
**Total Load**: ~300 requests per service

### 2. **load-test.sh** - Interactive Menu Script
Bash script with interactive menu for easy testing:
- Start frontend load test
- Start backend load test
- Light load (gentle testing)
- Heavy load (aggressive stress test)
- Watch HPA status in real-time
- Stop all tests
- View HPA details

### 3. **AUTOSCALING_TEST_GUIDE.md** - Complete Documentation
Comprehensive guide including:
- Quick start instructions
- Step-by-step load testing procedures
- Real-time metrics monitoring
- Troubleshooting section
- Advanced testing options
- Success criteria

---

## 🚀 Quick Start (2 minutes)

### Option 1: Simple Test
```bash
# Deploy load test pods
kubectl apply -f load-test-frontend.yaml

# Watch in another terminal
kubectl get hpa -A --watch

# After 5 minutes, watch pods scale back down
```

### Option 2: Interactive Menu
```bash
bash load-test.sh
```
Then choose:
- Option 1: Frontend test
- Option 6: Watch HPA status

---

## 📊 Current Setup

### HPA Configuration
| Component | Min | Max | CPU Threshold | Memory Threshold |
|-----------|-----|-----|---|---|
| **Backend** | 2 | 4 | 60% | 75% |
| **Frontend** | 2 | 5 | 70% | 80% |

### Resource Requests/Limits
| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|---|---|---|---|
| **Backend** | 100m | 500m | 512Mi | 2Gi |
| **Frontend** | 100m | 500m | 128Mi | 512Mi |

---

## 🧪 Testing Scenarios

### Scenario 1: Light Load (3 minutes)
**Purpose**: Verify autoscaling is working without overload
```bash
kubectl run -it load-light --image=curlimages/curl --restart=Never -- sh -c \
"for i in {1..180}; do curl -s http://deepface-frontend-service/ > /dev/null; sleep 1; done"
```

**Expected Result**: 
- Minimal scaling (usually stays at min replicas)
- CPU usage: 20-40%

---

### Scenario 2: Normal Load (5 minutes)
**Purpose**: Typical scaling behavior
```bash
kubectl apply -f load-test-frontend.yaml
```

**Expected Result**:
- Scale up to 3-4 replicas
- CPU usage: 50-70%
- 1-2 scaling events

---

### Scenario 3: Heavy Load (5 minutes)
**Purpose**: Maximum scaling test
```bash
kubectl run -it load-heavy --image=curlimages/curl --restart=Never -- sh -c \
"for i in {1..300}; do for j in {1..10}; do curl -s http://deepface-frontend-service/ > /dev/null & done; sleep 1; done"
```

**Expected Result**:
- Scale up to max replicas (5 for frontend, 4 for backend)
- CPU usage: 80-100%
- Multiple scaling events

---

## 👁️ Monitoring During Load Test

### Terminal 1: Watch HPA Status
```bash
kubectl get hpa -A --watch
```

### Terminal 2: Watch Pod Replicas
```bash
kubectl get pods -l app=deepface-frontend --watch
```

### Terminal 3: Monitor Resource Usage
```bash
watch kubectl top pods
```

### Terminal 4: View Events
```bash
kubectl get events --sort-by='.lastTimestamp'
```

---

## ✅ Verification Checklist

After running a load test, verify:
- [ ] HPA replica count increased during load
- [ ] CPU/Memory metrics showed above threshold
- [ ] New pods transitioned: Pending → Running → Ready
- [ ] After load, replicas scaled back to minimum
- [ ] All pods returned to Ready state
- [ ] No pod crashes or restarts

---

## 🔄 How Autoscaling Works

```
┌─────────────────────────────────────────────────────┐
│ 1. Load Test Sends Requests to Service             │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 2. Pods Process Requests, CPU/Memory Increases    │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 3. metrics-server Collects Metrics Every 15s      │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 4. HPA Evaluates Metrics (Every 15s)              │
│    IF: CPU > 70% OR Memory > 80%                  │
│    THEN: Increase replicas                         │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 5. New Pods Created and Scheduled                 │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 6. New Pods Pull Image and Start                  │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 7. Load Distributed Across More Pods              │
│    CPU/Memory per pod decreases                   │
└────────────────┬────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────┐
│ 8. When Load Stops, CPU/Memory Drop               │
│    HPA Scales Down After 5 minutes of low usage   │
└─────────────────────────────────────────────────────┘
```

---

## 📋 Commands Reference

```bash
# Deploy load tests
kubectl apply -f load-test-frontend.yaml

# Watch HPA in real-time
kubectl get hpa -A --watch

# Watch pod scaling
kubectl get pods -l app=deepface-frontend --watch

# Check detailed HPA status
kubectl describe hpa deepface-frontend-hpa

# Monitor CPU/Memory
kubectl top pods

# View metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq

# Delete load test pods
kubectl delete pod load-test-frontend load-test-backend

# Check HPA events
kubectl describe hpa deepface-frontend-hpa | tail -20
```

---

## 🎓 Learning Resources

1. **First Time**: Read [AUTOSCALING_TEST_GUIDE.md](AUTOSCALING_TEST_GUIDE.md) completely
2. **Quick Reference**: Use the commands above
3. **Troubleshooting**: See AUTOSCALING_TEST_GUIDE.md "Troubleshooting" section
4. **Advanced**: Explore custom metrics in the guide

---

## 🛠️ Troubleshooting

### "Pods not scaling up"
```bash
# 1. Check HPA status
kubectl describe hpa deepface-frontend-hpa

# 2. Verify metrics-server is running
kubectl get deployment metrics-server -n kube-system

# 3. Check if pods have resource requests
kubectl get pods -o yaml | grep -A 3 resources:
```

### "Can't see load test output"
```bash
# Check pod logs
kubectl logs load-test-frontend -f

# Check pod status
kubectl describe pod load-test-frontend
```

### "Load test pods stuck"
```bash
# Force delete
kubectl delete pod load-test-frontend --grace-period=0 --force
```

---

## 📊 Expected Timeline

**During Heavy Load Test** (from start to ~5 min):

| Time | Event |
|------|-------|
| T+0m | Load starts (300 requests/min) |
| T+1m | CPU metrics start rising |
| T+2m | HPA detects CPU > threshold |
| T+3m | **First scale-up event** → 3 replicas |
| T+4m | Metrics stabilize at 2-4 replicas |
| T+5m | Load stops, CPU drops |
| T+6m | HPA begins scale-down |
| T+10m | Back to 2 replicas (minimum) |

---

## 🎯 Success Criteria

Your autoscaling is working when:
- ✅ Replicas increase during load test
- ✅ CPU/Memory metrics climb
- ✅ New pods are created and become Ready
- ✅ After load ends, metrics drop
- ✅ Replicas scale back down

---

## 📝 Next Steps

1. **Run a light load test** (3 min) - Verify basic functionality
2. **Run a normal load test** (5 min) - See typical scaling behavior  
3. **Run a heavy load test** (5 min) - See maximum scaling
4. **Monitor in Grafana** - Create dashboard for scaling metrics
5. **Test failure scenarios** - Kill a pod and watch HPA recover

---

**Status**: ✅ **Ready to test autoscaling!**

For detailed instructions, see [AUTOSCALING_TEST_GUIDE.md](AUTOSCALING_TEST_GUIDE.md)

Happy load testing! 🚀
