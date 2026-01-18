# 📹 Video Recording Checklist - What to Explain

## Kriteria yang Harus Dipenuhi

✅ **[x] Merekam video penjelasan implementasi Kubernetes/OpenShift**
✅ **[x] Merekam video penjelasan HPA, CI/CD, dan monitoring tool**

---

## 🎬 STRUKTUR VIDEO YANG DIREKOMENDASIKAN

### VIDEO 1: Kubernetes Implementation (20 menit)
**Apa yang dijelaskan:**
- Architecture: Minikube cluster dengan 4 CPU, 6GB RAM
- Deployment files (backend.yaml, frontend.yaml)
- Services: ClusterIP (backend), LoadBalancer (frontend)
- Pods, containers, dan resource requests/limits
- Health checks (liveness & readiness probes)
- Volume mounts dan environment variables
- RBAC untuk monitoring

**Demo Live:**
- `kubectl get deployment, pods, svc`
- `kubectl describe pod`
- `kubectl port-forward` ke frontend

---

### VIDEO 2: HPA & Autoscaling (20 menit)
**Apa yang dijelaskan:**
- Horizontal Pod Autoscaler (HPA) fundamentals
- HPA configuration: min/max replicas, CPU/Memory thresholds
- Backend HPA: 2-4 replicas, 60% CPU / 75% Memory
- Frontend HPA: 2-5 replicas, 70% CPU / 80% Memory
- Metrics collection via metrics-server
- HPA scaling algorithm & decision flow
- Troubleshooting: metrics missing, stuck scaling

**Demo Live:**
- `kubectl get hpa -A --watch`
- Deploy load generator: `kubectl create deployment backend-load --replicas=20`
- Watch pods scale: 2 → 3 → 4 replicas
- Monitor metrics: `kubectl top pods`
- Show HPA events: `kubectl describe hpa`

---

### VIDEO 3: CI/CD Pipeline (20 menit)
**Apa yang dijelaskan:**
- GitHub Actions workflow (`.github/workflows/docker.yml`)
- 6 Jobs dalam pipeline:
  1. Backend testing (pytest + flake8)
  2. Frontend testing (ESLint + npm)
  3. Build Docker images
  4. Security scan (Trivy)
  5. Deploy to Kubernetes
  6. Notify on completion
- Secrets configuration (DOCKER_USERNAME, KUBE_CONFIG)
- Docker image building & pushing
- Kubernetes rolling update deployment
- Health check validation

**Demo Live:**
- Show workflow file
- Trigger pipeline: `git push origin master`
- Show GitHub Actions dashboard
- Watch tests running
- Show Docker images on Docker Hub
- Show pods updating in Kubernetes

---

### VIDEO 4: Monitoring Tools (20 menit)
**Apa yang dijelaskan:**
- Monitoring architecture: Prometheus → Grafana
- Prometheus: metrics scraper (9090)
- Grafana: dashboards & visualization (3000)
- kube-state-metrics: Kubernetes resource exporter
- What gets monitored:
  - Pod CPU/Memory
  - Deployment replicas
  - HPA status
  - Node metrics
- Pre-built dashboards (IDs: 1860, 6417, 8588)
- Custom dashboard: "Deepface Monitoring"
- PromQL queries examples
- Alert setup (optional)

**Demo Live:**
- Access Prometheus: `kubectl port-forward svc/prometheus -n monitoring 9090:9090`
- Query metrics: `up`, `kube_pod_info`
- Access Grafana: `kubectl port-forward svc/grafana -n monitoring 3000:3000`
- Show pre-built dashboards
- Show custom panels
- Trigger load test and watch metrics change

---

## 📋 DETAILED CONTENT BREAKDOWN

