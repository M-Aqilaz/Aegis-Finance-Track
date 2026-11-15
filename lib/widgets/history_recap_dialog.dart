import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

class HistoryRecapDialog {
  /// Opens the full History Recap and Backup modal sheet
  static void show(BuildContext context, StorageService storageService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HistoryRecapSheet(storageService: storageService),
    );
  }
}

class _HistoryRecapSheet extends StatefulWidget {
  final StorageService storageService;

  const _HistoryRecapSheet({required this.storageService});

  @override
  State<_HistoryRecapSheet> createState() => _HistoryRecapSheetState();
}

class _HistoryRecapSheetState extends State<_HistoryRecapSheet> {
  bool _isProcessing = false;

  Future<void> _handleExportFile() async {
    setState(() => _isProcessing = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final success = await BackupService.exportBackupFile(widget.storageService);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'File cadangan berhasil diekspor!'
                  : 'Gagal mengekspor file cadangan.',
            ),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePickAndImportFile() async {
    setState(() => _isProcessing = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final jsonContent = await BackupService.pickBackupFile();
      if (jsonContent == null || jsonContent.isEmpty) {
        return;
      }

      final preview = BackupService.previewBackup(jsonContent);
      if (!preview.isValid) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(preview.errorMessage ?? 'File cadangan tidak valid.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // Show confirmation dialog with preview details
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (confirmCtx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_download_done, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text('Konfirmasi Impor'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmRow('Total Catatan', '${preview.entriesCount} Hari'),
              _buildConfirmRow('Akun Aset', '${preview.assetsCount} Akun'),
              if (preview.startDate != null && preview.endDate != null)
                _buildConfirmRow(
                  'Periode',
                  '${CurrencyFormatter.formatDate(preview.startDate!)} - ${CurrencyFormatter.formatDate(preview.endDate!)}',
                ),
              _buildConfirmRow('Total Pemasukan', CurrencyFormatter.formatRp(preview.totalIncome)),
              _buildConfirmRow('Total Pengeluaran', CurrencyFormatter.formatRp(preview.totalExpense)),
              _buildConfirmRow('Total Simpanan', CurrencyFormatter.formatRp(preview.totalSaved)),
              _buildConfirmRow('Sisa Kas Akhir', CurrencyFormatter.formatRp(preview.finalSisa)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmCtx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(confirmCtx, true),
              child: const Text('Terapkan & Pulihkan'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await widget.storageService.importJson(jsonContent);
        if (mounted) {
          Navigator.pop(context); // Close recap sheet
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Data riwayat & aset berhasil dipulihkan!'
                    : 'Gagal memulihkan data.',
              ),
              backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handleCopyJsonText() {
    final jsonStr = widget.storageService.exportJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode cadangan disalin ke clipboard! Siap dikirim ke WA/catatan pribadi.'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }

  void _handlePasteJsonDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.paste_rounded, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 8),
            Text('Tempel Kode Cadangan', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempel kode cadangan yang disalin dari HP sebelumnya:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tempel kode di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final success = await widget.storageService.importJson(text);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Data riwayat & aset berhasil dipulihkan!'
                            : 'Gagal memulihkan data. Format kode tidak valid.',
                      ),
                      backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Terapkan & Pulihkan'),
          ),
        ],
      ),
    );
  }

  static Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recap = BackupService.getRecap(widget.storageService);

    String dateRangeStr = 'Belum Ada Catatan';
    if (recap.startDate != null && recap.endDate != null) {
      final startStr = CurrencyFormatter.formatDate(recap.startDate!);
      final endStr = CurrencyFormatter.formatDate(recap.endDate!);
      dateRangeStr = startStr == endStr ? startStr : '$startStr - $endStr';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Date Range Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cadangan & Pindah HP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${recap.totalDays} Hari',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateRangeStr,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            // Pindah HP Info Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phonelink_setup_rounded, color: Color(0xFF818CF8), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mau Ganti HP atau Pindah Device?',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '1. Di HP lama: Simpan file cadangan atau salin kode ke WhatsApp.\n2. Di HP baru: Buka file atau tempel kodenya di menu ini. Semua saldo & riwayat langsung pindah!',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Total Semua Aset Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Semua Aset',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRp(recap.totalAllAssets),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recap Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildRecapStatTile(
                    'Pemasukan',
                    CurrencyFormatter.formatRp(recap.totalIncome),
                    const Color(0xFF10B981),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRecapStatTile(
                    'Pengeluaran',
                    CurrencyFormatter.formatRp(recap.totalExpense),
                    const Color(0xFFEF4444),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRecapStatTile(
                    'Sisa Kas (Cash)',
                    CurrencyFormatter.formatRp(recap.currentSisa),
                    const Color(0xFF8B5CF6),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRecapStatTile(
                    'Total Simpan',
                    CurrencyFormatter.formatRp(recap.totalSaved),
                    const Color(0xFF06B6D4),
                    isDark,
                  ),
                ),
              ],
            ),

            if (recap.assets.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Custom Asset accounts row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: recap.assets.map((a) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: a.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(a.icon, size: 14, color: a.color),
                        const SizedBox(width: 6),
                        Text(
                          '${a.name}: ${CurrencyFormatter.formatShort(a.balance)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: a.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Action Buttons
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // 1. Export File Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _handleExportFile,
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  'Simpan File Cadangan (.json)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Pick & Import File Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _handlePickAndImportFile,
                icon: const Icon(Icons.file_open_rounded),
                label: const Text(
                  'Buka & Pulihkan File Cadangan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Copy / Paste Code Buttons Row
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _handleCopyJsonText,
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text(
                        'Salin Kode (WA)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _handlePasteJsonDialog,
                      icon: const Icon(Icons.paste_rounded, size: 16),
                      label: const Text(
                        'Tempel Kode',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecapStatTile(String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
