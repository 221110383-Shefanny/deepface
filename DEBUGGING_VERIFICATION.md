# DEBUGGING: Verifikasi Masih Gagal

## Status Update
Telah ditambahkan parameter yang lebih lengkap:

### Perubahan Backend (routes.py)
✅ `enforce_detection`: `True` → `False`
✅ `threshold`: Sekarang support `float` dan conversion dari `str`
✅ Logging detail untuk setiap parameter termasuk threshold
✅ Error handling untuk konversi threshold yang gagal

### Perubahan Frontend (App.js)
✅ Semua 3 lokasi verifikasi sekarang mengirim:
   - `threshold=0.5` (override default)
   - `enforce_detection=false` (lebih fleksibel)
   
✅ Lokasi 1: Initial camera capture (line ~414)
✅ Lokasi 2: Retry camera capture (line ~561)
✅ Lokasi 3: Manual upload (handleVerify) (line ~823)

---

## PENTING: RESTART BACKEND DIPERLUKAN!

```bash
# 1. Stop backend yang lama (Ctrl+C di terminal backend)
# 2. Jalankan ulang:
python main.py
```

---

## Cara Testing & Debugging

### Step 1: Restart Backend
```
Ctrl+C untuk stop backend yang lama
python main.py
```

### Step 2: Cek Console Backend
Harus melihat log seperti ini:

```
🔄 Starting verification with parameters:
   - Model: Facenet512
   - Detector Backend: retinaface
   - Distance Metric: cosine
   - Enforce Detection: False                    ← PENTING: harus False
   - Align: True
   - Normalization: base
   - Anti-spoofing: False
   - Custom Threshold (raw): 0.5               ← Parameter dari frontend
   - Converted Threshold: 0.5                  ← Berhasil dikonversi
   - Using custom threshold: 0.5               ← Digunakan untuk verifikasi

✅ Verification successful!
   - Verified: True                            ← CRITICAL: harus True jika cocok
   - Distance: 0.25                            ← Lebih rendah = lebih cocok
   - Threshold: 0.5
```

### Step 3: Buka Aplikasi Frontend
```
http://localhost:3000
```

### Step 4: Test Verifikasi
1. **Tab "Input Wajah Karyawan"**
   - Upload foto karyawan (misalkan: "Budi")
   - Klik "✓ Tambah Karyawan"
   - Lihat di daftar karyawan ada "Budi"

2. **Tab "Menu Absensi"**
   - Pilih tipe: "🔓 Absensi Masuk"
   - **Upload Foto atau Ambil Foto**:
     - **Upload**: Pilih foto yang SAMA seperti yang di-upload di step 1
     - **Camera**: Capture wajah Anda (SAMA dengan foto awal)
   - Klik "✓ Verifikasi Wajah"

### Step 5: Cek Hasil
**Jika berhasil:**
```
✓ Terverifikasi
Nama: Budi
Distance: 0.25
```

**Jika masih gagal:**
```
✗ Tidak Cocok dengan Siapapun
Distance: N/A
```

---

## Kemungkinan Penyebab Masih Gagal

### A. Backend Belum Di-restart
**Solusi**: Restart backend dengan `python main.py`

### B. Image Quality Terlalu Rendah
- Foto blur atau ukuran terlalu kecil
- **Solusi**: Ambil foto yang lebih jelas dan dekat

### C. Perbedaan Kondisi Terlalu Besar
- Lighting berbeda, angle berbeda, expression berbeda
- **Solusi**: Coba dengan foto yang lebih mirip

### D. Model Facenet512 Terlalu Ketat
- Threshold 0.5 sudah cukup toleran, tapi mungkin belum cukup
- **Solusi Alternatif**: Coba model lain atau naikkan threshold ke 0.6

---

## Jika Ingin Naikkan Threshold Lebih Lagi

Ubah di 3 lokasi di `App.js`:

```javascript
// Dari
formData.append("threshold", "0.5");

// Menjadi
formData.append("threshold", "0.6"); // Atau 0.7, 0.8, dst
```

**Range threshold untuk Facenet512:**
- 0.3 = sangat ketat (default)
- 0.4-0.5 = ketat
- 0.6-0.7 = sedang
- 0.8+ = sangat toleran (risiko false positive)

---

## Untuk Akurasi Maksimal

Pastikan saat upload dan verifikasi:
1. ✅ Wajah frontal (jangan miring)
2. ✅ Cukup terang (hindari backlight)
3. ✅ Tidak ada occlusion (kacamata OK, tapi jangan tertutup)
4. ✅ Photo quality tinggi (min 200x200 pixel)
5. ✅ Expression serupa (tersenyum atau netral konsisten)

---

**Status**: 🔧 SIAP TESTING - Restart backend terlebih dahulu!
