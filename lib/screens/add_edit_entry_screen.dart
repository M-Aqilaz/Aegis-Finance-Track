import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/impulse_item.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class AddEditEntryScreen extends StatefulWidget {
  final StorageService storageService;
  final DayEntry? existingEntry;

  const AddEditEntryScreen({
    super.key,
    required this.storageService,
    this.existingEntry,
  });

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  late DateTime _selectedDate;
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();
  final _saveController = TextEditingController();

  final List<ExpenseItem> _expenseItems = [];
  bool _showItems = false;
  ExpenseCategory _activeCategory = ExpenseCategory.makanan;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _selectedDate = e.date;
      _incomeController.text = e.income > 0 ? e.income.toInt().toString() : '';
      _expenseController.text = e.totalExpense > 0 ? e.totalExpense.toInt().toString() : '';
      _saveController.text = e.saveAmount > 0 ? e.saveAmount.toInt().toString() : '';
      _expenseItems.addAll(e.expenses);
      _showItems = e.expenses.isNotEmpty;
      if (e.expenses.isNotEmpty) {
        _activeCategory = e.expenses.first.category;
      }
    } else {
      _selectedDate = DateTime.now();
      final todayExisting = widget.storageService.getEntryByDate(_selectedDate);
      if (todayExisting != null) {
        _incomeController.text = todayExisting.income > 0 ? todayExisting.income.toInt().toString() : '';
        _expenseController.text = todayExisting.totalExpense > 0 ? todayExisting.totalExpense.toInt().toString() : '';
        _saveController.text = todayExisting.saveAmount > 0 ? todayExisting.saveAmount.toInt().toString() : '';
        _expenseItems.addAll(todayExisting.expenses);
        _showItems = todayExisting.expenses.isNotEmpty;
      } else {
        _incomeController.text = '';
        _expenseController.text = '';
        _saveController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _saveController.dispose();
    super.dispose();
  }

  double get _currentIncome => CurrencyFormatter.parseAmount(_incomeController.text);
  double get _currentExpense => CurrencyFormatter.parseAmount(_expenseController.text);
  double get _currentSave => CurrencyFormatter.parseAmount(_saveController.text);

  double get _previousSisa => widget.storageService.getSisaBeforeDate(
        _selectedDate,
        excludeEntryId: widget.existingEntry?.id,
      );

  double get _previousTotalSimpan => widget.storageService.getTotalSimpanBeforeDate(
        _selectedDate,
        excludeEntryId: widget.existingEntry?.id,
      );

  double get _calculatedSisa => _previousSisa + _currentIncome - _currentExpense - _currentSave;
  double get _calculatedTotalSimpan => _previousTotalSimpan + _currentSave;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (widget.existingEntry == null) {
          final existing = widget.storageService.getEntryByDate(picked);
          if (existing != null) {
            _incomeController.text = existing.income > 0 ? existing.income.toInt().toString() : '';
            _expenseController.text = existing.totalExpense > 0 ? existing.totalExpense.toInt().toString() : '';
            _saveController.text = existing.saveAmount > 0 ? existing.saveAmount.toInt().toString() : '';
            _expenseItems.clear();
            _expenseItems.addAll(existing.expenses);
            _showItems = existing.expenses.isNotEmpty;
          }
        }
      });
    }
  }

  void _addQuickAmount(TextEditingController controller, int addValue) {
    final current = CurrencyFormatter.parseAmount(controller.text);
    final next = (current + addValue).toInt();
    setState(() {
      controller.text = next.toString();
    });
  }

  void _clearAmount(TextEditingController controller) {
    setState(() {
      controller.text = '0';
    });
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseCategory selectedCat = _activeCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tambah Rincian Item',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Nama Item (Contoh: Nasi Goreng, Bensin)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      hintText: 'Contoh: 15k, 25000, 50rb',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Pilih Kategori:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ExpenseCategory.values.map((cat) {
                      final isSelected = selectedCat == cat;
                      return ChoiceChip(
                        selected: isSelected,
                        avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                        label: Text(cat.displayName.split('(').first.trim()),
                        selectedColor: cat.color.withValues(alpha: 0.35),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedCat = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF818CF8),
                            side: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final amount = CurrencyFormatter.parseAmount(amountController.text);
                            if (title.isEmpty || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Masukkan nama dan nominal yang benar')),
                              );
                              return;
                            }
                            final item = ImpulseItem(
                              id: const Uuid().v4(),
                              title: title,
                              amount: amount,
                              createdAt: DateTime.now(),
                              durationHours: 48,
                              category: selectedCat.displayName,
                            );
                            await widget.storageService.addImpulseItem(item);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF6366F1),
                                  content: Text('🛡️ Ditahan 48 Jam di Kotak Pending: $title'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.shield_outlined, size: 16),
                          label: const Text('Tahan 48 Jam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cyberMint,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            final title = titleController.text.trim();
                            final amount = CurrencyFormatter.parseAmount(amountController.text);
                            if (title.isEmpty || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Masukkan nama dan nominal yang benar')),
                              );
                              return;
                            }
                            setState(() {
                              _expenseItems.add(ExpenseItem(
                                id: const Uuid().v4(),
                                title: title,
                                amount: amount,
                                category: selectedCat,
                              ));
                              final sum = _expenseItems.fold(0.0, (s, i) => s + i.amount);
                              _expenseController.text = sum.toInt().toString();
                              _showItems = true;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Simpan Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveAll() async {
    final existingOnDate = widget.storageService.getEntryByDate(_selectedDate);
    final id = widget.existingEntry?.id ?? existingOnDate?.id ?? const Uuid().v4();
    final income = _currentIncome;
    final totalExp = _currentExpense;
    final save = _currentSave;

    final effectiveExpenses = totalExp == 0 ? <ExpenseItem>[] : _expenseItems;

    final entry = DayEntry(
      id: id,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      income: income,
      saveAmount: save,
      directExpense: totalExp,
      expenses: effectiveExpenses,
    );

    await widget.storageService.saveOrUpdateEntry(entry);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Catatan ${CurrencyFormatter.formatDate(_selectedDate)} tersimpan!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.cyberMint,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          widget.existingEntry == null ? 'Catat Keuangan Harian' : 'Ubah Catatan Keuangan',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.cyberMint),
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w900)),
            onPressed: _saveAll,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Date Picker Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.glassCardDecoration(borderRadius: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cyberMint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.cyberMint),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TANGGAL CATATAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.formatDate(_selectedDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.cyberMint.withValues(alpha: 0.4)),
                      foregroundColor: AppTheme.cyberMint,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _pickDate,
                    icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                    label: const Text('Ganti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Financial Impact Balance Card (Live Real-Time Feedback)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.cyberMint, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('Sisa Kas Berjalan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatRp(_calculatedSisa),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _calculatedSisa >= 0 ? Colors.white : AppTheme.neonCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 38, color: Colors.white12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.electricCyan, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('Total Simpanan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatRp(_calculatedTotalSimpan),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.electricCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Friendly Help Pill explaining input formats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, size: 16, color: AppTheme.solarAmber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bisa ketik angka langsung (misal: 25000) atau singkatan cepat (misal: 25k, 50rb, 1.5jt)',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. SECTION PENGELUARAN (Uang Keluar)
            _buildTransactionCard(
              title: 'PENGELUARAN (UANG KELUAR)',
              accentColor: AppTheme.neonCoral,
              icon: Icons.arrow_downward_rounded,
              controller: _expenseController,
              currentAmount: _currentExpense,
              quickChips: [5000, 10000, 20000, 50000, 100000],
              extraAction: TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppTheme.neonCoral,
                ),
                onPressed: _showAddExpenseDialog,
                icon: const Icon(Icons.playlist_add_rounded, size: 16),
                label: const Text('+ Rincian Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chips
                  const Text('Kategori Utama:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ExpenseCategory.values.map((cat) {
                        final isSel = _activeCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            selected: isSel,
                            avatar: Icon(cat.icon, size: 13, color: isSel ? Colors.white : cat.color),
                            label: Text(
                              cat.displayName.split('(').first.trim(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                color: isSel ? Colors.white : Colors.white70,
                              ),
                            ),
                            selectedColor: cat.color.withValues(alpha: 0.35),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _activeCategory = cat);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Itemized expenses list if available
                  if (_showItems && _expenseItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 4),
                    const Text('Daftar Rincian Item:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 6),
                    ..._expenseItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Icon(item.category.icon, size: 14, color: item.category.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatRp(item.amount),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.category.color,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _expenseItems.remove(item);
                                  final sum = _expenseItems.fold(0.0, (s, i) => s + i.amount);
                                  _expenseController.text = sum > 0 ? sum.toInt().toString() : '0';
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. SECTION PEMASUKAN (Uang Masuk)
            _buildTransactionCard(
              title: 'PEMASUKAN (UANG MASUK)',
              accentColor: AppTheme.cyberMint,
              icon: Icons.arrow_upward_rounded,
              controller: _incomeController,
              currentAmount: _currentIncome,
              quickChips: [20000, 50000, 100000, 250000, 500000],
            ),

            const SizedBox(height: 16),

            // 5. SECTION NABUNG VAULT (Tabungan)
            _buildTransactionCard(
              title: 'NABUNG VAULT (SIMPANAN)',
              accentColor: AppTheme.electricCyan,
              icon: Icons.savings_rounded,
              controller: _saveController,
              currentAmount: _currentSave,
              quickChips: [10000, 20000, 50000, 100000, 200000],
            ),

            const SizedBox(height: 24),

            // 6. Primary Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyberMint,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveAll,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 22, color: Colors.black87),
                    SizedBox(width: 8),
                    Text(
                      'Simpan Perubahan Catatan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required Color accentColor,
    required IconData icon,
    required TextEditingController controller,
    required double currentAmount,
    required List<int> quickChips,
    Widget? extraAction,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: currentAmount > 0 ? accentColor.withValues(alpha: 0.35) : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              ?extraAction,
            ],
          ),

          const SizedBox(height: 12),

          // Nominal Display & Live Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.obsidianBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                    cursorColor: accentColor,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 20, fontWeight: FontWeight.w900),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRp(currentAmount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: currentAmount > 0 ? accentColor : Colors.white24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Quick Increment Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...quickChips.map((val) {
                  final label = '+${CurrencyFormatter.formatShort(val.toDouble()).replaceAll('Rp ', '')}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => _addQuickAmount(controller, val),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCardElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                InkWell(
                  onTap: () => _clearAmount(controller),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (child != null) ...[
            const SizedBox(height: 12),
            child,
          ],
        ],
      ),
    );
  }
}
