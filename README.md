<p align="center">
  <img src="docs/screenshots/aegis_mascot_logo.jpg" alt="Aegis Finance Mascot" width="120" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,245,155,0.3);"/>
</p>

<h1 align="center">🛡️ Aegis Finance</h1>

<p align="center">
  <strong>Smart Wealth Guardian & Offline-First Personal Finance</strong><br>
  Aplikasi pembukuan keuangan modern dengan estetika <em>Obsidian Cosmic</em>, visual cincin aktivitas finansial ala <em>Apple Watch</em>, dan proteksi keamanan <em>Aegis Security Vault</em> berstandar tinggi.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Tests-29%2F29%20Passed-10B981" alt="Tests"/>
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline--First-00F59B" alt="Privacy"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-FF7043" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-F59E0B" alt="License"/>
</p>

---

## 📥 Download Langsung (Installer APK Siap Pakai)

Bagi pengguna umum atau teman-teman yang ingin langsung menggunakan Aegis Finance di HP Android, **tidak perlu setup Flutter atau coding dari awal!** Cukup unduh installer APK resmi di bawah ini:

<p align="center">
  <a href="https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/latest/download/AegisFinance-Universal.apk">
    <img src="https://img.shields.io/badge/Download_APK-AegisFinance--Universal.apk-00F59B?style=for-the-badge&logo=android&logoColor=0B0F17" alt="Download APK Siap Pakai"/>
  </a>
</p>

