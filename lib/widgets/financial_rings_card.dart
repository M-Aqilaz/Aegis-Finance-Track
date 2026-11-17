import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

/// 3 Concentric Financial Activity Rings (Apple Watch Fitness style for Finance)
class FinancialRingsCard extends StatelessWidget {
  final bool isRecordedToday;
  final int streakDays;
  final double todayExpense;
  final double dailyLimit;
  final double todaySave;
  final VoidCallback? onTap;

  const FinancialRingsCard({
    super.key,
    required this.isRecordedToday,
    required this.streakDays,
    required this.todayExpense,
    required this.dailyLimit,
    required this.todaySave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Ring Catat: 1.0 if recorded today, else 0.4
    final recordProgress = isRecordedToday ? 1.0 : (streakDays > 0 ? 0.4 : 0.1);

    // 2. Ring Kendali Kas: 1.0 if 0 expense, scales down as expense approaches dailyLimit
    final expenseRatio = dailyLimit > 0 ? (todayExpense / dailyLimit) : 0.0;
    final budgetProgress = (1.0 - expenseRatio).clamp(0.05, 1.0);

    // 3. Ring Nabung: 1.0 if saved today > 0, else 0.15
    final saveProgress = todaySave > 0 ? 1.0 : 0.15;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCardDecoration(borderRadius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.donut_large_rounded, size: 16, color: AppTheme.cyberMint),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'CINCIN FINANSIAL HARIAN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cyberMint.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isRecordedToday ? 'Misi Lengkap 🎯' : 'Misi Hari Ini',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cyberMint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Concentric Activity Rings
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: _ConcentricRingsPainter(
                          ring1Progress: recordProgress,
                          ring2Progress: budgetProgress,
                          ring3Progress: saveProgress,
                        ),
                      ),
                      // Clean Center Emblem
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.obsidianBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(
                          Icons.donut_large_rounded,
                          size: 16,
                          color: AppTheme.cyberMint,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 3 Metrics Breakdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ring 1: Catat
                      _buildRingMetricRow(
                        color: const Color(0xFF8B5CF6),
                        title: 'Catat Harian',
                        status: isRecordedToday ? 'Lengkap 🔥' : 'Belum Catat ⏳',
                        highlight: isRecordedToday,
                      ),
                      const SizedBox(height: 8),

                      // Ring 2: Kas
                      _buildRingMetricRow(
                        color: AppTheme.cyberMint,
                        title: 'Kendali Kas',
                        status: todayExpense == 0
                            ? 'Hemat Rp 0 🛡️'
                            : '${CurrencyFormatter.formatShort(todayExpense)} / ${CurrencyFormatter.formatShort(dailyLimit)}',
                        highlight: todayExpense < dailyLimit,
                      ),
                      const SizedBox(height: 8),

                      // Ring 3: Nabung
                      _buildRingMetricRow(
                        color: const Color(0xFFF59E0B),
                        title: 'Nabung Vault',
                        status: todaySave > 0
                            ? '+${CurrencyFormatter.formatShort(todaySave)} ✨'
                            : 'Belum Nabung',
                        highlight: todaySave > 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingMetricRow({
    required Color color,
    required String title,
    required String status,
    required bool highlight,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (highlight)
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: highlight ? Colors.white : Colors.white38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double ring1Progress; // Outer (Record)
  final double ring2Progress; // Middle (Budget)
  final double ring3Progress; // Inner (Save)

  _ConcentricRingsPainter({
    required this.ring1Progress,
    required this.ring2Progress,
    required this.ring3Progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 7.0;
    const gap = 3.0;

    // Radius
    final r1 = (size.width / 2) - (strokeWidth / 2);
    final r2 = r1 - strokeWidth - gap;
    final r3 = r2 - strokeWidth - gap;

    _drawRing(canvas, center, r1, strokeWidth, const Color(0xFF8B5CF6), ring1Progress);
    _drawRing(canvas, center, r2, strokeWidth, const Color(0xFF00F59B), ring2Progress);
    _drawRing(canvas, center, r3, strokeWidth, const Color(0xFFF59E0B), ring3Progress);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeWidth, Color color, double progress) {
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.01, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.ring1Progress != ring1Progress ||
        oldDelegate.ring2Progress != ring2Progress ||
        oldDelegate.ring3Progress != ring3Progress;
  }
}
