import 'package:flutter/material.dart';
import 'transaction_entry.dart';

class StreakDayItem {
  final DateTime date;
  final String dayLabel; // e.g. "Sen", "Sel", "Rab"
  final int dayNumber;   // 1..31
  final bool isRecorded;
  final bool isToday;
  final double totalIncome;
  final double totalExpense;
  final double totalSaved;

  const StreakDayItem({
    required this.date,
    required this.dayLabel,
    required this.dayNumber,
    required this.isRecorded,
    required this.isToday,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.totalSaved = 0.0,
  });
}

class StreakMilestone {
  final int days;
  final String title;
  final String icon;
  final Color color;
  final bool isUnlocked;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final int latestRunStreak;
  final bool isRecordedToday;
  final int totalDaysRecorded;
  final List<StreakDayItem> recent7Days;
  final List<StreakMilestone> milestones;
  final String levelTitle;
  final String levelIcon;
  final int nextMilestoneDays;
  final double progressToNext;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.latestRunStreak,
    required this.isRecordedToday,
    required this.totalDaysRecorded,
    required this.recent7Days,
    required this.milestones,
    required this.levelTitle,
    required this.levelIcon,
    required this.nextMilestoneDays,
    required this.progressToNext,
  });

  /// The primary streak number to highlight in UI
  int get displayStreak => currentStreak > 0 ? currentStreak : (latestRunStreak > 0 ? latestRunStreak : 0);

  /// Whether the streak is currently alive (either recorded today or yesterday)
  bool get isStreakActive => currentStreak > 0;

  static const List<String> _kDayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  static StreakInfo calculate(List<DayEntry> entries, {DateTime? now}) {
    if (entries.isEmpty) {
      final ref = now ?? DateTime.now();
      final today = DateTime(ref.year, ref.month, ref.day);
      final empty7 = List.generate(7, (i) {
        final d = today.subtract(Duration(days: 6 - i));
        return StreakDayItem(
          date: d,
          dayLabel: _kDayNames[d.weekday % 7],
          dayNumber: d.day,
          isRecorded: false,
          isToday: d.year == today.year && d.month == today.month && d.day == today.day,
        );
      });

      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        latestRunStreak: 0,
        isRecordedToday: false,
        totalDaysRecorded: 0,
        recent7Days: empty7,
        milestones: _buildMilestones(0),
        levelTitle: 'Mulai Mencatat',
        levelIcon: '🌱',
        nextMilestoneDays: 3,
        progressToNext: 0.0,
      );
    }

    // Map entries by normalized date
    final Map<DateTime, DayEntry> dateMap = {};
    for (var e in entries) {
      final norm = DateTime(e.date.year, e.date.month, e.date.day);
      dateMap[norm] = e;
    }

    final uniqueDates = dateMap.keys.toList()..sort();
    final totalDays = uniqueDates.length;

    // 1. Longest Streak (All-time best streak)
    int longest = 1;
    int currentRun = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      if (diff == 1) {
        currentRun++;
        if (currentRun > longest) {
          longest = currentRun;
        }
      } else {
        currentRun = 1;
      }
    }

    // 2. Latest continuous run streak (from latest entry backwards)
    int latestRun = 1;
    final latestDate = uniqueDates.last;
    DateTime checkBack = latestDate.subtract(const Duration(days: 1));
    while (dateMap.containsKey(checkBack)) {
      latestRun++;
      checkBack = checkBack.subtract(const Duration(days: 1));
    }

    // 3. Current active streak relative to today
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isRecordedToday = dateMap.containsKey(today);

    int activeStreak = 0;
    if (isRecordedToday) {
      activeStreak = 1;
      DateTime cur = today.subtract(const Duration(days: 1));
      while (dateMap.containsKey(cur)) {
        activeStreak++;
        cur = cur.subtract(const Duration(days: 1));
      }
    } else if (dateMap.containsKey(yesterday)) {
      activeStreak = 1;
      DateTime cur = yesterday.subtract(const Duration(days: 1));
      while (dateMap.containsKey(cur)) {
        activeStreak++;
        cur = cur.subtract(const Duration(days: 1));
      }
    }

    final effectiveStreak = activeStreak > 0 ? activeStreak : latestRun;

    // 4. Build recent 7 days display (centered on latest relevant date or today)
    final anchor = (today.difference(latestDate).inDays > 14) ? latestDate : today;
    final List<StreakDayItem> recent7 = [];
    for (int i = 6; i >= 0; i--) {
      final d = anchor.subtract(Duration(days: i));
      final entry = dateMap[d];
      recent7.add(StreakDayItem(
        date: d,
        dayLabel: _kDayNames[d.weekday % 7],
        dayNumber: d.day,
        isRecorded: entry != null,
        isToday: d.year == today.year && d.month == today.month && d.day == today.day,
        totalIncome: entry?.income ?? 0.0,
        totalExpense: entry?.totalExpense ?? 0.0,
        totalSaved: entry?.saveAmount ?? 0.0,
      ));
    }

    // 5. Level title & icon
    String lvlTitle;
    String lvlIcon;
    if (effectiveStreak >= 30) {
      lvlTitle = 'Master Finansial';
      lvlIcon = '👑';
    } else if (effectiveStreak >= 14) {
      lvlTitle = 'Dua Pekan Juara';
      lvlIcon = '🏆';
    } else if (effectiveStreak >= 7) {
      lvlTitle = '1 Minggu Konsisten';
      lvlIcon = '🌟';
    } else if (effectiveStreak >= 3) {
      lvlTitle = 'Rajin Mencatat';
      lvlIcon = '🔥';
    } else {
      lvlTitle = 'Pemula Hebat';
      lvlIcon = '⚡';
    }

    // 6. Milestones & Progress
    final milestones = _buildMilestones(effectiveStreak > longest ? effectiveStreak : longest);
    int nextMilestone = 3;
    for (var m in milestones) {
      if (!m.isUnlocked) {
        nextMilestone = m.days;
        break;
      }
    }

    double progress = 0.0;
    if (effectiveStreak >= 30) {
      progress = 1.0;
    } else {
      progress = (effectiveStreak / nextMilestone).clamp(0.0, 1.0);
    }

    return StreakInfo(
      currentStreak: activeStreak,
      longestStreak: longest > effectiveStreak ? longest : effectiveStreak,
      latestRunStreak: latestRun,
      isRecordedToday: isRecordedToday,
      totalDaysRecorded: totalDays,
      recent7Days: recent7,
      milestones: milestones,
      levelTitle: lvlTitle,
      levelIcon: lvlIcon,
      nextMilestoneDays: nextMilestone,
      progressToNext: progress,
    );
  }

  static List<StreakMilestone> _buildMilestones(int streak) {
    return [
      StreakMilestone(
        days: 3,
        title: '3 Hari Pemula',
        icon: '🥉',
        color: const Color(0xFFF97316),
        isUnlocked: streak >= 3,
      ),
      StreakMilestone(
        days: 7,
        title: '7 Hari Konsisten',
        icon: '🥈',
        color: const Color(0xFF6366F1),
        isUnlocked: streak >= 7,
      ),
      StreakMilestone(
        days: 14,
        title: '14 Hari Juara',
        icon: '🥇',
        color: const Color(0xFF10B981),
        isUnlocked: streak >= 14,
      ),
      StreakMilestone(
        days: 30,
        title: '30 Hari Sultan',
        icon: '👑',
        color: const Color(0xFFF59E0B),
        isUnlocked: streak >= 30,
      ),
    ];
  }
}
