import 'package:flutter/material.dart';

enum ExpenseCategory {
  makanan,
  jajan,
  transport,
  belanja,
  tagihan,
  hiburan,
  darurat,
  lainnya,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.makanan:
        return 'Makanan & Minuman';
      case ExpenseCategory.jajan:
        return 'Jajan & Kopi (Bocor Halus)';
      case ExpenseCategory.transport:
        return 'Transportasi & Bensin';
      case ExpenseCategory.belanja:
        return 'Belanja Kebutuhan';
      case ExpenseCategory.tagihan:
        return 'Tagihan & Pulsa';
      case ExpenseCategory.hiburan:
        return 'Hiburan & Gaya Hidup';
      case ExpenseCategory.darurat:
        return 'Darurat / Tak Terduga';
      case ExpenseCategory.lainnya:
        return 'Lain-lain';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.makanan:
        return Icons.restaurant;
      case ExpenseCategory.jajan:
        return Icons.local_cafe;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.belanja:
        return Icons.shopping_bag;
      case ExpenseCategory.tagihan:
        return Icons.receipt_long;
      case ExpenseCategory.hiburan:
        return Icons.sports_esports;
      case ExpenseCategory.darurat:
        return Icons.warning_amber_rounded;
      case ExpenseCategory.lainnya:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.makanan:
        return const Color(0xFFF59E0B); // Amber
      case ExpenseCategory.jajan:
        return const Color(0xFFEF4444); // Red/Rose (Highlight leak)
      case ExpenseCategory.transport:
        return const Color(0xFF3B82F6); // Blue
      case ExpenseCategory.belanja:
        return const Color(0xFFEC4899); // Pink
      case ExpenseCategory.tagihan:
        return const Color(0xFF8B5CF6); // Violet
      case ExpenseCategory.hiburan:
        return const Color(0xFF10B981); // Emerald
      case ExpenseCategory.darurat:
        return const Color(0xFFDC2626); // Dark Red
      case ExpenseCategory.lainnya:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.makanan:   return '🍱';
      case ExpenseCategory.jajan:     return '☕';
      case ExpenseCategory.transport: return '🚗';
      case ExpenseCategory.belanja:   return '🛍️';
      case ExpenseCategory.tagihan:   return '📱';
      case ExpenseCategory.hiburan:   return '🎮';
      case ExpenseCategory.darurat:   return '🚨';
      case ExpenseCategory.lainnya:   return '📦';
    }
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String note;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    this.category = ExpenseCategory.lainnya,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'note': note,
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Pengeluaran',
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.lainnya,
      ),
      note: json['note'] as String? ?? '',
    );
  }
}

class DayEntry {
  final String id;
  final DateTime date; // Normalized to YYYY-MM-DD
  final double income; // Pemasukan
  final String incomeNote;
  final double saveAmount; // Save (Tabungan hari ini)
  final String saveNote;
  final List<ExpenseItem> expenses; // Detailed items
  final double directExpense; // Fallback if no detailed expenses

  // Chronologically calculated fields
  double runningSisa; // Cumulative Sisa
  double runningTotalSimpan; // Cumulative Total Simpan

  DayEntry({
    required this.id,
    required DateTime date,
    this.income = 0.0,
    this.incomeNote = '',
    this.saveAmount = 0.0,
    this.saveNote = '',
    this.expenses = const [],
    this.directExpense = 0.0,
    this.runningSisa = 0.0,
    this.runningTotalSimpan = 0.0,
  }) : date = DateTime(date.year, date.month, date.day);

  double get totalExpense {
    if (directExpense > 0) return directExpense;
    if (expenses.isNotEmpty) {
      final itemsSum = expenses.fold(0.0, (sum, item) => sum + item.amount);
      if (itemsSum > 0) return itemsSum;
    }
    return directExpense;
  }

  /// Net cash flow for this specific day: Pemasukan - Pengeluaran - Save
  double get netCashFlow => income - totalExpense - saveAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'income': income,
        'incomeNote': incomeNote,
        'saveAmount': saveAmount,
        'saveNote': saveNote,
        'directExpense': directExpense,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    var rawExpenses = json['expenses'] as List<dynamic>?;
    List<ExpenseItem> items = [];
    if (rawExpenses != null) {
      items = rawExpenses.map((e) => ExpenseItem.fromJson(e)).toList();
    }

    final parsedDate = DateTime.parse(json['date'] as String);
    return DayEntry(
      id: json['id'] as String,
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      incomeNote: json['incomeNote'] as String? ?? '',
      saveAmount: (json['saveAmount'] as num?)?.toDouble() ?? 0.0,
      saveNote: json['saveNote'] as String? ?? '',
      directExpense: (json['directExpense'] as num?)?.toDouble() ?? 0.0,
      expenses: items,
    );
  }

  DayEntry copyWith({
    String? id,
    DateTime? date,
    double? income,
    String? incomeNote,
    double? saveAmount,
    String? saveNote,
    List<ExpenseItem>? expenses,
    double? directExpense,
    double? runningSisa,
    double? runningTotalSimpan,
  }) {
    final entry = DayEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      income: income ?? this.income,
      incomeNote: incomeNote ?? this.incomeNote,
      saveAmount: saveAmount ?? this.saveAmount,
      saveNote: saveNote ?? this.saveNote,
      expenses: expenses ?? this.expenses,
      directExpense: directExpense ?? this.directExpense,
      runningSisa: runningSisa ?? this.runningSisa,
      runningTotalSimpan: runningTotalSimpan ?? this.runningTotalSimpan,
    );
    return entry;
  }
}
