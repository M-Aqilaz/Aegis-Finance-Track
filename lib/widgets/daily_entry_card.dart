import 'package:flutter/material.dart';
import '../models/transaction_entry.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class DailyEntryCard extends StatefulWidget {
  final DayEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DailyEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<DailyEntryCard> createState() => _DailyEntryCardState();
}

class _DailyEntryCardState extends State<DailyEntryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasItems = entry.expenses.isNotEmpty;
    final netCashChange = entry.income - entry.totalExpense - entry.saveAmount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: AppTheme.glassCardDecoration(
        borderRadius: 22,
        glow: entry.saveAmount > 0 || netCashChange > 0,
      ),
      child: Column(
        children: [
          // Header Bar: Date Badge + Net Flow Indicator + Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.electricIndigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.electricIndigo.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 15,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.formatDate(entry.date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Net Flow Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: netCashChange >= 0
                                ? AppTheme.cyberMint.withValues(alpha: 0.12)
                                : AppTheme.neonCoral.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: netCashChange >= 0
                                  ? AppTheme.cyberMint.withValues(alpha: 0.3)
                                  : AppTheme.neonCoral.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                netCashChange >= 0 ? '▲ ' : '▼ ',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: netCashChange >= 0
                                      ? AppTheme.cyberMint
                                      : AppTheme.neonCoral,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                netCashChange >= 0
                                    ? 'Net +${CurrencyFormatter.formatShort(netCashChange)}'
                                    : 'Net -${CurrencyFormatter.formatShort(netCashChange.abs())}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: netCashChange >= 0
                                      ? AppTheme.cyberMint
                                      : AppTheme.neonCoral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: Colors.grey[400],
                      onPressed: widget.onEdit,
                      tooltip: 'Edit Catatan',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppTheme.neonCoral.withValues(alpha: 0.8),
                      onPressed: widget.onDelete,
                      tooltip: 'Hapus Catatan',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppTheme.borderLight, indent: 14, endIndent: 14),

          // Visual Metrics: Masuk, Keluar, Save
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildVisualMetric(
                    label: 'Masuk',
                    value: CurrencyFormatter.formatShort(entry.income),
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.cyberMint,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVisualMetric(
                    label: 'Keluar',
                    value: CurrencyFormatter.formatShort(entry.totalExpense),
                    icon: Icons.arrow_downward_rounded,
                    color: entry.totalExpense > 0 ? AppTheme.neonCoral : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVisualMetric(
                    label: 'Save',
                    value: CurrencyFormatter.formatShort(entry.saveAmount),
                    icon: Icons.savings_rounded,
                    color: AppTheme.electricCyan,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar: Running Sisa & Running Total Simpan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.obsidianBg.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: const Border(
                top: BorderSide(color: AppTheme.borderLight, width: 0.8),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppTheme.cyberMint),
                        const SizedBox(width: 6),
                        const Text(
                          'Sisa: ',
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(entry.runningSisa),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.savings_outlined, size: 14, color: AppTheme.electricCyan),
                        const SizedBox(width: 6),
                        const Text(
                          'Total Simpan: ',
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(entry.runningTotalSimpan),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Expandable items with Category Avatars
                if (hasItems) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCardElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isExpanded ? 'Tutup Rincian' : '${entry.expenses.length} Rincian Pengeluaran',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 8),
                    ...entry.expenses.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCardElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: item.category.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.category.icon,
                                size: 14,
                                color: item.category.color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '-${CurrencyFormatter.formatRp(item.amount)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: item.category.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 10, color: color),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
