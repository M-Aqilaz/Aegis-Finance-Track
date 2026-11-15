import 'package:flutter/material.dart';
import '../models/streak_info.dart';
import 'streak_dialog.dart';

class StreakBannerCard extends StatelessWidget {
  final StreakInfo streakInfo;
  final VoidCallback onRecordToday;

  const StreakBannerCard({
    super.key,
    required this.streakInfo,
    required this.onRecordToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayStreak = streakInfo.displayStreak;
    final isRecordedToday = streakInfo.isRecordedToday;

    return InkWell(
      onTap: () => StreakDialog.show(context, streakInfo: streakInfo),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E1B4B), // Deep Indigo
                    const Color(0xFF311042), // Deep Violet-Wine
                    const Color(0xFF451A03), // Warm Ember Dark
                  ]
                : [
                    const Color(0xFFFFF7ED),
                    const Color(0xFFFFEDD5),
                    const Color(0xFFFEF3C7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFF97316).withValues(alpha: isDark ? 0.4 : 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withValues(alpha: isDark ? 0.2 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Flame Icon + Streak Count + Level Badge
            Row(
              children: [
                // Glowing Animated-style Flame Badge
                Container(
                  padding: const EdgeInsets.all(10),
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
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayStreak > 0 ? '$displayStreak Hari Streak' : 'Mulai Streak',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF7C2D12),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF97316).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 13,
                                  color: Color(0xFFF97316),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  streakInfo.levelTitle,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRecordedToday
                            ? '✅ Catatan hari ini lengkap! Streak bertambah.'
                            : (displayStreak > 0
                                ? '⏳ Catat hari ini agar api streak tetap menyala!'
                                : 'Yuk catat transaksi pertamamu sekarang!'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : const Color(0xFF9A3412),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.grey[400] : const Color(0xFF9A3412),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 7-Day Visual Tracker Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: streakInfo.recent7Days.map((day) {
                return _buildDayVisualNode(day, isDark);
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Visual Progress to next milestone
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: streakInfo.progressToNext,
                      minHeight: 6,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Target: ${streakInfo.nextMilestoneDays} Hari',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : const Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayVisualNode(StreakDayItem day, bool isDark) {
    Color nodeBg;
    Color nodeBorder;
    Widget centerVisual;

    if (day.isRecorded) {
      nodeBg = const Color(0xFFF97316);
      nodeBorder = const Color(0xFFFDBA74);
      centerVisual = const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white);
    } else if (day.isToday) {
      nodeBg = const Color(0xFF6366F1).withValues(alpha: 0.3);
      nodeBorder = const Color(0xFF818CF8);
      centerVisual = Text(
        '${day.dayNumber}',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
      );
    } else {
      nodeBg = isDark ? const Color(0xFF1E293B) : Colors.grey[200]!;
      nodeBorder = isDark ? const Color(0xFF334155) : Colors.grey[350]!;
      centerVisual = Text(
        '${day.dayNumber}',
        style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[600]),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day.dayLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500,
            color: day.isToday
                ? const Color(0xFFF97316)
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: nodeBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: nodeBorder,
              width: day.isToday ? 2 : 1,
            ),
            boxShadow: day.isRecorded
                ? [
                    BoxShadow(
                      color: const Color(0xFFF97316).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Center(child: centerVisual),
        ),
      ],
    );
  }
}
