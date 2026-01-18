# 📹 Video Recording Script - Deepface Kubernetes Implementation

## Berdasarkan Kriteria:
- [x] Video penjelasan implementasi Kubernetes/OpenShift
- [x] Video penjelasan HPA, CI/CD, dan monitoring tool

---

## 📋 TOPIK YANG HARUS DIJELASKAN (30-45 menit per video)

### VIDEO 1: KUBERNETES IMPLEMENTATION (15-20 menit)

#### 1.1 **Kubernetes Architecture Overview**
- Apa itu Kubernetes dan mengapa digunakan?
- Minikube vs Production Kubernetes
- Cluster components: Master, Nodes, Pods
- Architecture diagram deployment:
  ```
  Minikube Cluster → 4 CPU, 6GB RAM
  ├── Default Namespace (Application)
  │   ├── Backend (FastAPI + DeepFace)
  │   ├── Frontend (React + Nginx)
  │   └── Services
  ├── Monitoring Namespace
  │   ├── Prometheus
  │   ├── Grafana
  │   └── kube-state-metrics
  └── kube-system (Kubernetes internals)
  ```

#### 1.2 **Deployment Files Explanation**
**File: deployment-backend.yaml**
- Container image specification
- Port configuration (5000)
- Environment variables
- Resource requests/limits:
  - CPU: 100m request, 500m limit
  - Memory: 512Mi request, 2Gi limit
- Health checks (liveness & readiness probes)
- Volume mounts
- Service configuration (ClusterIP)

**File: deployment-frontend.yaml**
- React app container (nginx)
- Port configuration (80)
- Environment variables (API URL)
- Resource requests/limits:
  - CPU: 100m request, 500m limit
  - Memory: 128Mi request, 512Mi limit
- Health checks
- Service configuration (LoadBalancer)

#### 1.3 **Service Discovery & Networking**
- ClusterIP: Internal only (backend)
- LoadBalancer: External access (frontend)
- Service DNS: deepface-backend-service, deepface-frontend-service
- Port mapping and traffic distribution
- Live demo: kubectl port-forward

#### 1.4 **Pod Lifecycle**
- Pod creation workflow
- Container startup sequence
- Ready vs Running states
- Termination and restart
- Live demo: kubectl describe pod

#### 1.5 **RBAC & Security**
- ServiceAccounts
- ClusterRoles & ClusterRoleBindings
- Monitoring stack RBAC configuration
- Permission model

---

### VIDEO 2: AUTOSCALING (HPA) - DEEP DIVE (15-20 menit)

#### 2.1 **HPA Fundamentals**
**What is HPA?**
- Automatic scaling based on metrics
- Horizontal vs Vertical scaling
- How HPA works step-by-step

**HPA Configuration:**
```yaml
Backend HPA:
- Min Replicas: 2
- Max Replicas: 4
- CPU Target: 60%
- Memory Target: 75%

Frontend HPA:
- Min Replicas: 2
- Max Replicas: 5
- CPU Target: 70%
- Memory Target: 80%
```

#### 2.2 **Metrics Collection**
- metrics-server role
- CPU/Memory metrics from containers
- Metric aggregation
- 15-second scrape interval

#### 2.3 **HPA Scaling Decision Algorithm**
```
Decision Flow:
1. Collect current metrics (15s)
2. Calculate average utilization
3. Compare with target threshold
4. If > threshold → scale up
5. If < threshold → scale down (after 5 min cool-down)
6. Respect min/max replica bounds
```

**Live Demo:**
- Show HPA status: `kubectl get hpa -A`
- Scale-up trigger with load
- Pod creation observation
- Metrics evaluation

#### 2.4 **Testing Autoscaling**
```bash
# Light Load (3 min)
kubectl run load-light ... --restart=Never

# Normal Load (5 min)  
kubectl apply -f load-test-frontend.yaml

# Heavy Load (5 min)
kubectl create deployment ultra-heavy --replicas=20
```

**What to Observe:**
- HPA replica count increasing
- New pods in Pending → Running → Ready
- CPU/Memory metrics rising
- Service load distribution
- Response time changes

#### 2.5 **Troubleshooting HPA**
- "HPA not scaling" → Check metrics-server
- "Stuck at max replicas" → Check actual workload
- "Missing metrics" → Check resource requests/limits
- View events: `kubectl describe hpa`

---

### VIDEO 3: CI/CD PIPELINE - GITHUB ACTIONS (15-20 menit)

#### 3.1 **CI/CD Pipeline Overview**
- Why CI/CD is important
- Automated testing, building, deploying
- Pipeline triggers (push, PR, workflow_dispatch)

