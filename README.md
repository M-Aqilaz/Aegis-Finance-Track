<p align="center">
  <img src="docs/screenshots/aegis_mascot_logo.jpg" alt="Aegis Finance Mascot" width="120" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,245,155,0.3);"/>
</p>

<h1 align="center">🛡️ Aegis Finance • Phoenix Edition</h1>

<p align="center">
  <strong>The Sophisticated, Offline-First Personal Wealth Guardian</strong><br>
  Designed with an Obsidian Cosmic aesthetic, Apple Watch-inspired financial activity rings, and military-grade PIN vault privacy.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Tests-28%2F28%20Passed-10B981" alt="Tests"/>
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline--First-00F59B" alt="Privacy"/>
  <img src="https://img.shields.io/badge/License-MIT-F59E0B" alt="License"/>
</p>

---

## 🌟 Overview

**Aegis Finance** is a modern personal finance application built with Flutter. Unlike standard expense tracking apps that feel like spreadsheets or casual toys, Aegis Finance treats personal finance with prestige and intentionality:

1. **Hierarchy of Truth**: Your actual net worth and liquid accounts appear first. No clutter, no distractions.
2. **Absolute Privacy by Design**: 100% offline-first. Your financial ledger never leaves your device. No analytics, no telemetry, no third-party cloud leaks.
3. **Sophisticated Gamification**: Replaces guilt-inducing streak banners with subtle micro-pills and concentric financial health rings inspired by Apple Watch activity rings.

---

## 📱 Visual Showcase

<table align="center">
  <tr>
    <td align="center"><b>Dashboard & Net Worth</b></td>
    <td align="center"><b>Aegis Security Vault (PIN Lock)</b></td>
    <td align="center"><b>Privacy & Vault Controls</b></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/aegis_finance_preview.png" width="260"/></td>
    <td><img src="docs/screenshots/aegis_pin_lock_preview.png" width="260"/></td>
    <td><img src="docs/screenshots/aegis_settings_preview.png" width="260"/></td>
  </tr>
</table>

---

## ⚡ Core Features

### 1. 💳 The Black Titanium VIP Card (Net Worth First)
* Instant glance at total consolidated wealth (**Net Worth**), liquid cash, high-yield savings, and digital bank accounts (SeaBank, Bank Jago, etc.).
* Realistic golden EMV chip, contactless waves glyph, and holographic ambient aura.
* **Instant Transfer & Ambil Dana**: Move funds seamlessly between pockets with conservation of funds.

### 2. 🟣 🟢 🟡 Concentric Financial Activity Rings
* Custom-drawn with Flutter `CustomPainter`:
  * **Ring 1 (Electric Purple 🟣)**: *Catat Streak* — Daily logging consistency.
  * **Ring 2 (Cyber-Mint 🟢)**: *Kendali Kas* — Real-time radar of daily expense vs. budget limit.
  * **Ring 3 (Solar Amber 🟡)**: *Nabung Vault* — Monthly savings goal progression.
* Cyber-Phoenix guardian avatar sits at the center of the ring.

### 3. 🔒 Aegis Security Vault (PIN & Biometric Lock)
* **4-Digit Tactile Numpad**: Custom obsidian numpad with alphanumeric sub-labels (ABC, DEF...).
* **Haptic Feedback**: Realistic vibration response on keypress, confirmation, and error states.
* **Auto-Lock Lifecycle**: Automatically locks the app whenever minimized or switched to another app.
* **Biometric Shortcut**: 1-tap fingerprint / Face ID instant unlock.

### 4. 👁️ "Tongkrongan Mode" (Privacy Curtain)
* One-tap eye toggle in the top bar and on the Titanium Card.
* Instantly disguises all sensitive figures as `Rp ••••••••` and `Rp •••`, allowing you to record expenses comfortably in public or cafes without shoulder surfers peeking at your balances.

### 5. ⚡ 3-Second Quick-Log BottomSheet
* Tactile numeric keypad, fast amount chips (`+5k`, `+10k`, `+20k`, `+50k`, `+100k`), and vibrant category avatars to log transactions in under 3 seconds.

### 6. 📊 Leakage Radar & Comprehensive Analytics
* Visual donut charts and latte factor detector that highlights wasteful micro-spending.
* Month-over-month trend recaps and exportable audit logs.

---

## 📐 Mathematical Invariants & Architecture

Aegis Finance is backed by strict financial formulas tested rigorously:

| Metric | Definition | Mathematical Invariant |
|---|---|---|
| **Sisa (Cash)** | Operational liquid cash | $\text{Sisa}_t = \text{Sisa}_{t-1} + \text{In}_t - \text{Out}_t - \text{Save}_t + \Delta_{\text{transfer}}$ |
| **Total Simpan** | Accumulated vault savings | $\text{TotalSimpan}_t = \text{TotalSimpan}_{t-1} + \text{Save}_t + \Delta_{\text{transfer}}$ |
| **Net Worth** | Total economic assets | $\text{NetWorth} = \text{Sisa} + \text{Total Simpan} + \sum \text{CustomAssets}$ |

---

## 🧪 Automated Test Suite

Aegis Finance maintains a 100% green test suite (28 passing tests):
* **Recalculation Engine Invariants**: Inductive proofs for Sisa and Simpan across arbitrary dates.
* **Chronological Ordering**: Guarantees balance consistency regardless of transaction insertion order.
* **Conservation of Assets**: Verifies fund totals before and after transfers between bank accounts.
* **Aegis Vault PIN Engine**: Validates setup, verification, persistence across restarts, and state machines.

To run tests:
```bash
flutter test
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.24+ recommended)
* Dart 3.5+
* Android Studio / VS Code

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/aegis-finance.git
   cd aegis-finance
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Building Release APK
To compile the standalone split APKs for Android:
```bash
flutter build apk --split-per-abi
```
The optimized APKs will be located in `build/app/outputs/flutter-apk/`:
* `app-arm64-v8a-release.apk` (Modern 64-bit Android)
* `app-armeabi-v7a-release.apk` (32-bit Android)

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Crafted with care by <strong>Azure</strong> • <em>Protected by the Cyber-Phoenix Guardian</em> 🦅
</p>
