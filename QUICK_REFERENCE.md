# 🔧 QUICK REFERENCE - DeepFace Face Verification

## Jika Verifikasi Gagal / Tidak Ada Hasil

### ✅ Langkah 1: Pastikan Backend Berjalan

**Check Status**:
- Buka browser ke: `http://localhost:5000/health`
- Seharusnya melihat: `{"status": "ok", "message": "Backend is running"}`

**Jika tidak berjalan**:
```bash
cd backend
python app.py
```

### ✅ Langkah 2: Pastikan Frontend Berjalan

**Check Status**:
- Buka browser ke: `http://localhost:3000`
- Seharusnya melihat aplikasi UI

**Jika tidak berjalan**:
```bash
cd frontend
npm start
```

### ✅ Langkah 3: Debug Error Messages

**Di Browser (F12)**:
1. Buka DevTools (tekan F12)
2. Lihat tab "Console" - akan terlihat error messages
3. Lihat tab "Network" - check status response dari backend

**Output Normal**:
```
🔄 Mengirim verifikasi ke backend...
Response status: 200
Verification result: {verified: true, distance: 0.45}
✅ Attendance record saved successfully
```

**Output Error**:
```
Response status: 400
Backend error: No face detected in image
```

### ✅ Langkah 4: Input Data Karyawan Dulu!

**PENTING**: Sebelum verifikasi, harus ada data karyawan:

1. Klik "Input Data Karyawan"
2. Masukkan:
   - **Nama**: Nama lengkap karyawan
   - **Departemen**: Pilih salah satu
   - **Foto**: Upload foto wajah yang jelas
3. Klik "✓ Tambah Karyawan"

**Foto harus**:
- ✅ Menunjukkan wajah dengan jelas
- ✅ Pencahayaan cukup baik
- ✅ Wajah menghadap ke kamera
- ✅ Format: JPG, PNG, atau format gambar standar

### ✅ Langkah 5: Verifikasi Wajah

Setelah ada data karyawan:

1. Klik "Menu Absensi Karyawan"
2. Pilih karyawan dari dropdown
3. Pilih "Absensi Masuk" atau "Absensi Keluar"
4. Upload foto atau ambil dari kamera
5. Klik "✓ Verifikasi Wajah"

**Result Ditampilkan di panel kanan**:
- ✅ Jika cocok: Status "✓ Terverifikasi", distance kecil (< 0.6)
- ✅ Jika tidak: Status "✗ Tidak Cocok", distance besar (> 0.6)
- ❌ Jika error: Error message dengan penjelasan

---

## Common Error & Solution

| Error | Penyebab | Solusi |
|-------|---------|--------|
| "Cannot reach backend" | Backend tidak berjalan | `python app.py` |
| "Foto karyawan tidak ditemukan" | Belum input data karyawan | Input di halaman "Input Data Karyawan" |
| "No face detected" | Foto tidak menunjukkan wajah | Upload foto wajah yang lebih jelas |
| "Network Error" | Frontend tidak connect ke backend | Check browser console (F12) |
| "DeepFace model not found" | Model sedang download | Tunggu 5-10 menit |
| "Connection refused" | Port 5000 sudah dipakai | Ubah port atau tutup aplikasi lain |

---

## Port Configuration

| Component | Port | URL |
|-----------|------|-----|
| Frontend (React) | 3000 | http://localhost:3000 |
| Backend (FastAPI) | 5000 | http://localhost:5000 |
| API Docs (Swagger) | 5000 | http://localhost:5000/docs |
| Health Check | 5000 | http://localhost:5000/health |

---

## Performance Tips

1. **First time run**: Tunggu DeepFace model download (~2-3 GB)
2. **Camera mode**: Akan auto-capture ketika wajah cocok
3. **Upload mode**: Manual klik tombol "Verifikasi Wajah"
4. **Distance**: Lebih kecil = lebih mirip (threshold 0.6)

---

## File Locations

- Backend code: `backend/app.py`, `backend/routes.py`
- Frontend code: `frontend/src/App.js`
- Config: `docker-compose.yml`
- Docs: `README.md`, `TROUBLESHOOTING.md`, `PERBAIKAN_SUMMARY.md`

---

## Getting Help

1. **Cek TROUBLESHOOTING.md**: Detailed guide untuk semua masalah
2. **Cek PERBAIKAN_SUMMARY.md**: Detail teknis perbaikan yang dilakukan
3. **Browser Console (F12)**: Lihat exact error messages
4. **Backend Terminal**: Lihat logs dari server

---

## Useful Commands

```bash
# Run dengan Docker (Recommended)
docker-compose up

# Run backend manual
cd backend
python app.py

# Run frontend manual
cd frontend
npm start

# Check health
curl http://localhost:5000/health

# View backend logs (in Docker)
docker-compose logs backend

# View frontend logs (in Docker)
docker-compose logs frontend

# Stop Docker
docker-compose down

# Stop manual apps
# Backend: Ctrl+C di terminal
# Frontend: Ctrl+C di terminal
```

---

## Version Info

- **Created**: January 2025
- **DeepFace Models**: 
  - Facenet512 (default, most accurate)
  - Available: VGGFace, DeepFace, ArcFace, etc.
- **Python**: 3.10+
- **Node**: 16+
- **React**: Latest

---

**Last Updated**: January 11, 2025
