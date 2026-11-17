import 'package:flutter/material.dart';
import 'transaction_entry.dart';

class CategorySummary {
  final ExpenseCategory category;
  final double totalAmount;
  final int count;
  final double percentage; // 0.0 - 100.0

  CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.count,
    required this.percentage,
  });
}

class LeakWarning {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String recommendation;

  LeakWarning({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.recommendation,
  });
}

class LeakAnalysis {
  final double totalIncome;
  final double totalExpense;
  final double totalSaved;
  final List<CategorySummary> categoryBreakdowns;
  final List<ExpenseItem> allExpenseItems;
  final List<LeakWarning> warnings;
  final double expenseRatio; // Expense / Income %
  final double saveRatio; // Saved / Income %

  LeakAnalysis({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaved,
    required this.categoryBreakdowns,
    required this.allExpenseItems,
    required this.warnings,
    required this.expenseRatio,
    required this.saveRatio,
  });

  factory LeakAnalysis.analyze(List<DayEntry> entries) {
    double sumIncome = 0;
    double sumExpense = 0;
    double sumSaved = 0;

    final Map<ExpenseCategory, double> catAmounts = {};
    final Map<ExpenseCategory, int> catCounts = {};
    final List<ExpenseItem> allItems = [];

    // Initialize map
    for (var cat in ExpenseCategory.values) {
      catAmounts[cat] = 0.0;
      catCounts[cat] = 0;
    }

    for (var day in entries) {
      sumIncome += day.income;
      sumSaved += day.saveAmount;
      final dayExp = day.totalExpense;
      sumExpense += dayExp;

      if (day.expenses.isNotEmpty) {
        for (var item in day.expenses) {
          allItems.add(item);
          catAmounts[item.category] = (catAmounts[item.category] ?? 0) + item.amount;
          catCounts[item.category] = (catCounts[item.category] ?? 0) + 1;
        }
      } else if (day.directExpense > 0) {
        // Direct lump sum fallback to 'lainnya'
        catAmounts[ExpenseCategory.lainnya] =
            (catAmounts[ExpenseCategory.lainnya] ?? 0) + day.directExpense;
        catCounts[ExpenseCategory.lainnya] =
            (catCounts[ExpenseCategory.lainnya] ?? 0) + 1;
      }
    }

    // Sort items by amount descending
    allItems.sort((a, b) => b.amount.compareTo(a.amount));

    // Calculate category summaries
    final List<CategorySummary> summaries = [];
    for (var cat in ExpenseCategory.values) {
      final amt = catAmounts[cat] ?? 0;
      if (amt > 0) {
        final pct = sumExpense > 0 ? (amt / sumExpense) * 100 : 0.0;
        summaries.add(CategorySummary(
          category: cat,
          totalAmount: amt,
          count: catCounts[cat] ?? 0,
          percentage: pct,
        ));
      }
    }

    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    final double expRatio = sumIncome > 0 ? (sumExpense / sumIncome) * 100 : 0;
    final double savRatio = sumIncome > 0 ? (sumSaved / sumIncome) * 100 : 0;

    // Detect leaks and generate actionable warnings
    final List<LeakWarning> warnings = [];

    // Check jajan & kopi (Latte factor leak)
    final jajanAmt = catAmounts[ExpenseCategory.jajan] ?? 0;
    if (jajanAmt > 0 && sumExpense > 0) {
      final jajanPct = (jajanAmt / sumExpense) * 100;
      if (jajanPct >= 20) {
        warnings.add(LeakWarning(
          title: 'Bocor Halus: Jajan & Kopi Tinggi',
          message:
              'Jajan & kopi menyerap ${jajanPct.toStringAsFixed(1)}% dari total pengeluaran (Rp ${jajanAmt.toInt()}).',
          icon: Icons.coffee,
          color: const Color(0xFFEF4444),
          recommendation: '',
        ));
      }
    }

    // Check expense ratio
    if (expRatio > 70) {
      warnings.add(LeakWarning(
        title: 'Pengeluaran Mendekati Batas Pemasukan',
        message:
            'Total pengeluaran mencapai ${expRatio.toStringAsFixed(1)}% dari total pemasukan bulan ini.',
        icon: Icons.trending_down,
        color: const Color(0xFFF59E0B),
        recommendation: '',
      ));
    }

    // Check high single expenses
    if (allItems.isNotEmpty && sumExpense > 0) {
      final topItem = allItems.first;
      if (topItem.amount >= (sumExpense * 0.4) && sumExpense > 30000) {
        warnings.add(LeakWarning(
          title: 'Pos Pengeluaran Dominan',
          message:
              '"${topItem.title}" memakan ${((topItem.amount / sumExpense) * 100).toStringAsFixed(1)}% dari total anggaran keluar.',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF3B82F6),
          recommendation: '',
        ));
      }
    }

    return LeakAnalysis(
      totalIncome: sumIncome,
      totalExpense: sumExpense,
      totalSaved: sumSaved,
      categoryBreakdowns: summaries,
      allExpenseItems: allItems,
      warnings: warnings,
      expenseRatio: expRatio,
      saveRatio: savRatio,
    );
  }
}
