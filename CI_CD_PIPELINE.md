# GitHub Actions CI/CD Pipeline Documentation

## 📋 Overview

Complete automated CI/CD pipeline for the Deepface Attendance System with:
- ✅ Backend testing (Python/pytest)
- ✅ Frontend testing (ESLint + Build)
- ✅ Docker image building & pushing
- ✅ Security scanning (Trivy)
- ✅ Automatic Kubernetes deployment
- ✅ Health checks & validation

---

## 🚀 Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Trigger: Push to master/main OR Pull Request OR Manual     │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   ┌────▼─────────┐        ┌────▼──────────┐
   │ Backend Test │        │ Frontend Test │
   │ (pytest)     │        │ (ESLint+Build)│
   └────┬─────────┘        └────┬──────────┘
        │                       │
        └───────────┬───────────┘
                    │
             ┌──────▼──────┐
             │ Build Images│
             │ (Docker)    │
             └──────┬──────┘
                    │
           ┌────────▼────────┐
           │ Security Scan   │
           │ (Trivy)         │
           └────────┬────────┘
                    │
        ┌───────────▼───────────┐
        │ Deploy to Kubernetes  │
        │ (if master branch)    │
        └───────────┬───────────┘
                    │
             ┌──────▼──────┐
             │ Health Check│
             │ & Notify    │
             └─────────────┘
```

---

## 📝 Jobs Breakdown

### 1. Backend Test (`backend-test`)
**Purpose**: Validate Python code quality and run unit tests

**Steps**:
- Setup Python 3.9
- Install dependencies (from requirements.txt)
- Install pytest & pytest-cov
- Run pytest with coverage
- Lint with flake8

**On Failure**: Pipeline stops (PR/Build rejected)

**Artifacts**: 
- Coverage report (if tests exist)
- Linting report

### 2. Frontend Test (`frontend-test`)
**Purpose**: Validate React code and build

**Steps**:
- Setup Node.js 18
- Install npm dependencies
- Run ESLint (max 5 warnings allowed)
- Build React app

**On Failure**: Pipeline stops (PR/Build rejected)

**Artifacts**:
- Built frontend (dist/)
- Linting report

### 3. Build (`build`)
**Depends on**: frontend-test, backend-test

**Purpose**: Build and push Docker images to Docker Hub

**Steps**:
- Setup Docker Buildx
- Login to Docker Hub
- Build backend image
- Push backend image with `latest` tag
- Build frontend image
- Push frontend image with `latest` tag

**Images Created**:
- `{USERNAME}/deepface-backend:latest`
- `{USERNAME}/deepface-frontend:latest`

### 4. Security Scan (`security-scan`)
**Depends on**: build

**Purpose**: Scan Docker images for vulnerabilities

**Tools**: Trivy (container security scanner)

**Scans**:
- Backend image for CVEs
- Frontend image for CVEs
- Generates SARIF reports

**Output**: 
- Trivy security reports
- SARIF format for GitHub Security tab

### 5. Deploy (`deploy`)
**Depends on**: build, security-scan
**Only on**: Push to master branch

**Purpose**: Deploy new images to Kubernetes cluster

**Steps**:
1. Verify images exist on Docker Hub
2. Setup kubeconfig (from secrets)
3. Update Kubernetes deployments:
   - `kubectl set image deployment/deepface-backend`
   - `kubectl set image deployment/deepface-frontend`
4. Wait for rollout (5 min timeout)
5. Verify pod health

**Requirements**:
- `KUBE_CONFIG` secret configured
- Kubernetes cluster accessible

### 6. Notify (`notify`)
**Depends on**: deploy

**Purpose**: Send success notification

**On Success**: Displays completion message
**On Failure**: Automatic GitHub notifications

---

## 🔐 Required GitHub Secrets

Create these in **Settings → Secrets and variables → Actions**:

| Secret | Value | Example |
|--------|-------|---------|
| `DOCKER_USERNAME` | Docker Hub username | `shefanny00` |
| `DOCKER_PASSWORD` | Docker Hub password/token | `dckr_pat_...` |
| `KUBE_CONFIG` | Base64 kubeconfig (optional) | `LS0tLS1CRUdJTi...` |

### How to Create KUBE_CONFIG Secret:

```bash
# On your local machine with kubectl configured:
cat ~/.kube/config | base64

# Copy output and paste into GitHub secret
```

---

## 🎯 Trigger Conditions

### Automatic Triggers:
1. **Push to master/main**: Full pipeline runs, deploys to K8s
2. **Pull Request to master/main**: Tests & security scan only (no deploy)
3. **Manual Trigger**: Click "Run workflow" in GitHub Actions tab

### Deploy Only Triggers:
- Push to `master` branch
- All tests pass
- Security scan completes
- Must have valid kubeconfig

---

## 📊 Pipeline Status Checks

Each job provides status indicators:

| Status | Meaning | Action |
|--------|---------|--------|
| ✅ Passed | Job succeeded | Proceeds to next job |
| ❌ Failed | Job failed | Pipeline stops |
| ⏭️ Skipped | Job skipped | (Conditional) |
| ⏳ In Progress | Job running | Wait for completion |

---

## 🔍 Viewing Pipeline Status

1. Go to repository → **Actions** tab
2. Click on the workflow run
3. View job details:
   - Logs for each step
   - Timing information
   - Error messages
   - Artifact downloads

### Check Status:
```bash
# View last 10 workflow runs
gh run list