### 📱 Panduan Install Cepat di HP Android (3 Langkah):
1. **Download**: Klik tombol download di atas atau unduh melalui halaman [GitHub Releases](https://github.com/M-Aqilaz/Aegis-Finance-Track/releases/latest).
2. **Pasang (Install)**: Buka file `.apk` hasil unduhan di HP Anda. Jika muncul notifikasi *"Izinkan instalasi dari sumber ini"*, pilih **Izinkan (Allow)**.
3. **Beres**: Buka aplikasi dan nikmati pembukuan keuangan pribadi yang 100% offline, tanpa iklan, dan tanpa perlu login/registrasi akun!

---

## 🌟 Overview & Filosofi Desain

Sebagian besar aplikasi pencatat keuangan terasa seperti tabel spreadsheet yang kaku atau mainan kasual yang penuh iklan dan spam notifikasi. **Aegis Finance** dirancang dengan pendekatan prestise, ketenangan pikiran, dan privasi mutlak:

1. **Hierarchy of Truth (Net Worth First)**: Total kekayaan riil (*Net Worth*) dan akun kas Anda ditampilkan di urutan teratas secara elegan dan transparan. Bebas dari clutter visual yang membingungkan.
2. **Privasi Mutlak & Zero-Leak (100% Offline-First)**: Data keuangan Anda adalah privasi sakral. Seluruh transaksi dan saldo tersimpan secara lokal di perangkat Anda (*Local Storage*). Tidak ada cloud pihak ketiga, tidak ada tracking analitik, dan instalasi baru di perangkat lain dimulai bersih (*zero balance*) tanpa kebocoran data.
3. **Desain Universal Bebas Hardcode**: Antarmuka bersih dengan identitas universal (*AEGIS FINANCE - Smart Wealth Guardian*) yang nyaman dan relevan digunakan oleh siapa pun.
4. **Gamifikasi Cincin Aktivitas Finansial**: Menggantikan banner streak yang mencolok dengan mikro-pill api halus dan tiga cincin konsentris yang terinspirasi dari Apple Watch Activity Rings.
5. **Migrasi Perangkat Tanpa Ribet (Pindah HP Jadi Mudah)**: Zero-cloud bukan berarti data Anda terkunci di satu HP. Anda bisa mencadangkan dan memindahkan seluruh saldo dan riwayat ke HP baru semudah menyalin teks ke chat WhatsApp atau mengekspor file cadangan.

---

## 📱 Visual Showcase

<table align="center">
  <tr>
    <td align="center"><b>Dashboard & Net Worth</b></td>
    <td align="center"><b>Aegis Security Vault (PIN Lock)</b></td>
    <td align="center"><b>Pengaturan & Privasi Vault</b></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/aegis_finance_preview.png" width="260"/></td>
    <td><img src="docs/screenshots/aegis_pin_lock_preview.png" width="260"/></td>
    <td><img src="docs/screenshots/aegis_settings_preview.png" width="260"/></td>
  </tr>
</table>

---

## ⚡ Fitur Utama (Core Features)

### 1. 💳 Black Titanium VIP Card & Multi-Pocket Assets
* **Net Worth Real-Time**: Pantau total akumulasi kekayaan secara terpusat, memadukan sisa kas cair (*Cash Stash*), brankas tabungan (*High-Yield Vault*), dan rekening digital (SeaBank, Bank Jago, atau kantong kustom lainnya).
* **Detail Finishing Mewah**: Kartu titanium gelap dengan golden EMV chip, glyph contactless wave, dan ambient aura holografik.
* **Pindah / Ambil Dana Seketika**: Transfer dana antar rekening atau tarik tabungan ke kas harian dengan hukum kekekalan dana (*conservation of funds*) tanpa selisih matematis.

### 2. 🟣 🟢 🟡 Trio Cincin Finansial Konsentris (Apple Watch Style)
* Digambar khusus dengan Flutter `CustomPainter` berkonsentris tiga:
  * **Cincin 1 (Ungu Elektrik 🟣)**: *Catat Streak* — Memantau konsistensi pencatatan transaksi harian Anda.
  * **Cincin 2 (Cyber-Mint 🟢)**: *Kendali Kas* — Radar real-time pengeluaran hari ini terhadap batas budget.
  * **Cincin 3 (Solar Amber 🟡)**: *Nabung Vault* — Progres tabungan bulanan menuju target finansial.
* Avatar maskot penjaga Aegis terletak elegan di pusat cincin.

### 3. 🔒 Aegis Security Vault (PIN 4-Digit & Biometrik)
* **Numpad Taktil Obsidian**: Keyboard angka custom bernuansa obsidian dengan sub-label alfabet (ABC, DEF...).
* **Haptic Vibration Feedback**: Respons getaran taktil yang realistis pada penekanan tombol angka dan konfirmasi keamanan.
* **Auto-Lock Lifecycle**: Otomatis mengunci aplikasi saat diminimalkan atau berpindah aplikasi untuk menjaga kerahasiaan.
* **Buka Cepat Biometrik**: Shortcut autentikasi 1-tap menggunakan sidik jari atau Face ID.

### 4. 👁️ Sensor Privasi Cepat (Privacy Curtain)
* Toggle 1-tap berlambang mata di top bar dan kartu Titanium VIP.
* Seketika menyamarkan seluruh nominal angka saldo menjadi `Rp ••••••••` dan `Rp •••`, sehingga Anda bisa mencatat pengeluaran di kafe atau tempat umum dengan nyaman tanpa khawatir orang di sebelah melirik saldo Anda.

### 5. ⚡ Pencatatan Kilat 3 Detik (Quick-Log)
* Modal lembar bawah (*BottomSheet*) gesit dengan numpad taktil terintegrasi.
* Chip nominal instan (`+5k`, `+10k`, `+20k`, `+50k`, `+100k`) dan avatar kategori ekspresif untuk mencatat pengeluaran atau pemasukan harian dalam waktu kurang dari 3 detik.

### 6. 📅 Riwayat Keuangan & Filter Cerdas
* **Filter Interaktif**: Filter chip fungsional (*Semua*, *Pengeluaran*, *Pemasukan*, *Simpan*) untuk meninjau arus kas harian tanpa gangguan visual.
* **Rincian Transaksi Expandable**: Rincian pengeluaran per hari dapat diperluas (*expand/collapse*) untuk melihat rincian item, waktu, dan kategori.
* **Rekapitulasi Bulanan**: Ringkasan akumulasi masuk, keluar, dan simpanan per bulan kalender.

### 7. 📲 Pusat Cadangan & Pindah HP (Device Migration)
* **Bebas Istilah Teknis**: Tidak perlu memahami format JSON yang membingungkan.
* **Salin Kode Cadangan (Kirim ke Chat/WA)**: Cukup salin kode cadangan dan kirimkan ke chat WhatsApp pribadi Anda atau simpan di Catatan HP.
* **Pemulihan 1-Tap**: Di HP baru, cukup pilih file cadangan atau tempel kodenya untuk memulihkan seluruh saldo aset, dompet, dan riwayat catatan dalam hitungan detik.

### 8. ⏰ Pengingat Harian Otomatis
* Notifikasi lokal terjadwal di jam pilihan pengguna (misal pukul 20:00 WIB) agar tidak ada pengeluaran harian yang terlewat dicatat.
* Dilengkapi tombol uji coba notifikasi instan langsung dari menu pengaturan.

---

## 📐 Invariant Matematika & Arsitektur Perhitungan

Aegis Finance dibangun di atas fondasi invariant matematis ketat yang diuji secara deterministik:

| Metrik Finansial | Definisi Operasional | Rumus Invariant Matematis |
|---|---|---|
| **Sisa Kas (Cash)** | Kas cair operasional harian | $\text{Sisa}_t = \text{Sisa}_{t-1} + \text{In}_t - \text{Out}_t - \text{Save}_t + \Delta_{\text{transfer}}$ |
| **Total Simpan** | Akumulasi tabungan vault | $\text{TotalSimpan}_t = \text{TotalSimpan}_{t-1} + \text{Save}_t + \Delta_{\text{transfer}}$ |
| **Net Worth** | Total kekayaan bersih konsolidasi | $\text{NetWorth} = \text{Sisa} + \text{Total Simpan} + \sum \text{CustomAssets}$ |

---

## 🧪 Automated Test Suite (29/29 Passed)

Aegis Finance mempertahankan 100% green test suite dengan 29 skenario pengujian otomatis (*white-box* & *black-box*):
* **Recalculation Engine**: Pembuktian induktif perhitungan running balance Sisa Kas & Total Simpan lintas hari.
* **Conservation of Assets**: Verifikasi kekekalan nilai total aset sebelum dan sesudah transfer dana antar rekening/kantong.
* **Indonesian Currency Parser**: Pengujian parsing notasi angka Indonesia (`40k`, `50rb`, `1.5jt`, teks desimal).
* **Storage Migration & Auto-Upgrade**: Validasi backward-compatibility impor data lama maupun format modern.
* **Streak & Gamification Algorithms**: Perhitungan kontinuitas hari berturut-turut tanpa false positive.
* **Aegis Vault PIN & Zero-Leak Security**: Validasi lifecycle PIN pengaman, biometrik, enkripsi lokal, dan inisialisasi data bersih.

Untuk menjalankan seluruh unit test:
```bash
flutter test
```

---

## 🚀 Panduan Developer (Build dari Source)

### Prasyarat
* Flutter SDK (3.24+ disarankan)
* Dart SDK 3.5+
* Android Studio / VS Code

### Instalasi & Menjalankan Aplikasi
1. Clone repository:
   ```bash
   git clone https://github.com/M-Aqilaz/Aegis-Finance-Track.git
   cd Aegis-Finance-Track
   ```
2. Pasang dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di emulator atau HP:
   ```bash
   flutter run
   ```

### Mengompilasi APK Rilis Sendiri
Untuk mengompilasi APK rilis bertanda tangan (*Universal APK*):
```bash
flutter build apk --release
```
File APK siap instal akan berada di folder `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📜 Lisensi

Didistribusikan di bawah **MIT License**. Lihat file `LICENSE` untuk informasi selengkapnya.

---

<p align="center">
  Crafted with care by <strong>M.Aqilaz</strong>
</p>
