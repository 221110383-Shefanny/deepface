# 📊 EXPECTED OUTPUT & EXAMPLES

Dokumentasi ini menunjukkan output yang diharapkan saat aplikasi berjalan dengan benar.

---

## Backend Terminal Output

### ✅ Backend Startup (Normal)

```
INFO:     Uvicorn running on http://0.0.0.0:5000
INFO:     Application startup complete
```

### ✅ Health Check Request

**Command**:
```bash
curl http://localhost:5000/health
```

**Response** (200 OK):
```json
{
  "status": "ok",
  "message": "Backend is running",
  "deepface_available": true
}
```

**Terminal Output**:
```
INFO:     127.0.0.1:54321 - "GET /health HTTP/1.1" 200
```

### ✅ Verification Request (Success)

**Terminal Output**:
```
✅ File saved: a1b2c3d4_img1.jpg (45823 bytes)
✅ File saved: a1b2c3d4_img2.jpg (52341 bytes)
🔄 Starting verification with model=Facenet512, backend=retinaface
✅ Verification successful: {'verified': True, 'distance': 0.45, 'threshold': 0.6, 'model': 'Facenet512', 'detector_backend': 'retinaface', ...}
INFO:     127.0.0.1:54322 - "POST /verify HTTP/1.1" 200
```

### ✅ Verification Request (No Face Detected)

**Terminal Output**:
```
✅ File saved: x9y8z7w6_img1.jpg (12345 bytes)
✅ File saved: x9y8z7w6_img2.jpg (54321 bytes)
🔄 Starting verification with model=Facenet512, backend=retinaface
❌ Verification error: Face not detected in image
📋 Traceback: 
  File "...", line xxx, in verify
    result = DeepFace.verify(...)
  deepface.commons.functions.ImageError: Face could not be detected ...
ERROR:    Exception in user code:
          deepface.commons.functions.ImageError: Face could not be detected ...
INFO:     127.0.0.1:54323 - "POST /verify HTTP/1.1" 400
```

### ✅ Server Down Log

```
[ERROR] Uvicorn server shutdown
[ERROR] Port 5000 already in use
```

---

## Frontend Browser Console Output

### ✅ Successful Verification

**Console Logs**:
```javascript
// User uploads/captures photo
// Then clicks "Verifikasi Wajah"

🔄 Mengirim verifikasi ke backend...
Response status: 200
Verification result: {verified: true, distance: 0.4523, threshold: 0.6, model: 'Facenet512', detector_backend: 'retinaface'}
✅ Attendance record saved successfully
```

**UI Result** (Right Panel):
```
Hasil Verifikasi
├── Status: ✓ Terverifikasi
├── Nama: [Nama Karyawan]
├── Departemen: [Department]
├── Tipe Absensi: Absensi Masuk
├── Waktu: 11/1/2025, 14:30:45
└── Distance: 0.45
```

**Attendance Log Update**:
```
Table shows new entry with Status = "✓ Terverifikasi"
```

### ✅ No Match Verification

**Console Logs**:
```
🔄 Mengirim verifikasi ke backend...
Response status: 200
Verification result: {verified: false, distance: 0.8945, threshold: 0.6, ...}
✅ Attendance record saved successfully
```

**UI Result**:
```
Hasil Verifikasi
├── Status: ✗ Tidak Cocok
├── Nama: [Nama Karyawan]
├── Departemen: [Department]
├── Tipe Absensi: Absensi Masuk
├── Waktu: 11/1/2025, 14:30:45
└── Distance: 0.89
```

### ✅ Backend Error

**Console Logs**:
```
🔄 Mengirim verifikasi ke backend...
Response status: 400
Backend error: Face not detected in image
```

**UI Result** (Red Error Box):
```
Hasil Verifikasi

❌ Verifikasi Gagal

Error: Face not detected in image
```

### ✅ Network Error

**Console Logs**:
```
🔄 Mengirim verifikasi ke backend...
Verification exception: TypeError: Failed to fetch
```

**UI Result**:
```
Hasil Verifikasi

❌ Terjadi Kesalahan

Error: Failed to fetch
```

**Diagnostic**: Berarti backend tidak berjalan atau tidak accessible

### ✅ No Employee Data

**Console/Alert**:
```
Alert: Foto karyawan tidak ditemukan di database!
```

**Fix**: Pergi ke "Input Data Karyawan" dulu

### ✅ No Face Image

**Console/Alert**:
```
Alert: Silakan pilih atau ambil foto terlebih dahulu!
```

**Fix**: Upload foto atau ambil dari camera

---

## Docker Compose Output

### ✅ Starting with Docker Compose

```
$ docker-compose up

Creating deepface_backend_1 ... done
Creating deepface_frontend_1 ... done
Attaching to deepface_backend_1, deepface_frontend_1

backend_1    | INFO:     Uvicorn running on http://0.0.0.0:5000
frontend_1   | Compiled successfully!
frontend_1   | You can now view the app in the browser.
frontend_1   | Local:            http://localhost:3000
```

### ✅ Stopping Docker Compose

```
$ docker-compose down

Stopping deepface_frontend_1 ... done
Stopping deepface_backend_1 ... done
Removing deepface_frontend_1 ... done
Removing deepface_backend_1 ... done
```

