import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';
import 'providers/shift_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase & Analytics safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AnalyticsService().init();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize storage service
  final storageService = await StorageService.init();

  // Initialize AdMob Ads
  await AdService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const ShiftPayApp(),
    ),
  );
}

class ShiftPayApp extends ConsumerWidget {
  const ShiftPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ShiftPay: Overtime & Wages',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
