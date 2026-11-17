import 'package:flutter/material.dart';
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
      title: '🔔 Aegis Finance: Pengingat Harian Berhasil!',
      body: 'Pengeluaran hari ini sudah dicatat? Cek sisa saldo & tabunganmu sekarang!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi uji coba telah dikirimkan ke bar notifikasi!'),
          backgroundColor: AppTheme.cyberMint,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.storageService;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr =
        '${s.reminderHour.toString().padLeft(2, '0')}:${s.reminderMinute.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
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
                  value: s.pinEnabled,
                  activeThumbColor: AppTheme.cyberMint,
                  onChanged: _togglePinLock,
                ),
                if (s.pinEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppTheme.solarAmber),
                    title: const Text('Ubah PIN Pengaman'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _openPinChange,
                  ),
                ],
              ],
            ),
          ),

          // NOTIFICATION SECTION
          _buildHeader('PENGINGAT & NOTIFIKASI', Icons.notifications_active_outlined),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pengingat Harian', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: s.reminderEnabled,
                  activeThumbColor: AppTheme.cyberMint,
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
                  leading: const Icon(Icons.notification_add, color: AppTheme.cyberMint),
                  title: const Text('Uji Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cyberMint)),
                  trailing: const Icon(Icons.play_arrow_rounded, color: AppTheme.cyberMint),
                  onTap: _testInstantNotification,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CADANGAN & PINDAH HP (DEVICE MIGRATION)
          _buildHeader('CADANGAN & PINDAH HP (GANTI DEVICE)', Icons.phonelink_setup_rounded),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phonelink_setup_rounded, color: AppTheme.electricCyan),
                  title: const Text('Pusat Cadangan & Pindah HP', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Simpan/pulihkan file cadangan atau kirim kode via WA', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => HistoryRecapDialog.show(context, widget.storageService),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined, color: Color(0xFF10B981)),
                  title: const Text('Export ke CSV (Excel)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  subtitle: const Text('Buka di Excel / Google Sheets', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.download_rounded, color: Color(0xFF10B981), size: 20),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await BackupService.exportCsvFile(widget.storageService);
                    if (mounted) {
                      messenger.showSnackBar(SnackBar(
                        content: Text(ok ? '✅ File CSV berhasil disimpan/dibagikan!' : '❌ Gagal export CSV.'),
                        backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
                      ));
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: Colors.orange),
                  title: const Text('Reset Data ke Awal', style: TextStyle(color: Colors.orange)),
                  subtitle: const Text('Kosongkan riwayat transaksi untuk mulai baru', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Data Aplikasi?'),
                        content: const Text(
                          'Semua riwayat transaksi dan penyesuaian saldo akan diatur ulang ke kondisi awal default. Pastikan Anda telah membuat cadangan data jika diperlukan.',
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
                                  const SnackBar(content: Text('Data aplikasi berhasil di-reset ke kondisi awal default.')),
                                );
                              }
                            },
                            child: const Text('Reset Sekarang'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
          Center(
            child: Column(
              children: [
                Text(
                  'Aegis Finance v2.4',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Signature Obsidian Executive • Penyimpanan Lokal Privat',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
