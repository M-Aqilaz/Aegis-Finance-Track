import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/floating_island_nav_bar.dart';
import 'asset_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'pin_lock_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final StorageService storageService;

  const MainNavigationScreen({super.key, required this.storageService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Auto-lock on app minimize / backgrounding if PIN is active
      widget.storageService.lockApp();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.storageService,
      builder: (context, _) {
        // Check onboarding first before lock or main screen
        if (!widget.storageService.hasSeenOnboarding) {
          return OnboardingScreen(storageService: widget.storageService);
        }

        // If app is locked by Aegis Vault PIN, display Lock Screen immediately
        if (widget.storageService.pinEnabled && widget.storageService.isAppLocked) {
          return PinLockScreen(
            storageService: widget.storageService,
            mode: PinLockMode.unlock,
          );
        }

        final screens = [
          HomeScreen(
            storageService: widget.storageService,
            onNavigateTab: _onTabTapped,
          ),
          AssetScreen(storageService: widget.storageService),
          HistoryScreen(storageService: widget.storageService),
          SettingsScreen(storageService: widget.storageService),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: FloatingIslandNavBar(
            currentIndex: _currentIndex,
            onTabSelected: _onTabTapped,
          ),
        );
      },
    );
  }
}
