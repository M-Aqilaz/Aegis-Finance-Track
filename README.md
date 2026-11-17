<p align="center">
  <img src="docs/screenshots/aegis_mascot_logo.jpg" alt="Aegis Finance Mascot" width="90" style="border-radius: 20px; box-shadow: 0 6px 20px rgba(0,245,155,0.2);"/>
</p>

<h1 align="center">Aegis Finance</h1>

<p align="center">
  <strong>Aplikasi Pembukuan & Manajemen Keuangan Pribadi 100% Offline-First</strong><br>
  Lacak arus kas harian, tabungan, dan rekening bank digital tanpa registrasi akun, tanpa iklan, dan tanpa server luar.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Tests-31%2F31%20Passed-10B981" alt="Tests"/>
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-00F59B" alt="Privacy"/>
  <img src="https://img.shields.io/badge/Theme-Obsidian%20%26%20Light-8B5CF6" alt="Theme"/>
  <img src="https://img.shields.io/badge/License-MIT-F59E0B" alt="License"/>
</p>

---

## 📱 Tampilan Aplikasi

<table align="center">
  <tr>
    <td align="center"><b>💳 Beranda & Cincin</b></td>
    <td align="center"><b>⚡ Catat 3 Detik</b></td>
    <td align="center"><b>📊 Alokasi Kantong</b></td>
    <td align="center"><b>📅 Riwayat Kas</b></td>
    <td align="center"><b>🔒 PIN Vault</b></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/aegis_finance_preview.png" width="180" alt="Beranda"/></td>
    <td><img src="docs/screenshots/aegis_input_preview.png" width="180" alt="Catat Cepat"/></td>
    <td><img src="docs/screenshots/aegis_asset_preview.png" width="180" alt="Alokasi Kantong"/></td>
    <td><img src="docs/screenshots/aegis_history_preview.png" width="180" alt="Riwayat Kas"/></td>
    <td><img src="docs/screenshots/aegis_pin_lock_preview.png" width="180" alt="PIN Vault"/></td>
  </tr>
</table>

---

## 📥 Download APK Android

Pasang langsung di HP tanpa perlu login atau registrasi akun:

<p align="center">
  <a href="https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/latest/download/AegisFinance-v1.1-arm64.apk">
    <img src="https://img.shields.io/badge/Download_APK_ARM64-21_MB-00F59B?style=for-the-badge&logo=android&logoColor=0B0F17" alt="Download APK ARM64"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/latest/download/AegisFinance-Universal.apk">
    <img src="https://img.shields.io/badge/Download_Universal-Kompatibel_Semua_HP-6366F1?style=for-the-badge&logo=android&logoColor=FFFFFF" alt="Download Universal APK"/>
  </a>
</p>

> **💡 Rekomendasi:**
> - Gunakan versi **ARM64 (~21 MB)** untuk smartphone Android modern (keluaran 2018 ke atas).
> - Gunakan versi **Universal** jika memasang di perangkat lama atau emulator.
>
> **Langkah Pemasangan:**
> 1. Unduh salah satu file APK di atas melalui browser HP.
> 2. Buka notifikasi unduhan lalu pilih **Install / Pasang**.
> 3. Buka Aegis Finance — data langsung aktif dan tersimpan aman di HP Anda.

---

## 🎯 Mengapa Aegis Finance?

Sebagian besar aplikasi keuangan saat ini mewajibkan pembuatan akun, mengunggah catatan pribadi ke cloud pihak ketiga, dan dipenuhi iklan atau langganan bulanan. 

**Aegis Finance dirancang berbeda:**
1. **Nol Dependensi Cloud**: Semua angka, catatan kas, dan mutasi saldo tersimpan murni di penyimpanan lokal HP Anda.
2. **Input Dua Mode Cepat**: Catat pengeluaran instan lewat numpad 3 detik di beranda, atau kelola rincian item dengan kategori lengkap di formulir detail.
3. **Multi-Kantong Saldo Nyata**: Pisahkan uang pegangan tunai (*Cash Stash*), brankas simpanan (*High-Yield Vault*), serta rekening bank digital (*SeaBank, Bank Jago, dll.*). Pindahkan dana antar-kantong secara instan.
4. **Cincin Finansial Harian**: Tiga cincin konsentris (*Catat Harian, Kendali Anggaran, dan Porsi Tabungan*) yang memberi umpan balik visual terhadap disiplin finansial Anda.
5. **Detektor Bocor Halus**: Algoritma lokal yang menganalisis frekuensi pengeluaran kecil berulang (kopi, cemilan harian) beserta estimasi dana yang bisa diselamatkan.
6. **Ekspor & Pindah HP Mandiri**: Ekspor seluruh buku kas ke format `.csv` untuk dibuka di Excel/Spreadsheets, atau gunakan cadangan terenkripsi sekali-klik saat berganti perangkat.
7. **Proteksi PIN 4-Digit**: Lindungi privasi layar saat HP dipinjam teman atau keluarga dengan PIN vault dan fitur sensor saldo instan (*Privacy Eye*).

---

## 🛠️ Pengembangan & Pengujian

Aplikasi dibangun menggunakan Flutter & Dart dengan cakupan uji logika (whitebox & blackbox) komprehensif:

```bash
# Uji seluruh algoritma dan rekurensi saldo (31 tests)
flutter test

# Jalankan aplikasi di emulator / perangkat fisik
flutter run

# Kompilasi paket rilis Android
flutter build apk --split-per-abi
```

---

## 📄 Lisensi

Proyek ini dirilis di bawah lisensi **MIT**. Bebas dipelajari, dimodifikasi, dan dikembangkan kembali.

<p align="center">
  Dibuat dengan dedikasi oleh <strong>M. Aqilaz</strong>
</p>
