# Mobile Pajak Jambi (SIMPATTI) 📱🇮🇩

Aplikasi Mobile Pembayaran Pajak Daerah untuk wilayah Kota Jambi, terintegrasi dengan Sistem Informasi Pajak Terintegrasi (SIMPATTI). 

Aplikasi ini didesain secara spesifik mengikuti regulasi **UU HKPD (Hubungan Keuangan antara Pemerintah Pusat dan Pemerintahan Daerah)** yang terbaru, di mana objek pajak disederhanakan dan diakses melalui **NPWPD** (Nomor Pokok Wajib Pajak Daerah) untuk usaha, dan **NOP** (Nomor Objek Pajak) untuk properti.

---

## 🎨 Fitur Utama & UI/UX
- **UI Modern & Premium**: Menggunakan kombinasi warna *Navy Blue*, putih bersih, dan aksen *Light Blue* dengan tipografi elegan (Google Fonts: Lora & Inter).
- **Dashboard Cerdas**: Menu utama disederhanakan menjadi 3 kategori besar yang merepresentasikan sistem asli BPPRD:
  - 🏠 **Pajak PBB** (Berbasis NOP)
  - 🏡 **BPHTB** (Pajak Transaksional / ID Transaksi)
  - 🏪 **Pajak Lainnya** (Berbasis NPWPD - Mencakup Hotel, Restoran, Hiburan, Parkir, Listrik, Reklame, dll).
- **Simulasi Tagihan Otomatis**: Cukup mendaftarkan 1 NPWPD, sistem akan otomatis mendeteksi dan menampilkan tagihan dari seluruh cabang usaha yang dimiliki (misal: Hotel + Kafe + Parkir).
- **Profil Terpadu**: Halaman profil yang menampilkan *badge verified*, menu akun, dan ringkasan **Pajak Terdaftar** beserta tenggat waktunya.

---

## 🛠️ Teknologi yang Digunakan
- **Framework:** [Flutter](https://flutter.dev/)
- **Bahasa Pemrograman:** Dart
- **State Management:** Provider (`ChangeNotifier`)
- **Routing:** GoRouter (Declarative Routing)
- **Desain & Font:** `google_fonts` (Lora & Inter)
- **Formatting:** `intl` (Untuk format mata uang Rupiah & Tanggal)

---

## 📂 Struktur Folder
```text
lib/
├── constants/
│   ├── colors.dart         # Konfigurasi warna utama UI
│   └── tax_config.dart     # Konfigurasi 3 menu utama & detail 11 jenis pajak
├── models/
│   └── tax_model.dart      # (Optional) Model data terpisah
├── providers/
│   └── tax_provider.dart   # Logic utama: simulasi NPWPD, tambah tagihan, dan histori bayar
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── register_nop_screen.dart  # Form daftar NOP/NPWPD
│   ├── main_shell.dart           # Bottom Navigation Bar
│   ├── home_screen.dart          # Dashboard 3 Menu Utama
│   ├── history_screen.dart
│   ├── profile_screen.dart       # Profil dengan List Pajak Terdaftar
│   ├── check_tax_screen.dart     # Form pencarian tagihan spesifik
│   ├── detail_pajak_screen.dart
│   ├── payment_method_screen.dart
│   └── payment_success_screen.dart
└── main.dart                     # Entry point & inisialisasi AppRouter
```

---

## 🚀 Cara Menjalankan Project (Run Locally)

1. **Pastikan Flutter SDK ter-install.**
   Cek dengan menjalankan:
   ```bash
   flutter doctor
   ```

2. **Clone Repository ini:**
   ```bash
   git clone https://github.com/Yogiexc/Mobile_Pajak_Jambi.git
   ```

3. **Masuk ke direktori project:**
   ```bash
   cd Mobile_Pajak_Jambi
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Jalankan Aplikasi:**
   ```bash
   flutter run
   ```
   *(Aplikasi ini sudah dioptimalkan dan dites menggunakan Google Chrome / Web Emulator selama masa development).*

---

## 📝 Catatan Penting
Aplikasi ini masih dalam tahap *Frontend Development* (Mockup/UI). Seluruh data tagihan dan riwayat pembayaran diatur menggunakan *dummy data* yang disimulasikan melalui `TaxProvider`. 

**Developed with ❤️ for BPPRD Kota Jambi.**
