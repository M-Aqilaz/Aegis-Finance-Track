import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_account.dart';
import '../models/impulse_item.dart';
import '../models/pocket_transfer.dart';
import '../models/savings_goal.dart';
import '../models/streak_info.dart';
import '../models/transaction_entry.dart';

class DailySafeSpendMetrics {
  final double safeQuota;
  final double spentToday;
  final double remainingQuota;
  final double percentUsed;
  final int daysLeftInCycle;
  final String cycleLabel;

  const DailySafeSpendMetrics({
    required this.safeQuota,
    required this.spentToday,
    required this.remainingQuota,
    required this.percentUsed,
    required this.daysLeftInCycle,
    required this.cycleLabel,
  });
}

class PocketOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double balance;

  const PocketOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
  });
}

class StorageService extends ChangeNotifier {
  static const String kPocketCashId = 'pocket_cash';
  static const String kPocketSavingsId = 'pocket_tabungan';

  static const String _kEntriesKey = 'financial_track_entries_v2';
  static const String _kSeedVersionKey = 'pref_seed_version_v3';
  static const int _kCurrentSeedVersion = 3;
  static const String _kReminderEnabledKey = 'pref_reminder_enabled';
  static const String _kReminderHourKey = 'pref_reminder_hour';
  static const String _kReminderMinuteKey = 'pref_reminder_minute';
  static const String _kExpenseLimitKey = 'pref_daily_expense_limit';
  static const String _kThemeModeKey = 'pref_theme_mode';
  static const String _kSeaBankBalanceKey = 'pref_seabank_balance';
  static const String _kBankJagoBalanceKey = 'pref_bank_jago_balance';
  static const String _kCustomAssetsKey = 'pref_custom_assets_v1';
  static const String _kTransfersKey = 'pref_pocket_transfers_v1';
  static const String _kPrivacyModeKey = 'pref_privacy_mode';
  static const String _kPinEnabledKey = 'pref_pin_enabled';
  static const String _kPinCodeKey = 'pref_pin_code';
  // _kBiometricsEnabledKey removed — biometric feature not implemented
  static const String _kHasSeenOnboardingKey = 'pref_has_seen_onboarding';
  static const String _kCycleTypeKey = 'pref_cycle_type_v2';
  static const String _kRefillDayKey = 'pref_refill_day_v2';
  static const String _kImpulseItemsKey = 'pref_impulse_items_v2';
  static const String _kSavingsGoalsKey = 'pref_savings_goals_v2';

  final List<DayEntry> _entries = [];
  final List<AssetAccount> _customAssets = [];
  final List<PocketTransfer> _transfers = [];
  final List<ImpulseItem> _impulseItems = [];
  final List<SavingsGoal> _savingsGoals = [];
  bool _isLoaded = false;
  bool _privacyMode = false;
  bool _pinEnabled = false;
  String _pinCode = '';
  bool _isAppLocked = false;
  bool _hasSeenOnboarding = false;

  String _cycleType = 'monthly'; // 'monthly', 'weekly', 'free'
  int _refillDay = 1; // 1st of month, or 1 = Monday

  bool _reminderEnabled = true;
  int _reminderHour = 20; // 20:00 / 8 PM
  int _reminderMinute = 0;
  double _dailyExpenseLimit = 50000;
  String _themeMode = 'dark'; // Dark theme default for modern sleek UI
  double _seaBankBalance = 0.0;
  double _bankJagoBalance = 0.0;

