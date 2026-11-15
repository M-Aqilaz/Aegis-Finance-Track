import 'package:flutter_test/flutter_test.dart';
import 'package:financial_track/models/pocket_transfer.dart';
import 'package:financial_track/models/transaction_entry.dart';
import 'package:financial_track/services/storage_service.dart';
import 'package:financial_track/utils/currency_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BLACKBOX: Indonesian Currency Input & Output Parser', () {
    test('Recognizes user shorthand notations (40k, 50k, 1.5jt, 0k)', () {
      expect(CurrencyFormatter.parseAmount('40k'), 40000);
      expect(CurrencyFormatter.parseAmount('50k'), 50000);
      expect(CurrencyFormatter.parseAmount('0k'), 0);
      expect(CurrencyFormatter.parseAmount('112k'), 112000);
      expect(CurrencyFormatter.parseAmount('1.5jt'), 1500000);
      expect(CurrencyFormatter.parseAmount('2,5jt'), 2500000);
    });

    test('Recognizes Indonesian textual keywords (ribu, juta, rb)', () {
      expect(CurrencyFormatter.parseAmount('50 ribu'), 50000);
      expect(CurrencyFormatter.parseAmount('50ribu'), 50000);
      expect(CurrencyFormatter.parseAmount('1 juta'), 1000000);
      expect(CurrencyFormatter.parseAmount('100 rb'), 100000);
      expect(CurrencyFormatter.parseAmount('150.000'), 150000);
    });

    test('Handles Indonesian currency prefixes (Rp., Rp, rp)', () {
      expect(CurrencyFormatter.parseAmount('Rp. 50k'), 50000);
      expect(CurrencyFormatter.parseAmount('Rp. 142.000'), 142000);
      expect(CurrencyFormatter.parseAmount('rp 100k'), 100000);
    });

    test('Display formatting outputs standard Indonesian format', () {
      expect(CurrencyFormatter.formatRp(142000), 'Rp 142.000');
      expect(CurrencyFormatter.formatRp(172000), 'Rp 172.000');
      expect(CurrencyFormatter.formatRp(2155000), 'Rp 2.155.000');
      expect(CurrencyFormatter.formatShort(142000), 'Rp 142k');
      expect(CurrencyFormatter.formatShort(100000), 'Rp 100k');
    });
  });

  group('BLACKBOX: Full 8-Day User Financial Tracking Flow (3-10 Nov 2026)', () {
    test('End-to-end output matches user ledger exactly per day', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Verify the list has all 8 days
      expect(storage.entries.length, 8);

      // Verify 3 November 2026: In 40k, Out 18k, Save 5k -> Sisa 17k, Total Simpan 5k
      final d3 = storage.getEntryByDate(DateTime(2026, 11, 3))!;
      expect(d3.income, 40000);
      expect(d3.totalExpense, 18000);
      expect(d3.saveAmount, 5000);
      expect(d3.runningSisa, 17000);
      expect(d3.runningTotalSimpan, 5000);

      // Verify 4 November 2026: In 50k, Out 19k, Save 5k -> Sisa 43k, Total Simpan 10k
      final d4 = storage.getEntryByDate(DateTime(2026, 11, 4))!;
      expect(d4.income, 50000);
      expect(d4.totalExpense, 19000);
      expect(d4.saveAmount, 5000);
      expect(d4.runningSisa, 43000);
      expect(d4.runningTotalSimpan, 10000);

      // Verify 5 November 2026: In 31k, Out 0k, Save 10k -> Sisa 64k, Total Simpan 20k
      final d5 = storage.getEntryByDate(DateTime(2026, 11, 5))!;
      expect(d5.income, 31000);
      expect(d5.totalExpense, 0);
      expect(d5.saveAmount, 10000);
      expect(d5.runningSisa, 64000);
      expect(d5.runningTotalSimpan, 20000);

      // Verify 6 November 2026: In 82k, Out 12k, Save 20k -> Sisa 114k, Total Simpan 40k
      final d6 = storage.getEntryByDate(DateTime(2026, 11, 6))!;
      expect(d6.income, 82000);
      expect(d6.totalExpense, 12000);
      expect(d6.saveAmount, 20000);
      expect(d6.runningSisa, 114000);
      expect(d6.runningTotalSimpan, 40000);

      // Verify 7 November 2026: In 10k, Out 12k, Save 20k -> Sisa 92k, Total Simpan 60k
      final d7 = storage.getEntryByDate(DateTime(2026, 11, 7))!;
      expect(d7.income, 10000);
      expect(d7.totalExpense, 12000);
      expect(d7.saveAmount, 20000);
      expect(d7.runningSisa, 92000);
      expect(d7.runningTotalSimpan, 60000);

      // Verify 8 November 2026: In 90k, Out 0k, Save 60k -> Sisa 122k, Total Simpan 120k
      final d8 = storage.getEntryByDate(DateTime(2026, 11, 8))!;
      expect(d8.income, 90000);
      expect(d8.totalExpense, 0);
      expect(d8.saveAmount, 60000);
      expect(d8.runningSisa, 122000);
      expect(d8.runningTotalSimpan, 120000);

      // Verify 9 November 2026: In 30k, Out 35k (Bensin), Save 50k -> Sisa 67k, Total Simpan 170k
      final d9 = storage.getEntryByDate(DateTime(2026, 11, 9))!;
      expect(d9.income, 30000);
      expect(d9.totalExpense, 35000);
      expect(d9.saveAmount, 50000);
      expect(d9.runningSisa, 67000);
      expect(d9.runningTotalSimpan, 170000);

      // Verify 10 November 2026: In 25k, Out 5k (Minuman), Save 10k -> Sisa 77k, Total Simpan 180k
      final d10 = storage.getEntryByDate(DateTime(2026, 11, 10))!;
      expect(d10.income, 25000);
      expect(d10.totalExpense, 5000);
      expect(d10.saveAmount, 10000);
      expect(d10.runningSisa, 77000);
      expect(d10.runningTotalSimpan, 180000);

      // Assert Global Balances
      expect(storage.currentSisa, 77000);
      expect(storage.currentTotalSimpan, 180000);
      expect(storage.cashBalance, 77000);
      expect(storage.savingsBalance, 180000);
      expect(storage.seaBankBalance, 143000);
      expect(storage.bankJagoBalance, 1755000);
      expect(storage.totalAllAssets, 2155000); // 77k + 180k + 143k + 1.755.000 = 2.155.000
    });

    test('UI Display Order: Dashboard and History always show latest date (10 Nov) first', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final displayEntries = List<DayEntry>.from(storage.entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      expect(displayEntries.first.date.day, 10, reason: 'Latest date 10 Nov must be first in display list');
      expect(displayEntries.last.date.day, 3, reason: 'Oldest date 3 Nov must be last in display list');
      expect(displayEntries[0].runningSisa, 77000);
    });
  });

  group('BLACKBOX: Ambil Tabungan & Pindah Dana Antar Kantong', () {
    test('User draws 50k from Tabungan into SeaBank', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      expect(storage.savingsBalance, 180000);
      expect(storage.seaBankBalance, 143000);
      expect(storage.totalAllAssets, 2155000);

      final transfer = PocketTransfer(
        id: 'user-tx-1',
        date: DateTime.now(),
        fromPocketId: StorageService.kPocketSavingsId,
        fromPocketName: 'Tabungan (Simpanan)',
        toPocketId: 'asset-seabank',
        toPocketName: 'SeaBank',
        amount: 50000,
        note: 'Pindah tabungan ke deposito SeaBank',
      );

      await storage.transferFunds(transfer);

      expect(storage.savingsBalance, 130000);
      expect(storage.seaBankBalance, 193000);
      expect(storage.totalAllAssets, 2155000); // Total aset tidak berubah!
    });
  });

  group('BLACKBOX: Backup File & Export-Import Flow', () {
    test('Export produces valid JSON and Import restores full state without loss', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final jsonStr = storage.exportJson();
      expect(jsonStr.isNotEmpty, isTrue);

      final freshStorage = StorageService();
      await freshStorage.init();

      final importSuccess = await freshStorage.importJson(jsonStr);
      expect(importSuccess, isTrue);

      expect(freshStorage.entries.length, 8);
      expect(freshStorage.currentSisa, 77000);
      expect(freshStorage.currentTotalSimpan, 180000);
      expect(freshStorage.seaBankBalance, 143000);
      expect(freshStorage.bankJagoBalance, 1755000);
      expect(freshStorage.totalAllAssets, 2155000);
    });
  });

  group('BLACKBOX: Streak System User Verification', () {
    test('User streak updates automatically when new daily entry is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      expect(storage.streakInfo.longestStreak, 8);

      // User adds 11 Nov entry
      final day11 = DayEntry(
        id: 'user-nov-11',
        date: DateTime(2026, 11, 11),
        income: 30000,
        saveAmount: 5000,
      );
      await storage.saveOrUpdateEntry(day11);

      // Now streak should extend to 9 days
      expect(storage.entries.length, 9);
      expect(storage.streakInfo.longestStreak, 9);
    });
  });
}
