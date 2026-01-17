# Quick Start Guide - Access Monitoring Dashboard

## 🚀 Getting Started (5 minutes)

### Step 1: Access Grafana
```
URL: http://192.168.49.2:31620
Username: admin
Password: admin
```

### Step 2: Change Password (Recommended)
1. Click profile icon (top-right) → Change password
2. Set a secure password
3. Click "Update Password"

### Step 3: Add Prometheus Data Source
1. Left sidebar → Connections → Data sources
2. Click "Add data source"
3. Select "Prometheus"
4. URL: `http://prometheus:9090`
5. Click "Save & test"
6. Should show "✅ 1 metrics found"

---

## 📊 Setup Pre-built Kubernetes Dashboards

### Import Dashboard Steps:
1. Left sidebar → Dashboards → New → Import
2. Enter dashboard ID
3. Select Prometheus as data source
4. Click "Import"

### Recommended Dashboards:

#### 1. Node Exporter (ID: 1860)
Shows node-level metrics:
- CPU, Memory, Disk, Network
- System load
- Swap usage
- File descriptors

**Steps**: Import ID 1860 → Review node metrics

#### 2. Kubernetes Cluster Monitoring (ID: 6417)
Shows cluster overview:
- Pod count by namespace
- Node status
- Container restarts
- Network I/O

**Steps**: Import ID 6417 → Monitor cluster health

#### 3. Kubernetes Deployments (ID: 8588)
Shows deployment metrics:
- Desired vs actual replicas
- Pod ready status
- Restart count
- CPU/Memory by deployment

**Steps**: Import ID 8588 → Track deployments

---

## 🎯 Create Custom Dashboard for Deepface

### Dashboard: "Deepface Monitoring"

#### Panel 1: Backend Replicas (Graph)
**Query**: `kube_deployment_status_replicas{deployment="deepface-backend"}`
- Shows desired, updated, available replicas
- Red if mismatch

#### Panel 2: Frontend Replicas (Graph)
**Query**: `kube_deployment_status_replicas{deployment="deepface-frontend"}`
- Shows frontend pod status
- Watch for scale-up/down events

#### Panel 3: Backend CPU Usage (Graph)
**Query**: `sum(rate(container_cpu_usage_seconds_total{pod=~"deepface-backend.*"}[5m])) by (pod)`
- CPU per backend pod
- Horizontal line at 60% (HPA threshold)

#### Panel 4: Backend Memory Usage (Graph)
**Query**: `sum(container_memory_usage_bytes{pod=~"deepface-backend.*"}) by (pod) / 1024 / 1024`
- Memory per backend pod (in MB)
- Horizontal line at 75% of limit (384MB)

#### Panel 5: Frontend CPU Usage (Graph)
**Query**: `sum(rate(container_cpu_usage_seconds_total{pod=~"deepface-frontend.*"}[5m])) by (pod)`
- CPU per frontend pod
- Horizontal line at 70% (HPA threshold)

#### Panel 6: Frontend Memory Usage (Graph)
**Query**: `sum(container_memory_usage_bytes{pod=~"deepface-frontend.*"}) by (pod) / 1024 / 1024`
- Memory per frontend pod (in MB)
- Horizontal line at 80% of limit (102MB)

#### Panel 7: Pod Restart Count (Stat)
**Query**: `sum(kube_pod_container_status_restarts_total{namespace="default"})`
- Should be 0 (no restarts)
- Red alert if > 0

#### Panel 8: Active Connections (Stat)
**Query**: `sum(rate(container_network_transmit_packets_total{pod=~"deepface-(backend|frontend).*"}[5m]))`
- Network activity trend
- Green if stable

---

## 🔍 Prometheus Queries (PromQL)

### Quick Queries to Try:

#### 1. Check if all targets are up
```promql
up
```
Shows all scrape targets and their status (1=up, 0=down)

#### 2. Pod CPU usage
```promql
sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace, pod)
```

#### 3. Pod Memory usage
```promql
sum(container_memory_usage_bytes) by (namespace, pod) / 1024 / 1024
```

#### 4. HPA target replicas
```promql
kube_horizontalpodautoscaler_status_desired_replicas
```

#### 5. Pod restart count
```promql
kube_pod_container_status_restarts_total
```

#### 6. Network I/O
```promql
rate(container_network_receive_bytes_total[5m])
```

#### 7. Disk I/O
```promql
rate(container_fs_writes_bytes_total[5m])
```

---

## 📈 Monitor Autoscaling in Action

