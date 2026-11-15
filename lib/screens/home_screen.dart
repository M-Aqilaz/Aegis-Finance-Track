import 'package:flutter/material.dart';
import '../models/transaction_entry.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/asset_dialogs.dart';
import '../widgets/daily_entry_card.dart';
import '../widgets/financial_rings_card.dart';
import '../widgets/quick_log_bottom_sheet.dart';
import '../widgets/titanium_card.dart';
import '../widgets/transfer_dialog.dart';
import 'add_edit_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storageService;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: storageService,
      builder: (context, _) {
        final entries = storageService.entries;
        final cashBalance = storageService.cashBalance;
        final savingsBalance = storageService.savingsBalance;
        final totalAllAssets = storageService.totalAllAssets;
        final streakInfo = storageService.streakInfo;
        final privacyMode = storageService.privacyMode;

        // Calculate other assets sum (SeaBank, Bank Jago, etc.)
        final otherAssetsSum = storageService.customAssets.fold(0.0, (sum, a) => sum + a.balance);

        final displayEntries = List<DayEntry>.from(entries)
          ..sort((a, b) => b.date.compareTo(a.date));

        // Today's Spending Health Meter
        final now = DateTime.now();
        final todayEntry = storageService.getEntryByDate(now);
        final todayExpense = todayEntry?.totalExpense ?? 0.0;
        final dailyLimit = storageService.dailyExpenseLimit;
        final expenseRatio = dailyLimit > 0 ? (todayExpense / dailyLimit).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          backgroundColor: AppTheme.obsidianBg,
          body: CustomScrollView(
            slivers: [
              // Signature Branded Header Bar
              SliverAppBar(
                backgroundColor: AppTheme.obsidianBg,
                pinned: true,
                floating: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 70,
                title: Row(
                  children: [
                    // FinTrack Mascot Phoenix Emblem
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyberMint.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/fintrack_mascot.png',
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.surfaceCardElevated,
                            child: const Icon(Icons.diamond_rounded, color: AppTheme.cyberMint),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AEGIS FINANCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppTheme.cyberMint,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.solarAmber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.solarAmber.withValues(alpha: 0.4),
                                  width: 0.6,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_rounded, size: 9, color: AppTheme.solarAmber),
                                  SizedBox(width: 3),
                                  Text(
                                    'PHOENIX',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.solarAmber,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Row(
                          children: [
                            Text(
                              'Halo, Azure',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.waving_hand_rounded, size: 16, color: Color(0xFFFBBF24)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  // Micro Streak Fire Pill (Non-intrusive & glanceable)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: streakInfo.isRecordedToday
                          ? AppTheme.solarAmber.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: streakInfo.isRecordedToday
                            ? AppTheme.solarAmber.withValues(alpha: 0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: streakInfo.isRecordedToday ? AppTheme.solarAmber : Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${streakInfo.displayStreak} Hari',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: streakInfo.isRecordedToday ? AppTheme.solarAmber : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Privacy Mode Toggle (Eye)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: privacyMode ? AppTheme.solarAmber.withValues(alpha: 0.5) : AppTheme.borderLight,
                        ),
                      ),
                      child: Icon(
                        privacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: privacyMode ? AppTheme.solarAmber : Colors.white70,
                      ),
                    ),
                    tooltip: privacyMode ? 'Tampilkan Saldo' : 'Sembunyikan Saldo (Privasi)',
                    onPressed: storageService.togglePrivacyMode,
                  ),

                  // Fast Transfer Button
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: AppTheme.cyberMint,
                      ),
                    ),
                    tooltip: 'Pindah Dana / Ambil Tabungan',
                    onPressed: () => TransferDialog.show(
                      context,
                      storageService: storageService,
                      initialFromPocketId: StorageService.kPocketSavingsId,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    children: [
                      // 1. The Signature Black Titanium VIP Card (Net Worth First!)
                      TitaniumCard(
                        totalAllAssets: totalAllAssets,
                        cashBalance: cashBalance,
                        savingsBalance: savingsBalance,
                        otherAssetsBalance: otherAssetsSum,
                        privacyMode: privacyMode,
                        onTogglePrivacy: storageService.togglePrivacyMode,
                        onTransfer: () => TransferDialog.show(
                          context,
                          storageService: storageService,
                          initialFromPocketId: StorageService.kPocketSavingsId,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Multi-Bank Vault Carousel (Authentic Mini Debit Cards)
                      SizedBox(
                        height: 106,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            // Cash Card
                            SizedBox(
                              width: 132,
                              child: _buildDebitCard(
                                title: 'Cash Stash',
                                subtitle: 'LIQUID CASH',
                                amount: cashBalance,
                                privacyMode: privacyMode,
                                gradient: AppTheme.cashCardGradient,
                                icon: Icons.payments_rounded,
                                isPrimary: true,
                                onTap: () => TransferDialog.show(
                                  context,
                                  storageService: storageService,
                                  initialFromPocketId: StorageService.kPocketCashId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Tabungan Vault Card
                            SizedBox(
                              width: 132,
                              child: _buildDebitCard(
                                title: 'Tabungan',
                                subtitle: 'HIGH-YIELD VAULT',
                                amount: savingsBalance,
                                privacyMode: privacyMode,
                                gradient: AppTheme.savingsCardGradient,
                                icon: Icons.savings_rounded,
                                onTap: () => TransferDialog.show(
                                  context,
                                  storageService: storageService,
                                  initialFromPocketId: StorageService.kPocketSavingsId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Dynamic Custom Bank Cards (SeaBank, Bank Jago, etc.)
                            ...storageService.customAssets.map((asset) {
                              LinearGradient cardGrad;
                              String sub = 'DIGITAL BANK';
                              if (asset.name.toLowerCase().contains('seabank')) {
                                cardGrad = AppTheme.seaBankGradient;
                                sub = 'SEABANK DIGITAL';
                              } else if (asset.name.toLowerCase().contains('jago')) {
                                cardGrad = AppTheme.bankJagoGradient;
                                sub = 'BANK JAGO';
                              } else {
                                cardGrad = LinearGradient(
                                  colors: [
                                    asset.color.withValues(alpha: 0.8),
                                    asset.color,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  width: 132,
                                  child: _buildDebitCard(
                                    title: asset.name,
                                    subtitle: sub,
                                    amount: asset.balance,
                                    privacyMode: privacyMode,
                                    gradient: cardGrad,
                                    icon: asset.icon,
                                    onTap: () => _showAssetActionSheet(context, asset),
                                  ),
                                ),
                              );
                            }),

                            // Add New Bank / Pocket Card
                            InkWell(
                              onTap: () => AssetDialogs.showAddEditAsset(
                                context,
                                storageService: storageService,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 95,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.cyberMint.withValues(alpha: 0.3),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cyberMint.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        size: 20,
                                        color: AppTheme.cyberMint,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '+ Kantong',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. The 3 Financial Activity Rings (Daily Goals & Habits)
                      FinancialRingsCard(
                        isRecordedToday: streakInfo.isRecordedToday,
                        streakDays: streakInfo.displayStreak,
                        todayExpense: todayExpense,
                        dailyLimit: dailyLimit,
                        todaySave: todayEntry?.saveAmount ?? 0.0,
                        onTap: () => QuickLogBottomSheet.show(context, storageService: storageService),
                      ),

                      const SizedBox(height: 16),

                      // 4. Daily Spending Health Radar / Gauge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: AppTheme.glassCardDecoration(borderRadius: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      todayExpense >= dailyLimit
                                          ? Icons.warning_amber_rounded
                                          : (todayExpense > 0 ? Icons.bolt_rounded : Icons.shield_rounded),
                                      size: 18,
                                      color: todayExpense >= dailyLimit
                                          ? AppTheme.neonCoral
                                          : (todayExpense > 0 ? AppTheme.solarAmber : AppTheme.cyberMint),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Radar Pengeluaran Hari Ini',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  todayExpense == 0
                                      ? 'Hemat Rp 0'
                                      : (privacyMode
                                          ? 'Rp ••• / Limit'
                                          : '${CurrencyFormatter.formatShort(todayExpense)} / ${CurrencyFormatter.formatShort(dailyLimit)}'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: todayExpense >= dailyLimit
                                        ? AppTheme.neonCoral
                                        : (todayExpense > 0 ? AppTheme.solarAmber : AppTheme.cyberMint),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: todayExpense == 0 ? 0.02 : expenseRatio,
                                minHeight: 7,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  todayExpense >= dailyLimit
                                      ? AppTheme.neonCoral
                                      : (todayExpense > 0 ? AppTheme.solarAmber : AppTheme.cyberMint),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Kantong Aset & Analisis Navigation Pill
                      InkWell(
                        onTap: () => onNavigateTab(1),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: AppTheme.electricIndigo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.electricIndigo.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pie_chart_rounded, color: Color(0xFF818CF8), size: 18),
                                  SizedBox(width: 10),
                                  Text(
                                    'Kantong Aset & Analisis Mendalam',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF818CF8),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF818CF8)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section Header: Jurnal Keuangan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Jurnal Keuangan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${displayEntries.length} Hari',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => onNavigateTab(2),
                            child: const Text(
                              'Arsip Lengkap ›',
                              style: TextStyle(
                                color: AppTheme.cyberMint,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Empty or Entries List
              displayEntries.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: AppTheme.glassCardDecoration(borderRadius: 24),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppTheme.cyberMint.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('✨🪙', style: TextStyle(fontSize: 32)),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Belum Ada Jurnal Keuangan',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Mulai catat transaksi untuk mengalirkan energi finansial & streak!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = displayEntries[index];
                          return DailyEntryCard(
                            entry: entry,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditEntryScreen(
                                    storageService: storageService,
                                    existingEntry: entry,
                                  ),
                                ),
                              );
                            },
                            onDelete: () => storageService.deleteEntry(entry.id),
                          );
                        },
                        childCount: displayEntries.length,
                      ),
                    ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyberMint.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: AppTheme.cyberMint,
              foregroundColor: Colors.black87,
              elevation: 0,
              onPressed: () => QuickLogBottomSheet.show(context, storageService: storageService),
              icon: const Icon(Icons.bolt_rounded, size: 22, color: Colors.black87),
              label: const Text(
                'Catat 3 Detik',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebitCard({
    required String title,
    required String subtitle,
    required double amount,
    required LinearGradient gradient,
    required IconData icon,
    bool isPrimary = false,
    bool privacyMode = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark icon
            Positioned(
              right: -8,
              bottom: -8,
              child: Opacity(
                opacity: 0.18,
                child: Icon(icon, size: 50, color: Colors.white),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Colors.white70),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetActionSheet(BuildContext context, dynamic asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (asset.color as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(asset.icon as IconData, color: asset.color as Color, size: 22),
                  ),
                  title: Text(asset.name as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  subtitle: Text(
                    CurrencyFormatter.formatRp(asset.balance as double),
                    style: TextStyle(fontWeight: FontWeight.bold, color: asset.color as Color),
                  ),
                ),
                const Divider(color: AppTheme.borderLight),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.cyberMint),
                  title: const Text('Pindahkan Saldo (Transfer)', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    TransferDialog.show(
                      context,
                      storageService: storageService,
                      initialFromPocketId: asset.id as String,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppTheme.solarAmber),
                  title: const Text('Ubah Saldo Cepat', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    AssetDialogs.showQuickEditBalance(
                      context,
                      assetName: asset.name as String,
                      currentBalance: asset.balance as double,
                      onSave: (val) => storageService.updateAssetBalance(asset.id as String, val),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
