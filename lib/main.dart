import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian date formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // Schedule daily notification if active
  if (storageService.reminderEnabled) {
    await notificationService.scheduleDailyReminder(
      hour: storageService.reminderHour,
      minute: storageService.reminderMinute,
    );
  }

  runApp(AegisFinanceApp(storageService: storageService));
}

class AegisFinanceApp extends StatelessWidget {
  final StorageService storageService;

  const AegisFinanceApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Finance',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Signature Obsidian Neo-Mint Mode
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainNavigationScreen(storageService: storageService),
    );
  }
}

