import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import 'package:reels/core/theme/app_theme.dart';
import 'package:reels/features/downloader/screens/home_screen.dart';
import 'package:reels/features/downloader/services/api_service.dart';
import 'package:reels/features/library/screens/library_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  REELS — iOS Video Downloader
// ═══════════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Dependency injection ───────────────────────────────────────────────
  final getIt = GetIt.instance;
  getIt.registerLazySingleton(() => ApiService());

  // ── Local notifications setup ──────────────────────────────────────────
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    ),
  );
  getIt.registerSingleton(notifications);

  runApp(const ReelsApp());
}

// ─── Root App ────────────────────────────────────────────────────────────────

class ReelsApp extends StatelessWidget {
  const ReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Reels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _MainTabs(),
    );
  }
}

// ─── Tab scaffold ────────────────────────────────────────────────────────────

class _MainTabs extends StatelessWidget {
  const _MainTabs();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xE6000000), // 90 % black — matches nav bar
        border: Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
        ),
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_down_circle),
            activeIcon: Icon(CupertinoIcons.arrow_down_circle_fill),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.play_rectangle),
            activeIcon: Icon(CupertinoIcons.play_rectangle_fill),
            label: 'Library',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return switch (index) {
              0 => const HomeScreen(),
              1 => const LibraryScreen(),
              _ => const HomeScreen(),
            };
          },
        );
      },
    );
  }
}
