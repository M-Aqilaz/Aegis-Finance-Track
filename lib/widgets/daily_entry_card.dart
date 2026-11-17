import 'package:flutter/material.dart';
import '../models/transaction_entry.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class DailyEntryCard extends StatefulWidget {
  final DayEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String activeFilter; // 'all', 'expense', 'income', 'save'
  final bool privacyMode;

  const DailyEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    this.activeFilter = 'all',
    this.privacyMode = false,
  });

  @override
  State<DailyEntryCard> createState() => _DailyEntryCardState();
}

class _DailyEntryCardState extends State<DailyEntryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final filter = widget.activeFilter;

    // Filter-specific rendering
    if (filter == 'expense') {
      return _buildExpenseSpecificCard(entry);
    } else if (filter == 'income') {
      return _buildIncomeSpecificCard(entry);
    } else if (filter == 'save') {
      return _buildSaveSpecificCard(entry);
    }

    // Default 'all' view with soft, modern, eye-friendly layout
    return _buildAllViewCard(entry);
  }

  // --- 1. FILTER: EXPENSE SPECIFIC CARD ---
  Widget _buildExpenseSpecificCard(DayEntry entry) {
    final p = widget.privacyMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: entry.totalExpense > 0
              ? AppTheme.neonCoral.withValues(alpha: 0.3)
              : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            entry,
            pillColor: AppTheme.neonCoral,
            pillText: p ? '-Rp •••' : '-${CurrencyFormatter.formatRp(entry.totalExpense)}',
          ),
          const Divider(height: 1, thickness: 0.8, color: AppTheme.borderLight),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.expenses.isEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.cyberMint.withValues(alpha: 0.8)),
                      const SizedBox(width: 8),
                      const Text(
                        'Hemat! Tidak ada pengeluaran hari ini',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'RINCIAN PENGELUARAN:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white38,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.expenses.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCardElevated,
                          borderRadius: BorderRadius.circular(10),
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
                              child: Icon(item.category.icon, size: 14, color: item.category.color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (item.note.isNotEmpty)
                                    Text(
                                      item.note,
                                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              p ? '-Rp •••' : '-${CurrencyFormatter.formatRp(item.amount)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: item.category.color,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          _buildFooterRow(
            leftLabel: 'Sisa Kas Berjalan',
            leftValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.runningSisa),
            rightLabel: 'Total Pengeluaran',
            rightValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.totalExpense),
            rightColor: AppTheme.neonCoral,
          ),
        ],
      ),
    );
  }

  // --- 2. FILTER: INCOME SPECIFIC CARD ---
  Widget _buildIncomeSpecificCard(DayEntry entry) {
    final p = widget.privacyMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: entry.income > 0
              ? AppTheme.cyberMint.withValues(alpha: 0.3)
              : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            entry,
            pillColor: AppTheme.cyberMint,
            pillText: p ? '+Rp •••' : '+${CurrencyFormatter.formatRp(entry.income)}',
          ),
          const Divider(height: 1, thickness: 0.8, color: AppTheme.borderLight),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_upward_rounded, size: 20, color: AppTheme.cyberMint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pemasukan Kas',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p ? '+Rp •••' : '+${CurrencyFormatter.formatRp(entry.income)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cyberMint,
                        ),
                      ),
                      if (entry.incomeNote.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ket: ${entry.incomeNote}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFooterRow(
            leftLabel: 'Sisa Kas Berjalan',
            leftValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.runningSisa),
            rightLabel: 'Pemasukan Hari Ini',
            rightValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.income),
            rightColor: AppTheme.cyberMint,
          ),
        ],
      ),
    );
  }

  // --- 3. FILTER: SAVE SPECIFIC CARD ---
  Widget _buildSaveSpecificCard(DayEntry entry) {
    final p = widget.privacyMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: entry.saveAmount > 0
              ? AppTheme.electricCyan.withValues(alpha: 0.3)
              : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            entry,
            pillColor: AppTheme.electricCyan,
            pillText: p ? 'Rp ••• Simpan' : '+${CurrencyFormatter.formatRp(entry.saveAmount)} Simpan',
          ),
          const Divider(height: 1, thickness: 0.8, color: AppTheme.borderLight),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.electricCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings_rounded, size: 20, color: AppTheme.electricCyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alokasi ke Vault / Tabungan',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p ? '+Rp •••' : '+${CurrencyFormatter.formatRp(entry.saveAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.electricCyan,
                        ),
                      ),
                      if (entry.saveNote.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ket: ${entry.saveNote}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFooterRow(
            leftLabel: 'Total Tabungan Akumulatif',
            leftValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.runningTotalSimpan),
            rightLabel: 'Simpan Hari Ini',
            rightValue: p ? 'Rp •••' : CurrencyFormatter.formatRp(entry.saveAmount),
            rightColor: AppTheme.electricCyan,
          ),
        ],
      ),
    );
  }

  // --- 4. DEFAULT 'ALL' CARD (CLEAN & EYE-FRIENDLY) ---
  Widget _buildAllViewCard(DayEntry entry) {
    final hasItems = entry.expenses.isNotEmpty;
    final netCashChange = entry.income - entry.totalExpense - entry.saveAmount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.glassCardDecoration(
        borderRadius: 20,
        glow: entry.saveAmount > 0 || netCashChange > 0,
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
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
                        Icons.calendar_today_rounded,
                        size: 14,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: netCashChange >= 0
                                ? AppTheme.cyberMint.withValues(alpha: 0.12)
                                : AppTheme.neonCoral.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            netCashChange >= 0
                                ? '▲ Net +${CurrencyFormatter.formatShort(netCashChange)}'
                                : '▼ Net -${CurrencyFormatter.formatShort(netCashChange.abs())}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: netCashChange >= 0 ? AppTheme.cyberMint : AppTheme.neonCoral,
                            ),
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

          const Divider(height: 1, thickness: 0.8, color: AppTheme.borderLight, indent: 14, endIndent: 14),

          // Calmer, softer 3-column summary (not glaring boxes)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildSubtleMetric(
                    label: 'Masuk',
                    value: widget.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(entry.income),
                    color: AppTheme.cyberMint,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                Container(width: 1, height: 24, color: AppTheme.borderLight),
                Expanded(
                  child: _buildSubtleMetric(
                    label: 'Keluar',
                    value: widget.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(entry.totalExpense),
                    color: entry.totalExpense > 0 ? AppTheme.neonCoral : Colors.white38,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                Container(width: 1, height: 24, color: AppTheme.borderLight),
                Expanded(
                  child: _buildSubtleMetric(
                    label: 'Save',
                    value: widget.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(entry.saveAmount),
                    color: AppTheme.electricCyan,
                    icon: Icons.savings_rounded,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.obsidianBg.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
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
                    Expanded(
                      child: Text(
                        'Sisa Kas: ${widget.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(entry.runningSisa)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Simpan: ${widget.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(entry.runningTotalSimpan)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.electricCyan,
                      ),
                    ),
                  ],
                ),
                if (hasItems) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            size: 14,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isExpanded ? 'Tutup Rincian' : '${entry.expenses.length} Rincian Pengeluaran',
                            style: const TextStyle(fontSize: 11, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 6),
                    ...entry.expenses.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(item.category.icon, size: 12, color: item.category.color),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                                ),
                              ),
                              Text(
                                widget.privacyMode ? '-Rp •••' : '-${CurrencyFormatter.formatRp(item.amount)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: item.category.color,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE HELPER COMPONENTS ---
  Widget _buildHeader(DayEntry entry, {required Color pillColor, required String pillText}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    CurrencyFormatter.formatDate(entry.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: pillColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pillText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: pillColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.edit_outlined, size: 17),
                color: Colors.grey[400],
                onPressed: widget.onEdit,
                tooltip: 'Edit Catatan',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.delete_outline, size: 17),
                color: AppTheme.neonCoral.withValues(alpha: 0.8),
                onPressed: widget.onDelete,
                tooltip: 'Hapus Catatan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    Color rightColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.obsidianBg.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: const Border(
          top: BorderSide(color: AppTheme.borderLight, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$leftLabel: $leftValue',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rightValue,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: rightColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtleMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
