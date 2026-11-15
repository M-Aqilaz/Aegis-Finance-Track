import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/asset_account.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';

class AssetDialogs {
  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'account_balance', 'icon': Icons.account_balance, 'label': 'Bank'},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet, 'label': 'Dompet'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'E-Wallet'},
    {'name': 'trending_up', 'icon': Icons.trending_up, 'label': 'Investasi'},
    {'name': 'monetization_on', 'icon': Icons.monetization_on, 'label': 'Emas'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Tabungan'},
    {'name': 'currency_bitcoin', 'icon': Icons.currency_bitcoin, 'label': 'Kripto'},
    {'name': 'credit_card', 'icon': Icons.credit_card, 'label': 'Kartu'},
  ];

  static const List<int> availableColors = [
    0xFF4F46E5, // Indigo
    0xFF10B981, // Emerald
    0xFFF97316, // Orange
    0xFF8B5CF6, // Purple
    0xFF3B82F6, // Blue
    0xFF06B6D4, // Cyan
    0xFFEC4899, // Pink
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
  ];

  /// Quick edit balance dialog (Centered and always visible above keyboard)
  static void showQuickEditBalance(
    BuildContext context, {
    required String assetName,
    required double currentBalance,
    required Function(double) onSave,
  }) {
    final controller = TextEditingController(
      text: currentBalance > 0 ? currentBalance.toInt().toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Ubah Saldo $assetName',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  cursorColor: const Color(0xFF6366F1),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: 'Saldo Terkini',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    hintText: 'Misal: 500k atau 500000',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['0', '50k', '100k', '250k', '500k', '1jt', '2jt', '5jt'].map((amt) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          label: Text(
                            amt,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            controller.text = amt;
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final amount = CurrencyFormatter.parseAmount(controller.text);
                onSave(amount);
                Navigator.pop(ctx);
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Full Create or Edit Asset Account Dialog (Centered, always visible above keyboard)
  static void showAddEditAsset(
    BuildContext context, {
    required StorageService storageService,
    AssetAccount? existingAsset,
  }) {
    final isEditing = existingAsset != null;
    final nameController = TextEditingController(text: existingAsset?.name ?? '');
    final balanceController = TextEditingController(
      text: existingAsset != null && existingAsset.balance > 0
          ? existingAsset.balance.toInt().toString()
          : '',
    );
    String selectedIcon = existingAsset?.iconName ?? 'account_balance';
    int selectedColor = existingAsset?.colorValue ?? 0xFF4F46E5;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Ubah Akun Aset' : 'Tambah Akun Aset',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Aset
                    TextField(
                      controller: nameController,
                      autofocus: !isEditing,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      cursorColor: const Color(0xFF6366F1),
                      decoration: InputDecoration(
                        labelText: 'Nama Aset',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        hintText: 'Misal: BCA, Bibit, Gopay, Emas',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Saldo Terkini
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      cursorColor: const Color(0xFF6366F1),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: 'Saldo Awal',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        hintText: 'Misal: 500k atau 1.5jt',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['0', '100k', '500k', '1jt', '2jt', '5jt', '10jt'].map((amt) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              label: Text(
                                amt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  balanceController.text = amt;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Ikon',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: availableIcons.map((item) {
                          final isSelected = selectedIcon == item['name'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedIcon = item['name'] as String;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(selectedColor).withValues(alpha: 0.2)
                                      : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? Color(selectedColor) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: isSelected ? Color(selectedColor) : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Warna',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: availableColors.map((colVal) {
                          final isSelected = selectedColor == colVal;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedColor = colVal;
                                });
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(colVal),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                    tooltip: 'Hapus Aset',
                    onPressed: () {
                      storageService.deleteAssetAccount(existingAsset.id);
                      Navigator.pop(ctx);
                    },
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final balance = CurrencyFormatter.parseAmount(balanceController.text);
                    if (isEditing) {
                      final updated = existingAsset.copyWith(
                        name: name,
                        balance: balance,
                        colorValue: selectedColor,
                        iconName: selectedIcon,
                      );
                      storageService.updateAssetAccount(updated);
                    } else {
                      final newAsset = AssetAccount(
                        id: const Uuid().v4(),
                        name: name,
                        balance: balance,
                        colorValue: selectedColor,
                        iconName: selectedIcon,
                      );
                      storageService.addAssetAccount(newAsset);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    isEditing ? 'Simpan' : 'Tambah',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
