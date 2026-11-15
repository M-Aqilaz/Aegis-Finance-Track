import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/asset_account.dart';
import '../models/transaction_entry.dart';
import '../utils/file_saver_stub.dart'
    if (dart.library.html) '../utils/file_saver_web.dart'
    if (dart.library.io) '../utils/file_saver_io.dart';
import 'storage_service.dart';

class HistoryRecap {
  final int totalDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalIncome;
  final double totalExpense;
  final double totalSaved;
  final double currentSisa;
  final double totalCustomAssets;
  final double totalAllAssets;
  final double avgDailyExpense;
  final double saveRatio;
  final List<AssetAccount> assets;

  const HistoryRecap({
    required this.totalDays,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaved,
    required this.currentSisa,
    required this.totalCustomAssets,
    required this.totalAllAssets,
    required this.avgDailyExpense,
    required this.saveRatio,
    required this.assets,
  });
}

class BackupPreview {
  final int version;
  final int entriesCount;
  final int assetsCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalIncome;
  final double totalExpense;
  final double totalSaved;
  final double finalSisa;
  final bool isValid;
  final String? errorMessage;

  const BackupPreview({
    required this.version,
    required this.entriesCount,
    required this.assetsCount,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaved,
    required this.finalSisa,
    required this.isValid,
    this.errorMessage,
  });
}

class BackupService {
  /// Calculate full history recap statistics from current storage state
  static HistoryRecap getRecap(StorageService storage) {
    final entries = List<DayEntry>.from(storage.entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return HistoryRecap(
        totalDays: 0,
        startDate: null,
        endDate: null,
        totalIncome: 0,
        totalExpense: 0,
        totalSaved: 0,
        currentSisa: 0,
        totalCustomAssets: storage.totalCustomAssets,
        totalAllAssets: storage.totalAllAssets,
        avgDailyExpense: 0,
        saveRatio: 0,
        assets: storage.customAssets,
      );
    }

    double sumIncome = 0;
    double sumExpense = 0;
    double sumSaved = 0;

    for (var e in entries) {
      sumIncome += e.income;
      sumExpense += e.totalExpense;
      sumSaved += e.saveAmount;
    }

    final daysCount = entries.length;
    final avgExpense = daysCount > 0 ? (sumExpense / daysCount) : 0.0;
    final saveRatio = sumIncome > 0 ? (sumSaved / sumIncome) * 100 : 0.0;

    return HistoryRecap(
      totalDays: daysCount,
      startDate: entries.first.date,
      endDate: entries.last.date,
      totalIncome: sumIncome,
      totalExpense: sumExpense,
      totalSaved: sumSaved,
      currentSisa: storage.currentSisa,
      totalCustomAssets: storage.totalCustomAssets,
      totalAllAssets: storage.totalAllAssets,
      avgDailyExpense: avgExpense,
      saveRatio: saveRatio,
      assets: storage.customAssets,
    );
  }

  /// Exports the backup to a real .json file (downloads on web, shares/saves on mobile)
  static Future<bool> exportBackupFile(StorageService storage) async {
    try {
      final jsonStr = storage.exportJson();
      final nowStr = DateTime.now().toIso8601String().substring(0, 10);
      final fileName = 'FinancialTrack_Backup_$nowStr.json';

      return await FileSaverPlatform.saveOrShareFile(
        fileName: fileName,
        content: jsonStr,
        mimeType: 'application/json',
      );
    } catch (e) {
      debugPrint('Export file error: $e');
      return false;
    }
  }

  /// Opens the native file picker to select a .json backup file
  static Future<String?> pickBackupFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return null;
      }

      return await files.first.xFile.readAsString();
    } catch (e) {
      debugPrint('Pick file error: $e');
      return null;
    }
  }

  /// Inspects and validates a JSON string before applying it
  static BackupPreview previewBackup(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      List<dynamic> entriesList = [];
      List<dynamic> assetsList = [];
      int version = 1;

      if (decoded is Map<String, dynamic>) {
        version = decoded['version'] is int ? decoded['version'] as int : 1;
        if (decoded['entries'] is List) {
          entriesList = decoded['entries'] as List<dynamic>;
        }
        if (decoded['assets'] is List) {
          assetsList = decoded['assets'] as List<dynamic>;
        }
      } else if (decoded is List<dynamic>) {
        entriesList = decoded;
      } else {
        return const BackupPreview(
          version: 0,
          entriesCount: 0,
          assetsCount: 0,
          startDate: null,
          endDate: null,
          totalIncome: 0,
          totalExpense: 0,
          totalSaved: 0,
          finalSisa: 0,
          isValid: false,
          errorMessage: 'Format data JSON tidak dikenali.',
        );
      }

      if (entriesList.isEmpty && assetsList.isEmpty) {
        return const BackupPreview(
          version: 0,
          entriesCount: 0,
          assetsCount: 0,
          startDate: null,
          endDate: null,
          totalIncome: 0,
          totalExpense: 0,
          totalSaved: 0,
          finalSisa: 0,
          isValid: false,
          errorMessage: 'File cadangan tidak memuat data catatan maupun aset.',
        );
      }

      final parsedEntries = <DayEntry>[];
      for (var item in entriesList) {
        parsedEntries.add(DayEntry.fromJson(item as Map<String, dynamic>));
      }

      parsedEntries.sort((a, b) => a.date.compareTo(b.date));

      double sumIncome = 0;
      double sumExpense = 0;
      double sumSaved = 0;
      double runningSisa = 0;

      for (var e in parsedEntries) {
        sumIncome += e.income;
        sumExpense += e.totalExpense;
        sumSaved += e.saveAmount;
        runningSisa += (e.income - e.totalExpense - e.saveAmount);
      }

      return BackupPreview(
        version: version,
        entriesCount: parsedEntries.length,
        assetsCount: assetsList.length,
        startDate: parsedEntries.isNotEmpty ? parsedEntries.first.date : null,
        endDate: parsedEntries.isNotEmpty ? parsedEntries.last.date : null,
        totalIncome: sumIncome,
        totalExpense: sumExpense,
        totalSaved: sumSaved,
        finalSisa: runningSisa,
        isValid: true,
      );
    } catch (e) {
      return BackupPreview(
        version: 0,
        entriesCount: 0,
        assetsCount: 0,
        startDate: null,
        endDate: null,
        totalIncome: 0,
        totalExpense: 0,
        totalSaved: 0,
        finalSisa: 0,
        isValid: false,
        errorMessage: 'Gagal membaca isi file: ${e.toString()}',
      );
    }
  }
}
