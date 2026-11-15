import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/pocket_transfer.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

class TransferDialog extends StatefulWidget {
  final StorageService storageService;
  final String? initialFromPocketId;
  final String? initialToPocketId;

  const TransferDialog({
    super.key,
    required this.storageService,
    this.initialFromPocketId,
    this.initialToPocketId,
  });

  static Future<void> show(
    BuildContext context, {
    required StorageService storageService,
    String? initialFromPocketId,
    String? initialToPocketId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => TransferDialog(
        storageService: storageService,
        initialFromPocketId: initialFromPocketId,
        initialToPocketId: initialToPocketId,
      ),
    );
  }

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  late String _fromPocketId;
  late String _toPocketId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final pockets = widget.storageService.getAvailablePockets();

    // Default 'From': passed ID, or Tabungan, or first available
    if (widget.initialFromPocketId != null &&
        pockets.any((p) => p.id == widget.initialFromPocketId)) {
      _fromPocketId = widget.initialFromPocketId!;
    } else {
      _fromPocketId = StorageService.kPocketSavingsId;
    }

    // Default 'To': passed ID, or Cash, or a different pocket
    if (widget.initialToPocketId != null &&
        widget.initialToPocketId != _fromPocketId &&
        pockets.any((p) => p.id == widget.initialToPocketId)) {
      _toPocketId = widget.initialToPocketId!;
    } else {
      final other = pockets.firstWhere(
        (p) => p.id != _fromPocketId,
        orElse: () => pockets.first,
      );
      _toPocketId = other.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _swapPockets() {
    setState(() {
      final temp = _fromPocketId;
      _fromPocketId = _toPocketId;
      _toPocketId = temp;
      _errorMessage = null;
    });
  }

  void _setAmount(double value) {
    setState(() {
      _amountController.text = value.toStringAsFixed(0);
      _errorMessage = null;
    });
  }

  void _executeTransfer() async {
    final rawText = _amountController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final amount = double.tryParse(rawText);

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Masukkan nominal yang valid';
      });
      return;
    }

    final fromBalance = widget.storageService.getPocketBalance(_fromPocketId);
    if (amount > fromBalance) {
      setState(() {
        _errorMessage = 'Saldo kantong asal tidak mencukupi (${CurrencyFormatter.formatRp(fromBalance)})';
      });
      return;
    }

    final pockets = widget.storageService.getAvailablePockets();
    final fromPocket = pockets.firstWhere((p) => p.id == _fromPocketId);
    final toPocket = pockets.firstWhere((p) => p.id == _toPocketId);

    final transfer = PocketTransfer(
      id: const Uuid().v4(),
      date: DateTime.now(),
      fromPocketId: fromPocket.id,
      fromPocketName: fromPocket.name,
      toPocketId: toPocket.id,
      toPocketName: toPocket.name,
      amount: amount,
      note: _noteController.text.trim(),
    );

    await widget.storageService.transferFunds(transfer);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil memindahkan ${CurrencyFormatter.formatRp(amount)} dari ${fromPocket.name} ke ${toPocket.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pockets = widget.storageService.getAvailablePockets();

    final fromPocket = pockets.firstWhere(
      (p) => p.id == _fromPocketId,
      orElse: () => pockets.first,
    );
    final toPocket = pockets.firstWhere(
      (p) => p.id == _toPocketId,
      orElse: () => pockets.last,
    );

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pindah Saldo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ambil Tabungan & Transfer Antar Kantong',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dari Kantong (Source)
            _buildPocketSelector(
              label: 'Dari Kantong (Sumber)',
              selectedPocket: fromPocket,
              pockets: pockets,
              excludeId: _toPocketId,
              isDark: isDark,
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _fromPocketId = id;
                    _errorMessage = null;
                  });
                }
              },
            ),

            // Swap Button in Center
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.swap_vert_rounded, size: 20),
                  onPressed: _swapPockets,
                  tooltip: 'Tukar Asal & Tujuan',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ),

            // Ke Kantong (Destination)
            _buildPocketSelector(
              label: 'Ke Kantong (Tujuan)',
              selectedPocket: toPocket,
              pockets: pockets,
              excludeId: _fromPocketId,
              isDark: isDark,
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _toPocketId = id;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Nominal Input Field
            const Text(
              'Nominal Transfer',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _errorMessage != null
                      ? Colors.red
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: const Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 10),

            // Quick Chips: 20k, 50k, 100k, Semua
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildQuickChip('20k', 20000, isDark),
                _buildQuickChip('50k', 50000, isDark),
                _buildQuickChip('100k', 100000, isDark),
                InkWell(
                  onTap: () => _setAmount(fromPocket.balance),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Semua',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Optional Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Catatan (Opsional)',
                hintText: 'Misal: Ambil tabungan untuk SeaBank',
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _executeTransfer,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Pindahkan Dana', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPocketSelector({
    required String label,
    required PocketOption selectedPocket,
    required List<PocketOption> pockets,
    required String excludeId,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    final available = pockets.where((p) => p.id != excludeId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: available.any((p) => p.id == selectedPocket.id) ? selectedPocket.id : available.first.id,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: available.map((pocket) {
                return DropdownMenuItem<String>(
                  value: pocket.id,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: pocket.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(pocket.icon, size: 16, color: pocket.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pocket.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              CurrencyFormatter.formatRp(pocket.balance),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pocket.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, double val, bool isDark) {
    return InkWell(
      onTap: () => _setAmount(val),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
