#  DeepFace Verification Dashboard

Aplikasi web berbasis **FastAPI** dan **React** yang memungkinkan pengguna melakukan verifikasi wajah menggunakan teknologi **DeepFace**. 
Sistem ini dirancang untuk memverifikasi identitas seseorang melalui pencocokan wajah secara otomatis menggunakan teknologi DeepFace.


---

## 👥 Anggota Kelompok 
(NB : hanya untuk mata kuliah Machine Learning)

| Nama Lengkap              | NIM       |
|---------------------------|-----------|
| Shefanny                  | 221110838 |
| Gilbert Garvin Widjaja    | 221111169 |
| Charlie William Wijaya    | 221110844 |

---

##  Petunjuk Penggunaan Aplikasi

###  Fitur Utama
- **Upload Gambar Wajah**: Pengguna dapat mengunggah gambar untuk proses verifikasi.
- **Verifikasi Wajah**: Sistem membandingkan dua gambar wajah dan memberikan hasil kecocokan dalam bentuk persentase.
    -Persentase kecocokan (misalnya: similarity: 92.3%)
    -Status verifikasi berupa nilai boolean (verified: true atau verified: false)
- **Representasi Wajah**: Menampilkan vektor representasi wajah untuk keperluan analisis atau pencocokan lanjutan.
- **Antarmuka Interaktif**: Menyediakan dashboard dengan preview gambar dan hasil verifikasi secara real-time.
  

###  Cara Menggunakan
1. Jalankan backend FastAPI secara lokal.
2. Jalankan frontend React secara lokal.
3. Akses aplikasi melalui browser di `http://localhost:3000`.
4. Gunakan fitur verifikasi wajah dengan mengunggah dua gambar.
5. Hasil akan ditampilkan dalam bentuk persentase kecocokan dan status validasi.

---

# 🚀 Quick Start - Jalankan Aplikasi

## Option 1: Menggunakan Docker Compose (Recommended) ⭐

Paling mudah dan tidak perlu install banyak dependencies.

```bash
cd d:\MIKROSKIL\OPERASI\deepface
docker-compose up
```

Aplikasi akan berjalan di:
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:5000

## Option 2: Menjalankan Manual (Local)

### Backend:
```bash
cd d:\MIKROSKIL\OPERASI\deepface\backend
pip install -r requirements.txt
python app.py
```

Backend berjalan di: `http://localhost:5000`

### Frontend (Buka terminal baru):
```bash
cd d:\MIKROSKIL\OPERASI\deepface\frontend
npm install
npm start
```

Frontend berjalan di: `http://localhost:3000`

---

# Petunjuk Instalasi & Menjalankan Proyek DeepFace Secara Lokal

## 1. Clone Repository
Clone repository dari GitHub:
```
git clone https://github.com/221110383-Shefanny/deepface.git
```

## 2. Masuk ke Folder Backend
```
cd deepface/backend
```

## 3. Install Semua Dependensi Backend
```
py -3.10 -m pip install -r requirements.txt 
```

## 4. Jalankan Server FastAPI
```
py -3.10 -m uvicorn backend.app:app --reload (jalankan di folder root)
```
Server akan berjalan di http://localhost:8000

## 5. Akses Dokumentasi API
Buka browser dan akses:
```
http://localhost:8000/docs
```
atau
```
http://localhost:8000/redoc
```

## 6. Menjalankan Frontend (React)
1. Masuk ke folder frontend:
```
cd ../frontend
```
2. Install dependensi frontend:
```
npm install
```
3. Jalankan frontend:
```
npm start
```
4. Buka browser dan akses:
```
http://localhost:3000
```


---

## Troubleshooting

Jika mengalami masalah, lihat file **`TROUBLESHOOTING.md`** untuk panduan lengkap.

### Common Issues:

| Problem | Solution |
|---------|----------|
| "Cannot reach backend" | Pastikan backend berjalan di port 5000 |
| "Foto karyawan tidak ditemukan" | Tambahkan data karyawan terlebih dahulu di halaman "Input Data Karyawan" |
| "No face detected" | Foto harus menunjukkan wajah dengan jelas, pencahayaan cukup |
| "Model not found" | Tunggu proses download model (pertama kali ~5-10 menit) |
| Python version error | Gunakan Python 3.10+ untuk kompatibilitas |
| CORS error | CORS sudah dikonfigurasi di `app.py` - restart backend jika belum terdeteksi |
| Port sudah dipakai | Ganti port di `docker-compose.yml` atau command line |

---

## API Endpoints

### 1. Verify (Verifikasi Wajah)
```
POST /verify
Content-Type: multipart/form-data

Parameters:
- img1: File (foto database/karyawan)
- img2: File (foto attendance/kamera)
- model_name: str (default: "Facenet512")
- detector_backend: str (default: "retinaface")

Response:
{
  "verified": true/false,
  "distance": 0.45,
  "threshold": 0.6,
  "model": "Facenet512",
  "detector_backend": "retinaface",
  ...
}
```

### 2. Health Check
```
GET /health

Response:
{
  "status": "ok",
  "message": "Backend is running",
  "deepface_available": true
}
```

---

## File Structure

```
deepface/
├── backend/
│   ├── app.py                 # Main FastAPI application
│   ├── routes.py              # API routes (/verify, /represent, /health)
│   ├── requirements.txt        # Python dependencies
│   ├── Dockerfile             # Docker configuration
│   └── __pycache__/
├── frontend/
│   ├── src/
│   │   ├── App.js             # Main React component
│   │   ├── App.css            # Styles
│   │   └── index.js           # Entry point
│   ├── public/
│   ├── Dockerfile
│   ├── package.json
│   └── node_modules/
├── docker-compose.yml         # Docker Compose configuration
├── README.md                  # This file
├── TROUBLESHOOTING.md         # Detailed troubleshooting guide
└── evalusasi.ipynb            # Evaluation notebook
```

---
