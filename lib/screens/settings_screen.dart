import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/history_recap_dialog.dart';
import 'pin_lock_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;

  const SettingsScreen({super.key, required this.storageService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  void _openPinSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PinLockScreen(
          storageService: widget.storageService,
          mode: PinLockMode.setup,
          onSuccess: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  void _openPinChange() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PinLockScreen(
          storageService: widget.storageService,
          mode: PinLockMode.change,
          onSuccess: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  void _togglePinLock(bool value) async {
    if (value) {
      _openPinSetup();
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceCardElevated,
          title: const Text('Nonaktifkan PIN Pengaman?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Aplikasi tidak akan terkunci lagi saat dibuka. Semua orang yang meminjam HP Anda bisa melihat saldo.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Nonaktifkan', style: TextStyle(color: AppTheme.neonCoral)),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await widget.storageService.disablePin();
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _pickTime() async {
    final s = widget.storageService;
    final initialTime = TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'PILIH JAM PENGINGAT HARIAN',
    );

    if (picked != null) {
      await widget.storageService.updateSettings(
        reminderHour: picked.hour,
        reminderMinute: picked.minute,
      );
      if (widget.storageService.reminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat harian disetel ke pukul ${picked.format(context)}',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    await widget.storageService.updateSettings(reminderEnabled: value);
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi belum diizinkan oleh sistem.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await _notificationService.scheduleDailyReminder(
        hour: widget.storageService.reminderHour,
        minute: widget.storageService.reminderMinute,
      );
    } else {
      await _notificationService.cancelReminder(101);
    }
    setState(() {});
  }

  Future<void> _testInstantNotification() async {
    await _notificationService.requestPermissions();
    await _notificationService.showInstantNotification(
      id: 999,
      title: '🔔 Financial Track: Pengingat Harian Berhasil!',
      body: 'Pengeluaran hari ini sudah dicatat? Cek sisa saldo & tabunganmu sekarang!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi uji coba telah dikirimkan ke bar notifikasi!'),
          backgroundColor: Color(0xFF6366F1),
        ),
      );
    }
  }

  void _showFormulaExplanation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.calculate_outlined, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Rumus Financial Track'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sistem perhitungan otomatis sesuai format pencatatanmu:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildFormulaItem(
                'Pemasukan (Income)',
                'Semua uang yang masuk ke kantongmu hari itu.',
                const Color(0xFF10B981),
              ),
              _buildFormulaItem(
                'Pengeluaran (Expense)',
                'Semua biaya hidup yang keluar. Dicatat rinci per kategori agar tidak bocor.',
                const Color(0xFFEF4444),
              ),
              _buildFormulaItem(
                'Save (Tabungan Harian)',
                'Uang yang disisihkan hari ini ke tabungan / brankas.',
                const Color(0xFF3B82F6),
              ),
              _buildFormulaItem(
                'Sisa (Saldo Kas Berjalan)',
                'Sisa Hari Ini = Sisa Kemarin + Pemasukan - Pengeluaran - Save.',
                const Color(0xFF8B5CF6),
              ),
              _buildFormulaItem(
                'Total Simpan (Akumulasi)',
                'Total Simpan = Total Simpan Kemarin + Save Hari Ini.',
                const Color(0xFF06B6D4),
              ),
              _buildFormulaItem(
                'Total Kekayaan (Net Worth)',
                'Net Worth = Sisa Saldo + Total Simpan.',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final jsonStr = widget.storageService.exportJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ekspor Cadangan Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salin teks JSON berikut untuk mencadangkan atau memindahkan catatan ke perangkat lain:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data JSON berhasil disalin ke clipboard!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Salin Data'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impor Data JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel teks data cadangan JSON yang valid di bawah ini:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '[{"date": "2026-11-03...", ...}]',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final success = await widget.storageService.importJson(text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Data berhasil diimpor & saldo telah dihitung ulang!'
                            : 'Gagal mengimpor data. Format JSON tidak sesuai.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Impor'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaItem(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.storageService;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr =
        '${s.reminderHour.toString().padLeft(2, '0')}:${s.reminderMinute.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      backgroundColor: AppTheme.obsidianBg,
      appBar: AppBar(
        backgroundColor: AppTheme.obsidianBg,
        elevation: 0,
        title: const Text(
          'Pengaturan & Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AEGIS VAULT SECURITY SECTION
          _buildHeader('KEAMANAN & PRIVASI (AEGIS VAULT)', Icons.shield_rounded),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.pin_rounded, color: AppTheme.cyberMint),
                  title: const Text('Kunci Aplikasi dengan PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    s.pinEnabled
                        ? 'Aegis Vault aktif (Aplikasi terkunci saat dibuka)'
                        : 'Nonaktif (Aplikasi langsung terbuka)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: s.pinEnabled,
                  activeThumbColor: AppTheme.cyberMint,
                  onChanged: _togglePinLock,
                ),
                if (s.pinEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppTheme.solarAmber),
                    title: const Text('Ubah PIN Pengaman'),
                    subtitle: const Text('Ganti 4-digit PIN rahasia Anda', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _openPinChange,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppTheme.electricCyan),
                    title: const Text('Buka Cepat dengan Biometrik', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Gunakan Sidik Jari / Face ID di lockscreen', style: TextStyle(fontSize: 12)),
                    value: s.biometricsEnabled,
                    activeThumbColor: AppTheme.electricCyan,
                    onChanged: (val) async {
                      await s.toggleBiometrics(val);
                      setState(() {});
                    },
                  ),
                ],
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_off_rounded, color: AppTheme.solarAmber),
                  title: const Text('Tongkrongan Mode (Privasi Saldo)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Samarkan nominal saldo menjadi Rp ••• di beranda', style: TextStyle(fontSize: 12)),
                  value: s.privacyMode,
                  activeThumbColor: AppTheme.solarAmber,
                  onChanged: (val) async {
                    await s.togglePrivacyMode();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // NOTIFICATION SECTION
          _buildHeader('PENGINGAT & NOTIFIKASI', Icons.notifications_active_outlined),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pengingat Harian', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: s.reminderEnabled,
                  activeThumbColor: const Color(0xFF6366F1),
                  onChanged: _toggleReminder,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded),
                  title: const Text('Waktu Pengingat'),
                  subtitle: Text(timeStr),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  enabled: s.reminderEnabled,
                  onTap: s.reminderEnabled ? _pickTime : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notification_add, color: Color(0xFF6366F1)),
                  title: const Text('Uji Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF6366F1)),
                  onTap: _testInstantNotification,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // FINANCIAL LOGIC & GUIDE
          _buildHeader('PANDUAN RUMUS', Icons.lightbulb_outline),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.functions_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('Rumus Sisa & Total Simpan'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _showFormulaExplanation,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // BACKUP & RESTORE
          _buildHeader('DATA & REKAPAN', Icons.backup_outlined),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics_rounded, color: Color(0xFF6366F1)),
                  title: const Text('Rekap & Cadangan Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => HistoryRecapDialog.show(context, widget.storageService),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: Color(0xFF10B981)),
                  title: const Text('Ekspor File Cadangan (.json)'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await BackupService.exportBackupFile(widget.storageService);
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'File cadangan berhasil diekspor / disimpan!'
                                : 'Gagal mengekspor file cadangan.',
                          ),
                          backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_open_rounded, color: Color(0xFF3B82F6)),
                  title: const Text('Pilih & Impor File (.json)'),
                  onTap: () => HistoryRecapDialog.show(context, widget.storageService),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_snippet_outlined, color: Colors.blueGrey),
                  title: const Text('Salin Teks Cadangan (JSON)'),
                  onTap: _showExportDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.paste_rounded, color: Colors.blueGrey),
                  title: const Text('Tempel Teks Cadangan (JSON)'),
                  onTap: _showImportDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.orange),
                  title: const Text('Reset ke Data 3-8 Nov 2026', style: TextStyle(color: Colors.orange)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Data?'),
                        content: const Text(
                          'Data akan dikembalikan ke catatan resmi 3-8 November 2026 dan saldo SeaBank Rp 30.000.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await widget.storageService.resetToDefault();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Data berhasil di-reset ke 3-8 November 2026')),
                                );
                              }
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Financial Track v1.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
