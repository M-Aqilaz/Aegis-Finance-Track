import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Signature Black Titanium VIP Card for Total Semua Aset with Privacy Mode & Mascot
class TitaniumCard extends StatelessWidget {
  final double totalAllAssets;
  final double cashBalance;
  final double savingsBalance;
  final double otherAssetsBalance;
  final VoidCallback onTransfer;
  final bool privacyMode;
  final VoidCallback? onTogglePrivacy;

  const TitaniumCard({
    super.key,
    required this.totalAllAssets,
    required this.cashBalance,
    required this.savingsBalance,
    required this.otherAssetsBalance,
    required this.onTransfer,
    this.privacyMode = false,
    this.onTogglePrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.titaniumCardGradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.cyberMint.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Holographic Radial Aura
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.cyberMint.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Mascot Watermark Emblem in Background
          Positioned(
            right: 15,
            bottom: 30,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/icon/fintrack_mascot.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shield_rounded,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Chip + Brand Monogram + Contactless
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Golden EMV Chip Illustration
                        Container(
                          width: 36,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFF2B2), width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 20,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF8C6D15), width: 0.6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Contactless Wave Glyph
                        const Icon(
                          Icons.contactless_outlined,
                          size: 22,
                          color: Colors.white70,
                        ),
                      ],
                    ),

                    // FinTrack Platinum Monogram
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.cyberMint.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 12, color: AppTheme.cyberMint),
                          SizedBox(width: 5),
                          Text(
                            'AEGIS VIP',
                            style: TextStyle(
                              color: AppTheme.cyberMint,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card Number Dots
                Text(
                  '••••  ••••  ••••  2026',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Total Net Worth Heading + Privacy Eye Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL SEMUA ASET (NET WORTH)',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (onTogglePrivacy != null)
                      GestureDetector(
                        onTap: onTogglePrivacy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                privacyMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 13,
                                color: privacyMode ? AppTheme.solarAmber : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                privacyMode ? 'Privasi Aktif' : 'Privasi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: privacyMode ? AppTheme.solarAmber : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Balance with High-Contrast Typography (or masked)
                Text(
                  privacyMode ? 'Rp ••••••••' : CurrencyFormatter.formatRp(totalAllAssets),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Sub-Metrics Bar (Cash, Tabungan, Akun Lain)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cash Liquid
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
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cash', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text(
                                privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(cashBalance),
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Container(width: 1, height: 22, color: Colors.white12),

                      // Tabungan Simpan
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.electricCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tabungan', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text(
                                privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(savingsBalance),
                                style: const TextStyle(
                                  color: AppTheme.electricCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (otherAssetsBalance > 0) ...[
                        Container(width: 1, height: 22, color: Colors.white12),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.solarAmber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bank Lain', style: TextStyle(color: Colors.white60, fontSize: 10)),
                                Text(
                                  privacyMode ? 'Rp •••' : CurrencyFormatter.formatShort(otherAssetsBalance),
                                  style: const TextStyle(
                                    color: AppTheme.solarAmber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Card Footer: Cardholder + Action Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'AZURE • PHOENIX GUARDIAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Luxury Action Glass Pill: Pindah / Ambil Dana
                    InkWell(
                      onTap: onTransfer,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.cyberMint.withValues(alpha: 0.2),
                              AppTheme.electricIndigo.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.cyberMint.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.cyberMint),
                            SizedBox(width: 6),
                            Text(
                              'Pindah / Ambil Dana',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