### KUBERNETES (25+ subtopics)
1. What is Kubernetes & why use it?
2. Minikube vs Production
3. Cluster architecture
4. Master & Worker nodes
5. Pod fundamentals
6. Container specifications
7. Resource requests vs limits
8. CPU units (millicores)
9. Memory units (Mi, Gi)
10. Health probes (liveness, readiness)
11. Services (ClusterIP, LoadBalancer)
12. Service DNS resolution
13. Endpoint discovery
14. Volume types (emptyDir)
15. Environment variables
16. ConfigMaps
17. RBAC (Roles, RoleBindings)
18. ServiceAccounts
19. Namespaces
20. Deployment strategy (Rolling update)
21. Pod lifecycle (Pending → Running → Ready)
22. Termination & cleanup
23. Pod restart policy
24. Image pulling
25. Port mapping

### HPA (20+ subtopics)
1. What is HPA?
2. Horizontal vs Vertical scaling
3. Metrics-server
4. CPU metrics collection
5. Memory metrics collection
6. Metric aggregation
7. Utilization calculation
8. Threshold comparison
9. Scale-up decision
10. Scale-down decision
11. Min/Max replicas
12. Cool-down periods
13. Target replicas formula
14. Rapid scaling prevention
15. Resource requests dependency
16. Pod disruption budgets
17. HPA status interpretation
18. Events & monitoring
19. Troubleshooting common issues
20. Load testing

### CI/CD (20+ subtopics)
1. What is CI/CD?
2. Benefits of automation
3. GitHub Actions
4. Workflow triggers (push, PR, manual)
5. Jobs & steps
6. Environment variables
7. Secrets management
8. Conditional execution
9. Matrix builds
10. Caching strategies
11. Docker registry login
12. Docker build commands
13. Multi-stage builds
14. Image tagging
15. Image pushing
16. Kubernetes credentials
17. kubectl configuration
18. Rolling updates
19. Health checks validation
20. Failure handling

### MONITORING (20+ subtopics)
1. Why monitoring matters
2. Prometheus architecture
3. Scrape targets
4. Scrape intervals
5. Metric types
6. Time-series data
7. Data retention
8. kube-state-metrics
9. Kubernetes metrics
10. Pod metrics
11. Node metrics
12. Deployment metrics
13. HPA metrics
14. Grafana dashboards
15. Dashboard creation
16. Panel types
17. PromQL queries
18. Query examples
19. Alert rules
20. Notification channels

---

## 🎥 PRODUCTION ASSETS NEEDED

### Files to Show
```
├── .github/workflows/docker.yml          ← CI/CD Pipeline
├── deployment-backend.yaml               ← Backend K8s
├── deployment-frontend.yaml              ← Frontend K8s
├── hpa.yaml                              ← Autoscaling
├── monitoring/
│   ├── prometheus-deployment.yaml        ← Prometheus
│   ├── prometheus-config.yaml            ← Config
│   ├── grafana-deployment.yaml           ← Grafana
│   └── kube-state-metrics-deployment.yaml ← kube-state
├── DEPLOYMENT_GUIDE.md
├── HPA_GUIDE.md
├── CI_CD_PIPELINE.md
├── MONITORING_SETUP.md
└── AUTOSCALING_TEST_GUIDE.md
```

### Tools to Show
- `kubectl` commands (20+ commands)
- GitHub Actions dashboard
- Docker Hub interface
- Grafana UI
- Prometheus UI
- Terminal/CLI output

### Metrics to Display
- Pod CPU: 3-60%
- Pod Memory: 10-80%
- Replicas scaling: 2 → 4
- Latency trends
- Request rates

---

## ✨ KEY DEMONSTRATIONS

### Demo 1: Pod Creation (2-3 min)
```bash
kubectl apply -f deployment-backend.yaml
kubectl get pods --watch
kubectl describe pod <pod-name>
```

### Demo 2: HPA Scaling (5-7 min)
```bash
kubectl get hpa --watch
# Load starts
kubectl create deployment load --replicas=20
# Watch replicas increase
# Wait for cool-down
# Stop load
# Watch replicas decrease
```

