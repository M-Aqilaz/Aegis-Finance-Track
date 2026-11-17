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
  <img src="https://img.shields.io/badge/Version-v1.2.0-blue?logo=android" alt="Version"/>
  <img src="https://img.shields.io/badge/Tests-36%2F36%20Passed-10B981" alt="Tests"/>
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-00F59B" alt="Privacy"/>
  <img src="https://img.shields.io/badge/Theme-Obsidian%20Executive-00F59B" alt="Theme"/>
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

## 📥 Download APK Android (v1.2.0)

Pasang langsung di HP tanpa perlu login atau registrasi akun:

<p align="center">
  <a href="https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/download/v1.2.0/AegisFinance-v1.2-arm64.apk">
    <img src="https://img.shields.io/badge/Download_APK_ARM64-v1.2.0_(21_MB)-00F59B?style=for-the-badge&logo=android&logoColor=0B0F17" alt="Download APK ARM64"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/download/v1.2.0/AegisFinance-v1.2-Universal.apk">
    <img src="https://img.shields.io/badge/Download_Universal-v1.2.0_(Semua_HP)-6366F1?style=for-the-badge&logo=android&logoColor=FFFFFF" alt="Download Universal APK"/>
  </a>
</p>

> **💡 Rekomendasi:**
> - Gunakan versi **ARM64 (~21 MB)** untuk smartphone Android modern (keluaran 2018 ke atas: Samsung, Xiaomi, Poco, Vivo, Oppo, Infinix, dsb).
> - Gunakan versi **Universal (~57 MB)** jika memasang di perangkat lawas atau emulator Android.
>
> **Langkah Pemasangan:**
> 1. Unduh salah satu file APK di atas melalui browser HP.
> 2. Buka notifikasi unduhan lalu pilih **Install / Pasang**.
> 3. Buka Aegis Finance — seluruh data langsung aktif dan tersimpan privat 100% di perangkat Anda.

---

## 🎯 Mengapa Aegis Finance?

Sebagian besar aplikasi keuangan saat ini mewajibkan pembuatan akun, mengunggah catatan pribadi ke cloud pihak ketiga, dan dipenuhi iklan atau langganan bulanan. 

**Aegis Finance dirancang berbeda:**
1. **Nol Dependensi Cloud**: Semua angka, catatan kas, dan mutasi saldo tersimpan murni di penyimpanan lokal HP Anda.
2. **⚡ One-Liner Smart Command Bar**: Catat transaksi secepat mengetik chat (`nasi padang 25k`, `kopi 18k seabank`, `gaji 2jt`). Parser otomatis mengekstrak nominal, kategori, dan kantong bank target tanpa perlu membuka formulir modal berbelit-belit.
3. **🛡 Freedom Runway & Safe Daily Pacing**: Tahu persis berapa hari atau bulan Anda bisa bertahan hidup dari cadangan likuid saat ini jika tanpa pemasukan sama sekali, lengkap dengan rekomendasi batas belanja harian yang aman.
4. **Multi-Kantong Saldo Nyata**: Pisahkan uang pegangan tunai (*Cash Stash*), brankas simpanan (*High-Yield Vault*), serta rekening bank digital (*SeaBank, Bank Jago, BCA, dll.*). Pindahkan dana antar-kantong secara instan.
5. **Cincin Finansial Harian**: Tiga cincin konsentris (*Catat Harian, Kendali Anggaran, dan Porsi Tabungan*) yang memberi umpan balik visual terhadap disiplin finansial Anda.
6. **Detektor Bocor Halus**: Algoritma lokal yang menganalisis frekuensi pengeluaran kecil berulang (kopi, cemilan harian) beserta estimasi dana yang bisa diselamatkan tanpa saran moralistis.
7. **Ekspor & Pindah HP Mandiri**: Ekspor seluruh buku kas ke format `.csv` untuk dibuka di Excel/Spreadsheets, atau gunakan cadangan terenkripsi sekali-klik saat berganti perangkat.
8. **Proteksi PIN 4-Digit**: Lindungi privasi layar saat HP dipinjam teman atau keluarga dengan PIN vault dan fitur sensor saldo instan (*Privacy Eye*).

---

## 🛠️ Pengembangan & Pengujian

Aplikasi dibangun menggunakan Flutter & Dart dengan cakupan uji logika (whitebox, blackbox, dan widget) komprehensif:

```bash
# Uji seluruh algoritma rekurensi saldo, parser perintah, dan keamanan PIN (36 tests)
flutter test

# Jalankan aplikasi di emulator / perangkat fisik
flutter run

# Kompilasi paket rilis Android (ARM64 & Universal)
flutter build apk --split-per-abi
flutter build apk
```

---

## 📄 Lisensi

Proyek ini dirilis di bawah lisensi **MIT**. Bebas dipelajari, dimodifikasi, dan dikembangkan kembali.

<p align="center">
  Dibuat dengan dedikasi oleh <strong>M. Aqilaz</strong>
</p>
