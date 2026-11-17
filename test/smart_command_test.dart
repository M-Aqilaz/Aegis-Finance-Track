import 'package:flutter_test/flutter_test.dart';
import 'package:financial_track/models/transaction_entry.dart';
import 'package:financial_track/services/smart_command_parser.dart';
import 'package:financial_track/services/storage_service.dart';

void main() {
  group('SmartCommandParser Tests', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('Parses expense with category and Indonesian short format', () {
      final res = SmartCommandParser.parse('nasi padang 25k', storageService);
      expect(res, isNotNull);
      expect(res!.amount, 25000.0);
      expect(res.category, ExpenseCategory.makanan);
      expect(res.type, ParsedType.expense);
      expect(res.pocketId, StorageService.kPocketCashId);
    });

    test('Parses coffee expense with specific bank pocket', () {
      final res = SmartCommandParser.parse('kopi kenangan 18k seabank', storageService);
      expect(res, isNotNull);
      expect(res!.amount, 18000.0);
      expect(res.category, ExpenseCategory.jajan);
      expect(res.type, ParsedType.expense);
    });

    test('Parses income with juta keyword', () {
      final res = SmartCommandParser.parse('gaji freelance 2jt', storageService);
      expect(res, isNotNull);
      expect(res!.amount, 2000000.0);
      expect(res.type, ParsedType.income);
    });

    test('Parses savings command', () {
      final res = SmartCommandParser.parse('nabung 100k', storageService);
      expect(res, isNotNull);
      expect(res!.amount, 100000.0);
      expect(res.type, ParsedType.save);
      expect(res.pocketId, StorageService.kPocketSavingsId);
    });

    test('Returns null on invalid or empty text', () {
      expect(SmartCommandParser.parse('', storageService), isNull);
      expect(SmartCommandParser.parse('halo apa kabar', storageService), isNull);
    });
  });
}
