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
  await storageService.init(loadSampleDataIfEmpty: true);

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

class AegisFinanceApp extends StatefulWidget {
  final StorageService storageService;

  const AegisFinanceApp({super.key, required this.storageService});

  @override
  State<AegisFinanceApp> createState() => _AegisFinanceAppState();
}

class _AegisFinanceAppState extends State<AegisFinanceApp> {
  @override
  void initState() {
    super.initState();
    widget.storageService.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    widget.storageService.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = widget.storageService.themeMode != 'light';
    return MaterialApp(
      title: 'Aegis Finance',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainNavigationScreen(storageService: widget.storageService),
    );
  }
}

