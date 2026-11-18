import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class SavingsGoalCard extends StatelessWidget {
  final StorageService storageService;
  final bool privacyMode;

  const SavingsGoalCard({
    super.key,
    required this.storageService,
    required this.privacyMode,
  });

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    int selectedColor = 0xFF00F59B;
    String selectedIcon = 'laptop_mac';

    final icons = [
      {'name': 'laptop_mac', 'icon': Icons.laptop_mac_rounded, 'label': 'Gadget'},
      {'name': 'shield', 'icon': Icons.shield_rounded, 'label': 'Darurat'},
      {'name': 'flight', 'icon': Icons.flight_takeoff_rounded, 'label': 'Liburan'},
      {'name': 'motorcycle', 'icon': Icons.two_wheeler_rounded, 'label': 'Kendaraan'},
      {'name': 'home', 'icon': Icons.home_rounded, 'label': 'Rumah/Kos'},
      {'name': 'savings', 'icon': Icons.savings_rounded, 'label': 'Investasi'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.flag_rounded, color: AppTheme.cyberMint, size: 22),
              SizedBox(width: 10),
              Text(
                'Buat Target Impian Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beri nama target impianmu dan tentukan nominal yang ingin dicapai.',
                  style: TextStyle(fontSize: 11.5, color: Colors.white60, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    labelText: 'Nama Impian',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    hintText: 'Misal: Laptop Skripsi, Liburan Bali',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.cyberMint, fontWeight: FontWeight.bold, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Target Nominal (Rp)',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                    hintText: 'Misal: 5000000',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Pilih Ikon:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((item) {
                    final isSel = selectedIcon == item['name'];
                    return InkWell(
                      onTap: () => setDlgState(() => selectedIcon = item['name'] as String),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.cyberMint.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppTheme.cyberMint : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'] as IconData, size: 14, color: isSel ? AppTheme.cyberMint : Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? AppTheme.cyberMint : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberMint,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = CurrencyFormatter.parseAmount(amountController.text);
                if (title.isEmpty || amount <= 0) return;

                final goal = SavingsGoal(
                  id: const Uuid().v4(),
                  title: title,
                  targetAmount: amount,
                  currentAmount: 0.0,
                  colorHex: selectedColor,
                  iconName: selectedIcon,
                  createdAt: DateTime.now(),
                );

                await storageService.addSavingsGoal(goal);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan Target', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();
    String selectedPocketId = StorageService.kPocketCashId;
    final pockets = storageService.getAvailablePockets();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: AppTheme.cyberMint, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nabung ke ${goal.title}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tersisa ${CurrencyFormatter.formatRp(goal.remainingAmount)} lagi untuk mencapai target.',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.cyberMint, fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Nominal Setoran (Rp)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  hintText: 'Misal: 50000',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Sumber Dana:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: selectedPocketId,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: pockets.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Row(
                      children: [
                        Icon(p.icon, size: 14, color: p.color),
                        const SizedBox(width: 8),
                        Text('${p.name} (${CurrencyFormatter.formatRp(p.balance)})'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedPocketId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberMint,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final amount = CurrencyFormatter.parseAmount(amountController.text);
                if (amount <= 0) return;

                final success = await storageService.depositToSavingsGoal(
                  goalId: goal.id,
                  amount: amount,
                  fromPocketId: selectedPocketId,
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.cyberMint,
                      content: Text(
                        '🎉 Berhasil menyisihkan ${CurrencyFormatter.formatRp(amount)} ke [${goal.title}]!',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Setor Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();
    String selectedPocketId = StorageService.kPocketCashId;
    final pockets = storageService.getAvailablePockets();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.solarAmber, size: 22),
              SizedBox(width: 8),
              Text(
                'Tarik dari Celengan?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo terkumpul di [${goal.title}]: ${CurrencyFormatter.formatRp(goal.currentAmount)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              const Text(
                '⚠️ Peringatan: Menarik uang ini akan memundurkan estimasi tanggal tercapainya impianmu.',
                style: TextStyle(fontSize: 11, color: AppTheme.solarAmber, height: 1.3),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Nominal Penarikan (Rp)',
                  labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
                  hintText: 'Misal: 50000',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Kembalikan ke Dompet:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: selectedPocketId,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: pockets.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Row(
                      children: [
                        Icon(p.icon, size: 14, color: p.color),
                        const SizedBox(width: 8),
                        Text(p.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedPocketId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.solarAmber,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final amount = CurrencyFormatter.parseAmount(amountController.text);
                if (amount <= 0 || amount > goal.currentAmount) return;

                await storageService.withdrawFromSavingsGoal(
                  goalId: goal.id,
                  amount: amount,
                  toPocketId: selectedPocketId,
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.surfaceCard,
                      content: Text('Dana Rp ${CurrencyFormatter.formatRp(amount)} ditarik kembali ke dompet.'),
                    ),
                  );
                }
              },
              child: const Text('Tarik Dana', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'laptop_mac':
        return Icons.laptop_mac_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'motorcycle':
        return Icons.two_wheeler_rounded;
      case 'home':
        return Icons.home_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = storageService.savingsGoals;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.cyberMint.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: AppTheme.cyberMint,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KANTONG IMPIAN (GOALS)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Kumpulkan dana bertahap untuk target nyata',
                          style: TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showAddGoalDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.cyberMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.cyberMint.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: AppTheme.cyberMint),
                        SizedBox(width: 4),
                        Text(
                          '+ Target',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyberMint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars_rounded, size: 28, color: Colors.white38),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum Ada Target Impian',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Buat target pertamamu (misal: Beli Laptop, Dana Darurat, Liburan) dan kumpulkan dana sedikit demi sedikit!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyberMint,
                        side: const BorderSide(color: AppTheme.cyberMint),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddGoalDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Buat Target Pertama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: goals.map((goal) {
                  final daysLeft = storageService.calculateDaysToReachGoal(goal);
                  final isDone = goal.isCompleted;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.obsidianBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? AppTheme.cyberMint.withValues(alpha: 0.5) : Colors.white12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Title, Icon, Percentage
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppTheme.cyberMint.withValues(alpha: 0.2)
                                    : AppTheme.electricIndigo.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getIconData(goal.iconName),
                                size: 18,
                                color: isDone ? AppTheme.cyberMint : const Color(0xFF818CF8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isDone
                                        ? '🎉 Target Tercapai 100%!'
                                        : 'Tersisa ${privacyMode ? "Rp •••" : CurrencyFormatter.formatRp(goal.remainingAmount)} lagi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDone ? AppTheme.cyberMint : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppTheme.cyberMint.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDone ? AppTheme.cyberMint : Colors.white12,
                                ),
                              ),
                              child: Text(
                                '${(goal.progressPercent * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isDone ? AppTheme.cyberMint : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(
                            children: [
                              Container(
                                height: 7,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                              FractionallySizedBox(
                                widthFactor: goal.progressPercent,
                                child: Container(
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.electricCyan,
                                        AppTheme.cyberMint,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Row 3: Metrics & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isDone
                                  ? 'Siap digunakan'
                                  : '⏳ ~${daysLeft} hari lagi tercapai',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDone ? AppTheme.cyberMint : Colors.white54,
                              ),
                            ),
                            Row(
                              children: [
                                if (goal.currentAmount > 0)
                                  InkWell(
                                    onTap: () => _showWithdrawDialog(context, goal),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        'Tarik',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white60,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _showDepositDialog(context, goal),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cyberMint.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.cyberMint.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const Text(
                                      '+ Nabung',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.cyberMint,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