### Watch HPA Scale-Up:
1. Open Grafana dashboard
2. Add metric: `kube_deployment_status_replicas{deployment="deepface-backend"}`
3. Generate load (hit frontend multiple times)
4. Watch backend replicas increase

### Generate Load:
```bash
# Simple curl loop
for i in {1..100}; do
  curl -s http://192.168.49.2:31265 > /dev/null &
done
wait
```

### View HPA Status:
```bash
kubectl get hpa -w  # Watch mode

# Or detailed:
kubectl describe hpa deepface-backend-hpa
```

---

## 🎨 Grafana Tips & Tricks

### Dark Mode
- Profile → Preferences → Theme → Dark
- Save changes

### Refresh Rate
- Dashboard settings (gear icon) → Refresh interval
- Set to 5s, 10s, or 30s
- Or auto-refresh toggle

### Time Range
- Top-right corner
- Quick options: Last 5m, 15m, 1h, 6h, 24h
- Or custom date range

### Export Dashboard
- Dashboard settings → Export
- Download JSON
- Share with team

### Set as Home Dashboard
- Star icon → Set as home

### Pin Panel
- Panel menu (top-right) → Pin

---

## 🔔 Alert Setup (Optional)

### Create Alert Rule:
1. Dashboard → Panel edit → Alert
2. Set condition: "when backend CPU > 80%"
3. Set for: "for 5 minutes"
4. Set notification channel
5. Save panel

### Example Alert Queries:
```promql
# Backend overloaded
avg(rate(container_cpu_usage_seconds_total{pod=~"deepface-backend.*"}[5m])) > 0.8

# Frontend pods restarting
rate(kube_pod_container_status_restarts_total{pod=~"deepface-frontend.*"}[5m]) > 0.1

# Low memory available
(1 - (sum(container_memory_usage_bytes) / (6 * 1024 * 1024 * 1024))) < 0.2
```

---

## 📊 Common Dashboards to Create

### 1. Service Health Dashboard
- Pod status (running/failing)
- Service endpoints status
- Recent restarts
- Error rates

### 2. Performance Dashboard
- Response times (if exposed)
- Throughput (requests/sec)
- Error rate
- P95/P99 latency

### 3. Infrastructure Dashboard
- Node CPU/Memory
- Disk usage
- Network throughput
- System load

### 4. Scaling Dashboard
- HPA current/target replicas
- CPU/Memory trending
- Scaling events
- Autoscaler status

---

## 🔗 Useful Grafana URLs

| Feature | URL |
|---------|-----|
| Explore | http://192.168.49.2:31620/explore |
| Dashboards | http://192.168.49.2:31620/dashboards |
| Alerts | http://192.168.49.2:31620/alerting/list |
| Data sources | http://192.168.49.2:31620/connections/datasources |
| Admin | http://192.168.49.2:31620/admin |
| Profile | http://192.168.49.2:31620/profile |

---

## ⚠️ Common Issues & Solutions

### "No data" in panel
- Check time range (top-right)
- Verify query syntax in Prometheus
- Ensure Prometheus datasource is connected
- Check pod labels match query

### Prometheus shows red
- Verify URL is correct: `http://prometheus:9090`
- Check Prometheus pod is running: `kubectl get pods -n monitoring`
- View Prometheus logs: `kubectl logs -n monitoring -l app=prometheus`

### Grafana showing old data
- Hard refresh: Ctrl+Shift+R
- Clear cache: Settings → Dashboards → Clear dashboard cache
- Increase refresh rate

### Cannot access Minikube IP
- Get correct IP: `minikube ip`
- Verify port: `kubectl get svc -n monitoring`
- Try tunnel: `minikube tunnel`

---

## 🚀 Next Level Monitoring

### Add Custom Metrics from App
Export metrics from deepface backend:
```python
from prometheus_client import Counter, Histogram, Gauge

face_matches = Counter('face_matches_total', 'Total face matches', ['status'])
verification_time = Histogram('verification_time_seconds', 'Verification duration')
cache_size = Gauge('cache_size_bytes', 'Cache size in bytes')

# In your verification endpoint:
face_matches.labels(status='success').inc()
verification_time.observe(elapsed_time)
```

### Expose in FastAPI:
```python
from prometheus_client import make_wsgi_app
from starlette.middleware.wsgi import WSGIMiddleware

app.add_middleware(WSGIMiddleware, app=make_wsgi_app())
```

Then update Prometheus scrape config to include your app's `/metrics` endpoint.

---

**Quick Reference Card**: Save this page bookmark! 🔖

Access Grafana: **http://192.168.49.2:31620**
Access Prometheus: **http://192.168.49.2:30095**
Default Password: **admin**
