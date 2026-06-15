import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/applications_provider.dart';
import 'providers/interviews_provider.dart';
import 'providers/contacts_provider.dart';
import 'providers/companies_provider.dart';
import 'providers/goals_provider.dart';
import 'providers/referrals_provider.dart';
import 'services/hive_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/notification_service.dart';
import 'services/notification_capture_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.init();
  await NotificationService.init();
  await NotificationCaptureService.startListening();
  runApp(const ProviderScope(child: AppliTrackApp()));
}

/// Reloads every local provider from Hive (used after a cloud pull / clear).
void _refreshData(WidgetRef ref) {
  ref.invalidate(applicationsNotifierProvider);
  ref.invalidate(interviewsNotifierProvider);
  ref.invalidate(contactsNotifierProvider);
  ref.invalidate(companiesNotifierProvider);
  ref.invalidate(goalsNotifierProvider);
  ref.invalidate(referralsNotifierProvider);
  ref.invalidate(referralSourcesNotifierProvider);
}

class AppliTrackApp extends ConsumerWidget {
  const AppliTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start/stop cloud sync as the user signs in/out, and refresh local
    // providers once the cloud copy has been pulled down.
    ref.listen(authStateProvider, (prev, next) async {
      final user = next.valueOrNull;
      if (user != null) {
        await CloudSyncService.start();
        _refreshData(ref);
      } else if (prev?.valueOrNull != null) {
        await CloudSyncService.stop();
        _refreshData(ref);
      }
    });

    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsNotifierProvider);

    final themeMode = switch (settings.themeModeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'AppliTrack',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
