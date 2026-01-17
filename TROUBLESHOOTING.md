# TROUBLESHOOTING - Verifikasi Wajah Gagal

Jika Anda melihat error "verifikasi wajah gagal, tidak memberikan hasil", ikuti langkah-langkah berikut:

## 1. Pastikan Backend Berjalan

### Option A: Menggunakan Docker Compose (Recommended)
```bash
cd d:\MIKROSKIL\OPERASI\deepface
docker-compose up
```

Backend akan berjalan di `http://localhost:5000`
Frontend akan berjalan di `http://localhost:3000`

### Option B: Menjalankan Backend Manual
```bash
cd d:\MIKROSKIL\OPERASI\deepface\backend
pip install -r requirements.txt
python app.py
```

Pastikan output menunjukkan:
```
✅ Uvicorn running on http://0.0.0.0:5000
```

### Option C: Menjalankan Frontend Manual
```bash
cd d:\MIKROSKIL\OPERASI\deepface\frontend
npm install
npm start
```

Pastikan output menunjukkan:
```
Compiled successfully!
You can now view the app in the browser.
Local: http://localhost:3000
```

## 2. Check Backend Status

Buka browser dan akses: `http://localhost:5000/`

Anda seharusnya melihat:
```json
{
  "message": "Face Verification API is running",
  "version": "1.0.0",
  "endpoints": {
    "verify": "/verify",
    "represent": "/represent",
    "health": "/health"
  }
}
```

Jika tidak, backend belum berjalan.

## 3. Common Error Messages & Solutions

### ❌ "Network Error" atau "Cannot reach backend"
- **Penyebab**: Backend tidak berjalan atau tidak accessible
- **Solusi**: 
  1. Pastikan backend sudah dijalankan (`python app.py` atau `docker-compose up`)
  2. Cek port 5000 tidak digunakan aplikasi lain
  3. Di Windows, coba buka Firewall settings dan allow port 5000

### ❌ "Foto karyawan tidak ditemukan di database"
- **Penyebab**: Belum ada data karyawan atau foto tidak tersimpan
- **Solusi**:
  1. Pergi ke halaman "Input Data Karyawan"
  2. Masukkan nama karyawan
  3. Pilih departemen
  4. Upload foto dengan jelas menunjukkan wajah
  5. Klik tombol "✓ Verifikasi Wajah"

### ❌ "DeepFace model not found" atau "Timeout"
- **Penyebab**: Model DeepFace sedang download (pertama kali)
- **Solusi**:
  1. Tunggu 5-10 menit untuk model download
  2. Cek koneksi internet
  3. Check space disk, minimal 2-3 GB tersedia

### ❌ "No face detected"
- **Penyebab**: Foto tidak menunjukkan wajah dengan jelas
- **Solusi**:
  1. Pastikan wajah terlihat jelas di foto
  2. Pencahayaan cukup baik
  3. Wajah menghadap ke kamera langsung
  4. Upload foto baru atau ambil foto dari kamera dengan kondisi lebih baik

### ❌ "Face verification failed - Low similarity"
- **Penyebab**: Wajah di camera tidak cocok dengan database (berbeda orang)
- **Solusi**:
  1. Pastikan orang yang benar
  2. Coba ambil ulang foto dari kamera
  3. Atau gunakan foto yang sudah di-upload

## 4. Check Python Dependencies

Buka PowerShell/Terminal dan jalankan:
```bash
pip list | findstr -i "deepface tensorflow opencv fastapi"
```

Pastikan installed:
- deepface
- tensorflow
- opencv-python
- fastapi
- uvicorn
- python-multipart

Jika ada yang missing, install ulang:
```bash
cd d:\MIKROSKIL\OPERASI\deepface\backend
pip install -r requirements.txt
```

## 5. Clear Temporary Files (Optional)

Jika terlalu banyak temporary files di backend folder:
```bash
cd d:\MIKROSKIL\OPERASI\deepface\backend
del /F /Q *.jpg 2>nul
```

## 6. Check Console Output

### Di Backend (Terminal/Console):
Seharusnya melihat logs seperti:
```
✅ File saved: xxx_img1.jpg (12345 bytes)
✅ File saved: xxx_img2.jpg (12345 bytes)
🔄 Starting verification with model=Facenet512, backend=retinaface
✅ Verification successful: {'verified': True, 'distance': 0.45, ...}
```

### Di Frontend (Browser Developer Tools - F12):
Seharusnya melihat:
```
🔄 Mengirim verifikasi ke backend...
Response status: 200
Verification result: {verified: true, distance: 0.45}
✅ Attendance record saved successfully
```

Jika ada error, akan terlihat jelas di console.

## 7. Restart Everything

Jika masih ada masalah, coba restart:
```bash
# Kalau pakai Docker Compose
docker-compose down
docker-compose up --build

# Kalau manual
# 1. Close terminal backend
# 2. Close browser frontend
# 3. Jalankan ulang app.py
# 4. Refresh browser (F5)
```

## 8. System Requirements

Minimal:
- RAM: 4 GB (better 8GB+)
- Disk: 5 GB free (untuk models)
- Python: 3.8+
- GPU: Optional (lebih cepat tapi CPU juga ok)

## Need Help?

Jika masih tidak bisa, coba:
1. Check log files (ada di backend folder)
2. Buka issue dengan error message lengkap
3. Screenshot dari browser console (F12 > Console tab)

---

**Last Updated**: January 2025
**Version**: 1.0
