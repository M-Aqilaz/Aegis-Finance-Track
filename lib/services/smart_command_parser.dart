import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

enum ParsedType { expense, income, save }

class ParsedCommand {
  final String originalText;
  final String title;
  final double amount;
  final ParsedType type;
  final ExpenseCategory category;
  final String pocketId;
  final String pocketName;

  const ParsedCommand({
    required this.originalText,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.pocketId,
    required this.pocketName,
  });
}

class SmartCommandParser {
  /// Parse a free-form one-liner into a structured transaction.
  /// Examples:
  /// - "nasi padang 25k" -> Expense: Makanan, 25000, Cash
  /// - "kopi kenangan 18k seabank" -> Expense: Jajan, 18000, SeaBank
  /// - "gaji freelance 2jt jago" -> Income: 2000000, Bank Jago
  /// - "nabung 100k" -> Save: 100000, Tabungan
  static ParsedCommand? parse(String input, StorageService storageService) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    final tokens = raw.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return null;

    // 1. Detect Amount
    double amount = 0.0;
    int amountIndex = -1;
    int amountTokenLength = 1;

    for (int i = 0; i < tokens.length; i++) {
      // Check two-token amount first, e.g. "50 ribu", "2 juta", "100 rb"
      if (i + 1 < tokens.length) {
        final pair = '${tokens[i]} ${tokens[i + 1]}';
        final parsedPair = CurrencyFormatter.parseAmount(pair);
        if (parsedPair > 0) {
          amount = parsedPair;
          amountIndex = i;
          amountTokenLength = 2;
          break;
        }
      }

      // Check single token amount, e.g. "25k", "25000", "1.5jt", "rp25000"
      final parsedSingle = CurrencyFormatter.parseAmount(tokens[i]);
      if (parsedSingle > 0) {
        amount = parsedSingle;
        amountIndex = i;
        amountTokenLength = 1;
        break;
      }
    }

    if (amount <= 0) return null; // No valid amount found

    // Remaining tokens without the amount
    final remainingTokens = <String>[];
    for (int i = 0; i < tokens.length; i++) {
      if (i == amountIndex) {
        if (amountTokenLength == 2) i++; // skip next token too
        continue;
      }
      remainingTokens.add(tokens[i]);
    }

    final lowerRemaining = remainingTokens.map((t) => t.toLowerCase()).toList();

    // 2. Detect Transaction Type
    ParsedType type = ParsedType.expense;
    final incomeKeywords = [
      'gaji', 'income', 'pemasukan', 'dapet', 'dapat', 'transferan',
      'freelance', 'bonus', 'cuan', 'refund', 'honor', 'komisi'
    ];
    final saveKeywords = [
      'tabung', 'nabung', 'simpan', 'save', 'deposito', 'investasi', 'saving'
    ];

    if (lowerRemaining.any((w) => incomeKeywords.contains(w))) {
      type = ParsedType.income;
    } else if (lowerRemaining.any((w) => saveKeywords.contains(w))) {
      type = ParsedType.save;
    }

    // 3. Detect Pocket / Wallet
    String pocketId = StorageService.kPocketCashId;
    String pocketName = 'Kas Tunai';

    if (type == ParsedType.save) {
      pocketId = StorageService.kPocketSavingsId;
      pocketName = 'Tabungan';
    }

    // Check for custom assets or specific pockets
    int pocketTokenIndex = -1;
    for (int i = 0; i < lowerRemaining.length; i++) {
      final w = lowerRemaining[i];
      if (w == 'cash' || w == 'tunai' || w == 'dompet') {
        pocketId = StorageService.kPocketCashId;
        pocketName = 'Kas Tunai';
        pocketTokenIndex = i;
        break;
      } else if (w == 'tabungan' || w == 'vault') {
        pocketId = StorageService.kPocketSavingsId;
        pocketName = 'Tabungan';
        pocketTokenIndex = i;
        break;
      } else {
        // Search custom bank accounts
        for (final asset in storageService.customAssets) {
          final assetNameLower = asset.name.toLowerCase();
          if (w == assetNameLower || assetNameLower.contains(w)) {
            pocketId = asset.id;
            pocketName = asset.name;
            pocketTokenIndex = i;
            break;
          }
        }
        if (pocketTokenIndex != -1) break;
      }
    }

