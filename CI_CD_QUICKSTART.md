# CI/CD Quick Reference Card

## 🚀 Pipeline Overview

```
Push to master → Tests (2 parallel) → Build Images → Security Scan → Deploy K8s → Notify
     (5s)             (2-3 min)        (2-3 min)      (1-2 min)      (2-3 min)   (10s)
                                                                      ↓ if master
                                                                   Deploy only
```

---

## 📊 Current Status

| Component | Status | Details |
|-----------|--------|---------|
| **Pipeline** | ✅ Active | All 6 jobs enabled |
| **Tests** | ✅ Enabled | Backend (pytest) + Frontend (ESLint) |
| **Build** | ✅ Enabled | Docker Hub (linux/amd64) |
| **Security** | ✅ Enabled | Trivy vulnerability scanning |
| **Deploy** | ⏳ Needs Config | Requires KUBE_CONFIG secret |
| **Documentation** | ✅ Complete | Full setup guides included |

---

## 🔧 One-Time Setup Required

### 1. Add Docker Hub Secrets (2 min)
```
Go to GitHub → Settings → Secrets and variables → Actions
Add:
  - DOCKER_USERNAME = your docker hub username
  - DOCKER_PASSWORD = your personal access token (from hub.docker.com)
```

### 2. Add Kubernetes Secret (Optional, 5 min)
```
Add:
  - KUBE_CONFIG = base64(~/.kube/config)
```

### 3. Done! ✅
Pipeline will start on next push

---

## 📝 How to Use

### Automatic Triggers:
```bash
# Push to master → Full pipeline (test + build + deploy)
git push origin master

# Pull request → Tests only (no deploy)
git pull-request origin feature-branch
```

### Manual Trigger:
1. GitHub → **Actions** tab
2. Click **"Docker CI/CD Pipeline"**
3. Click **"Run workflow"** → **"Run workflow"**

### Check Status:
1. GitHub → **Actions** tab
2. Click running workflow
3. Expand jobs to see logs

---

## 📦 What Gets Built

### Docker Images:
- ✅ `{USERNAME}/deepface-backend:latest`
- ✅ `{USERNAME}/deepface-frontend:latest`
- Pushed to Docker Hub
- Available for Kubernetes deployment

### Test Results:
- ✅ Backend: pytest coverage report
- ✅ Frontend: ESLint report + built app
- Available in GitHub Actions logs

### Security Reports:
- ✅ Backend: Trivy vulnerability scan
- ✅ Frontend: Trivy vulnerability scan
- Viewable in GitHub Security tab

### Deployments:
- ✅ Kubernetes: Auto-updated (if K8s configured)
- ✅ Health: Post-deployment health checks
- ✅ Rollout: Tracks deployment progress

---

## ✅ Jobs Timeline

| # | Job | Duration | Status |
|---|-----|----------|--------|
| 1️⃣ | backend-test | 1-2 min | Parallel |
| 2️⃣ | frontend-test | 2-3 min | Parallel |
| 3️⃣ | build | 2-3 min | After 1&2 |
| 4️⃣ | security-scan | 1-2 min | After 3 |
| 5️⃣ | deploy | 2-3 min | After 4 (master only) |
| 6️⃣ | notify | 10s | After 5 |

**Total Time**: ~7-10 minutes

---

## 🔍 Monitor Pipeline

### Real-time:
1. GitHub → Actions → Click workflow run
2. Watch jobs execute
3. See logs live

### On Completion:
```
✅ Tests Passed
✅ Images Built & Pushed
✅ Security Scan OK
✅ Kubernetes Deployed
✅ Health Checks Pass
```

---

## 🛠️ Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Pipeline not running | Secrets not set | Add DOCKER_USERNAME & DOCKER_PASSWORD |
| Tests fail | Code errors | Fix code, run tests locally first |
| Docker build fails | Missing dependencies | Update requirements.txt |
| K8s deploy fails | kubeconfig not set | Base64 encode and add KUBE_CONFIG |
| Security scan slow | First time | Subsequent scans are faster (cached) |

---

## 📋 Checklist Before Push

- [ ] Tests pass locally: `pytest backend/tests/`
- [ ] Linting passes: `npx eslint frontend/src/`
- [ ] Code builds: `npm run build` (frontend)
- [ ] No secrets in code
- [ ] GitHub secrets configured
- [ ] Commit message is clear

---

## 🎯 Next Steps

1. ✅ Read [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)
2. ✅ Configure Docker Hub secrets
3. ✅ (Optional) Configure Kubernetes secret
4. ✅ Push code to trigger pipeline
5. ✅ Monitor in GitHub Actions tab

---

## 📚 Full Documentation

- **[CI_CD_PIPELINE.md](./CI_CD_PIPELINE.md)** - Complete technical guide
- **[GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)** - Secret configuration
- **[.github/workflows/docker.yml](./.github/workflows/docker.yml)** - Workflow YAML

---

## 🔗 Quick Links

| Resource | URL |
|----------|-----|
| GitHub Actions | https://github.com/{owner}/{repo}/actions |
| Workflow File | https://github.com/{owner}/{repo}/blob/master/.github/workflows/docker.yml |
| Docker Hub | https://hub.docker.com |
| Docker PAT | https://hub.docker.com/settings/security |

---

## 💡 Pro Tips

### View Pipeline Status Badge:
Add to README.md:
```markdown
[![CI/CD Pipeline](https://github.com/{owner}/{repo}/workflows/Docker%20CI%2FCD%20Pipeline/badge.svg)](https://github.com/{owner}/{repo}/actions)
```

### Trigger Workflow from Terminal:
```bash
# If GitHub CLI installed
gh workflow run docker.yml -r master
```

### View All Workflow Runs:
```bash
gh run list --workflow=docker.yml
```

### Cancel Running Workflow:
```bash
gh run cancel <run-id>
```

---

**Pipeline Version**: 2.0 (Enhanced)
**Last Updated**: 2026-01-17
**Status**: ✅ Ready to Use
