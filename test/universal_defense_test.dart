import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_track/models/impulse_item.dart';
import 'package:financial_track/models/savings_goal.dart';
import 'package:financial_track/models/transaction_entry.dart';
import 'package:financial_track/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Universal Financial Defense Tests (v2.0)', () {
    test('Calculates Life Days of Survival Equivalent based on burn rate', () async {
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Verify averageDailyBurn is positive
      expect(storage.averageDailyBurn, greaterThan(0));

      final burn = storage.averageDailyBurn;
      final testAmount = burn * 3.5;
      final days = storage.calculateLifeDaysEquivalent(testAmount);
      expect(days, closeTo(3.5, 0.01));
    });

    test('Cycle Configuration: Monthly, Weekly, and Free Cycle calculation', () async {
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      // Monthly cycle test
      await storage.setCycleConfiguration(cycleType: 'monthly', refillDay: 1);
      expect(storage.cycleType, 'monthly');
      expect(storage.refillDay, 1);

      final monthlyMetrics = storage.getDailySafeSpendingMetrics();
      expect(monthlyMetrics.daysLeftInCycle, inInclusiveRange(1, 31));
      expect(monthlyMetrics.safeQuota, greaterThan(0));
      expect(monthlyMetrics.cycleLabel.contains('Bulanan'), isTrue);

      // Weekly cycle test
      await storage.setCycleConfiguration(cycleType: 'weekly', refillDay: 1); // Senin
      expect(storage.cycleType, 'weekly');
      final weeklyMetrics = storage.getDailySafeSpendingMetrics();
      expect(weeklyMetrics.daysLeftInCycle, inInclusiveRange(1, 7));
      expect(weeklyMetrics.cycleLabel.contains('Mingguan'), isTrue);

      // Free cycle test
      await storage.setCycleConfiguration(cycleType: 'free', refillDay: 1);
      expect(storage.cycleType, 'free');
      final freeMetrics = storage.getDailySafeSpendingMetrics();
      expect(freeMetrics.daysLeftInCycle, greaterThanOrEqualTo(1));
      expect(freeMetrics.cycleLabel.contains('Bebas'), isTrue);
    });

    test('Impulse Quarantine Vault: Add, Divert to Savings, and Claim as Purchase', () async {
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final initialSavings = storage.savingsBalance;

      final item = ImpulseItem(
        id: 'impulse-test-1',
        title: 'Jaket Keren',
        amount: 150000,
        createdAt: DateTime.now(),
        durationHours: 48,
        category: 'Keinginan',
      );

      await storage.addImpulseItem(item);
      expect(storage.impulseItems.length, 1);
      expect(storage.pendingImpulseItems.length, 1);
      expect(storage.pendingImpulseItems.first.title, 'Jaket Keren');

      // Test diverting impulse to savings
      await storage.divertImpulseToSavings(item);
      expect(storage.pendingImpulseItems.isEmpty, isTrue);
      expect(storage.impulseItems.first.status, 'saved');
      expect(storage.savingsBalance, initialSavings + 150000);

      // Test claim as purchase for second item
      final item2 = ImpulseItem(
        id: 'impulse-test-2',
        title: 'Headphone Gaming',
        amount: 200000,
        createdAt: DateTime.now(),
        durationHours: 48,
        category: 'Elektronik',
      );
      await storage.addImpulseItem(item2);
      expect(storage.pendingImpulseItems.length, 1);

      await storage.claimImpulseAsPurchase(item2);
      expect(storage.pendingImpulseItems.isEmpty, isTrue);
      expect(storage.impulseItems.first.status, 'purchased');

      // Test delete impulse item
      await storage.deleteImpulseItem('impulse-test-1');
      expect(storage.impulseItems.any((i) => i.id == 'impulse-test-1'), isFalse);

      // Test resetToCleanSlate sets all balances and entries to 0
      await storage.resetToCleanSlate();
      expect(storage.entries.isEmpty, isTrue);
      expect(storage.transfers.isEmpty, isTrue);
      expect(storage.impulseItems.isEmpty, isTrue);
      expect(storage.totalAllAssets, 0.0);
      expect(storage.cashBalance, 0.0);
      expect(storage.savingsBalance, 0.0);
    });

    test('Savings Goal Vault: Create, Deposit, Withdraw, and Calculate Days', () async {
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: true);

      final goal = SavingsGoal(
        id: 'goal-1',
        title: 'MacBook Air M3',
        targetAmount: 18000000,
        currentAmount: 2000000,
        createdAt: DateTime.now(),
      );

      await storage.addSavingsGoal(goal);
      expect(storage.savingsGoals.length, 1);
      expect(storage.savingsGoals.first.title, 'MacBook Air M3');
      expect(storage.savingsGoals.first.progressPercent, closeTo(2000000 / 18000000, 0.001));

      // Test depositing money into goal
      final success = await storage.depositToSavingsGoal(
        goalId: 'goal-1',
        amount: 1000000,
        fromPocketId: StorageService.kPocketCashId,
      );
      expect(success, isTrue);
      expect(storage.savingsGoals.first.currentAmount, 3000000);

      // Test days calculation
      final days = storage.calculateDaysToReachGoal(storage.savingsGoals.first);
      expect(days, greaterThan(0));

      // Test withdrawing from goal
      final withdrawSuccess = await storage.withdrawFromSavingsGoal(
        goalId: 'goal-1',
        amount: 500000,
        toPocketId: StorageService.kPocketCashId,
      );
      expect(withdrawSuccess, isTrue);
      expect(storage.savingsGoals.first.currentAmount, 2500000);

      // Test deleting goal
      await storage.deleteSavingsGoal('goal-1');
      expect(storage.savingsGoals.isEmpty, isTrue);
    });

    test('Multi-tab isolated transaction logging preserves both expense and income without amount leak', () async {
      final storage = StorageService();
      await storage.init(loadSampleDataIfEmpty: false);

      final today = DateTime.now();
      final normalizedDate = DateTime(today.year, today.month, today.day);

      // Simulate user logging expense 2000 and income 10000 in one session
      final expAmount = 2000.0;
      final incAmount = 10000.0;

      final entry = DayEntry(
        id: 'test-multi-tab-entry',
        date: normalizedDate,
        income: incAmount,
        saveAmount: 0.0,
        expenses: [
          ExpenseItem(
            id: 'exp-1',
            title: ExpenseCategory.makanan.displayName,
            amount: expAmount,
            category: ExpenseCategory.makanan,
          ),
        ],
      );

      await storage.saveOrUpdateEntry(entry);

      final saved = storage.getEntryByDate(normalizedDate);
      expect(saved, isNotNull);
      expect(saved!.income, 10000.0);
      expect(saved.totalExpense, 2000.0);
      // Net cash flow must be 10000 - 2000 = 8000 (NOT 12000!)
      expect(saved.netCashFlow, 8000.0);
    });
  });
}
