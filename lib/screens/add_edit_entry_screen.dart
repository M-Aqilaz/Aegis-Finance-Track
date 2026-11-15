import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
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

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseCategory selectedCat = ExpenseCategory.makanan;

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
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        'Tambah Item Pengeluaran',
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
                    decoration: InputDecoration(
                      labelText: 'Nama Item',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      hintText: 'Contoh: 15k atau 15000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ExpenseCategory.values.map((cat) {
                      final isSelected = selectedCat == cat;
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(cat.displayName.split('(').first.trim()),
                        selectedColor: cat.color.withValues(alpha: 0.3),
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
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          // Update total expense
                          final sum = _expenseItems.fold(0.0, (s, i) => s + i.amount);
                          _expenseController.text = sum.toInt().toString();
                          _showItems = true;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Simpan Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry == null ? 'Catat Harian' : 'Ubah Catatan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            color: const Color(0xFF10B981),
            onPressed: _saveAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6366F1)),
                      const SizedBox(width: 10),
                      Text(
                        CurrencyFormatter.formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Ganti'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Calculated Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Sisa', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatShort(_calculatedSisa),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Column(
                        children: [
                          const Text('Total Simpan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatShort(_calculatedTotalSimpan),
                            style: const TextStyle(
                              color: Color(0xFF67E8F9),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 1. Pemasukan
            const Text('Pemasukan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              cursorColor: const Color(0xFF6366F1),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                hintText: 'Misal: 50k atau 50000',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 6),
            _buildChips(['30k', '40k', '50k', '100k'], (val) {
              setState(() {
                _incomeController.text = val;
              });
            }),

            const SizedBox(height: 18),

            // 2. Pengeluaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pengeluaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddExpenseDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Rincian Item'),
                ),
              ],
            ),
            TextField(
              controller: _expenseController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              cursorColor: const Color(0xFF6366F1),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                hintText: 'Misal: 19k atau 19000',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 6),
            _buildChips(['0', '10k', '18k', '19k', '25k'], (val) {
              setState(() {
                _expenseController.text = val;
              });
            }),

            // List of items if added
            if (_showItems && _expenseItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              ..._expenseItems.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.formatRp(item.amount),
                          style: TextStyle(color: item.category.color, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
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
                  ),
                );
              }),
            ],

            const SizedBox(height: 18),

            // 3. Save
            const Text('Save', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _saveController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              cursorColor: const Color(0xFF6366F1),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                hintText: 'Misal: 5k atau 10k',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 6),
            _buildChips(['0', '5k', '10k', '20k', '50k'], (val) {
              setState(() {
                _saveController.text = val;
              });
            }),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveAll,
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(List<String> items, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((val) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(val, style: const TextStyle(fontSize: 12)),
              onPressed: () => onSelect(val),
            ),
          );
        }).toList(),
      ),
    );
  }
}
