import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/txa_config.dart';
import '../core/localization/txa_language.dart';
import '../core/utils/txa_device_info.dart';

class TXALogger {
  static final TXALogger instance = TXALogger._internal();
  TXALogger._internal();

  static const String _keyCrashLogs = 'txa_crash_logs_queue';

  // Throttle map & repeat counters to prevent spam
  static final Map<String, DateTime> _errorThrottleMap = {};
  static final Map<String, int> _errorRepeatCounts = {};
  static const Duration _throttleWindow = Duration(seconds: 30);

  static final List<Map<String, dynamic>> _localErrorLogs = [];
  static List<Map<String, dynamic>> get localErrorLogs => List.unmodifiable(_localErrorLogs);

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<Directory> _getLogsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${baseDir.path}/txa_logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir;
  }

  static Future<File> _getLogFile(String type, [String? dateStr]) async {
    final logsDir = await _getLogsDirectory();
    final date = dateStr ?? _todayString();
    final cleanType = type.toLowerCase().trim();
    return File('${logsDir.path}/${cleanType}_$date.log');
  }

  /// Phương thức ghi log cơ sở lưu vào tệp theo ngày
  static Future<void> log(String message, {String type = 'app'}) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
    final upperType = type.toUpperCase();
    final logLine = '[$timeStr] [$upperType] $message\n';

    debugPrint('📝 [TXALogger] $logLine'.trim());

    if (!kIsWeb) {
      try {
        final file = await _getLogFile(type);
        await file.writeAsString(logLine, mode: FileMode.append, flush: true);
      } catch (e) {
        debugPrint('❌ [TXALogger] Error writing log file: $e');
      }
    }
  }

  /// Các phương thức ghi log chuyên biệt
  static void logApp(String message) => log(message, type: 'app');
  static void logApi(String message) => log(message, type: 'api');
  static void logIap(String message) => log(message, type: 'iap');
  static void logIau(String message) => log(message, type: 'iau');
  static void logGpgs(String message) => log(message, type: 'gpgs');
  static void logInfo(String message, {Map<String, dynamic>? extraInfo}) {
    final extraStr = extraInfo != null ? ' | Extra: $extraInfo' : '';
    log('$message$extraStr', type: 'app');
  }

  /// Khởi tạo hệ thống bắt lỗi toàn cục
  static Future<void> init() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      final exStr = details.exception.toString();
      if (exStr.contains('RenderFlex') || exStr.contains('overflowed')) {
        return;
      }
      logCrash(
        details.exception,
        stackTrace: details.stack,
        contextDescription: details.context?.toString(),
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final errStr = error.toString();
      final isTransientNetwork = errStr.contains('SocketException') ||
          errStr.contains('HttpException') ||
          errStr.contains('ClientException') ||
          errStr.contains('HandshakeException') ||
          errStr.contains('timedOut');

      if (isTransientNetwork) {
        logApi('Transient Network Exception: $errStr');
        return true;
      }

      logCrash(
        error,
        stackTrace: stack,
        contextDescription: 'PlatformDispatcher Async Error',
      );
      return true;
    };
  }

  /// Đọc nhật ký theo danh mục (all, app, api, crash, services)
  static Future<String> readLogs(String type, [String? dateStr]) async {
    final cleanType = type.toLowerCase().trim();
    final date = dateStr ?? _todayString();

    if (cleanType == 'all') {
      final List<String> allLines = [];
      for (final t in ['app', 'api', 'crash', 'iap', 'iau', 'gpgs']) {
        try {
          final file = await _getLogFile(t, date);
          if (await file.exists()) {
            final lines = await file.readAsLines();
            allLines.addAll(lines);
          }
        } catch (_) {}
      }

      if (allLines.isEmpty) {
        return TxaLanguage.instance.getText('log_empty');
      }

      allLines.sort((a, b) {
        final matchA = RegExp(r'^\[(\d{2}:\d{2}:\d{2}\.\d{3})\]').firstMatch(a);
        final matchB = RegExp(r'^\[(\d{2}:\d{2}:\d{2}\.\d{3})\]').firstMatch(b);
        if (matchA != null && matchB != null) {
          return matchA.group(1)!.compareTo(matchB.group(1)!);
        }
        return 0;
      });

      return allLines.join('\n');
    } else if (cleanType == 'services') {
      final List<String> serviceLines = [];
      for (final t in ['iap', 'iau', 'gpgs']) {
        try {
          final file = await _getLogFile(t, date);
          if (await file.exists()) {
            final lines = await file.readAsLines();
            serviceLines.addAll(lines);
          }
        } catch (_) {}
      }

      if (serviceLines.isEmpty) {
        return TxaLanguage.instance.getText('log_empty');
      }

      serviceLines.sort((a, b) {
        final matchA = RegExp(r'^\[(\d{2}:\d{2}:\d{2}\.\d{3})\]').firstMatch(a);
        final matchB = RegExp(r'^\[(\d{2}:\d{2}:\d{2}\.\d{3})\]').firstMatch(b);
        if (matchA != null && matchB != null) {
          return matchA.group(1)!.compareTo(matchB.group(1)!);
        }
        return 0;
      });

      return serviceLines.join('\n');
    } else {
      try {
        final file = await _getLogFile(cleanType, date);
        if (await file.exists()) {
          final content = await file.readAsString();
          return content.trim().isEmpty ? TxaLanguage.instance.getText('log_empty') : content;
        }
      } catch (e) {
        debugPrint('TXALogger readLogs error: $e');
      }
      return TxaLanguage.instance.getText('log_empty');
    }
  }

  /// Xóa toàn bộ tệp nhật ký
  static Future<void> clearLogs() async {
    try {
      final logsDir = await _getLogsDirectory();
      if (await logsDir.exists()) {
        final entities = logsDir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.log')) {
            await entity.delete();
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCrashLogs);
      _localErrorLogs.clear();
      debugPrint('🧹 [TXALogger] Cleared all local log files.');
    } catch (e) {
      debugPrint('TXALogger clearLogs error: $e');
    }
  }

  /// Chia sẻ tệp nhật ký qua Share Dialog hệ điều hành
  static Future<void> shareLogs(String type) async {
    try {
      final cleanType = type.toLowerCase().trim();
      final logsDir = await _getLogsDirectory();
      final date = _todayString();

      File shareTargetFile;
      if (cleanType == 'all' || cleanType == 'services') {
        final content = await readLogs(cleanType, date);
        shareTargetFile = File('${logsDir.path}/${cleanType}_$date.log');
        await shareTargetFile.writeAsString(content);
      } else {
        shareTargetFile = await _getLogFile(cleanType, date);
        if (!await shareTargetFile.exists()) {
          await shareTargetFile.writeAsString(TxaLanguage.instance.getText('log_empty'));
        }
      }

      await Share.shareXFiles(
        [XFile(shareTargetFile.path, mimeType: 'text/plain', name: 'zerogrid_${cleanType}_$date.log')],
        subject: 'Zero Grid System Logs ($cleanType)',
        text: 'Zero Grid System Logs ($cleanType - $date)',
      );
    } catch (e) {
      debugPrint('TXALogger shareLogs error: $e');
    }
  }

  /// Ghi nhận Crash nghiêm trọng
  static Future<void> logCrash(
    dynamic crashError, {
    StackTrace? stackTrace,
    String? contextDescription,
  }) async {
    await _processLog(
      level: 'CRASH',
      error: crashError,
      stackTrace: stackTrace,
      contextDescription: contextDescription,
    );
  }

  /// Ghi nhận Lỗi Error / Bug
  static Future<void> logError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extraInfo,
  }) async {
    await _processLog(
      level: 'ERROR',
      error: error,
      stackTrace: stackTrace,
      extraInfo: extraInfo,
    );
  }

  /// Bộ xử lý log trung tâm
  static Future<void> _processLog({
    required String level,
    required dynamic error,
    StackTrace? stackTrace,
    String? contextDescription,
    Map<String, dynamic>? extraInfo,
  }) async {
    final errorMessage = error.toString();
    final errorType = error.runtimeType.toString();
    final fingerprint = '$level:$errorType:$errorMessage';
    final now = DateTime.now();

    final extraStr = extraInfo != null ? '\nExtraInfo: $extraInfo' : '';
    final stackStr = stackTrace != null ? '\nStackTrace:\n$stackTrace' : '';
    await log('$level: [$errorType] $errorMessage$extraStr$stackStr', type: 'crash');

    if (_errorThrottleMap.containsKey(fingerprint)) {
      final lastTime = _errorThrottleMap[fingerprint]!;
      if (now.difference(lastTime) < _throttleWindow) {
        _errorRepeatCounts[fingerprint] = (_errorRepeatCounts[fingerprint] ?? 1) + 1;
        debugPrint('🛡️ [TXALogger] Throttled duplicate $level: "$errorMessage"');
        return;
      }
    }

    _errorThrottleMap[fingerprint] = now;
    final count = _errorRepeatCounts[fingerprint] ?? 1;
    _errorRepeatCounts[fingerprint] = 1;

    final deviceInfo = await TXADeviceInfo.getDiagnosticMetadata();

    final logPayload = {
      'id': 'crash_${now.millisecondsSinceEpoch}',
      'level': level,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace?.toString() ?? 'No StackTrace Available',
      'contextDescription': contextDescription ?? 'General Zero Grid Execution',
      'repeatCountInWindow': count,
      'app': {
        'appName': TxaConfig.appName,
        'version': TxaConfig.appVersion,
      },
      'deviceInfo': deviceInfo,
      'timestamp': now.toIso8601String(),
    };

    _localErrorLogs.insert(0, logPayload);
  }
}