    // 4. Detect Category (for expense)
    ExpenseCategory category = ExpenseCategory.lainnya;

    final makananWords = [
      'makan', 'padang', 'nasi', 'ayam', 'mie', 'bakso', 'sate', 'warteg',
      'resto', 'dinner', 'lunch', 'breakfast', 'sarapan', 'roti', 'burger',
      'pizza', 'mcd', 'kfc', 'pecel', 'soto', 'rawon', 'seblak'
    ];
    final jajanWords = [
      'kopi', 'coffee', 'snack', 'minum', 'boba', 'jajan', 'es', 'teh',
      'cemilan', 'kue', 'starbucks', 'kenangan', 'janji', 'esteh', 'boba'
    ];
    final transportWords = [
      'bensin', 'bbm', 'pertalite', 'pertamax', 'ojol', 'gojek', 'grab',
      'maxim', 'parkir', 'tol', 'kereta', 'mrt', 'krl', 'busway',
      'transjakarta', 'angkot', 'driver', 'taksi'
    ];
    final belanjaWords = [
      'belanja', 'supermarket', 'minimarket', 'indomaret', 'alfamart',
      'shopee', 'tokopedia', 'tiktok', 'baju', 'sepatu', 'sabun',
      'shampo', 'deterjen', 'pasar'
    ];
    final tagihanWords = [
      'tagihan', 'listrik', 'pln', 'air', 'pdam', 'wifi', 'indihome',
      'pulsa', 'kuota', 'data', 'iuran', 'kos', 'kontrakan', 'netflix',
      'spotify', 'youtube', 'bpjs'
    ];
    final hiburanWords = [
      'nonton', 'bioskop', 'game', 'steam', 'mlbb', 'topup', 'wisata',
      'karaoke', 'hangout', 'playstation', 'cinema'
    ];
    final daruratWords = [
      'obat', 'dokter', 'klinik', 'rs', 'rumahsakit', 'tambalban',
      'bengkel', 'rusak', 'servis', 'apotek'
    ];

    if (lowerRemaining.any((w) => makananWords.contains(w))) {
      category = ExpenseCategory.makanan;
    } else if (lowerRemaining.any((w) => jajanWords.contains(w))) {
      category = ExpenseCategory.jajan;
    } else if (lowerRemaining.any((w) => transportWords.contains(w))) {
      category = ExpenseCategory.transport;
    } else if (lowerRemaining.any((w) => belanjaWords.contains(w))) {
      category = ExpenseCategory.belanja;
    } else if (lowerRemaining.any((w) => tagihanWords.contains(w))) {
      category = ExpenseCategory.tagihan;
    } else if (lowerRemaining.any((w) => hiburanWords.contains(w))) {
      category = ExpenseCategory.hiburan;
    } else if (lowerRemaining.any((w) => daruratWords.contains(w))) {
      category = ExpenseCategory.darurat;
    }

    // 5. Construct Clean Title
    final titleTokens = <String>[];
    for (int i = 0; i < remainingTokens.length; i++) {
      if (i == pocketTokenIndex) continue; // omit pocket word from title
      titleTokens.add(remainingTokens[i]);
    }

    String title = titleTokens.join(' ').trim();
    if (title.isEmpty) {
      if (type == ParsedType.income) {
        title = 'Pemasukan';
      } else if (type == ParsedType.save) {
        title = 'Tabungan';
      } else {
        title = category.displayName;
      }
    } else {
      // Capitalize first letter of each word
      title = title.split(' ').map((word) {
        if (word.isEmpty) return '';
        return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
      }).join(' ');
    }

    return ParsedCommand(
      originalText: raw,
      title: title,
      amount: amount,
      type: type,
      category: category,
      pocketId: pocketId,
      pocketName: pocketName,
    );
  }
}
