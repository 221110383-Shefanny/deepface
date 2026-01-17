# 🚀 START HERE - Petunjuk Memulai

**Selamat datang ke DeepFace Face Verification System**

Dokumentasi ini akan memandu Anda untuk menjalankan aplikasi dengan cepat.

---

## ⚡ QUICK START (5 Menit)

### Option 1: Docker Compose (Recommended) 🐳

**Requirement**: Docker & Docker Compose installed

```bash
cd d:\MIKROSKIL\OPERASI\deepface
docker-compose up
```

**Wait for**:
```
backend_1    | INFO:     Uvicorn running on http://0.0.0.0:5000
frontend_1   | Compiled successfully!
frontend_1   | You can now view the app in the browser.
frontend_1   | Local:            http://localhost:3000
```

**Then**: Open browser → http://localhost:3000

---

### Option 2: Manual Mode (Windows)

#### Terminal 1 - Backend:
```bash
cd d:\MIKROSKIL\OPERASI\deepface\backend
pip install -r requirements.txt
python app.py
```

**Wait for**:
```
INFO:     Uvicorn running on http://0.0.0.0:5000
```

#### Terminal 2 - Frontend (New Terminal):
```bash
cd d:\MIKROSKIL\OPERASI\deepface\frontend
npm install
npm start
```

**Wait for**:
```
Compiled successfully!
```

**Then**: Browser should open automatically at http://localhost:3000

---

## ✅ Verify Setup

### Check Backend
```bash
curl http://localhost:5000/health
```

**Expected response**:
```json
{"status": "ok", "message": "Backend is running", "deepface_available": true}
```

### Check Frontend
Open browser → http://localhost:3000

Should see the Face Verification application UI.

---

## 🎯 First Use

### Step 1: Add Employee Data

1. Click **"Input Data Karyawan"** button
2. Fill in:
   - **Nama**: Employee name (e.g., John Doe)
   - **Departemen**: Department (e.g., IT)
   - **Foto**: Upload a clear face photo
3. Click **"✓ Tambah Karyawan"**

### Step 2: Verify Wajah

1. Click **"Menu Absensi Karyawan"** button
2. Select employee from dropdown
3. Choose: "🔓 Absensi Masuk" or "🔒 Absensi Keluar"
4. Choose input method:
   - **📁 Upload Foto**: Select a photo file
   - **📷 Ambil Foto**: Use camera
5. Click **"✓ Verifikasi Wajah"**

### Step 3: View Result

Result appears in right panel:
- ✅ **Terverifikasi**: Face matched (distance < 0.6)
- ❌ **Tidak Cocok**: Face didn't match (distance > 0.6)
- **Error**: Clear error message explaining what went wrong

---

## 🐛 Troubleshooting

### Problem: Backend not running

**Check**:
```bash
curl http://localhost:5000/health
```

**If error**, make sure:
1. Backend terminal shows "Uvicorn running..."
2. No error messages
3. Port 5000 is not used by other app

**Solution**:
```bash
cd backend
python app.py
```

### Problem: Frontend not loading

**Check**: Browser shows http://localhost:3000

**If error**, make sure:
1. Frontend terminal shows "Compiled successfully!"
2. npm install completed
3. Port 3000 is not used by other app

**Solution**:
```bash
cd frontend
npm start
```

### Problem: Verification fails

**Check** browser console (F12):
1. Press F12
2. Click "Console" tab
3. Look for error messages

**Common errors**:
- "Cannot reach backend" → Start backend
- "Foto karyawan tidak ditemukan" → Add employee data first
- "No face detected" → Upload clearer photo
- "DeepFace model not found" → Wait for model download (5-10 min)

### Problem: Cannot detect face

**Make sure**:
- ✅ Face is clearly visible
- ✅ Good lighting
- ✅ Face facing camera
- ✅ Photo is not blurry
- ✅ File format is JPG/PNG

---

## 📚 Documentation

### Need More Help?

