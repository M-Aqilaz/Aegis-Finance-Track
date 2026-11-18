import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/asset_dialogs.dart';
import '../widgets/financial_rings_card.dart';
import '../widgets/leak_analysis_card.dart';
import '../widgets/quick_log_bottom_sheet.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/smart_command_bar.dart';
import '../widgets/titanium_card.dart';
import '../widgets/transfer_dialog.dart';
import '../widgets/universal_safe_quota_card.dart';

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
        final cashBalance = storageService.cashBalance;
        final savingsBalance = storageService.savingsBalance;
        final totalAllAssets = storageService.totalAllAssets;
        final streakInfo = storageService.streakInfo;
        final privacyMode = storageService.privacyMode;

        // Calculate other assets sum (SeaBank, Bank Jago, etc.)
        final otherAssetsSum = storageService.customAssets.fold(0.0, (sum, a) => sum + a.balance);

        // Today's Spending Health Meter
        final now = DateTime.now();
        final todayEntry = storageService.getEntryByDate(now);
        final todayExpense = todayEntry?.totalExpense ?? 0.0;
        final dailyLimit = storageService.dailyExpenseLimit;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Freedom Runway (Total Liquid Assets / Daily Burn Rate) & Safe Daily Spend
        double totalRecentExpense = 0.0;
        final recentEntries = storageService.entries.take(7).toList();
        for (final e in recentEntries) {
          totalRecentExpense += e.totalExpense;
        }
        final avgDailyBurn = recentEntries.isNotEmpty
            ? (totalRecentExpense / recentEntries.length)
            : 25000.0;
        final runwayDays = totalAllAssets > 0 && avgDailyBurn > 0
            ? (totalAllAssets / avgDailyBurn)
            : 0.0;
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        final daysRemaining = (lastDayOfMonth - now.day).clamp(1, 31);
        final safeDailySpend = cashBalance > 0 ? (cashBalance / daysRemaining) : 0.0;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Signature Branded Header Bar
              SliverAppBar(
                backgroundColor: isDark ? AppTheme.obsidianBg : Theme.of(context).scaffoldBackgroundColor,
                pinned: true,
                floating: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 70,
                title: Row(
                  children: [
                    // The Aegis Vault Prism Logomark
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.cyberMint.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyberMint.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => const Center(
                            child: Icon(Icons.shield_rounded, size: 18, color: AppTheme.cyberMint),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AEGIS FINANCE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Buku Kas & Portofolio',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cyberMint,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Clean Streak Badge
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: streakInfo.isRecordedToday
                          ? AppTheme.solarAmber.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: streakInfo.isRecordedToday
                            ? AppTheme.solarAmber.withValues(alpha: 0.4)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: streakInfo.isRecordedToday ? AppTheme.solarAmber : Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${streakInfo.displayStreak} Hari',
                          style: TextStyle(
                            fontSize: 10.5,
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: privacyMode ? AppTheme.solarAmber.withValues(alpha: 0.5) : AppTheme.borderLight,
                        ),
                      ),
                      child: Icon(
                        privacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: privacyMode ? AppTheme.solarAmber : Colors.white70,
                      ),
                    ),
                    onPressed: storageService.togglePrivacyMode,
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    children: [
                      // 1. The Signature Executive Net Worth Card
                      TitaniumCard(
                        totalAllAssets: totalAllAssets,
                        cashBalance: cashBalance,
                        savingsBalance: savingsBalance,
                        otherAssetsBalance: otherAssetsSum,
                        privacyMode: privacyMode,
                        runwayDays: runwayDays,
                        safeDailySpend: safeDailySpend,
                        onQuickLog: () => QuickLogBottomSheet.show(context, storageService: storageService),
                        onTransfer: () => TransferDialog.show(
                          context,
                          storageService: storageService,
                          initialFromPocketId: StorageService.kPocketSavingsId,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 2. Universal Daily Safe Quota & Quarantine Vault (v2.0)
                      UniversalSafeQuotaCard(
                        storageService: storageService,
                        privacyMode: privacyMode,
                      ),

                      const SizedBox(height: 12),

                      // 3. One-Liner Smart Command Bar (Conversational Quick Log)
                      SmartCommandBar(storageService: storageService),

                      const SizedBox(height: 22),

                      // Section Label: Rekening & Dompet
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DOMPET & REKENING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onNavigateTab(1),
                            child: const Text(
                              'Lihat Semua ›',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cyberMint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2. Multi-Bank Vault Carousel (Authentic Mini Debit Cards)
                      SizedBox(
                        height: 106,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            // Cash Card
                            SizedBox(
                              width: 148,
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
                              width: 148,
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
                                  width: 148,
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

                      const SizedBox(height: 20),

                      // Kantong Impian (Savings Goal Vault)
                      SavingsGoalCard(
                        storageService: storageService,
                        privacyMode: privacyMode,
                      ),

                      const SizedBox(height: 24),

                      // Section Label: Target & Aktivitas
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TARGET & AKTIVITAS HARI INI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. The 3 Financial Activity Rings (Daily Goals & Habits)
                      FinancialRingsCard(
                        isRecordedToday: streakInfo.isRecordedToday,
                        streakDays: streakInfo.displayStreak,
                        todayExpense: todayExpense,
                        dailyLimit: dailyLimit,
                        todaySave: todayEntry?.saveAmount ?? 0.0,
                        onTap: () => QuickLogBottomSheet.show(context, storageService: storageService),
                      ),

                      const SizedBox(height: 22),

                      // 4. Transaksi Terbaru (Recent Activity Feed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TRANSAKSI TERBARU',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.white54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onNavigateTab(2),
                            child: const Text(
                              'Lihat Semua ›',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cyberMint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      RecentTransactionsCard(
                        storageService: storageService,
                        onViewAll: () => onNavigateTab(2),
                      ),

                      const SizedBox(height: 22),

                      // 5. Executive Financial Health Summary (Clean & Ergonomic)
                      if (storageService.entries.isNotEmpty) ...[
                        InkWell(
                          onTap: () => onNavigateTab(1),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: AppTheme.glassCardDecoration(borderRadius: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyberMint.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.insights_rounded, size: 18, color: AppTheme.cyberMint),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'STATUS KESEHATAN ARUS KAS',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white54,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Pola pengeluaran terkendali • Ketuk untuk analisis lengkap',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white38),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white54,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
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
