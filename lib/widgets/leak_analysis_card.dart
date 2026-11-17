import 'package:flutter/material.dart';
import '../models/leak_analysis.dart';
import '../models/transaction_entry.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Financial Leak Detector card — shows expense category breakdown + warnings
class LeakAnalysisCard extends StatelessWidget {
  final List<DayEntry> entries;

  const LeakAnalysisCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final analysis = LeakAnalysis.analyze(entries);

    if (analysis.totalIncome == 0 && analysis.totalExpense == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCardDecoration(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.radar_rounded, color: Color(0xFFEF4444), size: 16),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETEKTOR KEBOCORAN FINANSIAL',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.white54),
                  ),
                  Text(
                    'Analisis pola pengeluaran bulan ini',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Income / Expense / Save ratio bar
          _buildRatioBar(analysis),

          const SizedBox(height: 14),

          // Category breakdown (top 3 max)
          if (analysis.categoryBreakdowns.isNotEmpty) ...[
            const Text(
              'Distribusi Pengeluaran',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ...analysis.categoryBreakdowns.take(4).map((cat) => _buildCategoryRow(cat)),
            const SizedBox(height: 10),
          ],

          // Warnings or Clean Status
          if (analysis.warnings.isNotEmpty)
            ...analysis.warnings.map((w) => _buildWarningChip(w))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 13, color: AppTheme.cyberMint),
                  SizedBox(width: 6),
                  Text(
                    'Arus Kas Sehat • Tidak terdeteksi kebocoran kritis',
                    style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatioBar(LeakAnalysis analysis) {
    final total = analysis.totalIncome;
    if (total <= 0) return const SizedBox.shrink();

    final expRatio = (analysis.expenseRatio / 100).clamp(0.0, 1.0);
    final saveRatio = (analysis.saveRatio / 100).clamp(0.0, 1.0);
    final sisaRatio = (1.0 - expRatio - saveRatio).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    if (expRatio > 0)
                      Flexible(
                        flex: (expRatio * 100).round(),
                        child: Container(height: 10, color: const Color(0xFFEF4444)),
                      ),
                    if (saveRatio > 0)
                      Flexible(
                        flex: (saveRatio * 100).round(),
                        child: Container(height: 10, color: const Color(0xFF3B82F6)),
                      ),
                    if (sisaRatio > 0)
                      Flexible(
                        flex: (sisaRatio * 100).clamp(0, 100).round(),
                        child: Container(height: 10, color: const Color(0xFF10B981)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ratioLabel('Keluar', analysis.expenseRatio, const Color(0xFFEF4444)),
            _ratioLabel('Simpan', analysis.saveRatio, const Color(0xFF3B82F6)),
            _ratioLabel('Sisa', (100 - analysis.expenseRatio - analysis.saveRatio).clamp(0, 100), const Color(0xFF10B981)),
            Text(
              CurrencyFormatter.formatShort(analysis.totalIncome),
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratioLabel(String label, double pct, Color color) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          '$label ${pct.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(CategorySummary cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            cat.category.emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat.category.displayName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    Text(
                      '${cat.percentage.toStringAsFixed(0)}% · ${CurrencyFormatter.formatShort(cat.totalAmount)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (cat.percentage / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cat.percentage > 50
                          ? const Color(0xFFEF4444)
                          : cat.percentage > 30
                              ? const Color(0xFFF59E0B)
                              : AppTheme.cyberMint,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningChip(LeakWarning w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: w.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: w.color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(w.icon, color: w.color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: w.color)),
                const SizedBox(height: 2),
                Text(w.message, style: const TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
