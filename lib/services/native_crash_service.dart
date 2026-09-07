import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'txa_logger.dart';

/// Dữ liệu chi tiết về sự cố crash tầng Native (Kotlin / Android)
class NativeCrashInfo {
  final String error;
  final String stackTrace;
  final String thread;
  final String timestamp;
  final String device;

  const NativeCrashInfo({
    required this.error,
    required this.stackTrace,
    required this.thread,
    required this.timestamp,
    required this.device,
  });

  factory NativeCrashInfo.fromMap(Map<dynamic, dynamic> map) {
    return NativeCrashInfo(
      error: map['error']?.toString() ?? 'Unknown Native Error',
      stackTrace: map['stackTrace']?.toString() ?? '',
      thread: map['thread']?.toString() ?? 'main',
      timestamp: map['timestamp']?.toString() ?? '',
      device: map['device']?.toString() ?? '',
    );
  }
}

/// Dịch vụ cầu nối (Bridge) bắt lỗi truyền từ Kotlin sang Dart / Flutter
class NativeCrashService {
  static const MethodChannel _channel =
      MethodChannel('txa.zerogrid.quantumshift/native_crash');

  static void Function(NativeCrashInfo crashInfo)? _onCrashListener;

  /// Khởi tạo listener lắng nghe crash thời gian thực từ Kotlin qua MethodChannel
  static void init({void Function(NativeCrashInfo crashInfo)? onCrash}) {
    if (kIsWeb || !Platform.isAndroid) return;
    _onCrashListener = onCrash;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNativeCrash') {
        try {
          final args = call.arguments;
          if (args is Map) {
            final crash = NativeCrashInfo.fromMap(args);
            TXALogger.logCrash(
              '[KOTLIN NATIVE CRASH] ${crash.error}',
              stackTrace: StackTrace.fromString(crash.stackTrace),
              contextDescription: 'Real-time Native Crash on Thread: ${crash.thread} (${crash.device})',
            );
            _onCrashListener?.call(crash);
          }
        } catch (e) {
          debugPrint('Error parsing onNativeCrash: $e');
        }
      }
    });
  }

  /// Kiểm tra xem phiên trước đó có gặp lỗi sập tầng Native Kotlin không
  static Future<NativeCrashInfo?> getPendingNativeCrash() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final res = await _channel.invokeMethod('getPendingNativeCrash');
      if (res is Map) {
        return NativeCrashInfo.fromMap(res);
      }
    } catch (e) {
      debugPrint('NativeCrashService.getPendingNativeCrash error: $e');
    }
    return null;
  }

  /// Xóa sạch dữ liệu lỗi native đã lưu
  static Future<void> clearNativeCrash() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('clearNativeCrash');
    } catch (_) {}
  }
}
