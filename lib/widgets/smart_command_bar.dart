import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_entry.dart';
import '../services/smart_command_parser.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class SmartCommandBar extends StatefulWidget {
  final StorageService storageService;

  const SmartCommandBar({super.key, required this.storageService});

  @override
  State<SmartCommandBar> createState() => _SmartCommandBarState();
}

class _SmartCommandBarState extends State<SmartCommandBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _executeCommand() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final parsed = SmartCommandParser.parse(text, widget.storageService);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E2738),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            'Format belum terbaca. Contoh: "nasi padang 25k" atau "kopi 18k seabank"',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
      return;
    }

    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    final existing = widget.storageService.getEntryByDate(normalizedDate);

    // Apply transaction based on parsed type
    if (parsed.type == ParsedType.expense) {
      final newItem = ExpenseItem(
        id: const Uuid().v4(),
        title: parsed.title,
        amount: parsed.amount,
        category: parsed.category,
        note: parsed.originalText,
      );

      final updatedExpenses = existing != null
          ? (List<ExpenseItem>.from(existing.expenses)..add(newItem))
          : [newItem];

      final entry = DayEntry(
        id: existing?.id ?? const Uuid().v4(),
        date: normalizedDate,
        income: existing?.income ?? 0.0,
        incomeNote: existing?.incomeNote ?? '',
        saveAmount: existing?.saveAmount ?? 0.0,
        saveNote: existing?.saveNote ?? '',
        expenses: updatedExpenses,
        directExpense: 0.0,
      );
      await widget.storageService.saveOrUpdateEntry(entry);

      // If pocket is custom asset, adjust its balance
      if (parsed.pocketId != StorageService.kPocketCashId &&
          parsed.pocketId != StorageService.kPocketSavingsId) {
        final asset = widget.storageService.customAssets
            .where((a) => a.id == parsed.pocketId)
            .firstOrNull;
        if (asset != null) {
          final newBal = (asset.balance - parsed.amount).clamp(0.0, double.infinity);
          await widget.storageService.updateAssetBalance(asset.id, newBal);
        }
      }
    } else if (parsed.type == ParsedType.income) {
      final entry = DayEntry(
        id: existing?.id ?? const Uuid().v4(),
        date: normalizedDate,
        income: (existing?.income ?? 0.0) + parsed.amount,
        incomeNote: existing?.incomeNote.isNotEmpty == true
            ? '${existing!.incomeNote}, ${parsed.title}'
            : parsed.title,
        saveAmount: existing?.saveAmount ?? 0.0,
        saveNote: existing?.saveNote ?? '',
        expenses: existing?.expenses ?? [],
        directExpense: existing?.directExpense ?? 0.0,
      );
      await widget.storageService.saveOrUpdateEntry(entry);

      if (parsed.pocketId != StorageService.kPocketCashId &&
          parsed.pocketId != StorageService.kPocketSavingsId) {
        final asset = widget.storageService.customAssets
            .where((a) => a.id == parsed.pocketId)
            .firstOrNull;
        if (asset != null) {
          await widget.storageService.updateAssetBalance(asset.id, asset.balance + parsed.amount);
        }
      }
    } else if (parsed.type == ParsedType.save) {
      final entry = DayEntry(
        id: existing?.id ?? const Uuid().v4(),
        date: normalizedDate,
        income: existing?.income ?? 0.0,
        incomeNote: existing?.incomeNote ?? '',
        saveAmount: (existing?.saveAmount ?? 0.0) + parsed.amount,
        saveNote: existing?.saveNote.isNotEmpty == true
            ? '${existing!.saveNote}, ${parsed.title}'
            : parsed.title,
        expenses: existing?.expenses ?? [],
        directExpense: existing?.directExpense ?? 0.0,
      );
      await widget.storageService.saveOrUpdateEntry(entry);
    }

    _controller.clear();
    _focusNode.unfocus();

    if (!mounted) return;

    final typeSign = parsed.type == ParsedType.expense ? '-' : '+';
    final typeColor = parsed.type == ParsedType.expense
        ? const Color(0xFFF87171)
        : (parsed.type == ParsedType.income ? AppTheme.cyberMint : AppTheme.solarAmber);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF111726),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.white12, width: 0.8),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: typeColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${parsed.category.displayName} • ${parsed.pocketName}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            Text(
              '$typeSign${CurrencyFormatter.formatShort(parsed.amount)}',
              style: TextStyle(
                color: typeColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _executeCommand(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintText: 'Ketik cepat: "nasi padang 25k", "kopi 18k seabank"...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 12,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.bolt_rounded,
              size: 20,
              color: _hasText ? AppTheme.cyberMint : Colors.white38,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          suffixIcon: _hasText
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppTheme.cyberMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFF0B0F19),
                        size: 14,
                      ),
                    ),
                    onPressed: _executeCommand,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