**Pipeline Flow:**
```
┌─ Push to GitHub (master branch)
│
├─ Backend Tests (pytest + flake8)
├─ Frontend Tests (ESLint + npm build)
├─ Build Docker Images
├─ Security Scan (Trivy)
├─ Push to Docker Hub
├─ Deploy to Kubernetes
└─ Notify Success
```

#### 3.2 **GitHub Actions Workflow File**
**File: .github/workflows/docker.yml**

**Job 1: Backend Testing**
- Python 3.9 setup
- pip install requirements
- pytest execution
- flake8 linting

**Job 2: Frontend Testing**
- Node.js 18 setup
- npm install
- ESLint validation
- React build
- Test execution

**Job 3: Build & Push**
- Docker buildx setup
- Docker Hub login
- Multi-stage builds:
  - Backend: Python 3.9 base → ~4.4GB
  - Frontend: Node → Nginx → ~488MB
- Push tagged images

**Job 4: Security Scan**
- Trivy vulnerability scanner
- Backend image scan
- Frontend image scan
- SARIF report generation

**Job 5: Deploy to Kubernetes**
- Decode KUBE_CONFIG secret
- kubectl image update
  - Backend: `kubectl set image`
  - Frontend: `kubectl set image`
- Rollout status monitoring
- Health verification

**Job 6: Notify**
- Success notification
- Summary of completed steps

#### 3.3 **Secrets Configuration**
- DOCKER_USERNAME & DOCKER_PASSWORD
- KUBE_CONFIG (base64 encoded kubeconfig)
- How to set up in GitHub repo
- Security best practices

#### 3.4 **Deployment Strategy**
```
Rolling Update Process:
1. New pod starts with new image
2. Old pod terminates gradually
3. Service reroutes traffic
4. Zero-downtime deployment
5. Automatic rollback on failure
```

#### 3.5 **CI/CD Best Practices**
- Branch protection rules
- Required status checks
- Automated testing before merge
- Docker image versioning
- Kubernetes resource limits
- Health check validation

---

### VIDEO 4: MONITORING - PROMETHEUS + GRAFANA (15-20 menit)

#### 4.1 **Monitoring Architecture**
```
┌─────────────────────────────────────┐
│ Kubernetes Cluster Metrics          │
│ (Pod CPU, Memory, Endpoints)        │
└───────────────┬─────────────────────┘
                │
        ┌───────▼────────┐
        │  Prometheus    │
        │  (Scraper)     │
        │  Port: 9090    │
        └────────┬───────┘
                 │
         ┌───────▼──────────┐
         │ Time-Series DB   │
         │ (15s intervals)  │
         └───────┬──────────┘
                 │
         ┌───────▼──────────┐
         │  Grafana         │
         │  (Visualizer)    │
         │  Port: 3000      │
         └──────────────────┘
```

#### 4.2 **Prometheus Configuration**
**What Prometheus Monitors:**
- Kubernetes API server
- Nodes (CPU, Memory, Network)
- Pods (CPU, Memory, Restart count)
- Services & Endpoints
- Custom metrics (if exposed)

**Scrape Targets:**
- kube-state-metrics: Kubernetes resource state
- kubelet: Node metrics
- Kubernetes API: Cluster metadata

**File: prometheus-config.yaml**
- Job configurations
- Scrape intervals: 15s
- Evaluation intervals: 15s
- Alert rules (if configured)

#### 4.3 **Grafana Dashboards**
**Pre-built Dashboards to Import:**
- ID 1860: Node Exporter Full
- ID 6417: Kubernetes Cluster Monitoring
- ID 8588: Kubernetes Deployments

**Custom Dashboard: "Deepface Monitoring"**
Panels to create:
1. Backend Replicas (kube_deployment_status_replicas)
2. Frontend Replicas (kube_deployment_status_replicas)
3. Backend CPU Usage (container_cpu_usage_seconds_total)
4. Backend Memory Usage (container_memory_usage_bytes)
5. Frontend CPU Usage
6. Frontend Memory Usage
7. Pod Restart Count (kube_pod_container_status_restarts_total)
8. Network Activity (container_network_transmit_packets_total)

#### 4.4 **Key Metrics Explained**
```
PromQL Queries:

1. Pod CPU:
   sum(rate(container_cpu_usage_seconds_total{pod=~"deepface.*"}[5m])) by (pod)

2. Pod Memory:
   sum(container_memory_usage_bytes{pod=~"deepface.*"}) by (pod) / 1024 / 1024

3. HPA Target Replicas:
   kube_horizontalpodautoscaler_status_desired_replicas{hpa="deepface-backend-hpa"}

4. Deployment Status:
   kube_deployment_status_replicas{deployment="deepface-backend"}

5. Pod Ready Status:
   kube_pod_status_ready{namespace="default"}
```

