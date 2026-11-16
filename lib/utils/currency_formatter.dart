import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format as Rp 40.000
  static String formatRp(num amount) {
    if (amount < 0) {
      return '-${_idrFormatter.format(amount.abs())}';
    }
    return _idrFormatter.format(amount);
  }

  /// Format as 40k, 1.2jt, 2.5M, 1.2T, etc. or Rp 40k
  static String formatShort(num amount, {bool withSymbol = true}) {
    if (amount == 0) {
      return withSymbol ? 'Rp 0' : '0';
    }
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formattedText;

    if (absAmount >= 1000000000000) {
      final val = absAmount / 1000000000000;
      final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      formattedText = withSymbol ? 'Rp ${formatted}T' : '${formatted}T';
    } else if (absAmount >= 1000000000) {
      final val = absAmount / 1000000000;
      final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      formattedText = withSymbol ? 'Rp ${formatted}M' : '${formatted}M';
    } else if (absAmount >= 1000000) {
      final val = absAmount / 1000000;
      final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      formattedText = withSymbol ? 'Rp ${formatted}jt' : '${formatted}jt';
    } else if (absAmount >= 1000) {
      final val = absAmount / 1000;
      final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      formattedText = withSymbol ? 'Rp ${formatted}k' : '${formatted}k';
    } else {
      formattedText = withSymbol ? 'Rp ${absAmount.toInt()}' : '${absAmount.toInt()}';
    }

    return isNegative ? '-$formattedText' : formattedText;
  }

  /// Parse text input flexibly: "40k", "40K", "40.000", "40000", "1.5jt", "5k", "50 ribu", "2M", "1T", etc.
  static double parseAmount(String input) {
    if (input.trim().isEmpty) return 0.0;
    String clean = input.trim().toLowerCase();

    // Check negative
    bool isNegative = false;
    if (clean.startsWith('-') || clean.startsWith('(')) {
      isNegative = true;
      clean = clean.replaceAll('-', '').replaceAll('(', '').replaceAll(')', '');
    }

    // Strip "rp.", "rp", "idr" and spaces
    clean = clean.replaceAll('idr', '').replaceAll('rp.', '').replaceAll('rp', '').replaceAll(' ', '');

    // Handle "triliun", "milyar", "miliar", "juta", "ribu", "jt", "rb", "t", "m", "k"
    // Order matters: check longer multi-character suffixes before single-character suffixes!
    double multiplier = 1.0;
    if (clean.endsWith('triliun')) {
      clean = clean.substring(0, clean.length - 7);
      multiplier = 1000000000000.0;
    } else if (clean.endsWith('milyar')) {
      clean = clean.substring(0, clean.length - 6);
      multiplier = 1000000000.0;
    } else if (clean.endsWith('miliar')) {
      clean = clean.substring(0, clean.length - 6);
      multiplier = 1000000000.0;
    } else if (clean.endsWith('juta')) {
      clean = clean.substring(0, clean.length - 4);
      multiplier = 1000000.0;
    } else if (clean.endsWith('ribu')) {
      clean = clean.substring(0, clean.length - 4);
      multiplier = 1000.0;
    } else if (clean.endsWith('jt')) {
      clean = clean.substring(0, clean.length - 2);
      multiplier = 1000000.0;
    } else if (clean.endsWith('rb')) {
      clean = clean.substring(0, clean.length - 2);
      multiplier = 1000.0;
    } else if (clean.endsWith('t')) {
      clean = clean.substring(0, clean.length - 1);
      multiplier = 1000000000000.0;
    } else if (clean.endsWith('m') && !clean.contains('com')) {
      clean = clean.substring(0, clean.length - 1);
      multiplier = 1000000000.0;
    } else if (clean.endsWith('k')) {
      clean = clean.substring(0, clean.length - 1);
      multiplier = 1000.0;
    }

    clean = clean.trim();
    if (clean.isEmpty) return 0.0;

    // Handle thousand separators and decimals:
    // Case A: contains both '.' and ',' (e.g. "1.500.000,50" or "1,500,000.50")
    if (clean.contains('.') && clean.contains(',')) {
      final lastDot = clean.lastIndexOf('.');
      final lastComma = clean.lastIndexOf(',');
      if (lastComma > lastDot) {
        // Indonesian format: 1.500.000,50 -> dot is thousand, comma is decimal
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // US format: 1,500,000.50 -> comma is thousand, dot is decimal
        clean = clean.replaceAll(',', '');
      }
    } else if (clean.contains(',')) {
      final parts = clean.split(',');
      if (parts.length == 2 && parts[1].length != 3 && multiplier == 1.0) {
        clean = clean.replaceAll(',', '.');
      } else if (multiplier != 1.0) {
        clean = clean.replaceAll(',', '.');
      } else if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        clean = clean.replaceAll(',', '');
      } else {
        clean = clean.replaceAll(',', '.');
      }
    } else if (clean.contains('.')) {
      final parts = clean.split('.');
      if (parts.length > 2) {
        // Multiple dots -> definitely thousand separators e.g. 1.500.000
        clean = clean.replaceAll('.', '');
      } else if (parts.length == 2) {
        if (multiplier != 1.0) {
          // E.g. "1.5jt" or "2.5k" -> decimal dot, keep dot as is
        } else if (parts[1].length == 3) {
          // Exactly 3 digits e.g. "50.000" -> thousand separator
          clean = clean.replaceAll('.', '');
        }
      }
    }

    final val = double.tryParse(clean) ?? 0.0;
    final result = val * multiplier;
    return isNegative ? -result : result;
  }

  /// Format standard date e.g. "3 November 2026"
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  /// Format short date e.g. "03 Nov"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd MMM', 'id_ID').format(date);
  }

  /// Format month year e.g. "November 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  /// Format day name e.g. "Jumat"
  static String formatDayName(DateTime date) {
    return DateFormat('EEEE', 'id_ID').format(date);
  }
}
