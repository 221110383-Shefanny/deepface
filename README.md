#  DeepFace Verification Dashboard

Aplikasi web berbasis **FastAPI** dan **React** yang memungkinkan pengguna melakukan verifikasi wajah menggunakan teknologi **DeepFace**. 
Sistem ini dirancang untuk memverifikasi identitas seseorang melalui pencocokan wajah secara otomatis menggunakan teknologi DeepFace.

> 📌 *Catatan: tidak dilakukan deployment ke platform cloud. Semua fungsi dijalankan secara lokal untuk keperluan pengujian dan dokumentasi.*

---

## 👥 Anggota Kelompok

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

## 7. Troubleshooting
- **Python version:** Gunakan Python 3.10 (bukan 3.14) agar kompatibel dengan deepface & tensorflow.
- **Error tensorflow/deepface:** Pastikan versi Python dan dependensi sudah sesuai.
- **CORS error:** Pastikan backend mengaktifkan CORS (sudah diatur di app.py).
- **Port bentrok:** Jika port 8000/3000 sudah dipakai, ganti dengan port lain di perintah uvicorn/npm start.
- **File __pycache__:** Folder ini bisa diabaikan/dihapus, tidak mempengaruhi source code.

## 8. Catatan Penggunaan API
- Endpoint utama: `/verify` (POST, upload dua gambar dengan key `img1_path` dan `img2_path`)
---
Jika ada kendala, cek error di terminal dan pastikan semua dependensi sudah terinstall dengan benar. 

LINK FILE ZIP : https://mikroskilacid-my.sharepoint.com/:u:/g/personal/221110383_students_mikroskil_ac_id/EXgBcLRqJ_VLrGA1cTSWzrQB0YvCWQ585KDcirQH_lA3lA?e=c2oM19
