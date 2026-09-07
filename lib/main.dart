import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/txa_config.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/txa_crash_screen.dart';
import 'presentation/widgets/txa_toast.dart';
import 'services/auth/txa_auth_service.dart';
import 'services/native_crash_service.dart';
import 'services/service_providers.dart';
import 'services/storage_service.dart';
import 'services/txa_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Bắt lỗi framework UI (RenderObject, Build phase, widget tree)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    TXALogger.logCrash(
      details.exceptionAsString(),
      stackTrace: details.stack,
      contextDescription: 'FlutterError.onError: ${details.context}',
    );
  };

  // 2. Bắt lỗi asynchronous tầng sâu của Dart/Engine (Platform channel, Microtasks)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 PlatformDispatcher Unhandled Error: $error');
    TXALogger.logCrash(
      error,
      stackTrace: stack,
      contextDescription: 'PlatformDispatcher.instance.onError',
    );
    return true; // Đánh dấu đã xử lý để tránh crash đột ngột
  };

  // 3. Thay thế màn hình đỏ/xám mặc định của Flutter bằng TXACrashScreen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return TXACrashScreen(
      details: details,
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(() async {
    // 0. Cầu nối bắt lỗi từ Kotlin Native thời gian thực
    NativeCrashService.init(onCrash: (crashInfo) {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: TXACrashScreen(
            error: '[NATIVE KOTLIN CRASH]\n'
                'Thread: ${crashInfo.thread}\n'
                'Device: ${crashInfo.device}\n\n'
                '${crashInfo.error}',
            stackTrace: StackTrace.fromString(crashInfo.stackTrace),
            isStandalone: true,
          ),
        ),
      );
    });

    // Kiểm tra và hiển thị ngay nếu có crash từ Kotlin native ở phiên trước
    try {
      final pendingNativeCrash = await NativeCrashService.getPendingNativeCrash();
      if (pendingNativeCrash != null) {
        TXALogger.logCrash(
          '[PENDING NATIVE KOTLIN CRASH] ${pendingNativeCrash.error}',
          stackTrace: StackTrace.fromString(pendingNativeCrash.stackTrace),
          contextDescription: 'Captured Kotlin Native Crash on Thread: ${pendingNativeCrash.thread} (${pendingNativeCrash.device})',
        );

        runApp(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            home: TXACrashScreen(
              error: '[NATIVE KOTLIN CRASH]\n'
                  'Thread: ${pendingNativeCrash.thread}\n'
                  'Device: ${pendingNativeCrash.device}\n\n'
                  '${pendingNativeCrash.error}',
              stackTrace: StackTrace.fromString(pendingNativeCrash.stackTrace),
              isStandalone: true,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error reading pending native crash: $e');
    }

    StorageService? storageService;
    TxaAuthService? authService;

    try {
      // 1. Tự động đồng bộ version & build code từ pubspec.yaml và Supabase Remote Config
      await TxaConfig.init().timeout(
        const Duration(seconds: 3),
        onTimeout: () => debugPrint('⚠️ [TxaConfig] Init timeout -> Proceeding'),
      );

      // 2. Khởi tạo logger trung tâm & bắt lỗi toàn cục
      await TXALogger.init();

      // 3. Khóa màn hình dọc cho trải nghiệm Puzzle tối ưu
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // 4. Khởi tạo Storage (Hive + SharedPreferences)
      storageService = StorageService();
      await storageService.initialize();

      // 5. Khởi tạo Auth Service & Deep Link listener cho TXA Studio ID OAuth
      authService = TxaAuthService(storageService);
      authService.initDeepLinkListener();
    } catch (startupError, startupStack) {
      debugPrint('⚠️ Early startup initialization error: $startupError');
      TXALogger.logCrash(
        startupError,
        stackTrace: startupStack,
        contextDescription: 'Early Main Init Catch',
      );
      storageService ??= StorageService();
      authService ??= TxaAuthService(storageService);
    }

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
          isStandalone: true,
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