### Demo 3: CI/CD Trigger (5-7 min)
```bash
git push origin master
# Show GitHub Actions running
# Show build logs
# Show Docker push
# Show kubectl rollout
```

### Demo 4: Monitoring Metrics (5 min)
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Query metrics
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Show dashboards
```

---

## 📊 EXPECTED OUTPUTS TO SHOW

### kubectl get hpa Output
```
NAMESPACE   NAME                      REFERENCE                    TARGETS                MINPODS MAXPODS REPLICAS AGE
default     deepface-backend-hpa      Deployment/deepface-backend  36%/60%, 58%/75%       2       4       4        25h
default     deepface-frontend-hpa     Deployment/deepface-frontend 39%/70%, 10%/80%       2       5       2        25h
```

### kubectl get pods Output
```
NAME                                 READY   STATUS    RESTARTS   AGE
deepface-backend-7dfc959df4-qxbqf    1/1     Running   0          16h
deepface-backend-7dfc959df4-s2dxj    1/1     Running   0          5m ← NEW
deepface-backend-7dfc959df4-s66jf    1/1     Running   0          5m ← NEW
deepface-backend-7dfc959df4-xlx8v    1/1     Running   0          16h
deepface-frontend-69557974c5-jplb9   1/1     Running   0          39m
deepface-frontend-69557974c5-vjv98   1/1     Running   0          39m
```

### Grafana Dashboard
- 8+ panels showing metrics
- Backend replicas trending
- Frontend CPU/Memory usage
- Pod restart counts
- Network activity

### Prometheus Queries
```
up - all targets status
container_cpu_usage_seconds_total - CPU per pod
container_memory_usage_bytes - Memory per pod
kube_deployment_status_replicas - deployment replicas
kube_horizontalpodautoscaler_status_desired_replicas - HPA targets
```

---

## ⏱️ ESTIMATED TIMING

| Topic | Duration | Demos | Total |
|-------|----------|-------|-------|
| Kubernetes Intro | 5 min | 3 min | 8 min |
| Deployments & Services | 7 min | 3 min | 10 min |
| HPA Fundamentals | 8 min | 5 min | 13 min |
| HPA Demo & Scaling | 5 min | 7 min | 12 min |
| CI/CD Overview | 8 min | 3 min | 11 min |
| CI/CD Pipeline Demo | 5 min | 7 min | 12 min |
| Monitoring Stack | 8 min | 3 min | 11 min |
| Grafana & Prometheus | 5 min | 5 min | 10 min |
| **TOTAL** | **51 min** | **36 min** | **87 min** |

**Recommendation**: Split into 4 videos × 20 minutes each

---

## ✅ RECORDING CHECKLIST

Before Recording:
- [ ] Minikube running (`minikube status`)
- [ ] All pods deployed (`kubectl get pods`)
- [ ] HPA active (`kubectl get hpa`)
- [ ] Prometheus running (`kubectl get pods -n monitoring`)
- [ ] Grafana accessible (`port-forward 3000`)
- [ ] Terminal font size readable
- [ ] Screen resolution 1920x1080
- [ ] No background noise
- [ ] Internet stable
- [ ] GitHub Actions dashboard ready
- [ ] Docker Hub account logged in
- [ ] Load testing tools ready

After Recording:
- [ ] Audio quality good
- [ ] Screen capture clear
- [ ] No sensitive data exposed
- [ ] Timestamps added
- [ ] Transcription prepared
- [ ] Captions generated

---

## 🎯 SUCCESS CRITERIA

Viewers should understand:
✅ How Kubernetes orchestrates containers
✅ How HPA automatically scales workloads
✅ How CI/CD automates testing & deployment
✅ How Prometheus & Grafana provide visibility
✅ Real-world workflow demonstration
✅ Troubleshooting & monitoring
✅ Best practices & recommendations

---

**Status**: 📋 **READY TO RECORD**

See [VIDEO_RECORDING_GUIDE.md](VIDEO_RECORDING_GUIDE.md) for detailed scripts!
