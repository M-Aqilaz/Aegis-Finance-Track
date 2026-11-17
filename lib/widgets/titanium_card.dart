import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Clean Executive Portfolio Overview Card for Net Worth & Pockets
class TitaniumCard extends StatelessWidget {
  final double totalAllAssets;
  final double cashBalance;
  final double savingsBalance;
  final double otherAssetsBalance;
  final VoidCallback onTransfer;
  final VoidCallback? onQuickLog;
  final bool privacyMode;
  final VoidCallback? onTogglePrivacy;
  final double? runwayDays;
  final double? safeDailySpend;

  const TitaniumCard({
    super.key,
    required this.totalAllAssets,
    required this.cashBalance,
    required this.savingsBalance,
    required this.otherAssetsBalance,
    required this.onTransfer,
    this.onQuickLog,
    this.privacyMode = false,
    this.onTogglePrivacy,
    this.runwayDays,
    this.safeDailySpend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Header + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.cyberMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TOTAL KEKAYAAN BERSIH (NET WORTH)',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        privacyMode ? Icons.visibility_off_rounded : Icons.shield_rounded,
                        size: 11,
                        color: privacyMode ? AppTheme.solarAmber : AppTheme.cyberMint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        privacyMode ? 'Privasi Aktif' : 'Terkonsolidasi',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: privacyMode ? AppTheme.solarAmber : Colors.white70,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Large Net Worth Number
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  privacyMode ? 'Rp ••••••••' : CurrencyFormatter.formatRp(totalAllAssets),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),

            if (runwayDays != null && runwayDays! > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 13, color: AppTheme.cyberMint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Freedom Runway: ~${runwayDays!.toStringAsFixed(0)} Hari Bebas Beban',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (safeDailySpend != null && safeDailySpend! > 0)
                      Text(
                        'Aman: ${CurrencyFormatter.formatShort(safeDailySpend!)}/hari',
                        style: const TextStyle(
                          color: AppTheme.cyberMint,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Clean Sub-Metrics Row (Cash, Tabungan, Bank Lain)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.obsidianBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cash
                  _buildSubItem(
                    label: 'Kas Tunai',
                    amount: cashBalance,
                    color: AppTheme.cyberMint,
                    privacyMode: privacyMode,
                  ),

                  Container(width: 1, height: 26, color: Colors.white12),

                  // Tabungan
                  _buildSubItem(
                    label: 'Tabungan',
                    amount: savingsBalance,
                    color: AppTheme.electricCyan,
                    privacyMode: privacyMode,
                  ),

                  if (otherAssetsBalance > 0) ...[
                    Container(width: 1, height: 26, color: Colors.white12),
                    // Bank Lain
                    _buildSubItem(
                      label: 'Bank Digital',
                      amount: otherAssetsBalance,
                      color: AppTheme.solarAmber,
                      privacyMode: privacyMode,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dual Ergonomic Actions: Quick Log + Transfer
            Row(
              children: [
                if (onQuickLog != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberMint,
                        foregroundColor: const Color(0xFF0B0F19),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: onQuickLog,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text(
                        'Catat Transaksi',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onTransfer,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: AppTheme.cyberMint),
                    label: const Text(
                      'Pindah Saldo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubItem({
    required String label,
    required double amount,
    required Color color,
    required bool privacyMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10.5, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(amount),
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
