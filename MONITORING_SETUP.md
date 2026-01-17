# Monitoring Stack Setup - Prometheus + Grafana + kube-state-metrics

## ✅ Deployment Status

All monitoring components successfully deployed to Minikube Kubernetes cluster:

### Running Services
- **Prometheus**: 1/1 Running ✅
- **Grafana**: 1/1 Running ✅
- **kube-state-metrics**: 1/1 Running ✅

### HPA Monitoring Active
- **Backend HPA**: 2-4 replicas, tracking CPU/Memory metrics ✅
- **Frontend HPA**: 2-5 replicas, tracking CPU/Memory metrics ✅

---

## 🌐 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://192.168.49.2:31620 | admin / admin |
| **Prometheus** | http://192.168.49.2:30095 | N/A |
| **Frontend App** | http://192.168.49.2:31265 | N/A |
| **Backend API** | http://deepface-backend-service:5000 | Internal ClusterIP |

---

## 📊 Monitoring Architecture

### Prometheus
- **Role**: Metrics collection and storage
- **Port**: 9090 (LoadBalancer on 30095)
- **Config**: Monitors Kubernetes cluster, pods, services, nodes
- **Scrape Interval**: 15 seconds
- **Data Retention**: Temporary (emptyDir volume)
- **Location**: `monitoring/prometheus-deployment.yaml`