---

## Browser Network Tab (F12)

### ✅ Successful Verification Request

**Request**:
```
POST /verify HTTP/1.1
Host: localhost:5000
Content-Type: multipart/form-data

[Binary file data for img1 and img2]
```

**Response** (200):
```json
{
  "verified": true,
  "distance": 0.4523,
  "threshold": 0.6,
  "model": "Facenet512",
  "detector_backend": "retinaface",
  "facial_areas": {
    "img1": {...},
    "img2": {...}
  },
  "time": 2.45
}
```

**Response Time**: 1-5 seconds (depends on image quality and system)

### ✅ Failed Verification Request

**Response** (400):
```json
{
  "detail": "Face not detected in image"
}
```

---

## First Time Setup Output

### ✅ Initial Model Download

**Console** (first time verification):
```
Downloading model: VGGFace2_DeepFace_weights_best.h5
Downloaded: 1/2
Downloaded: 2/2
Model loading...
[================================================>] 100%
✅ Model loaded successfully
```

**Time**: 5-10 minutes (one-time only)

**Size**: ~2-3 GB

---

## Camera Mode Output

### ✅ Realtime Verification (Continuous)

**Console Logs** (setiap 300ms):
```
Frame 1: Checking... (no match)
Frame 2: Checking... (no match)
Frame 3: ✓ Cocok! Distance: 0.45
[Auto-capture triggered]
```

**UI Realtime Result Box** (updates every 300ms):
```
Realtime Result Box:
├── Status: ✓ Cocok / ✗ Tidak Cocok
└── Distance: 0.45
```

**After Match**:
```
Auto-capture result displayed
Camera closed
Attendance log updated
```

---

## Performance Metrics

### ✅ Response Times

| Operation | Expected | Actual | Status |
|-----------|----------|--------|--------|
| Health Check | <100ms | 50-100ms | ✅ Good |
| Verification | 1-5s | 2-4s | ✅ Good |
| Upload Process | <500ms | 200-400ms | ✅ Good |
| UI Update | <100ms | 50-100ms | ✅ Good |
| Camera Frame | 300ms | 250-350ms | ✅ Good |

---

## Memory & Resource Usage

### ✅ Backend
- Memory: ~200-400 MB (idle) -> 800-1000 MB (during verification)
- CPU: 0% (idle) -> 30-50% (during verification)
- Disk: 2-3 GB (for models) + temp files

### ✅ Frontend
- Memory: ~100-200 MB
- CPU: 0% (idle) -> 10-20% (during camera/processing)
- Network: ~50 KB per verification

---

## Error Message Examples

### ✅ Face Detection Error
```
❌ Verifikasi Gagal

Error: Face not detected in image

Solusi: Upload foto yang menunjukkan wajah dengan jelas
```

### ✅ Connection Error
```
❌ Terjadi Kesalahan

Error: Failed to fetch

Solusi: Pastikan backend berjalan di http://localhost:5000
```

### ✅ File Error
```
❌ Verifikasi Gagal

Error: File kosong atau format tidak valid

Solusi: Upload file image dengan ukuran > 1 KB
```

### ✅ Model Error
```
❌ Verifikasi Gagal

Error: DeepFace model not found

Solusi: Tunggu model download selesai (pertama kali ~10 menit)
```

---

## Normal Workflow Output Summary

### 1. Application Start
```
✅ Backend running: http://localhost:5000
✅ Frontend running: http://localhost:3000
✅ Health check: OK
```

### 2. Add Employee
```
✅ Employee saved: John Doe (emp001)
✅ Photo stored: base64 data
✅ Message: "Karyawan "John Doe" berhasil ditambahkan!"
```

### 3. Verification (Match)
```
🔄 Sending verification...
✅ Response status: 200
✅ Result: verified=true, distance=0.45
✅ UI: "✓ Terverifikasi"
✅ Log: Updated
```

### 4. Verification (No Match)
```
🔄 Sending verification...
✅ Response status: 200
✅ Result: verified=false, distance=0.89
✅ UI: "✗ Tidak Cocok"
✅ Log: Updated
```

### 5. Error Handling
```
❌ Response status: 400
❌ Backend error: [detailed message]
❌ UI: Error message displayed clearly
❌ Console: Full traceback for debugging
```

---

## Success Indicators ✅

Your application is working correctly if you see:

- [ ] Backend terminal shows "Uvicorn running on http://0.0.0.0:5000"
- [ ] Frontend browser shows the UI without errors
- [ ] Health check returns {"status": "ok"}
- [ ] Employee data can be added without errors
- [ ] Verification produces a result (verified or not)
- [ ] Error messages display clearly when something fails
- [ ] Browser console (F12) shows proper logs
- [ ] Attendance log updates correctly
- [ ] Camera mode captures and verifies in real-time

---

## Debugging with Output

If something goes wrong:

1. **Check Backend Terminal**: Look for error messages
2. **Check Browser Console (F12)**: Look for JavaScript errors
3. **Check Network Tab (F12)**: Look for failed requests
4. **Check Health Endpoint**: `curl http://localhost:5000/health`
5. **Check Logs**: Review TROUBLESHOOTING.md

---

**Last Updated**: January 11, 2025