# View specific run details
gh run view <run-id>

# Watch live logs
gh run watch <run-id>
```

---

## 🛠️ Customization Guide

### Run Tests Locally:

**Backend**:
```bash
cd backend
pip install -r requirements.txt pytest
pytest tests/ -v --cov=.
```

**Frontend**:
```bash
cd frontend
npm install
npm run build
npx eslint src --ext .js,.jsx
```

### Add More Tests:

**Backend** - Create `tests/test_routes.py`:
```python
import pytest
from main import app

def test_health_endpoint():
    response = app.test_client().get('/health')
    assert response.status_code == 200
    assert response.json['status'] == 'healthy'
```

**Frontend** - Already configured in `App.test.js`:
```javascript
test('renders app component', () => {
  const { container } = render(<App />);
  expect(container).toBeInTheDocument();
});
```

### Change Docker Registry:

Edit `.github/workflows/docker.yml`:
```yaml
tags: your-registry.azurecr.io/deepface-backend:latest
```

### Add Slack Notifications:

Add step in `notify` job:
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "✅ Deepface deployment successful!"
      }
```

---

## ⚠️ Troubleshooting

### Issue: Tests Failing

**Solution**:
1. Check error logs in GitHub Actions
2. Run locally: `pytest tests/ -v`
3. Fix issues before pushing
4. Push corrected code

### Issue: Docker Hub Login Failed

**Solution**:
1. Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
2. Check Docker Hub credentials are correct
3. Use personal access token instead of password
4. Test locally: `docker login -u <username>`

### Issue: Kubernetes Deployment Failed

**Solution**:
1. Verify `KUBE_CONFIG` secret is configured
2. Check cluster is running: `kubectl cluster-info`
3. Verify deployments exist: `kubectl get deployments`
4. Check pod logs: `kubectl logs <pod-name>`

### Issue: Security Scan Takes Too Long

**Solution**:
- Normal for first scan (caches results)
- Subsequent scans faster
- Can skip with `if: false` condition in YAML

---

## 📈 Best Practices

### Code Quality:
- ✅ Keep tests passing
- ✅ Follow linting standards
- ✅ Fix security warnings
- ✅ Avoid breaking changes

### Deployment:
- ✅ Always merge to master via PR
- ✅ Review tests before merge
- ✅ Monitor health after deployment
- ✅ Rollback if issues found

### Secrets Management:
- ✅ Use personal access tokens (not passwords)
- ✅ Rotate secrets regularly
- ✅ Never commit secrets to repo
- ✅ Use separate secrets for prod/dev

---

## 🚀 Advanced Features

### Matrix Strategy (Optional):
Run tests on multiple Python/Node versions:

```yaml
strategy:
  matrix:
    python-version: [3.8, 3.9, '3.10']
    node-version: [16, 18, 20]
```

### Conditional Deployments:
Deploy only on specific tags:

```yaml
if: startsWith(github.ref, 'refs/tags/v')
```

### Artifact Storage:
Upload test reports:

```yaml
- uses: actions/upload-artifact@v3
  with:
    name: coverage-report
    path: coverage/
```

---

## 📞 Monitoring & Alerts

### GitHub Status Checks:
- Set required checks on master branch
- PR cannot merge if checks fail
- Admins can override (not recommended)

### Workflow Notifications:
- Email notifications for failures
- Can subscribe to specific events
- Settings → Notifications → Actions

### Integration with Tools:
- Slack (webhook)
- Microsoft Teams
- Jira
- Custom webhooks

---

## 📚 Pipeline Metrics

**Current Configuration**:
- Total Jobs: 6
- Parallel Jobs: 2 (backend-test, frontend-test)
- Sequential Stages: 5
- Estimated Duration: 3-5 minutes
- Storage: Images on Docker Hub

**Performance Optimization**:
- Cache Docker layers
- Cache npm dependencies
- Parallel testing jobs
- Shallow clone (not used, can enable)

---

## ✅ Checklist Before Deployment

- [ ] All tests pass locally
- [ ] Code is linted and formatted
- [ ] Docker images build successfully
- [ ] Security scan shows no critical issues
- [ ] Kubernetes cluster is running
- [ ] KUBE_CONFIG secret is configured
- [ ] Secrets are not in source code
- [ ] Documentation is updated

---

## 🎓 Learning Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Action](https://github.com/docker/build-push-action)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)
- [kubectl Commands](https://kubernetes.io/docs/reference/kubectl/)

---

**Last Updated**: 2026-01-17
**Status**: ✅ Full CI/CD Pipeline Ready
**Version**: 2.0 (Enhanced with testing, security, deployment)
