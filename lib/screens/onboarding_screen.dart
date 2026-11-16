import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final StorageService storageService;

  const OnboardingScreen({super.key, required this.storageService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      badge: 'OBSIDIAN WEALTH GUARDIAN',
      title: 'Pencatatan Keuangan\nPresisi & Berkelas',
      description:
          'Pantau akumulasi seluruh kekayaan (Net Worth), kas operasional harian, dan brankas tabungan dalam satu tampilan eksekutif tanpa distraksi.',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.cyberMint,
      imageAsset: 'assets/icon/fintrack_mascot.png',
    ),
    _OnboardingItem(
      badge: '100% OFFLINE-FIRST & PRIVATE',
      title: 'Privasi Mutlak,\nTanpa Server Luar',
      description:
          'Data finansial Anda sepenuhnya tersimpan aman di perangkat. Tanpa pelacakan analitik, tanpa perlu login akun, dan aman di dalam Aegis Security Vault.',
      icon: Icons.shield_rounded,
      color: AppTheme.electricCyan,
    ),
    _OnboardingItem(
      badge: 'APPLE WATCH-INSPIRED RINGS',
      title: 'Cincin Finansial &\nCatat Kilat 3 Detik',
      description:
          'Bangun kebiasaan menabung dengan visualisasi tiga cincin konsentris, radar kendali kas, dan pencatatan transaksi kilat tanpa ribet.',
      icon: Icons.donut_large_rounded,
      color: AppTheme.solarAmber,
    ),
  ];

  void _finish() async {
    await widget.storageService.completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberMint.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: AppTheme.cyberMint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AEGIS FINANCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _items.length - 1)
                    TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual Art Hero
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                item.color.withValues(alpha: 0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: item.imageAsset != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.asset(
                                      item.imageAsset!,
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => Icon(
                                        item.icon,
                                        size: 70,
                                        color: item.color,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: item.color.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: item.color.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 46,
                                      color: item.color,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item.color.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            item.badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: item.color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions & Page Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.cyberMint
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberMint,
                        foregroundColor: const Color(0xFF0B0F17),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: AppTheme.cyberMint.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        if (_currentPage < _items.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finish();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _items.length - 1
                                ? 'Mulai Sekarang'
                                : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _items.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageAsset;

  const _OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageAsset,
  });
}