#### 4.5 **Alerting Setup** (Optional)
- Alert rules creation
- Notification channels (Slack, Email)
- Alert thresholds
- Example alerts:
  - High CPU usage
  - Pod crashes
  - Low memory available
  - Failed deployments

#### 4.6 **Live Monitoring Demo**
- Show Grafana dashboard
- Trigger load test
- Watch metrics change in real-time
- See HPA scaling reflected
- Pod creation/destruction events

---

## 📊 LIVE DEMONSTRATIONS TO INCLUDE

### Demo 1: Deployment & Service Discovery
```bash
# Show deployment
kubectl get deployment
kubectl describe deployment deepface-backend

# Show services
kubectl get svc

# Show pods
kubectl get pods

# Port forward and access
kubectl port-forward svc/deepface-frontend 80:80
# Open browser → localhost
```

### Demo 2: HPA in Action
```bash
# Terminal 1: Watch HPA
kubectl get hpa -A --watch

# Terminal 2: Watch Pods
kubectl get pods -l app=deepface-backend --watch

# Terminal 3: Generate Load
kubectl create deployment ultra-heavy --image=curlimages/curl --replicas=20 \
  -- sh -c "while true; do curl -s http://deepface-backend-service/health > /dev/null; done"

# Observe: Replicas increase 2 → 3 → 4
```

### Demo 3: CI/CD Trigger
```bash
# Push to GitHub
git push origin master

# Show GitHub Actions running
# Show test results
# Show Docker images pushed
# Show Kubernetes deployment updated
```

### Demo 4: Monitoring Dashboards
```bash
# Access Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000
# Browser → localhost:3000

# Show Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090
# Browser → localhost:9090/graph
```

---

## 📝 KEY POINTS TO EMPHASIZE

### Kubernetes Concepts
- ✅ Containerization benefits
- ✅ Orchestration automation
- ✅ Self-healing (pod restart)
- ✅ Load distribution
- ✅ Service abstraction

### HPA Benefits
- ✅ Automatic scaling based on demand
- ✅ Cost optimization (use only needed resources)
- ✅ High availability
- ✅ Zero-downtime scaling
- ✅ Metrics-driven decisions

### CI/CD Benefits
- ✅ Automated testing (less bugs)
- ✅ Automated deployment (fewer errors)
- ✅ Fast feedback loop
- ✅ Reproducible builds
- ✅ Security scanning

### Monitoring Benefits
- ✅ Real-time visibility
- ✅ Performance trending
- ✅ Early problem detection
- ✅ Resource optimization
- ✅ Compliance & auditing

---

## 🎬 RECORDING TIPS

1. **Screen Resolution**: 1920x1080 or higher
2. **Font Size**: Make terminal text readable
3. **Slow Down**: Pause after each command result
4. **Explain Output**: Walk through kubectl output
5. **Use Captions**: Highlight important commands
6. **Timing**: ~20 min per video (not too long)
7. **Zoom**: Zoom into important sections
8. **Background**: Quiet environment

---

## 📚 SUPPORTING MATERIALS

For users to reference while watching:

1. **Kubernetes Basics**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
2. **HPA Details**: [HPA_GUIDE.md](HPA_GUIDE.md)
3. **CI/CD Pipeline**: [CI_CD_PIPELINE.md](CI_CD_PIPELINE.md)
4. **Monitoring Setup**: [MONITORING_SETUP.md](MONITORING_SETUP.md)
5. **Quick Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
6. **Load Testing**: [AUTOSCALING_TEST_GUIDE.md](AUTOSCALING_TEST_GUIDE.md)

---

## ✅ FINAL CHECKLIST BEFORE RECORDING

- [ ] Minikube running and healthy
- [ ] All pods deployed and ready
- [ ] HPA metrics showing correctly
- [ ] Grafana/Prometheus accessible
- [ ] CI/CD secrets configured
- [ ] Docker images built and available
- [ ] Load testing tools ready
- [ ] Terminal configured with readable fonts
- [ ] Network connection stable
- [ ] Screen recording software tested

---

**Total Recording Time**: ~60-80 minutes (4 videos × 15-20 min each)

**Suggested Order**:
1. Kubernetes Implementation (foundation)
2. HPA / Autoscaling (intermediate)
3. CI/CD Pipeline (application)
4. Monitoring Tools (visualization)