  List<DayEntry> get entries => List.unmodifiable(_entries);
  List<AssetAccount> get customAssets => List.unmodifiable(_customAssets);
  List<PocketTransfer> get transfers => List.unmodifiable(_transfers);
  List<ImpulseItem> get impulseItems => List.unmodifiable(_impulseItems);
  List<ImpulseItem> get pendingImpulseItems =>
      _impulseItems.where((i) => i.status == 'pending').toList();
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);
  String get cycleType => _cycleType;
  int get refillDay => _refillDay;
  bool get isLoaded => _isLoaded;
  bool get privacyMode => _privacyMode;
  bool get pinEnabled => _pinEnabled;
  bool get isAppLocked => _isAppLocked;
  bool get hasPinSet => _pinCode.isNotEmpty;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  double get dailyExpenseLimit => _dailyExpenseLimit;
  String get themeMode => _themeMode;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenOnboardingKey, true);
    notifyListeners();
  }

  Future<void> togglePrivacyMode() async {
    _privacyMode = !_privacyMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyModeKey, _privacyMode);
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    if (!_pinEnabled || _pinCode.isEmpty) return true;
    return _pinCode == enteredPin;
  }

  Future<void> setPin(String newPin) async {
    _pinCode = newPin;
    _pinEnabled = true;
    _isAppLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPinCodeKey, newPin);
    await prefs.setBool(_kPinEnabledKey, true);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _pinCode = '';
    _pinEnabled = false;
    _isAppLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPinCodeKey);
    await prefs.setBool(_kPinEnabledKey, false);
    notifyListeners();
  }

  void unlockApp() {
    _isAppLocked = false;
    notifyListeners();
  }

  void lockApp() {
    if (_pinEnabled && _pinCode.isNotEmpty) {
      _isAppLocked = true;
      notifyListeners();
    }
  }

  double get seaBankBalance {
    final found = _customAssets.where((a) => a.id == 'asset-seabank' || a.name.toLowerCase() == 'seabank');
    return found.isNotEmpty ? found.first.balance : _seaBankBalance;
  }

  double get bankJagoBalance {
    final found = _customAssets.where((a) => a.id == 'asset-bank-jago' || a.name.toLowerCase() == 'bank jago');
    return found.isNotEmpty ? found.first.balance : _bankJagoBalance;
  }

  /// Latest balance (Sisa)
  double get currentSisa {
    if (_entries.isEmpty) return 0.0;
    return _entries.last.runningSisa;
  }

  /// Latest cumulative savings (Total Simpan)
  double get currentTotalSimpan {
    if (_entries.isEmpty) return 0.0;
    return _entries.last.runningTotalSimpan;
  }

  /// Net transfer delta for Tabungan (Simpanan)
  double get savingsTransferDelta {
    return _transfers.fold(0.0, (sum, t) {
      if (t.toPocketId == kPocketSavingsId) return sum + t.amount;
      if (t.fromPocketId == kPocketSavingsId) return sum - t.amount;
      return sum;
    });
  }

  /// Net transfer delta for Cash (Dompet Tunai)
  double get cashTransferDelta {
    return _transfers.fold(0.0, (sum, t) {
      if (t.toPocketId == kPocketCashId) return sum + t.amount;
      if (t.fromPocketId == kPocketCashId) return sum - t.amount;
      return sum;
    });
  }

  /// Available Cash balance (Sisa harian + net transfer tunai)
  double get cashBalance => currentSisa + cashTransferDelta;

  /// Available Savings balance (Total simpanan + net transfer tabungan)
  double get savingsBalance => currentTotalSimpan + savingsTransferDelta;

  /// Total sum of all dynamic custom asset accounts
  double get totalCustomAssets => _customAssets.fold(0.0, (sum, a) => sum + a.balance);

  /// Total of ALL assets (Cash + Tabungan + Custom Assets)
  double get totalAllAssets => cashBalance + savingsBalance + totalCustomAssets;

  /// Total Net Worth = Sisa + Tabungan + Custom Assets
  double get currentNetWorth => totalAllAssets;

  /// Streak Analysis & Daily Consistency Metrics
  StreakInfo get streakInfo => StreakInfo.calculate(_entries);

  /// Get balance of any pocket by id
  double getPocketBalance(String pocketId) {
    if (pocketId == kPocketSavingsId) return savingsBalance;
    if (pocketId == kPocketCashId) return cashBalance;
    final found = _customAssets.where((a) => a.id == pocketId);
    if (found.isNotEmpty) return found.first.balance;
    return 0.0;
  }

  /// List of all available pockets for transfer
  List<PocketOption> getAvailablePockets() {
    final List<PocketOption> list = [
      PocketOption(
        id: kPocketSavingsId,
        name: 'Tabungan (Simpanan)',
        icon: Icons.savings_rounded,
        color: const Color(0xFF06B6D4),
        balance: savingsBalance,
      ),
      PocketOption(
        id: kPocketCashId,
        name: 'Dompet Tunai (Cash)',
        icon: Icons.payments_rounded,
        color: const Color(0xFF10B981),
        balance: cashBalance,
      ),
    ];
    for (var a in _customAssets) {
      list.add(PocketOption(
        id: a.id,
        name: a.name,
        icon: a.icon,
        color: a.color,
        balance: a.balance,
      ));
    }
    return list;
  }

  Future<void> init({bool loadSampleDataIfEmpty = false}) async {
    final prefs = await SharedPreferences.getInstance();

    _reminderEnabled = prefs.getBool(_kReminderEnabledKey) ?? true;
    _reminderHour = prefs.getInt(_kReminderHourKey) ?? 20;
    _reminderMinute = prefs.getInt(_kReminderMinuteKey) ?? 0;
    _dailyExpenseLimit = prefs.getDouble(_kExpenseLimitKey) ?? 50000;
    _themeMode = prefs.getString(_kThemeModeKey) ?? 'dark';
    _privacyMode = prefs.getBool(_kPrivacyModeKey) ?? false;
    _seaBankBalance = prefs.getDouble(_kSeaBankBalanceKey) ?? 0.0;
    _bankJagoBalance = prefs.getDouble(_kBankJagoBalanceKey) ?? 0.0;
    _pinEnabled = prefs.getBool(_kPinEnabledKey) ?? false;
    _pinCode = prefs.getString(_kPinCodeKey) ?? '';
    _hasSeenOnboarding = prefs.getBool(_kHasSeenOnboardingKey) ?? false;
    _cycleType = prefs.getString(_kCycleTypeKey) ?? 'monthly';
    _refillDay = prefs.getInt(_kRefillDayKey) ?? 1;
    if (_pinEnabled && _pinCode.isNotEmpty) {
      _isAppLocked = true;
    }

    // Load impulse items
    final impulseJson = prefs.getString(_kImpulseItemsKey);
    if (impulseJson != null && impulseJson.isNotEmpty) {
      try {
        final List<dynamic> decodedImpulse = jsonDecode(impulseJson);
        _impulseItems.clear();
        for (var item in decodedImpulse) {
          _impulseItems.add(ImpulseItem.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Failed to decode impulse items: $e');
      }
    }

    // Load savings goals
    final goalsJson = prefs.getString(_kSavingsGoalsKey);
    if (goalsJson != null && goalsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedGoals = jsonDecode(goalsJson);
        _savingsGoals.clear();
        for (var item in decodedGoals) {
          _savingsGoals.add(SavingsGoal.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Failed to decode savings goals: $e');
      }
    }

    // Load transfers
    final transfersJson = prefs.getString(_kTransfersKey);
    if (transfersJson != null && transfersJson.isNotEmpty) {
      try {
        final List<dynamic> decodedTransfers = jsonDecode(transfersJson);
        _transfers.clear();
        for (var item in decodedTransfers) {
          _transfers.add(PocketTransfer.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Failed to decode pocket transfers: $e');
      }
    }

    // Load dynamic custom assets
    final assetsJson = prefs.getString(_kCustomAssetsKey);
    if (assetsJson != null && assetsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedAssets = jsonDecode(assetsJson);
        _customAssets.clear();
        for (var item in decodedAssets) {
          _customAssets.add(AssetAccount.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Failed to decode custom assets: $e');
      }
    }

    // Initialize default starter pockets with 0 balance if empty (Clean Slate for new users)
    if (_customAssets.isEmpty) {
      _customAssets.add(AssetAccount(
        id: 'asset-seabank',
        name: 'SeaBank',
        balance: 0.0,
        colorValue: 0xFFF97316,
        iconName: 'account_balance',
      ));
      _customAssets.add(AssetAccount(
        id: 'asset-bank-jago',
        name: 'Bank Jago',
        balance: 0.0,
        colorValue: 0xFF8B5CF6,
        iconName: 'account_balance_wallet',
      ));
      await _saveCustomAssetsToPrefs();
    }

    // Load user entries (loads user existing data; keeps clean empty [] for new users)
    final jsonString = prefs.getString(_kEntriesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _entries.clear();
        for (var item in decoded) {
          _entries.add(DayEntry.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Failed to decode stored entries: $e');
      }
    }

    final storedSeedVersion = prefs.getInt(_kSeedVersionKey) ?? 0;
    final hasLegacySeedAnomaly = _entries.any((e) => e.income == 112000.0);
    if (storedSeedVersion < _kCurrentSeedVersion && hasLegacySeedAnomaly) {
      await loadSampleDemoData();
      await prefs.setInt(_kSeedVersionKey, _kCurrentSeedVersion);
      return;
    }

    if (_entries.isEmpty && loadSampleDataIfEmpty) {
      await loadSampleDemoData();
      return;
    }

    _recalculateBalances();
    _isLoaded = true;
    notifyListeners();
  }

  /// Load sample demo dataset (for testing or manual demo)
  Future<void> loadSampleDemoData() async {
    _loadSeedData();
    await _saveEntriesToPrefs();

    final seaBankIndex = _customAssets.indexWhere((a) => a.id == 'asset-seabank' || a.name.toLowerCase() == 'seabank');
    if (seaBankIndex != -1) {
      _customAssets[seaBankIndex] = _customAssets[seaBankIndex].copyWith(balance: 143000);
      await _saveCustomAssetsToPrefs();
    }

    final jagoIndex = _customAssets.indexWhere((a) => a.id == 'asset-bank-jago' || a.name.toLowerCase() == 'bank jago');
    if (jagoIndex != -1) {
      _customAssets[jagoIndex] = _customAssets[jagoIndex].copyWith(balance: 1755000);
      await _saveCustomAssetsToPrefs();
    }

    _transfers.clear();
    await _saveTransfersToPrefs();

    _recalculateBalances();
    notifyListeners();
  }

  void _loadSeedData() {
    _entries.clear();
    final uuid = const Uuid();

    // 3 November 2026: Pemasukan 40k, Pengeluaran 18k, Save 5k -> Sisa 17k, Total Simpan 5k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 3),
      income: 40000,
      incomeNote: 'Pemasukan harian',
      saveAmount: 5000,
      saveNote: 'Save harian',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Pengeluaran',
          amount: 18000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 18000,
    ));

    // 4 November 2026: Pemasukan 50k, Pengeluaran 19k, Sisa 43k, Save 5k, Total Simpan 10k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 4),
      income: 50000,
      incomeNote: 'Pemasukan harian',
      saveAmount: 5000,
      saveNote: 'Save harian',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Pengeluaran',
          amount: 19000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 19000,
    ));

    // 5 November 2026: Pemasukan 31k, Pengeluaran 0k, Sisa 64k, Save 10k, Total Simpan 20k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 5),
      income: 31000,
      incomeNote: 'Pemasukan harian',
      saveAmount: 10000,
      saveNote: 'Save harian',
      expenses: [],
      directExpense: 0,
    ));

    // 6 November 2026: Pemasukan 82k, Pengeluaran 12k, Sisa 114k, Save 20k, Masuk Seabank 30k, Total Simpan 40k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 6),
      income: 82000,
      incomeNote: 'Pemasukan harian',
      saveAmount: 20000,
      saveNote: 'Save harian (Masuk SeaBank 30k)',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Pengeluaran',
          amount: 12000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 12000,
    ));

    // 7 November 2026: Pemasukan 10k, Pengeluaran 12k, Sisa 92k, Save 20k, Total Simpan 60k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 7),
      income: 10000,
      incomeNote: 'Pemasukan harian',
      saveAmount: 20000,
      saveNote: 'Save harian',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Pengeluaran',
          amount: 12000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 12000,
    ));

    // 8 November 2026: Pemasukan 90k, Pengeluaran 0k, Sisa 122k, Save 60k, Total Simpan 120k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 8),
      income: 90000,
      incomeNote: '',
      saveAmount: 60000,
      saveNote: '',
      expenses: [],
      directExpense: 0,
    ));

    // 9 November 2026: Pemasukan 30k, Pengeluaran 35k (Bensin), Sisa 67k, Save 50k, Total Simpan 170k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 9),
      income: 30000,
      incomeNote: '',
      saveAmount: 50000,
      saveNote: '',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Bensin',
          amount: 35000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 35000,
    ));

    // 10 November 2026: Pemasukan 25k, Pengeluaran 5k (Minuman), Sisa 77k, Save 10k, Total Simpan 180k
    _entries.add(DayEntry(
      id: uuid.v4(),
      date: DateTime(2026, 11, 10),
      income: 25000,
      incomeNote: '',
      saveAmount: 10000,
      saveNote: '',
      expenses: [
        ExpenseItem(
          id: uuid.v4(),
          title: 'Minuman',
          amount: 5000,
          category: ExpenseCategory.makanan,
        ),
      ],
      directExpense: 5000,
    ));
  }

  /// Recalculate running balances (Sisa & Total Simpan) in chronological order
  void _recalculateBalances() {
    _entries.sort((a, b) => a.date.compareTo(b.date));

    double runningSisa = 0.0;
    double runningTotalSimpan = 0.0;

    for (var entry in _entries) {
      runningSisa += (entry.income - entry.totalExpense - entry.saveAmount);
      runningTotalSimpan += entry.saveAmount;

      entry.runningSisa = runningSisa;
      entry.runningTotalSimpan = runningTotalSimpan;
    }
  }

  Future<void> _saveEntriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _entries.map((e) => e.toJson()).toList();
    await prefs.setString(_kEntriesKey, jsonEncode(jsonList));
  }

  /// Calculate previous Sisa before a given date
  double getSisaBeforeDate(DateTime date, {String? excludeEntryId}) {
    final target = DateTime(date.year, date.month, date.day);
    final list = _entries
        .where((e) =>
            (excludeEntryId == null || e.id != excludeEntryId) &&
            DateTime(e.date.year, e.date.month, e.date.day).isBefore(target))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    double s = 0.0;
    for (var e in list) {
      s += (e.income - e.totalExpense - e.saveAmount);
    }
    return s;
  }

  /// Calculate previous Total Simpan before a given date
  double getTotalSimpanBeforeDate(DateTime date, {String? excludeEntryId}) {
    final target = DateTime(date.year, date.month, date.day);
    final list = _entries
        .where((e) =>
            (excludeEntryId == null || e.id != excludeEntryId) &&
            DateTime(e.date.year, e.date.month, e.date.day).isBefore(target))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    double ts = 0.0;
    for (var e in list) {
      ts += e.saveAmount;
    }
    return ts;
  }

  /// Add or update entry for a specific date
  Future<void> saveOrUpdateEntry(DayEntry entry) async {
    // Remove existing entry with the same ID if it exists (handles date edits cleanly)
    _entries.removeWhere((e) => e.id == entry.id);

    final index = _entries.indexWhere(
      (e) =>
          e.date.year == entry.date.year &&
          e.date.month == entry.date.month &&
          e.date.day == entry.date.day,
    );

    if (index >= 0) {
      _entries[index] = entry;
    } else {
      _entries.add(entry);
    }

    _recalculateBalances();
    await _saveEntriesToPrefs();
    notifyListeners();
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _recalculateBalances();
    await _saveEntriesToPrefs();
    notifyListeners();
  }

  /// Get entry by exact date
  DayEntry? getEntryByDate(DateTime date) {
    try {
      return _entries.firstWhere(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  /// Filter entries by month & year
  List<DayEntry> getEntriesByMonth(int year, int month) {
    return _entries
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  /// Save preferences
  Future<void> updateSettings({
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    double? dailyExpenseLimit,
    String? themeMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (reminderEnabled != null) {
      _reminderEnabled = reminderEnabled;
      await prefs.setBool(_kReminderEnabledKey, reminderEnabled);
    }
    if (reminderHour != null) {
      _reminderHour = reminderHour;
      await prefs.setInt(_kReminderHourKey, reminderHour);
    }
    if (reminderMinute != null) {
      _reminderMinute = reminderMinute;
      await prefs.setInt(_kReminderMinuteKey, reminderMinute);
    }
    if (dailyExpenseLimit != null) {
      _dailyExpenseLimit = dailyExpenseLimit;
      await prefs.setDouble(_kExpenseLimitKey, dailyExpenseLimit);
    }
    if (themeMode != null) {
      _themeMode = themeMode;
      await prefs.setString(_kThemeModeKey, themeMode);
    }

    notifyListeners();
  }

  /// Save custom assets to SharedPreferences
  Future<void> _saveCustomAssetsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _customAssets.map((a) => a.toJson()).toList();
    await prefs.setString(_kCustomAssetsKey, jsonEncode(jsonList));
  }

  /// Add a dynamic custom asset account
  Future<void> addAssetAccount(AssetAccount account) async {
    _customAssets.add(account);
    await _saveCustomAssetsToPrefs();
    notifyListeners();
  }

  /// Update an existing dynamic custom asset account
  Future<void> updateAssetAccount(AssetAccount account) async {
    final index = _customAssets.indexWhere((a) => a.id == account.id);
    if (index >= 0) {
      _customAssets[index] = account;
      await _saveCustomAssetsToPrefs();
      notifyListeners();
    }
  }

  /// Quick update balance of a specific custom asset account
  Future<void> updateAssetBalance(String id, double newBalance) async {
    final index = _customAssets.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _customAssets[index].balance = newBalance;
      await _saveCustomAssetsToPrefs();
      notifyListeners();
    }
  }

  /// Delete a dynamic custom asset account
  Future<void> deleteAssetAccount(String id) async {
    _customAssets.removeWhere((a) => a.id == id);
    await _saveCustomAssetsToPrefs();
    notifyListeners();
  }

  /// Update bank asset balances (SeaBank & Bank Jago) with backwards compatibility
  Future<void> updateBankBalances({double? seaBank, double? bankJago}) async {
    final prefs = await SharedPreferences.getInstance();
    if (seaBank != null) {
      _seaBankBalance = seaBank;
      await prefs.setDouble(_kSeaBankBalanceKey, seaBank);
      final idx = _customAssets.indexWhere((a) => a.id == 'asset-seabank' || a.name.toLowerCase() == 'seabank');
      if (idx >= 0) {
        _customAssets[idx].balance = seaBank;
      }
    }
    if (bankJago != null) {
      _bankJagoBalance = bankJago;
      await prefs.setDouble(_kBankJagoBalanceKey, bankJago);
      final idx = _customAssets.indexWhere((a) => a.id == 'asset-bank-jago' || a.name.toLowerCase() == 'bank jago');
      if (idx >= 0) {
        _customAssets[idx].balance = bankJago;
      }
    }
    await _saveCustomAssetsToPrefs();
    notifyListeners();
  }

  /// Transfer funds between pockets (Tabungan, Cash, SeaBank, Bank Jago, etc.)
  Future<void> transferFunds(PocketTransfer transfer) async {
    // If from is a custom asset account, deduct balance
    final fromIdx = _customAssets.indexWhere((a) => a.id == transfer.fromPocketId);
    if (fromIdx >= 0) {
      _customAssets[fromIdx].balance -= transfer.amount;
    }

    // If to is a custom asset account, add balance
    final toIdx = _customAssets.indexWhere((a) => a.id == transfer.toPocketId);
    if (toIdx >= 0) {
      _customAssets[toIdx].balance += transfer.amount;
    }

    _transfers.insert(0, transfer);
    await _saveTransfersToPrefs();
    await _saveCustomAssetsToPrefs();
    notifyListeners();
  }

  /// Delete / cancel a transfer
  Future<void> deleteTransfer(String transferId) async {
    final idx = _transfers.indexWhere((t) => t.id == transferId);
    if (idx >= 0) {
      final transfer = _transfers[idx];
      // Reverse custom asset modifications
      final fromIdx = _customAssets.indexWhere((a) => a.id == transfer.fromPocketId);
      if (fromIdx >= 0) {
        _customAssets[fromIdx].balance += transfer.amount;
      }
      final toIdx = _customAssets.indexWhere((a) => a.id == transfer.toPocketId);
      if (toIdx >= 0) {
        _customAssets[toIdx].balance -= transfer.amount;
      }

      _transfers.removeAt(idx);
      await _saveTransfersToPrefs();
      await _saveCustomAssetsToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveTransfersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _transfers.map((t) => t.toJson()).toList();
    await prefs.setString(_kTransfersKey, jsonEncode(jsonList));
  }

  /// Reset all data to 0 (Clean Slate for fresh app start)
  Future<void> resetToCleanSlate() async {
    _entries.clear();
    _recalculateBalances();
    await _saveEntriesToPrefs();

    _transfers.clear();
    await _saveTransfersToPrefs();

    _impulseItems.clear();
    await _saveImpulseItemsToPrefs();

    _savingsGoals.clear();
    await _saveSavingsGoalsToPrefs();

    _customAssets.clear();
    _customAssets.add(AssetAccount(
      id: 'asset-seabank',
      name: 'SeaBank',
      balance: 0.0,
      colorValue: 0xFFF97316,
      iconName: 'account_balance',
    ));
    _customAssets.add(AssetAccount(
      id: 'asset-bank-jago',
      name: 'Bank Jago',
      balance: 0.0,
      colorValue: 0xFF8B5CF6,
      iconName: 'account_balance_wallet',
    ));
    await _saveCustomAssetsToPrefs();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeedVersionKey, _kCurrentSeedVersion);

    notifyListeners();
  }

  /// Reset to initial user sample data
  Future<void> resetToDefault() async {
    _loadSeedData();
    _recalculateBalances();
    await _saveEntriesToPrefs();

    _customAssets.clear();
    _customAssets.add(AssetAccount(
      id: 'asset-seabank',
      name: 'SeaBank',
      balance: 143000,
      colorValue: 0xFFF97316,
      iconName: 'account_balance',
    ));
    _customAssets.add(AssetAccount(
      id: 'asset-bank-jago',
      name: 'Bank Jago',
      balance: 1755000,
      colorValue: 0xFF8B5CF6,
      iconName: 'account_balance_wallet',
    ));
    await _saveCustomAssetsToPrefs();

    _transfers.clear();
    await _saveTransfersToPrefs();

    _savingsGoals.clear();
    _savingsGoals.add(SavingsGoal(
      id: 'goal-sample-1',
      title: 'Laptop Kerja & Skripsi',
      targetAmount: 5000000,
      currentAmount: 2500000,
      colorHex: 0xFF00F59B,
      iconName: 'laptop_mac',
      createdAt: DateTime(2026, 11, 1),
    ));
    await _saveSavingsGoalsToPrefs();

    notifyListeners();
  }

  /// Export data as formatted JSON string (entries + custom assets + transfers)
  String exportJson() {
    final data = {
      'version': 3,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': _entries.map((e) => e.toJson()).toList(),
      'assets': _customAssets.map((a) => a.toJson()).toList(),
      'transfers': _transfers.map((t) => t.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Import data from JSON string (supports version 3 map, version 2 map, and legacy list)
  Future<bool> importJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final hasEntries = decoded.containsKey('entries') && decoded['entries'] is List;
        final hasAssets = decoded.containsKey('assets') && decoded['assets'] is List;
        final hasTransfers = decoded.containsKey('transfers') && decoded['transfers'] is List;

        if (!hasEntries && !hasAssets && !hasTransfers) {
          return false;
        }

        if (hasEntries) {
          _entries.clear();
          for (var item in decoded['entries'] as List<dynamic>) {
            _entries.add(DayEntry.fromJson(item as Map<String, dynamic>));
          }
        }
        if (hasAssets) {
          _customAssets.clear();
          for (var item in decoded['assets'] as List<dynamic>) {
            _customAssets.add(AssetAccount.fromJson(item as Map<String, dynamic>));
          }
          await _saveCustomAssetsToPrefs();
        }
        if (hasTransfers) {
          _transfers.clear();
          for (var item in decoded['transfers'] as List<dynamic>) {
            _transfers.add(PocketTransfer.fromJson(item as Map<String, dynamic>));
          }
          await _saveTransfersToPrefs();
        }
      } else if (decoded is List<dynamic>) {
        _entries.clear();
        for (var item in decoded) {
          _entries.add(DayEntry.fromJson(item as Map<String, dynamic>));
        }
      } else {
        return false;
      }

      _recalculateBalances();
      await _saveEntriesToPrefs();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  // ==========================================
  // UNIVERSAL DEFENSE: IMPULSE & CYCLE METHODS
  // ==========================================

  Future<void> _saveImpulseItemsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_impulseItems.map((e) => e.toJson()).toList());
    await prefs.setString(_kImpulseItemsKey, jsonStr);
  }

  Future<void> addImpulseItem(ImpulseItem item) async {
    _impulseItems.insert(0, item);
    await _saveImpulseItemsToPrefs();
    notifyListeners();
  }

  Future<void> updateImpulseItem(ImpulseItem item) async {
    final idx = _impulseItems.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _impulseItems[idx] = item;
      await _saveImpulseItemsToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteImpulseItem(String id) async {
    _impulseItems.removeWhere((i) => i.id == id);
    await _saveImpulseItemsToPrefs();
    notifyListeners();
  }

  /// Diverts quarantined impulse to savings! Boosts savings balance.
  Future<void> divertImpulseToSavings(ImpulseItem item) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = getEntryByDate(today);

    if (existing != null) {
      final updated = existing.copyWith(saveAmount: existing.saveAmount + item.amount);
      await saveOrUpdateEntry(updated);
    } else {
      final newEntry = DayEntry(
        id: const Uuid().v4(),
        date: today,
        income: 0.0,
        saveAmount: item.amount,
        directExpense: 0.0,
        expenses: [],
      );
      await saveOrUpdateEntry(newEntry);
    }

    await updateImpulseItem(item.copyWith(status: 'saved'));
  }

  /// Claims quarantined impulse as purchase: creates real logged expense on today's entry!
  Future<void> claimImpulseAsPurchase(ImpulseItem item) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = getEntryByDate(today);

    ExpenseCategory category = ExpenseCategory.lainnya;
    for (var cat in ExpenseCategory.values) {
      if (cat.name.toLowerCase() == item.category.toLowerCase() ||
          cat.displayName.toLowerCase().contains(item.category.toLowerCase())) {
        category = cat;
        break;
      }
    }

    final newItem = ExpenseItem(
      id: const Uuid().v4(),
      title: item.title,
      amount: item.amount,
      category: category,
      note: 'Dibeli setelah karantina 48 jam',
    );

    if (existing != null) {
      final updatedExpenses = List<ExpenseItem>.from(existing.expenses)..add(newItem);
      final updated = existing.copyWith(expenses: updatedExpenses);
      await saveOrUpdateEntry(updated);
    } else {
      final newEntry = DayEntry(
        id: const Uuid().v4(),
        date: today,
        income: 0.0,
        saveAmount: 0.0,
        directExpense: item.amount,
        expenses: [newItem],
      );
      await saveOrUpdateEntry(newEntry);
    }

    await updateImpulseItem(item.copyWith(status: 'purchased'));
  }

  Future<void> setCycleConfiguration({
    required String cycleType,
    required int refillDay,
  }) async {
    _cycleType = cycleType;
    _refillDay = refillDay;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCycleTypeKey, cycleType);
    await prefs.setInt(_kRefillDayKey, refillDay);
    notifyListeners();
  }

  /// Average daily burn rate across recent entries
  double get averageDailyBurn {
    if (_entries.isEmpty) return _dailyExpenseLimit > 0 ? _dailyExpenseLimit : 35000.0;
    final recent = _entries.reversed.take(14).toList();
    double sumExp = 0.0;
    int count = 0;
    for (final e in recent) {
      if (e.totalExpense > 0) {
        sumExp += e.totalExpense;
        count++;
      }
    }
    if (count == 0) return _dailyExpenseLimit > 0 ? _dailyExpenseLimit : 35000.0;
    final avg = sumExp / count;
    return avg > 1000 ? avg : 35000.0;
  }

  /// Calculates equivalent days of survival / daily allowance for a given amount
  double calculateLifeDaysEquivalent(double amount) {
    final burn = averageDailyBurn;
    if (burn <= 0) return 0.0;
    return amount / burn;
  }

  /// Deterministic universal safe spending metrics
  DailySafeSpendMetrics getDailySafeSpendingMetrics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEntry = getEntryByDate(today);
    final spentToday = todayEntry?.totalExpense ?? 0.0;

    int daysLeft = 1;
    String label = '';

    if (_cycleType == 'weekly') {
      final currentWeekday = now.weekday;
      final target = _refillDay.clamp(1, 7);
      if (currentWeekday == target) {
        daysLeft = 7;
      } else if (currentWeekday < target) {
        daysLeft = target - currentWeekday;
      } else {
        daysLeft = 7 - (currentWeekday - target);
      }
      const dayNames = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      label = 'Mingguan (Refill ${dayNames[target]})';
    } else if (_cycleType == 'monthly') {
      final targetDay = _refillDay.clamp(1, 31);
      if (now.day < targetDay) {
        daysLeft = targetDay - now.day;
      } else {
        final nextMonth = DateTime(now.year, now.month + 1, targetDay);
        daysLeft = nextMonth.difference(today).inDays;
      }
      daysLeft = daysLeft.clamp(1, 31);
      label = 'Bulanan (Refill tgl $targetDay)';
    } else {
      final totalAssets = totalAllAssets;
      final burn = averageDailyBurn;
      daysLeft = burn > 0 ? (totalAssets / burn).ceil() : 30;
      if (daysLeft < 1) daysLeft = 1;
      label = 'Siklus Bebas / Runway';
    }

    final availableLiquid = totalAllAssets;
    final safeQuota = daysLeft > 0 ? (availableLiquid / daysLeft) : _dailyExpenseLimit;
    final remainingQuota = safeQuota - spentToday;
    final percentUsed = safeQuota > 0 ? (spentToday / safeQuota) : 0.0;

    return DailySafeSpendMetrics(
      safeQuota: safeQuota,
      spentToday: spentToday,
      remainingQuota: remainingQuota,
      percentUsed: percentUsed,
      daysLeftInCycle: daysLeft,
      cycleLabel: label,
    );
  }

  // ==========================================
  // SAVINGS GOAL VAULT (KANTONG IMPIAN) METHODS
  // ==========================================

  Future<void> _saveSavingsGoalsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_savingsGoals.map((g) => g.toJson()).toList());
    await prefs.setString(_kSavingsGoalsKey, jsonStr);
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await _saveSavingsGoalsToPrefs();
    notifyListeners();
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final idx = _savingsGoals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _savingsGoals[idx] = goal;
      await _saveSavingsGoalsToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    _savingsGoals.removeWhere((g) => g.id == id);
    await _saveSavingsGoalsToPrefs();
    notifyListeners();
  }

  /// Deposit money into a savings goal from a specific pocket
  Future<bool> depositToSavingsGoal({
    required String goalId,
    required double amount,
    required String fromPocketId,
  }) async {
    if (amount <= 0) return false;
    final goalIdx = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return false;

    // Deduct from pocket
    if (fromPocketId == kPocketCashId) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final existing = getEntryByDate(today);
      final entry = (existing != null)
          ? existing.copyWith(saveAmount: existing.saveAmount + amount)
          : DayEntry(
              id: const Uuid().v4(),
              date: today,
              saveAmount: amount,
            );
      await saveOrUpdateEntry(entry);
    } else if (fromPocketId != kPocketSavingsId) {
      final asset = _customAssets.where((a) => a.id == fromPocketId).firstOrNull;
      if (asset != null) {
        final newBal = (asset.balance - amount).clamp(0.0, double.infinity);
        await updateAssetBalance(asset.id, newBal);
      }
    }

    final goal = _savingsGoals[goalIdx];
    _savingsGoals[goalIdx] = goal.copyWith(currentAmount: goal.currentAmount + amount);
    await _saveSavingsGoalsToPrefs();
    notifyListeners();
    return true;
  }

  /// Withdraw money from a savings goal back to a specific pocket
  Future<bool> withdrawFromSavingsGoal({
    required String goalId,
    required double amount,
    required String toPocketId,
  }) async {
    if (amount <= 0) return false;
    final goalIdx = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (goalIdx == -1) return false;

    final goal = _savingsGoals[goalIdx];
    if (goal.currentAmount < amount) return false;

    _savingsGoals[goalIdx] = goal.copyWith(currentAmount: goal.currentAmount - amount);
    await _saveSavingsGoalsToPrefs();

    // Add back to destination pocket
    if (toPocketId == kPocketCashId) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final existing = getEntryByDate(today);
      if (existing != null && existing.saveAmount >= amount) {
        await saveOrUpdateEntry(existing.copyWith(saveAmount: existing.saveAmount - amount));
      } else {
        await saveOrUpdateEntry(DayEntry(
          id: const Uuid().v4(),
          date: today,
          income: amount,
          incomeNote: 'Tarik dari Kantong Impian (${goal.title})',
        ));
      }
    } else if (toPocketId != kPocketSavingsId) {
      final asset = _customAssets.where((a) => a.id == toPocketId).firstOrNull;
      if (asset != null) {
        await updateAssetBalance(asset.id, asset.balance + amount);
      }
    }

    notifyListeners();
    return true;
  }

  /// Calculates estimated days remaining to reach goal based on daily savings rate
  int calculateDaysToReachGoal(SavingsGoal goal) {
    if (goal.isCompleted) return 0;
    final remaining = goal.remainingAmount;
    final burn = averageDailyBurn;
    final dailySavingRate = burn > 0 ? (burn * 0.35) : 20000.0;
    return (remaining / dailySavingRate).ceil().clamp(1, 999);
  }
}