- **Quick tips**: Read [QUICK_REFERENCE.md](QUICK_REFERENCE.md) (2-5 min)
- **Detailed help**: Read [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (10-20 min)
- **Understand fix**: Read [PERBAIKAN_SUMMARY.md](PERBAIKAN_SUMMARY.md)
- **All docs**: Check [INDEX.md](INDEX.md) or [DOCUMENTATION_GUIDE.md](DOCUMENTATION_GUIDE.md)

---

## 🔍 Check Application Status

**Option 1**: Using Browser
```
http://localhost:5000/health
http://localhost:3000
```

**Option 2**: Using Script (Windows)
```bash
.\health_check.bat
```

**Option 3**: Using Commands
```bash
# Check backend
curl http://localhost:5000/health

# Check frontend
curl http://localhost:3000
```

---

## 🎮 Using the Application

### Left Panel: Input
- Select employee
- Choose attendance type (in/out)
- Upload photo or use camera
- Click verify button

### Right Panel: Results
- Shows verification result
- Displays recent attendance history
- Shows clear error messages if any

### Features
- ✅ Real-time face detection (camera mode)
- ✅ Auto-capture when match found
- ✅ Clear attendance history
- ✅ Employee management

---

## 🛠️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| F12 | Open DevTools (for debugging) |
| Ctrl+R | Refresh browser |
| Escape | Close camera |

---

## ⚙️ Configuration

### Ports
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:5000
- **Health Check**: http://localhost:5000/health

### Environment
- **Python**: 3.10+
- **Node**: 16+
- **Docker**: Latest

---

## 🚨 Error Messages Explained

| Message | Meaning | Solution |
|---------|---------|----------|
| Cannot reach backend | Backend not running | Start backend with `python app.py` |
| Foto karyawan tidak ditemukan | No employee data | Add employee in "Input Data Karyawan" |
| No face detected | Photo quality issue | Upload clearer photo |
| Verification failed | Network error | Check backend terminal |
| Model not found | DeepFace downloading | Wait 5-10 minutes |

---

## 💡 Tips

1. **Camera Mode Tips**:
   - Good lighting is important
   - Face should be centered
   - Stay still for capture
   - System auto-captures when match found

2. **Upload Mode Tips**:
   - Use high-quality photos
   - Clear face is essential
   - JPG format works best
   - At least 200x200 pixel resolution

3. **Debug Tips**:
   - Open F12 DevTools during test
   - Watch console for errors
   - Check backend terminal logs
   - Use health check endpoint to verify

4. **Performance Tips**:
   - First verification takes longer (model loading)
   - Subsequent verifications are faster
   - Camera mode is real-time (updates every 300ms)

---

## 📱 System Requirements

### Minimum
- **RAM**: 4 GB
- **Disk**: 5 GB free
- **CPU**: Dual core
- **OS**: Windows 10+, Linux, macOS

### Recommended
- **RAM**: 8 GB+
- **Disk**: 10 GB+ free
- **CPU**: Quad core
- **OS**: Latest version

---

## 🚀 Advanced Usage

### Using Docker Compose
```bash
# Start
docker-compose up

# Stop (Ctrl+C)
# or in another terminal
docker-compose down

# View logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild
docker-compose up --build
```

### Running Manual Mode
```bash
# Backend
cd backend
python app.py

# Frontend (new terminal)
cd frontend
npm start

# Stop: Ctrl+C in both terminals
```

### API Testing
```bash
# Health check
curl http://localhost:5000/health

# Swagger UI (if available)
http://localhost:5000/docs
```

---

## 🎓 Learning Resources

- **Full Documentation**: [INDEX.md](INDEX.md)
- **Troubleshooting Guide**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Quick Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Technical Details**: [PERBAIKAN_SUMMARY.md](PERBAIKAN_SUMMARY.md)

---

## 📞 Support

### If You're Stuck:

1. **Check Error Message**: Read what it says carefully
2. **Open DevTools**: Press F12 and check console
3. **Check Backend Terminal**: Look for server errors
4. **Read Docs**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
5. **Health Check**: Verify backend is running

### Common Issues:
- Backend not running → Start it
- Port in use → Close other apps or change port
- Face not detected → Upload clearer photo
- Dependencies missing → Run `pip install -r requirements.txt`

---

## 🎯 Success Checklist

After setup, you should see:

- [x] Backend running (terminal shows "Uvicorn running...")
- [x] Frontend loaded (browser shows UI)
- [x] Health check works (curl returns JSON)
- [x] Can add employee data
- [x] Can perform verification
- [x] Results display correctly
- [x] Error messages are clear

---

## 🎉 You're Ready!

Your DeepFace Face Verification System is now running.

**Next Steps**:
1. Add employee data
2. Try face verification
3. Check attendance history
4. Explore features

**Having issues?** Check the troubleshooting docs or DevTools console.

---

## 📋 Quick Commands

```bash
# Docker
docker-compose up              # Start
docker-compose down            # Stop

# Backend manual
cd backend && python app.py    # Start
curl http://localhost:5000/health  # Check

# Frontend manual
cd frontend && npm start       # Start

# Check app
http://localhost:3000         # Open app
http://localhost:5000/health   # Check backend
```

---

**Happy Verifying! 🚀**

*Questions? Check [DOCUMENTATION_GUIDE.md](DOCUMENTATION_GUIDE.md) for all available resources.*

---

**Version**: 1.0  
**Date**: January 11, 2025  
**Status**: ✅ Ready to Use
