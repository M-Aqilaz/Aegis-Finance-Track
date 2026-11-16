import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:financial_track/models/asset_account.dart';
import 'package:financial_track/models/leak_analysis.dart';
import 'package:financial_track/models/pocket_transfer.dart';
import 'package:financial_track/models/streak_info.dart';
import 'package:financial_track/models/transaction_entry.dart';
import 'package:financial_track/services/backup_service.dart';
import 'package:financial_track/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WHITEBOX: Recalculation Engine & Invariants', () {
    test('Invariant 1: Sisa Recurrence Relation (Sisa[i] = Sisa[i-1] + In[i] - Out[i] - Save[i])', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final entries = storage.entries;
      expect(entries.length, 8);

      // Verify Day 0 base case
      final baseExpectedSisa = entries[0].income - entries[0].totalExpense - entries[0].saveAmount;
      expect(entries[0].runningSisa, baseExpectedSisa);
      expect(entries[0].runningTotalSimpan, entries[0].saveAmount);

      // Verify inductive recurrence for Day 1..N
      for (int i = 1; i < entries.length; i++) {
        final prev = entries[i - 1];
        final curr = entries[i];
        final expectedSisa = prev.runningSisa + curr.income - curr.totalExpense - curr.saveAmount;
        final expectedTotalSimpan = prev.runningTotalSimpan + curr.saveAmount;

        expect(curr.runningSisa, expectedSisa,
            reason: 'Sisa invariant violated on index $i (${curr.date})');
        expect(curr.runningTotalSimpan, expectedTotalSimpan,
            reason: 'TotalSimpan invariant violated on index $i (${curr.date})');
      }
    });

    test('Invariant 2: Chronological Ordering Invariant', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      // Insert dates in chaotic random order
      final chaoticDates = [
        DayEntry(id: 'c1', date: DateTime(2026, 11, 15), income: 20000),
        DayEntry(id: 'c2', date: DateTime(2026, 11, 1), income: 10000),
        DayEntry(id: 'c3', date: DateTime(2026, 11, 12), income: 30000),
      ];

      for (var entry in chaoticDates) {
        await storage.saveOrUpdateEntry(entry);
      }

      // Internal storage list must strictly maintain ascending date sequence
      final list = storage.entries;
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].date.isBefore(list[i + 1].date) || list[i].date.isAtSameMomentAs(list[i + 1].date), isTrue,
            reason: 'Order violation: ${list[i].date} should precede ${list[i + 1].date}');
      }
    });

    test('Branch Coverage: Head, Middle, and Tail Deletion', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Record baseline sisa at end before deletions
      expect(storage.entries.length, 8);

      // 1. Delete middle entry (5 Nov)
      final nov5 = storage.getEntryByDate(DateTime(2026, 11, 5))!;
      await storage.deleteEntry(nov5.id);
      expect(storage.entries.length, 7);
      expect(storage.getEntryByDate(DateTime(2026, 11, 5)), isNull);

      // 2. Delete head entry (3 Nov)
      final nov3 = storage.getEntryByDate(DateTime(2026, 11, 3))!;
      await storage.deleteEntry(nov3.id);
      expect(storage.entries.length, 6);

      // 3. Delete tail entry (10 Nov)
      final nov10 = storage.getEntryByDate(DateTime(2026, 11, 10))!;
      await storage.deleteEntry(nov10.id);
      expect(storage.entries.length, 5);
      expect(storage.getEntryByDate(DateTime(2026, 11, 10)), isNull);

      // 4. Delete non-existent ID (graceful no-op)
      await storage.deleteEntry('non-existent-id-999');
      expect(storage.entries.length, 5);
    });
  });

  group('WHITEBOX: Storage Migration & Auto-Upgrade Logic', () {
    test('Auto-detects and migrates outdated seed with 112k income to 3-10 Nov dataset', () async {
      final legacyEntries = [
        {
          'id': 'legacy-1',
          'date': '2026-11-03T00:00:00.000',
          'income': 40000.0,
          'saveAmount': 5000.0,
          'directExpense': 18000.0,
          'expenses': [],
        },
        {
          'id': 'legacy-4',
          'date': '2026-11-06T00:00:00.000',
          'income': 112000.0,
          'saveAmount': 20000.0,
          'directExpense': 0.0,
          'expenses': [],
        },
      ];

      SharedPreferences.setMockInitialValues({
        'financial_track_entries_v2': jsonEncode(legacyEntries),
        'pref_seed_version_v3': 1, // older version
      });

      final storage = StorageService();
      await storage.init();

      // Must have auto-upgraded to the full 8 days sequence
      expect(storage.entries.length, 8);
      expect(storage.entries.any((e) => e.income == 112000.0), isFalse);

      // 10 Nov must exist with 77k sisa and 180k total simpan
      final nov10 = storage.getEntryByDate(DateTime(2026, 11, 10))!;
      expect(nov10.income, 25000);
      expect(nov10.saveAmount, 10000);
      expect(nov10.runningSisa, 77000);
      expect(nov10.runningTotalSimpan, 180000);
    });

    test('Backward compatibility: importJson accepts legacy flat List format and Map format', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      // 1. Test Map format with entries, assets, and transfers
      final v3Json = jsonEncode({
        'version': 3,
        'entries': [
          {
            'id': 'v3-entry-1',
            'date': '2026-11-10T00:00:00.000',
            'income': 75000.0,
            'saveAmount': 25000.0,
            'directExpense': 15000.0,
            'expenses': [],
          }
        ],
        'assets': [
          {
            'id': 'asset-custom-1',
            'name': 'Gopay Wallet',
            'balance': 150000.0,
            'colorValue': 4287323382,
            'iconName': 'account_balance_wallet',
          }
        ],
        'transfers': []
      });

      final v3Result = await storage.importJson(v3Json);
      expect(v3Result, isTrue);
      expect(storage.entries.length, 1);
      expect(storage.customAssets.any((a) => a.name == 'Gopay Wallet'), isTrue);
      expect(storage.cashBalance, 35000); // 75k - 15k - 25k

      // 2. Test legacy flat list JSON format
      final legacyListJson = jsonEncode([
        {
          'id': 'list-entry-1',
          'date': '2026-11-11T00:00:00.000',
          'income': 100000.0,
          'saveAmount': 20000.0,
          'directExpense': 30000.0,
          'expenses': [],
        }
      ]);

      final listResult = await storage.importJson(legacyListJson);
      expect(listResult, isTrue);
      expect(storage.entries.length, 1);
      expect(storage.entries.first.income, 100000);

      // 3. Test malformed JSON returns false gracefully without exception
      expect(await storage.importJson('not-a-json-string-12345'), isFalse);
      expect(await storage.importJson('{"invalid": true}'), isFalse);
    });
  });

  group('WHITEBOX: Pocket Transfers & Fund Conservation', () {
    test('Conservation of Total Assets: Transfer from Tabungan to SeaBank', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final initialCash = storage.cashBalance; // 77,000
      final initialSavings = storage.savingsBalance; // 180,000
      final initialSeaBank = storage.seaBankBalance; // 143,000
      final initialJago = storage.bankJagoBalance; // 1,755,000
      final initialTotal = storage.totalAllAssets; // 2,155,000

      expect(initialTotal, 2155000);

      // Transfer Rp 50.000 from Tabungan to SeaBank
      final transfer = PocketTransfer(
        id: 't-1',
        date: DateTime.now(),
        fromPocketId: StorageService.kPocketSavingsId,
        fromPocketName: 'Tabungan',
        toPocketId: 'asset-seabank',
        toPocketName: 'SeaBank',
        amount: 50000,
        note: 'Ambil tabungan untuk SeaBank',
      );

      await storage.transferFunds(transfer);

      // Tabungan should decrease by 50k
      expect(storage.savingsBalance, initialSavings - 50000); // 130,000
      // SeaBank should increase by 50k
      expect(storage.seaBankBalance, initialSeaBank + 50000); // 193,000
      // Cash & Bank Jago remain untouched
      expect(storage.cashBalance, initialCash);
      expect(storage.bankJagoBalance, initialJago);

      // Conservation Law: Total All Assets MUST remain strictly 2,155,000!
      expect(storage.totalAllAssets, initialTotal);
      expect(storage.transfers.length, 1);
    });

    test('Conservation of Total Assets: Transfer from Tabungan to Cash', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final initialCash = storage.cashBalance; // 77,000
      final initialSavings = storage.savingsBalance; // 180,000
      final initialTotal = storage.totalAllAssets; // 2,155,000

      // Transfer Rp 30.000 from Tabungan to Cash
      final transfer = PocketTransfer(
        id: 't-2',
        date: DateTime.now(),
        fromPocketId: StorageService.kPocketSavingsId,
        fromPocketName: 'Tabungan',
        toPocketId: StorageService.kPocketCashId,
        toPocketName: 'Dompet Tunai',
        amount: 30000,
        note: 'Tarik tunai dari tabungan',
      );

      await storage.transferFunds(transfer);

      expect(storage.savingsBalance, initialSavings - 30000); // 150,000
      expect(storage.cashBalance, initialCash + 30000); // 107,000
      expect(storage.totalAllAssets, initialTotal); // strictly 2,155,000
    });

    test('Revert / Delete Transfer restores exact initial balances', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final initialSavings = storage.savingsBalance;
      final initialSeaBank = storage.seaBankBalance;
      final initialTotal = storage.totalAllAssets;

      final transfer = PocketTransfer(
        id: 't-revert',
        date: DateTime.now(),
        fromPocketId: StorageService.kPocketSavingsId,
        fromPocketName: 'Tabungan',
        toPocketId: 'asset-seabank',
        toPocketName: 'SeaBank',
        amount: 40000,
      );

      await storage.transferFunds(transfer);
      expect(storage.savingsBalance, initialSavings - 40000);
      expect(storage.seaBankBalance, initialSeaBank + 40000);

      // Now cancel / delete transfer
      await storage.deleteTransfer('t-revert');

      expect(storage.savingsBalance, initialSavings);
      expect(storage.seaBankBalance, initialSeaBank);
      expect(storage.totalAllAssets, initialTotal);
      expect(storage.transfers.isEmpty, isTrue);
    });

    test('Available pockets listing returns all valid sources and destinations', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final pockets = storage.getAvailablePockets();
      expect(pockets.length, 4); // Cash, Tabungan, SeaBank, Bank Jago
      expect(pockets.any((p) => p.id == StorageService.kPocketCashId), isTrue);
      expect(pockets.any((p) => p.id == StorageService.kPocketSavingsId), isTrue);
      expect(pockets.any((p) => p.id == 'asset-seabank'), isTrue);
      expect(pockets.any((p) => p.id == 'asset-bank-jago'), isTrue);
    });
  });

  group('WHITEBOX: Dynamic Asset State Machine', () {
    test('State transitions: Add -> Update Balance -> Update Meta -> Delete', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final initialCash = storage.cashBalance; // 77,000
      final initialTotal = storage.totalAllAssets; // 2,155,000

      // 1. ADD: New Asset "Bibit Reksadana" Rp 500.000
      final bibit = AssetAccount(
        id: 'asset-bibit',
        name: 'Bibit Reksadana',
        balance: 500000,
        colorValue: 0xFF10B981,
        iconName: 'trending_up',
      );
      await storage.addAssetAccount(bibit);

      expect(storage.customAssets.length, 3);
      expect(storage.totalAllAssets, initialTotal + 500000);

      // 2. UPDATE BALANCE: Modify Bibit balance to Rp 750.000
      await storage.updateAssetBalance('asset-bibit', 750000);
      expect(storage.totalAllAssets, initialTotal + 750000);
      // Cash balance must remain invariant when custom asset balance changes
      expect(storage.cashBalance, initialCash);

      // 3. UPDATE META: Change name to "Bibit Obligasi", balance unchanged
      final updatedMeta = bibit.copyWith(name: 'Bibit Obligasi', balance: 750000);
      await storage.updateAssetAccount(updatedMeta);
      final found = storage.customAssets.firstWhere((a) => a.id == 'asset-bibit');
      expect(found.name, 'Bibit Obligasi');
      expect(found.balance, 750000);

      // 4. DELETE: Remove Bibit account
      await storage.deleteAssetAccount('asset-bibit');
      expect(storage.customAssets.any((a) => a.id == 'asset-bibit'), isFalse);
      expect(storage.totalAllAssets, initialTotal);
    });
  });

  group('WHITEBOX: Leak Analysis Service Algorithms', () {
    test('Calculates leak severity and expense distribution accurately', () {
      final entries = [
        DayEntry(
          id: 'e1',
          date: DateTime(2026, 11, 3),
          income: 40000,
          expenses: [
            ExpenseItem(id: 'exp1', title: 'Makan', amount: 18000, category: ExpenseCategory.makanan),
          ],
        ),
        DayEntry(
          id: 'e2',
          date: DateTime(2026, 11, 4),
          income: 50000,
          expenses: [
            ExpenseItem(id: 'exp2', title: 'Bensin', amount: 19000, category: ExpenseCategory.transport),
          ],
        ),
        DayEntry(
          id: 'e3',
          date: DateTime(2026, 11, 5),
          income: 31000,
          directExpense: 0,
        ),
      ];

      final analysis = LeakAnalysis.analyze(entries);

      expect(analysis.totalIncome, 121000);
      expect(analysis.totalExpense, 37000);
      expect(analysis.categoryBreakdowns.length, 2);

      final makanSummary = analysis.categoryBreakdowns.firstWhere((c) => c.category == ExpenseCategory.makanan);
      expect(makanSummary.totalAmount, 18000);

      final transportSummary = analysis.categoryBreakdowns.firstWhere((c) => c.category == ExpenseCategory.transport);
      expect(transportSummary.totalAmount, 19000);
    });
  });

  group('WHITEBOX: BackupService & History Recap Statistics', () {
    test('Calculates comprehensive history recap across 3-10 Nov 2026', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final recap = BackupService.getRecap(storage);

      expect(recap.totalDays, 8);
      expect(recap.startDate, DateTime(2026, 11, 3));
      expect(recap.endDate, DateTime(2026, 11, 10));
      expect(recap.totalIncome, 358000);
      expect(recap.totalExpense, 101000);
      expect(recap.totalSaved, 180000);
      expect(recap.currentSisa, 77000);
      expect(recap.totalCustomAssets, 1898000); // 143k + 1.755.000
      expect(recap.totalAllAssets, 2155000); // 77k Cash + 180k Tabungan + 1.898.000 Custom
      expect(recap.avgDailyExpense, 101000 / 8);
      expect(recap.saveRatio, (180000 / 358000) * 100);
    });

    test('Validates and parses backup JSON preview accurately', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final jsonStr = storage.exportJson();
      final preview = BackupService.previewBackup(jsonStr);

      expect(preview.isValid, isTrue);
      expect(preview.version, 3);
      expect(preview.entriesCount, 8);
      expect(preview.assetsCount, 2);
      expect(preview.totalIncome, 358000);
      expect(preview.totalExpense, 101000);
      expect(preview.totalSaved, 180000);
      expect(preview.finalSisa, 77000);

      // Malformed test
      final invalidPreview = BackupService.previewBackup('{"random": 123}');
      expect(invalidPreview.isValid, isFalse);
    });
  });

  group('WHITEBOX: Streak Engine & Gamification Algorithms', () {
    test('Calculates 8-day continuous streak accurately across 3-10 Nov 2026', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Test with reference date = 10 Nov 2026 (day of 8th entry)
      final streakOnNov10 = StreakInfo.calculate(storage.entries, now: DateTime(2026, 11, 10));
      expect(streakOnNov10.currentStreak, 8);
      expect(streakOnNov10.longestStreak, 8);
      expect(streakOnNov10.isRecordedToday, isTrue);
      expect(streakOnNov10.totalDaysRecorded, 8);
      expect(streakOnNov10.levelTitle, '1 Minggu Konsisten');

      // Test with reference date = 11 Nov 2026 (day after 10 Nov, waiting for entry)
      final streakOnNov11 = StreakInfo.calculate(storage.entries, now: DateTime(2026, 11, 11));
      expect(streakOnNov11.currentStreak, 8); // active from yesterday
      expect(streakOnNov11.isRecordedToday, isFalse);
      expect(streakOnNov11.isStreakActive, isTrue);

      // Milestones: 3 and 7 days should be unlocked
      expect(streakOnNov10.milestones.firstWhere((m) => m.days == 3).isUnlocked, isTrue);
      expect(streakOnNov10.milestones.firstWhere((m) => m.days == 7).isUnlocked, isTrue);
      expect(streakOnNov10.milestones.firstWhere((m) => m.days == 14).isUnlocked, isFalse);
    });

    test('Streak handles empty entries and gaps gracefully', () {
      final emptyStreak = StreakInfo.calculate([]);
      expect(emptyStreak.currentStreak, 0);
      expect(emptyStreak.longestStreak, 0);
      expect(emptyStreak.isRecordedToday, isFalse);

      // Gap test: 1 Nov, 2 Nov, 5 Nov (gap between 2 and 5)
      final gapEntries = [
        DayEntry(id: 'g1', date: DateTime(2026, 11, 1), income: 10000),
        DayEntry(id: 'g2', date: DateTime(2026, 11, 2), income: 10000),
        DayEntry(id: 'g3', date: DateTime(2026, 11, 5), income: 10000),
      ];

      final gapStreak = StreakInfo.calculate(gapEntries, now: DateTime(2026, 11, 5));
      expect(gapStreak.currentStreak, 1); // Only 5 Nov (gap broken after 2 Nov)
      expect(gapStreak.longestStreak, 2); // 1-2 Nov was 2 days
    });
  });

  group('WHITEBOX: Aegis Vault PIN & Security Engine', () {
    test('PIN disabled by default; enabling sets pin and verification works', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      expect(storage.pinEnabled, isFalse);
      expect(storage.isAppLocked, isFalse);
      expect(storage.hasPinSet, isFalse);
      expect(storage.verifyPin('1234'), isTrue); // If disabled, open

      // Set PIN
      await storage.setPin('8899');
      expect(storage.pinEnabled, isTrue);
      expect(storage.hasPinSet, isTrue);
      expect(storage.verifyPin('8899'), isTrue);
      expect(storage.verifyPin('0000'), isFalse);

      // Lock app
      storage.lockApp();
      expect(storage.isAppLocked, isTrue);

      // Unlock app
      storage.unlockApp();
      expect(storage.isAppLocked, isFalse);

      // Disable PIN
      await storage.disablePin();
      expect(storage.pinEnabled, isFalse);
      expect(storage.hasPinSet, isFalse);
      expect(storage.isAppLocked, isFalse);
    });

    test('Persistent PIN reload locks app on fresh start', () async {
      SharedPreferences.setMockInitialValues({
        'pref_pin_enabled': true,
        'pref_pin_code': '4321',
      });
      final storage = StorageService();
      await storage.init();

      expect(storage.pinEnabled, isTrue);
      expect(storage.isAppLocked, isTrue); // Locked on startup
      expect(storage.verifyPin('4321'), isTrue);

      storage.unlockApp();
      expect(storage.isAppLocked, isFalse);
    });

    test('Zero-Leak Privacy: Fresh init without sample flag starts with 0 entries and 0 default balances', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      expect(storage.entries.isEmpty, isTrue);
      expect(storage.currentSisa, 0.0);
      expect(storage.currentTotalSimpan, 0.0);
      expect(storage.seaBankBalance, 0.0);
      expect(storage.bankJagoBalance, 0.0);
      expect(storage.totalAllAssets, 0.0);
    });

    test('CSV Generation: Produces clean header and valid rows', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final csv = BackupService.generateCsv(storage);
      expect(csv.startsWith('Tanggal,Pemasukan,Pengeluaran,Simpan,Sisa,Total Simpan'), isTrue);
      expect(csv.contains('03/11/2026,40000,18000,5000,17000,5000'), isTrue);
      expect(csv.contains('10/11/2026,25000,5000,10000,77000,18000'), isTrue);
    });

    test('ThemeMode: Toggling persists in storage and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      expect(storage.themeMode, 'dark'); // Default
      await storage.updateSettings(themeMode: 'light');
      expect(storage.themeMode, 'light');

      await storage.updateSettings(themeMode: 'dark');
      expect(storage.themeMode, 'dark');
    });
  });
}
