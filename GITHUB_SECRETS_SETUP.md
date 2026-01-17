# GitHub Secrets Setup Guide

## 🔐 Required Secrets

Before the CI/CD pipeline works, you need to configure GitHub Secrets.

### Step 1: Go to Repository Settings

1. Open your GitHub repository
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)

---

## 📝 Configure Required Secrets

### Secret 1: DOCKER_USERNAME

**What it is**: Your Docker Hub username

**How to get it**:
1. Go to [hub.docker.com](https://hub.docker.com)
2. Login with your Docker Hub account
3. Your username is shown in top-right profile

**Steps to add**:
1. Click **"New repository secret"** button
2. Name: `DOCKER_USERNAME`
3. Value: `your-docker-username` (e.g., `shefanny00`)
4. Click **"Add secret"**

---

### Secret 2: DOCKER_PASSWORD

**What it is**: Your Docker Hub personal access token (recommended) or password

**⚠️ IMPORTANT**: Use Personal Access Token, NOT password!

**How to get PAT (Personal Access Token)**:

1. Go to [hub.docker.com](https://hub.docker.com)
2. Login
3. Click profile → **Account Settings**
4. Click **Security** → **Personal access tokens** (or **New Access Token**)
5. Click **Generate new token**
6. Name: `GitHub Actions`
7. Permissions: Check `Read & Write` (or at minimum `Read`)
8. Click **Generate**
9. Copy the token (you won't see it again!)

**Steps to add secret**:
1. Click **"New repository secret"** button
2. Name: `DOCKER_PASSWORD`
3. Value: Paste your PAT token
4. Click **"Add secret"**

---

### Secret 3: KUBE_CONFIG (Optional - for Kubernetes deployment)

**What it is**: Your Kubernetes configuration file (base64 encoded)

**Only needed if you want automatic Kubernetes deployment**

**How to get it**:

On your local machine (where kubectl is configured):

**Windows PowerShell**:
```powershell
# Read kubeconfig and convert to base64
$config = Get-Content $ENV:USERPROFILE\.kube\config -Raw
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($config))
```

**Mac/Linux**:
```bash
cat ~/.kube/config | base64
```

**Copy the output** (entire base64 string)

**Steps to add secret**:
1. Click **"New repository secret"** button
2. Name: `KUBE_CONFIG`
3. Value: Paste the entire base64 string
4. Click **"Add secret"**

---

## ✅ Verify Secrets are Set

After adding secrets, verify they're configured:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see:
   - ✅ `DOCKER_USERNAME` (last updated X minutes ago)
   - ✅ `DOCKER_PASSWORD` (last updated X minutes ago)
   - ✅ `KUBE_CONFIG` (optional, last updated X minutes ago)

---

## 🧪 Test the Pipeline

### Trigger Pipeline:

**Option 1: Push to master**
```bash
git add .
git commit -m "Enable CI/CD pipeline"
git push origin master
```

**Option 2: Manual Trigger**
1. Go to repository → **Actions** tab
2. Click **"Docker CI/CD Pipeline"** workflow
3. Click **"Run workflow"** → master branch
4. Click **"Run workflow"** button

### Monitor Pipeline:

1. Go to **Actions** tab
2. Click the running workflow
3. Watch jobs execute in real-time:
   - 🟦 backend-test (running)
   - 🟦 frontend-test (running)
   - ⏳ build (waiting)
   - ⏳ security-scan (waiting)
   - ⏳ deploy (waiting)

---

## 📊 View Workflow Results

### Check Status:
1. **Actions** tab → Click workflow run
2. View each job:
   - Green ✅ = Success
   - Red ❌ = Failed
   - Click to expand and see logs

### Download Artifacts:
1. After success, click workflow run
2. Scroll down to **Artifacts**
3. Download scan reports, coverage, etc.

---

## 🐛 Troubleshooting Secrets

### "Secrets are not available"
- Pipeline runs as: `ubuntu-latest`
- Secrets only available in GitHub Actions runner
- Secrets are masked in logs (shown as ****)

### "Docker login failed"
```
Error: 401 Unauthorized
```
**Solutions**:
- Verify Docker Hub credentials are correct
- Verify PAT token is not expired
- Try creating new token
- Test locally: `docker login -u <username>`

### "Kubeconfig invalid"
```
Error: unable to decode kubeconfig
```
**Solutions**:
- Ensure full kubeconfig is base64 encoded
- Verify no newlines added during copying
- Re-create secret and paste carefully

---

## 🔒 Security Best Practices

### DO:
- ✅ Use Personal Access Token (not password)
- ✅ Set token expiration (e.g., 90 days)
- ✅ Use strong, unique passwords
- ✅ Review secrets regularly
- ✅ Rotate secrets every 3-6 months

### DON'T:
- ❌ Commit secrets to Git
- ❌ Share secrets with others
- ❌ Use personal passwords (use tokens)
- ❌ Leave expired tokens active
- ❌ Log secrets in output

---

## 📋 Secrets Summary Table

| Secret | Required | Type | Expires |
|--------|----------|------|---------|
| `DOCKER_USERNAME` | ✅ Yes | Text | Never |
| `DOCKER_PASSWORD` | ✅ Yes | Token | 90 days (set) |
| `KUBE_CONFIG` | ❌ Optional | Encoded | Never |

---

## 🚀 Next Steps

After secrets are configured:

1. ✅ Push code to master branch
2. ✅ Watch pipeline run in Actions tab
3. ✅ Verify Docker images pushed to Hub
4. ✅ Check Kubernetes deployment (if configured)
5. ✅ Monitor health checks

---

## 📞 Support

**If pipeline fails**:
1. Check GitHub Actions logs
2. Verify secrets are correct
3. Run tests locally
4. Check error messages in logs
5. Fix issues and re-run

**Common errors**:
- `401 Unauthorized` = Wrong Docker credentials
- `connection refused` = Kubernetes cluster not running
- `test failed` = Code has errors (fix locally first)

---

**Setup Complete!** 🎉

Your CI/CD pipeline is now fully configured and ready to use.
Every push to master will automatically:
- Run tests ✅
- Build Docker images 🐳
- Scan for security issues 🔒
- Deploy to Kubernetes ☸️
- Check health 💚
