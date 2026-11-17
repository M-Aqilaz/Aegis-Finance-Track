import 'package:flutter/material.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/daily_entry_card.dart';
import '../widgets/history_recap_dialog.dart';
import 'add_edit_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storageService;

  const HistoryScreen({super.key, required this.storageService});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, expense, income, save
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.storageService,
      builder: (context, _) {
        final allEntries = widget.storageService.entries;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Filter by month
        final monthEntries = allEntries.where((e) {
          return e.date.year == _selectedMonth.year &&
              e.date.month == _selectedMonth.month;
        }).toList();

        final expenseCount = monthEntries.where((e) => e.totalExpense > 0).length;
        final incomeCount = monthEntries.where((e) => e.income > 0).length;
        final saveCount = monthEntries.where((e) => e.saveAmount > 0).length;

        var filtered = List<DayEntry>.from(monthEntries);

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filtered = filtered.where((e) {
            final matchIncome = e.incomeNote.toLowerCase().contains(q);
            final matchSave = e.saveNote.toLowerCase().contains(q);
            final matchExpense = e.expenses.any((item) =>
                item.title.toLowerCase().contains(q) ||
                item.note.toLowerCase().contains(q) ||
                item.category.displayName.toLowerCase().contains(q));
            return matchIncome || matchSave || matchExpense;
          }).toList();
        }

        // Filter by type
        if (_filterType == 'expense') {
          filtered = filtered.where((e) => e.totalExpense > 0).toList();
        } else if (_filterType == 'income') {
          filtered = filtered.where((e) => e.income > 0).toList();
        } else if (_filterType == 'save') {
          filtered = filtered.where((e) => e.saveAmount > 0).toList();
        }

        // Sort descending (latest on top)
        filtered.sort((a, b) => b.date.compareTo(a.date));

        // Month statistics
        double monthIncome = 0;
        double monthExpense = 0;
        double monthSave = 0;
        for (var e in allEntries.where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)) {
          monthIncome += e.income;
          monthExpense += e.totalExpense;
          monthSave += e.saveAmount;
        }

        return Scaffold(
          backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text(
              'Riwayat Keuangan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  widget.storageService.privacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: widget.storageService.privacyMode ? AppTheme.solarAmber : Colors.white70,
                ),
                tooltip: widget.storageService.privacyMode ? 'Tampilkan Saldo' : 'Sembunyikan Saldo (Privasi)',
                onPressed: widget.storageService.togglePrivacyMode,
              ),
              IconButton(
                icon: const Icon(Icons.backup_table_rounded, color: AppTheme.cyberMint),
                tooltip: 'Rekap & Cadangan',
                onPressed: () => HistoryRecapDialog.show(context, widget.storageService),
              ),
            ],
          ),
          body: Column(
            children: [
              // Month Selector Bar (Prev, Current Month, Next)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceCard,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderLight, width: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      CurrencyFormatter.formatMonthYear(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Monthly Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.obsidianBg,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.borderLight,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniSum('Masuk', monthIncome, const Color(0xFF10B981)),
                    _buildMiniSum('Keluar', monthExpense, const Color(0xFFEF4444)),
                    _buildMiniSum('Tabung', monthSave, const Color(0xFF3B82F6)),
                    _buildMiniSum('Net', monthIncome - monthExpense - monthSave, const Color(0xFF8B5CF6)),
                  ],
                ),
              ),

              // Search & Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari catatan...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua (${monthEntries.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('expense', 'Pengeluaran ($expenseCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('income', 'Pemasukan ($incomeCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('save', 'Simpan ($saveCount)'),
                  ],
                ),
              ),

              // List of entries
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada data pada filter ini',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final entry = filtered[index];
                          return Dismissible(
                            key: ValueKey(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.white, size: 26),
                                  SizedBox(height: 4),
                                  Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Hapus Catatan?'),
                                  content: Text(
                                    'Catatan tanggal ${CurrencyFormatter.formatDate(entry.date)} akan dihapus. Perhitungan Sisa & Total Simpan akan otomatis diperbarui.',
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (_) {
                              widget.storageService.deleteEntry(entry.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Catatan ${CurrencyFormatter.formatDate(entry.date)} dihapus'),
                                  backgroundColor: Colors.red.shade700,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: DailyEntryCard(
                              entry: entry,
                              activeFilter: _filterType,
                              privacyMode: widget.storageService.privacyMode,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditEntryScreen(
                                      storageService: widget.storageService,
                                      existingEntry: entry,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDelete(context, entry),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniSum(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          widget.storageService.privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _filterType == type;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onSelected: (val) {
        if (val) {
          setState(() {
            _filterType = type;
          });
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, DayEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Catatan tanggal ${CurrencyFormatter.formatDate(entry.date)} akan dihapus. Perhitungan Sisa & Total Simpan akan otomatis diperbarui.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.storageService.deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
