import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../screens/add_edit_entry_screen.dart';

class RecentTransactionsCard extends StatelessWidget {
  final StorageService storageService;
  final VoidCallback onViewAll;

  const RecentTransactionsCard({
    super.key,
    required this.storageService,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final entries = storageService.entries;
    final privacyMode = storageService.privacyMode;

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 36, color: Colors.white30),
            const SizedBox(height: 10),
            const Text(
              'Belum ada transaksi tercatat',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ketuk "Catat Transaksi" di atas untuk mencatat pengeluaran atau pemasukan pertamamu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // Sort entries descending to get the most recent days
    final sortedEntries = List<DayEntry>.from(entries)..sort((a, b) => b.date.compareTo(a.date));

    // Extract recent items: up to 4 recent distinct actions (expenses, incomes, saves)
    final recentItems = <_RecentActivityItem>[];
    for (final day in sortedEntries) {
      // 1. Detailed expenses
      for (final exp in day.expenses) {
        recentItems.add(_RecentActivityItem(
          title: exp.title.isNotEmpty ? exp.title : exp.category.displayName,
          subtitle: '${DateFormat('d MMM', 'id_ID').format(day.date)} • ${exp.category.displayName}',
          amount: exp.amount,
          isExpense: true,
          icon: exp.category.icon,
          iconColor: const Color(0xFFF87171),
          dayEntry: day,
        ));
        if (recentItems.length >= 4) break;
      }
      if (recentItems.length >= 4) break;

      // 2. Direct expense fallback
      if (day.directExpense > 0 && day.expenses.isEmpty) {
        recentItems.add(_RecentActivityItem(
          title: 'Pengeluaran Harian',
          subtitle: DateFormat('d MMM', 'id_ID').format(day.date),
          amount: day.directExpense,
          isExpense: true,
          icon: Icons.shopping_bag_outlined,
          iconColor: const Color(0xFFF87171),
          dayEntry: day,
        ));
        if (recentItems.length >= 4) break;
      }

      // 3. Income
      if (day.income > 0) {
        recentItems.add(_RecentActivityItem(
          title: day.incomeNote.isNotEmpty ? day.incomeNote : 'Pemasukan',
          subtitle: DateFormat('d MMM', 'id_ID').format(day.date),
          amount: day.income,
          isExpense: false,
          isIncome: true,
          icon: Icons.arrow_downward_rounded,
          iconColor: AppTheme.cyberMint,
          dayEntry: day,
        ));
        if (recentItems.length >= 4) break;
      }

      // 4. Save
      if (day.saveAmount > 0) {
        recentItems.add(_RecentActivityItem(
          title: day.saveNote.isNotEmpty ? day.saveNote : 'Simpan ke Tabungan',
          subtitle: DateFormat('d MMM', 'id_ID').format(day.date),
          amount: day.saveAmount,
          isExpense: false,
          isSave: true,
          icon: Icons.savings_outlined,
          iconColor: AppTheme.solarAmber,
          dayEntry: day,
        ));
        if (recentItems.length >= 4) break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: recentItems.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withValues(alpha: 0.06),
          height: 1,
          indent: 56,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = recentItems[index];
          final amountText = privacyMode
              ? 'Rp •••'
              : (item.isExpense
                  ? '-${CurrencyFormatter.formatShort(item.amount)}'
                  : '+${CurrencyFormatter.formatShort(item.amount)}');

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditEntryScreen(
                    storageService: storageService,
                    existingEntry: item.dayEntry,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: 18, color: item.iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountText,
                    style: TextStyle(
                      color: item.isExpense
                          ? const Color(0xFFF87171)
                          : (item.isIncome ? AppTheme.cyberMint : AppTheme.solarAmber),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentActivityItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final bool isIncome;
  final bool isSave;
  final IconData icon;
  final Color iconColor;
  final DayEntry dayEntry;

  const _RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    this.isIncome = false,
    this.isSave = false,
    required this.icon,
    required this.iconColor,
    required this.dayEntry,
  });
}
