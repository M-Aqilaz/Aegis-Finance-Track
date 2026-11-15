import 'package:flutter/material.dart';
import '../models/streak_info.dart';

class StreakDialog extends StatelessWidget {
  final StreakInfo streakInfo;

  const StreakDialog({super.key, required this.streakInfo});

  static Future<void> show(BuildContext context, {required StreakInfo streakInfo}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StreakDialog(streakInfo: streakInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayStreak = streakInfo.displayStreak;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1B4B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(20),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory Top Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEF4444), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text('🔥', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 14),
            Text(
              '$displayStreak Hari Konsisten!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(streakInfo.levelIcon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  streakInfo.levelTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3 Visual Stat Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatBadge(
                    icon: '🔥',
                    title: 'Streak',
                    value: '$displayStreak Hari',
                    color: const Color(0xFFF97316),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBadge(
                    icon: '⚡',
                    title: 'Rekor',
                    value: '${streakInfo.longestStreak} Hari',
                    color: const Color(0xFFEAB308),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBadge(
                    icon: '📅',
                    title: 'Total',
                    value: '${streakInfo.totalDaysRecorded} Hari',
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Milestones Gallery
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pencapaian Streak',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            ...streakInfo.milestones.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: m.isUnlocked
                        ? m.color.withValues(alpha: 0.6)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: m.isUnlocked ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(m.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: m.isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                            ),
                          ),
                          Text(
                            m.isUnlocked
                                ? 'Tercapai! Disiplin luar biasa 🌟'
                                : 'Target: ${m.days} hari berturut-turut',
                            style: TextStyle(
                              fontSize: 11,
                              color: m.isUnlocked ? const Color(0xFF10B981) : Colors.grey,
                              fontWeight: m.isUnlocked ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (m.isUnlocked)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                    else
                      const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Semangat Mencatat!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
