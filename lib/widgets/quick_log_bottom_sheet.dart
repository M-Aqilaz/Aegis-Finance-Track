import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/impulse_item.dart';
import '../models/transaction_entry.dart';
import '../screens/add_edit_entry_screen.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class QuickLogBottomSheet extends StatefulWidget {
  final StorageService storageService;

  const QuickLogBottomSheet({super.key, required this.storageService});

  static Future<void> show(BuildContext context, {required StorageService storageService}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickLogBottomSheet(storageService: storageService),
    );
  }

  @override
  State<QuickLogBottomSheet> createState() => _QuickLogBottomSheetState();
}

class _QuickLogBottomSheetState extends State<QuickLogBottomSheet> {
  String _type = 'expense'; // 'expense', 'income', 'save'
  ExpenseCategory _selectedCategory = ExpenseCategory.makanan;

  // Independent isolated amounts per tab so amounts never leak across categories
  String _expenseAmountStr = '0';
  String _incomeAmountStr = '0';
  String _saveAmountStr = '0';

  String get _currentAmountStr {
    switch (_type) {
      case 'income':
        return _incomeAmountStr;
      case 'save':
        return _saveAmountStr;
      case 'expense':
      default:
        return _expenseAmountStr;
    }
  }

  set _currentAmountStr(String val) {
    switch (_type) {
      case 'income':
        _incomeAmountStr = val;
        break;
      case 'save':
        _saveAmountStr = val;
        break;
      case 'expense':
      default:
        _expenseAmountStr = val;
        break;
    }
  }

  double get _expenseAmount => double.tryParse(_expenseAmountStr) ?? 0.0;
  double get _incomeAmount => double.tryParse(_incomeAmountStr) ?? 0.0;
  double get _saveAmount => double.tryParse(_saveAmountStr) ?? 0.0;
  double get _amount => double.tryParse(_currentAmountStr) ?? 0.0;

  void _onDigit(String d) {
    setState(() {
      var cur = _currentAmountStr;
      if (cur == '0') {
        cur = d;
      } else if (cur.length < 9) {
        cur += d;
      }
      _currentAmountStr = cur;
    });
  }

  void _onBackspace() {
    setState(() {
      var cur = _currentAmountStr;
      if (cur.length <= 1) {
        cur = '0';
      } else {
        cur = cur.substring(0, cur.length - 1);
      }
      _currentAmountStr = cur;
    });
  }

  void _onClear() {
    setState(() {
      _currentAmountStr = '0';
    });
  }

  void _addQuick(int val) {
    setState(() {
      final current = double.tryParse(_currentAmountStr) ?? 0.0;
      _currentAmountStr = (current + val).toInt().toString();
    });
  }

