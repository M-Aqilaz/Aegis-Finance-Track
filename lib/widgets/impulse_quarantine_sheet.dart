import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/impulse_item.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class ImpulseQuarantineSheet extends StatefulWidget {
  final StorageService storageService;

  const ImpulseQuarantineSheet({super.key, required this.storageService});

  static Future<void> show(BuildContext context, {required StorageService storageService}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ImpulseQuarantineSheet(storageService: storageService),
    );
  }

  @override
  State<ImpulseQuarantineSheet> createState() => _ImpulseQuarantineSheetState();
}

class _ImpulseQuarantineSheetState extends State<ImpulseQuarantineSheet> {
  void _handleDivert(ImpulseItem item) {
    final goals = widget.storageService.savingsGoals;
    if (goals.isEmpty) {
      widget.storageService.divertImpulseToSavings(item);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.cyberMint,
            content: Text(
              '🎉 Hebat! ${CurrencyFormatter.formatRp(item.amount)} berhasil diamankan ke Tabungan!',
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCardElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Alokasikan Uang Hemat ke Mana?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Anda berhasil menahan nafsu belanja ${CurrencyFormatter.formatRp(item.amount)}. Masukkan ke target impian:',
              style: const TextStyle(fontSize: 11.5, color: Colors.white60),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.savings_rounded, color: AppTheme.cyberMint),
              title: const Text('Tabungan Utama (Simpanan Umum)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              onTap: () async {
                await widget.storageService.divertImpulseToSavings(item);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
            ),
            const Divider(color: Colors.white10),
            ...goals.map((g) {
              return ListTile(
                leading: const Icon(Icons.flag_rounded, color: Color(0xFF818CF8)),
                title: Text(g.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Terkumpul ${CurrencyFormatter.formatRp(g.currentAmount)} / ${CurrencyFormatter.formatRp(g.targetAmount)}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                onTap: () async {
                  await widget.storageService.depositToSavingsGoal(
                    goalId: g.id,
                    amount: item.amount,
                    fromPocketId: StorageService.kPocketCashId,
                  );
                  await widget.storageService.updateImpulseItem(item.copyWith(status: 'saved'));
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.cyberMint,
                        content: Text(
                          '🚀 Luar biasa! ${CurrencyFormatter.formatRp(item.amount)} dialokasikan ke [${g.title}]!',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openAddImpulseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    int hours = 48;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF818CF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Tahan Belanja Impulsif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tunda keinginan belanja ini selama 48 jam. 74% impuls belanja akan hilang setelah masa pending berlalu.',
                style: TextStyle(fontSize: 11.5, color: Colors.white60),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Nama Barang / Keinginan',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  hintText: 'Misal: Skin Game, Jaket, Sepatu',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.cyberMint, fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  hintText: 'Misal: 150000',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = CurrencyFormatter.parseAmount(amountController.text);
                if (title.isEmpty || amount <= 0) return;

                final item = ImpulseItem(
                  id: const Uuid().v4(),
                  title: title,
                  amount: amount,
                  createdAt: DateTime.now(),
                  durationHours: hours,
                  category: 'Keinginan',
                );

                await widget.storageService.addImpulseItem(item);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
              },
              child: const Text('Karantina 48 Jam', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingItems = widget.storageService.pendingImpulseItems;
    final historyItems = widget.storageService.impulseItems.where((i) => i.status != 'pending').toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: const BoxDecoration(
        color: AppTheme.obsidianBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.electricIndigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 18,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KOTAK PENDING (48 JAM)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Isolasi keinginan sebelum dompet jebol',
                        style: TextStyle(fontSize: 10.5, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.cyberMint, size: 24),
                tooltip: 'Tahan Belanja Baru',
                onPressed: _openAddImpulseDialog,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Content List
          Expanded(
            child: pendingItems.isEmpty && historyItems.isEmpty
                ? _buildEmptyState()
                : ListView(
                    children: [
                      if (pendingItems.isNotEmpty) ...[
                        const Text(
                          'SEDANG DALAM MASA TAHAN (PENDING)',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...pendingItems.map((item) => _buildItemCard(item)),
                      ],

                      if (historyItems.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        const Text(
                          'RIWAYAT KEPUTUSAN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...historyItems.map((item) => _buildHistoryCard(item)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: AppTheme.cyberMint,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Belanja yang Ditahan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Saat kepikiran mau beli skin game, baju, atau barang non-pokok, tahan dulu 48 jam di sini!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberMint,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _openAddImpulseDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tahan Belanja Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ImpulseItem item) {
    final lifeDays = widget.storageService.calculateLifeDaysEquivalent(item.amount);
    final isDone = item.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppTheme.cyberMint.withValues(alpha: 0.4) : const Color(0xFF6366F1).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatRp(item.amount),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.cyberMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.solarAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 12, color: AppTheme.solarAmber),
                    const SizedBox(width: 4),
                    Text(
                      'Setara ~${lifeDays.toStringAsFixed(1)} Hari Jatah Hidup',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.solarAmber,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                item.remainingTimeString,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppTheme.cyberMint : const Color(0xFF818CF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.cyberMint,
                    side: const BorderSide(color: AppTheme.cyberMint, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _handleDivert(item),
                  icon: const Icon(Icons.savings_rounded, size: 15),
                  label: const Text('Simpan ke Tabungan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () async {
                  await widget.storageService.claimImpulseAsPurchase(item);
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.surfaceCard,
                        content: Text('Tercatat sebagai pengeluaran hari ini: ${item.title}'),
                      ),
                    );
                  }
                },
                child: const Text('Beli', style: TextStyle(fontSize: 11.5)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white38),
                onPressed: () async {
                  await widget.storageService.deleteImpulseItem(item.id);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ImpulseItem item) {
    final isSaved = item.status == 'saved';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            isSaved ? Icons.savings_rounded : Icons.shopping_bag_outlined,
            size: 16,
            color: isSaved ? AppTheme.cyberMint : Colors.white54,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                Text(
                  isSaved ? 'Dialihkan ke Tabungan' : 'Dibeli setelah pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSaved ? AppTheme.cyberMint.withValues(alpha: 0.8) : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatRp(item.amount),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isSaved ? AppTheme.cyberMint : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
