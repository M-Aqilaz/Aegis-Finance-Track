import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/leak_analysis.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

class LeakageScreen extends StatefulWidget {
  final StorageService storageService;

  const LeakageScreen({super.key, required this.storageService});

  @override
  State<LeakageScreen> createState() => _LeakageScreenState();
}

class _LeakageScreenState extends State<LeakageScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.storageService,
      builder: (context, _) {
        final entries = widget.storageService.entries;
        final analysis = LeakAnalysis.analyze(entries);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (entries.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Belum ada data transaksi')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Radar Kebocoran', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Masuk', CurrencyFormatter.formatShort(analysis.totalIncome), const Color(0xFF10B981)),
                      _buildStat('Keluar', CurrencyFormatter.formatShort(analysis.totalExpense), const Color(0xFFEF4444)),
                      _buildStat('Simpan', CurrencyFormatter.formatShort(analysis.totalSaved), const Color(0xFF06B6D4)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Chart & Categories
                if (analysis.totalExpense > 0 && analysis.categoryBreakdowns.isNotEmpty) ...[
                  const Text('Kategori Pengeluaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              sections: List.generate(
                                analysis.categoryBreakdowns.length,
                                (i) {
                                  final isTouched = i == _touchedIndex;
                                  final item = analysis.categoryBreakdowns[i];
                                  final radius = isTouched ? 55.0 : 45.0;
                                  return PieChartSectionData(
                                    color: item.category.color,
                                    value: item.totalAmount,
                                    title: '${item.percentage.toStringAsFixed(0)}%',
                                    radius: radius,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...analysis.categoryBreakdowns.map((catItem) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: catItem.category.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    catItem.category.displayName.split('(').first.trim(),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatRp(catItem.totalAmount),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: catItem.category.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Top Items
                if (analysis.allExpenseItems.isNotEmpty) ...[
                  const Text('Item Terbesar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...analysis.allExpenseItems.take(5).map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: Text(
                          CurrencyFormatter.formatRp(item.amount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: item.category.color,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
