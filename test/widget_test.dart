import 'package:flutter_test/flutter_test.dart';
import 'package:financial_track/models/transaction_entry.dart';
import 'package:financial_track/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Financial Track Math & Logic Tests', () {
    test('Calculates Sisa and Total Simpan exactly matches user data (3-10 Nov 2026)', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Check initial 8 days seeded
      final entries = storage.entries;
      expect(entries.length, 8);

      // Day 1: 3 Nov 2026 -> Pemasukan 40k, Pengeluaran 18k, Save 5k -> Sisa 17k, Total Simpan 5k
      expect(entries[0].income, 40000);
      expect(entries[0].totalExpense, 18000);
      expect(entries[0].saveAmount, 5000);
      expect(entries[0].runningSisa, 17000);
      expect(entries[0].runningTotalSimpan, 5000);

      // Day 2: 4 Nov 2026 -> Pemasukan 50k, Pengeluaran 19k, Save 5k -> Sisa 43k, Total Simpan 10k
      expect(entries[1].income, 50000);
      expect(entries[1].totalExpense, 19000);
      expect(entries[1].saveAmount, 5000);
      expect(entries[1].runningSisa, 43000);
      expect(entries[1].runningTotalSimpan, 10000);

      // Day 3: 5 Nov 2026 -> Pemasukan 31k, Pengeluaran 0k, Save 10k -> Sisa 64k, Total Simpan 20k
      expect(entries[2].income, 31000);
      expect(entries[2].totalExpense, 0);
      expect(entries[2].saveAmount, 10000);
      expect(entries[2].runningSisa, 64000);
      expect(entries[2].runningTotalSimpan, 20000);

      // Day 4: 6 Nov 2026 -> Pemasukan 82k, Pengeluaran 12k, Save 20k -> Sisa 114k, Total Simpan 40k
      expect(entries[3].income, 82000);
      expect(entries[3].totalExpense, 12000);
      expect(entries[3].saveAmount, 20000);
      expect(entries[3].runningSisa, 114000);
      expect(entries[3].runningTotalSimpan, 40000);

      // Day 5: 7 Nov 2026 -> Pemasukan 10k, Pengeluaran 12k, Save 20k -> Sisa 92k, Total Simpan 60k
      expect(entries[4].income, 10000);
      expect(entries[4].totalExpense, 12000);
      expect(entries[4].saveAmount, 20000);
      expect(entries[4].runningSisa, 92000);
      expect(entries[4].runningTotalSimpan, 60000);

      // Day 6: 8 Nov 2026 -> Pemasukan 90k, Pengeluaran 0k, Save 60k -> Sisa 122k, Total Simpan 120k
      expect(entries[5].income, 90000);
      expect(entries[5].totalExpense, 0);
      expect(entries[5].saveAmount, 60000);
      expect(entries[5].runningSisa, 122000);
      expect(entries[5].runningTotalSimpan, 120000);

      // Day 7: 9 Nov 2026 -> Pemasukan 30k, Pengeluaran 35k (Bensin), Save 50k -> Sisa 67k, Total Simpan 170k
      expect(entries[6].income, 30000);
      expect(entries[6].totalExpense, 35000);
      expect(entries[6].saveAmount, 50000);
      expect(entries[6].runningSisa, 67000);
      expect(entries[6].runningTotalSimpan, 170000);

      // Day 8: 10 Nov 2026 -> Pemasukan 25k, Pengeluaran 5k (Minuman), Save 10k -> Sisa 77k, Total Simpan 180k
      expect(entries[7].income, 25000);
      expect(entries[7].totalExpense, 5000);
      expect(entries[7].saveAmount, 10000);
      expect(entries[7].runningSisa, 77000);
      expect(entries[7].runningTotalSimpan, 180000);

      // Cash balance = 77k, Total Simpan = 180k
      expect(storage.currentSisa, 77000);
      expect(storage.currentTotalSimpan, 180000);
      expect(storage.cashBalance, 77000);
      expect(storage.savingsBalance, 180000);

      // SeaBank = 143k, Bank Jago = 1.755.000
      expect(storage.seaBankBalance, 143000);
      expect(storage.bankJagoBalance, 1755000);

      // Total Semua Aset = Cash (77k) + Tabungan (180k) + SeaBank (143k) + Bank Jago (1.755.000) = 2.155.000
      expect(storage.totalAllAssets, 2155000);
    });

    test('Adding 11 Nov rolls forward running balances correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Add 11 Nov 2026: Pemasukan 50k, Pengeluaran 10k, Save 20k
      // Previous Sisa: 77k, Previous Total Simpan: 180k
      // New Sisa should be: 77k + 50k - 10k - 20k = 97k
      // New Total Simpan should be: 180k + 20k = 200k
      final newDay = DayEntry(
        id: 'test-day-11',
        date: DateTime(2026, 11, 11),
        income: 50000,
        saveAmount: 20000,
        directExpense: 10000,
      );

      await storage.saveOrUpdateEntry(newDay);

      expect(storage.currentSisa, 97000);
      expect(storage.currentTotalSimpan, 200000);
      expect(storage.totalAllAssets, 97000 + 200000 + 143000 + 1755000); // 2.195.000
    });
  });
}
