import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/txa_config.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/txa_crash_screen.dart';
import 'presentation/widgets/txa_toast.dart';
import 'services/auth/txa_auth_service.dart';
import 'services/service_providers.dart';
import 'services/storage_service.dart';
import 'services/txa_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Thay thế màn hình đỏ/xám mặc định của Flutter bằng TXACrashScreen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return TXACrashScreen(
      details: details,
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(() async {
    // 1. Tự động đồng bộ version & build code từ pubspec.yaml và Supabase Remote Config
    await TxaConfig.init();

    // 2. Khởi tạo logger trung tâm & bắt lỗi toàn cục
    await TXALogger.init();

    // 3. Khóa màn hình dọc cho trải nghiệm Puzzle tối ưu
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 4. Khởi tạo Storage (Hive + SharedPreferences)
    final storageService = StorageService();
    await storageService.initialize();

    // 5. Khởi tạo Auth Service & Deep Link listener cho TXA Studio ID OAuth
    final authService = TxaAuthService(storageService);
    authService.initDeepLinkListener();

    runApp(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: const ZeroGridApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('🚨 Unhandled Top-level Exception: $error');
    TXALogger.logCrash(
      error,
      stackTrace: stack,
      contextDescription: 'Top-Level runZonedGuarded Catch',
    );

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: TXACrashScreen(
          error: error,
          stackTrace: stack,
        ),
      ),
    );
  });
}

class ZeroGridApp extends StatelessWidget {
  const ZeroGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: TxaToast.navigatorKey,
      title: 'Zero Grid: Quantum Shift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C14),
        fontFamily: 'Roboto',
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