  Future<void> _submit() async {
    final exp = _expenseAmount;
    final inc = _incomeAmount;
    final sav = _saveAmount;

    if (exp <= 0 && inc <= 0 && sav <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal lebih dari 0'),
          backgroundColor: AppTheme.neonCoral,
        ),
      );
      return;
    }

    const uuid = Uuid();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = widget.storageService.getEntryByDate(today);

    final List<ExpenseItem> updatedExpenses = existing != null
        ? List<ExpenseItem>.from(existing.expenses)
        : <ExpenseItem>[];

    if (exp > 0) {
      updatedExpenses.add(ExpenseItem(
        id: uuid.v4(),
        title: _selectedCategory.displayName,
        amount: exp,
        category: _selectedCategory,
      ));
    }

    final double newIncome = (existing?.income ?? 0.0) + (inc > 0 ? inc : 0.0);
    final double newSave = (existing?.saveAmount ?? 0.0) + (sav > 0 ? sav : 0.0);

    final newEntry = DayEntry(
      id: existing?.id ?? uuid.v4(),
      date: today,
      income: newIncome,
      incomeNote: existing?.incomeNote ?? '',
      saveAmount: newSave,
      saveNote: existing?.saveNote ?? '',
      expenses: updatedExpenses,
      directExpense: 0.0,
    );

    await widget.storageService.saveOrUpdateEntry(newEntry);

    if (mounted) {
      Navigator.pop(context);
      final List<String> summaryParts = [];
      if (exp > 0) summaryParts.add('Keluar: ${CurrencyFormatter.formatRp(exp)}');
      if (inc > 0) summaryParts.add('Masuk: ${CurrencyFormatter.formatRp(inc)}');
      if (sav > 0) summaryParts.add('Nabung: ${CurrencyFormatter.formatRp(sav)}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tercatat: ${summaryParts.join(' • ')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.cyberMint,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _quarantine() async {
    final amount = _expenseAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal pengeluaran di tab Keluar terlebih dahulu'),
          backgroundColor: AppTheme.neonCoral,
        ),
      );
      return;
    }
    final item = ImpulseItem(
      id: const Uuid().v4(),
      title: _selectedCategory.displayName,
      amount: amount,
      createdAt: DateTime.now(),
      durationHours: 48,
      category: _selectedCategory.displayName,
    );
    await widget.storageService.addImpulseItem(item);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF6366F1),
          content: Row(
            children: [
              const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🛡️ Berhasil ditahan 48 Jam di Kotak Pending! Anda mengamankan ${CurrencyFormatter.formatRp(amount)}.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppTheme.borderLight, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Type Selector: Keluar | Masuk | Save
            Row(
              children: [
                _buildTypeTab('Keluar', 'expense', AppTheme.neonCoral, Icons.arrow_downward_rounded),
                const SizedBox(width: 8),
                _buildTypeTab('Masuk', 'income', AppTheme.cyberMint, Icons.arrow_upward_rounded),
                const SizedBox(width: 8),
                _buildTypeTab('Nabung', 'save', AppTheme.electricCyan, Icons.savings_rounded),
              ],
            ),

            const SizedBox(height: 16),

            // Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.obsidianBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nominal:', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    CurrencyFormatter.formatRp(_amount),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            if (_type == 'expense' && _amount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.solarAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 13, color: AppTheme.solarAmber),
                    const SizedBox(width: 5),
                    Text(
                      'Setara ~${widget.storageService.calculateLifeDaysEquivalent(_amount).toStringAsFixed(1)} Hari Uang Saku / Jatah Hidup',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.solarAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Quick Amount Increment Chips (+5k, +10k, +20k, +50k, +100k)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickChip('+5k', 5000),
                  _buildQuickChip('+10k', 10000),
                  _buildQuickChip('+20k', 20000),
                  _buildQuickChip('+50k', 50000),
                  _buildQuickChip('+100k', 100000),
                  InkWell(
                    onTap: _onClear,
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            if (_type == 'expense') ...[
              const SizedBox(height: 12),
              // Category avatar selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ExpenseCategory.values.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? cat.color.withValues(alpha: 0.25) : AppTheme.surfaceCardElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? cat.color : AppTheme.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 14, color: cat.color),
                            const SizedBox(width: 5),
                            Text(
                              cat.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                color: isSel ? Colors.white : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Custom Numpad Grid
            Column(
              children: [
                _buildPadRow(['1', '2', '3']),
                const SizedBox(height: 6),
                _buildPadRow(['4', '5', '6']),
                const SizedBox(height: 6),
                _buildPadRow(['7', '8', '9']),
                const SizedBox(height: 6),
                _buildPadRow(['000', '0', '⌫']),
              ],
            ),

            const SizedBox(height: 14),

            // Submit / Quarantine Actions
            if (_type == 'expense' && _amount > 0) ...[
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF818CF8),
                          side: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _quarantine,
                        icon: const Icon(Icons.shield_outlined, size: 16),
                        label: const Text(
                          'Tahan 48 Jam',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyberMint,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _submit,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, size: 18, color: Colors.black87),
                            SizedBox(width: 6),
                            Text(
                              'Simpan Instan',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyberMint,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _submit,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, size: 20, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Instan (3 Detik)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Link to full detail form
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditEntryScreen(storageService: widget.storageService),
                  ),
                );
              },
              child: const Text(
                'Buka Formulir Detail Lengkap ›',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, String type, Color color, IconData icon) {
    final isSel = _type == type;
    double tabAmount = 0.0;
    if (type == 'expense') tabAmount = _expenseAmount;
    if (type == 'income') tabAmount = _incomeAmount;
    if (type == 'save') tabAmount = _saveAmount;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.2) : AppTheme.surfaceCardElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel
                  ? color
                  : (tabAmount > 0 ? color.withValues(alpha: 0.5) : AppTheme.borderLight),
              width: isSel ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: isSel ? color : (tabAmount > 0 ? color : Colors.white60)),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? Colors.white : (tabAmount > 0 ? Colors.white70 : Colors.white60),
                    ),
                  ),
                ],
              ),
              if (tabAmount > 0) ...[
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatShort(tabAmount),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, int val) {
    return GestureDetector(
      onTap: () => _addQuick(val),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCardElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cyberMint),
        ),
      ),
    );
  }

  Widget _buildPadRow(List<String> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 42,
            child: Material(
              color: AppTheme.surfaceCardElevated,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (item == '⌫') {
                    _onBackspace();
                  } else {
                    _onDigit(item);
                  }
                },
                child: Center(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: item == '000' ? 14 : 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