### Grafana
- **Role**: Visualization and dashboards
- **Port**: 3000 (LoadBalancer on 31620)
- **Default Admin**: admin / admin
- **Datasource**: Prometheus (http://prometheus:9090)
- **Storage**: Temporary (emptyDir volume)
- **Location**: `monitoring/grafana-deployment.yaml`

### kube-state-metrics
- **Role**: Kubernetes resource state metrics exporter
- **Port**: 8080 (ClusterIP)
- **Metrics**: Deployments, pods, nodes, HPA, services, etc.
- **Storage**: None (stateless)
- **Location**: `monitoring/kube-state-metrics-deployment.yaml`

---

## 🔧 Configuration Files

### 1. Prometheus ConfigMap
**File**: `monitoring/prometheus-config.yaml`
```yaml
- Kubernetes cluster discovery (nodes, pods, services)
- Scrape configs for all resource types
- 15-second scrape interval
- 15-second evaluation interval
```

### 2. Prometheus Deployment
**File**: `monitoring/prometheus-deployment.yaml`
```yaml
- RBAC: ClusterRole + ServiceAccount
- Namespace: monitoring
- CPU: 100m request / 500m limit
- Memory: 256Mi request / 512Mi limit
- Service: LoadBalancer on port 9090
```

### 3. Grafana Deployment
**File**: `monitoring/grafana-deployment.yaml`
```yaml
- Namespace: monitoring (created by Prometheus)
- Admin Password: admin
- CPU: 100m request / 200m limit
- Memory: 128Mi request / 256Mi limit
- Service: LoadBalancer on port 3000
```

### 4. kube-state-metrics Deployment
**File**: `monitoring/kube-state-metrics-deployment.yaml`
```yaml
- RBAC: ClusterRole + ServiceAccount
- Namespace: monitoring
- CPU: 100m request / 200m limit
- Memory: 128Mi request / 256Mi limit
- Service: ClusterIP on port 8080
```

---

## 🚀 Setup Summary

### Step 1: Applied Prometheus Deployment
```bash
kubectl apply -f monitoring/prometheus-deployment.yaml
# Creates: namespace/monitoring, clusterrole, clusterrolebinding, serviceaccount, deployment, service
```

### Step 2: Applied Grafana Deployment
```bash
kubectl apply -f monitoring/grafana-deployment.yaml
# Creates: deployment, service in monitoring namespace
```

### Step 3: Applied kube-state-metrics
```bash
kubectl apply -f monitoring/kube-state-metrics-deployment.yaml
# Creates: deployment, service, serviceaccount, clusterrole, clusterrolebinding
```

### Step 4: Applied Prometheus Config
```bash
kubectl apply -f monitoring/prometheus-config.yaml
# Creates: configmap/prometheus-config in monitoring namespace
# Fixed: Pod restart to mount ConfigMap
```

---

## 📈 Metrics Available

### From Prometheus
- Kubernetes API server metrics
- Node metrics (CPU, Memory, Disk, Network)
- Container metrics
- Pod metrics
- Service metrics
- Custom application metrics (if exported)

### From kube-state-metrics
- Deployment replicas and desired state
- Pod status (Running, Pending, Failed)
- HPA current/desired replicas
- Node status
- PersistentVolume metrics
- Service endpoints

---

## ⚙️ Next Steps

### 1. Configure Grafana Datasource (First Login)
```
1. Login: http://192.168.49.2:31620
2. Username: admin
3. Password: admin
4. Skip/Set new password
5. Go to: Connections → Data sources → Add data source
6. Select: Prometheus
7. URL: http://prometheus:9090
8. Click: Save & Test
```

### 2. Import Kubernetes Dashboards
In Grafana:
- Go to: Dashboards → New → Import
- Import ID: 1860 (Node Exporter Full)
- Import ID: 6417 (Kubernetes Cluster Monitoring)
- Import ID: 8588 (Kubernetes Deployment Statefulset Daemonset Metrics)

### 3. Create Custom Dashboards
Monitor your deepface deployment:
- Backend Pod Replicas
- Frontend Pod Replicas
- HPA metrics (Target Replicas, Current Replicas)
- CPU/Memory usage by pod
- Request latency
- Error rates

---

## 🔍 Kubernetes Service Discovery

### Prometheus automatically scrapes:
- **kubernetes-cluster**: All nodes
- **kubernetes-pods**: All pods across namespaces
- **kubernetes-services**: All services
- **kubernetes-nodes**: Detailed node metrics

### Labels attached to metrics:
- `namespace`: Pod namespace
- `pod`: Pod name
- `container`: Container name
- `node`: Node name
- `service`: Service name
- `job`: Kubernetes role (pod, node, service)

---

## 📝 Troubleshooting

### Issue: Prometheus stays in ContainerCreating
**Solution**: 
```bash
# Check if ConfigMap exists
kubectl get configmap -n monitoring

# If missing, apply it:
kubectl apply -f monitoring/prometheus-config.yaml

# Restart pod:
kubectl delete pod -l app=prometheus -n monitoring
```

### Issue: Grafana showing no data
**Solution**:
```bash
# Verify Prometheus is accessible from Grafana pod
kubectl exec -it <grafana-pod> -n monitoring -- curl http://prometheus:9090/api/v1/query?query=up

# Verify data in Prometheus
kubectl exec -it <prometheus-pod> -n monitoring -- curl http://localhost:9090/api/v1/query?query=up
```

### Issue: Cannot access services from outside
**Solution**:
```bash
# Check services
kubectl get svc -n monitoring

# Use minikube service command
minikube service prometheus -n monitoring
minikube service grafana -n monitoring
```

---

## 🗑️ Cleanup

To remove monitoring stack:
```bash
kubectl delete ns monitoring
# Removes all resources in monitoring namespace
```

To remove specific component:
```bash
kubectl delete deployment prometheus -n monitoring
kubectl delete deployment grafana -n monitoring
kubectl delete deployment kube-state-metrics -n monitoring
```

---

## 📊 System Overview

```
┌─────────────────────────────────────────┐
│  Kubernetes Cluster (Minikube v1.34.0) │
├─────────────────────────────────────────┤
│                                         │
│  DEFAULT NAMESPACE:                     │
│  ├─ deepface-backend (2 pods)          │
│  ├─ deepface-frontend (2 pods)         │
│  ├─ HPA for both                       │
│  └─ Services (ClusterIP + LoadBalancer)│
│                                         │
│  MONITORING NAMESPACE:                  │
│  ├─ Prometheus (1 pod)                 │
│  ├─ Grafana (1 pod)                    │
│  ├─ kube-state-metrics (1 pod)         │
│  └─ Services (LoadBalancer + ClusterIP)│
│                                         │
│  METRICS-SERVER (system addon):         │
│  └─ Provides pod/node metrics to HPA   │
│                                         │
└─────────────────────────────────────────┘

Data Flow:
  Prometheus Scraper → kube-state-metrics (Kubernetes resources)
  Prometheus Scraper → Kubernetes API (nodes, pods, endpoints)
  Grafana → Prometheus (time-series queries)
  HPA Controller → metrics-server (CPU/Memory for autoscaling)
```

---

**Deployment Date**: 2026-01-17
**Status**: ✅ All systems operational
**Next**: Configure Grafana dashboards and set up alerts
