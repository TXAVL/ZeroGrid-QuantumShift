import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_device_info.dart';
import '../../main.dart';
import '../../services/auth/txa_auth_service.dart';
import '../../services/service_providers.dart';
import '../../services/storage_service.dart';
import '../../services/txa_logger.dart';
import '../widgets/txa_toast.dart';
import 'splash_screen.dart';

class TXACrashScreen extends StatefulWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final FlutterErrorDetails? details;
  final bool isStandalone;

  const TXACrashScreen({
    super.key,
    this.error,
    this.stackTrace,
    this.details,
    this.isStandalone = false,
  });

  @override
  State<TXACrashScreen> createState() => _TXACrashScreenState();
}

class _TXACrashScreenState extends State<TXACrashScreen> {
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _submitCrashLog();
  }

  Future<void> _submitCrashLog() async {
    final errStr = _getErrorMessage();
    final stackStr = _getStackTraceString();
    TXALogger.logCrash(
      errStr,
      stackTrace: widget.stackTrace ?? widget.details?.stack ?? StackTrace.current,
      contextDescription: 'TXACrashScreen Boundary Capture ($stackStr)',
    );
  }

  String _getErrorMessage() {
    if (widget.details != null) {
      return widget.details!.exceptionAsString();
    }
    if (widget.error != null) {
      return widget.error.toString();
    }
    return 'Uncaught Zero Grid Exception';
  }

  String _getStackTraceString() {
    if (widget.details?.stack != null) {
      return widget.details!.stack.toString();
    }
    if (widget.stackTrace != null) {
      return widget.stackTrace.toString();
    }
    return TxaLanguage.instance.getText('crash_no_stacktrace');
  }

  Future<void> _restartApp() async {
    try {
      final storage = StorageService();
      await storage.initialize().catchError((e) {
        debugPrint("Storage re-init error during crash recovery: $e");
      });
      final auth = TxaAuthService(storage);
      auth.initDeepLinkListener();

      runApp(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            authServiceProvider.overrideWithValue(auth),
          ],
          child: const ZeroGridApp(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      try {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      } catch (e) {
        SystemNavigator.pop();
      }
    }
  }

  Future<void> _clearCacheAndRestart() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      try {
        await Hive.deleteBoxFromDisk('settings_box');
        await Hive.deleteBoxFromDisk('progress_box');
        await Hive.deleteBoxFromDisk('replays_box');
      } catch (_) {}
      if (mounted) {
        TxaToast.success(
          context,
          TxaLanguage.instance.getText('crash_toast_cleared'),
        );
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
        _restartApp();
      }
    }
  }

  Future<void> _copyLogToClipboard() async {
    final txaLang = TxaLanguage.instance;
    String recentLogs = '';
    try {
      recentLogs = await TXALogger.readLogs('all');
    } catch (_) {}

    final header = await TXADeviceInfo.getFormattedHeader(
      logType: 'CRASH',
      timestamp: DateTime.now().toIso8601String(),
      status: 'FATAL_CRASH',
    );

    final logText = '''
$header
=========================================
💥 ${txaLang.getText('crash_reason_label')}
=========================================
${_getErrorMessage()}

-----------------------------------------
🔍 ${txaLang.getText('crash_stacktrace_label')}
-----------------------------------------
${_getStackTraceString()}

-----------------------------------------
📜 ${txaLang.getText('crash_recent_logs_label')}
-----------------------------------------
${recentLogs.isNotEmpty && recentLogs != txaLang.getText('log_empty') ? recentLogs : '(Không có nhật ký)'}
=========================================
''';
    await Clipboard.setData(ClipboardData(text: logText));
    if (mounted) {
      TxaToast.info(
        context,
        txaLang.getText('crash_toast_copied'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMsg = _getErrorMessage();
    final stackStr = _getStackTraceString();
    final txaLang = TxaLanguage.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header Warning Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF1744).withValues(alpha: 0.15),
                    border: Border.all(
                      color: const Color(0xFFFF1744),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1744).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF1744),
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                txaLang.getText('crash_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                txaLang.getText('crash_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Glassmorphic Error Log Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181822),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final isNative = errorMsg.contains('[NATIVE KOTLIN CRASH]') ||
                                errorMsg.contains('[KOTLIN NATIVE CRASH]');
                            return Row(
                              children: [
                                Icon(
                                  isNative ? Icons.android_rounded : Icons.bug_report_rounded,
                                  color: isNative ? const Color(0xFF00E5FF) : const Color(0xFFFF9100),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  txaLang.getText(isNative
                                      ? 'crash_native_header'
                                      : 'crash_log_header'),
                                  style: TextStyle(
                                    color: isNative ? const Color(0xFF00E5FF) : const Color(0xFFFF9100),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          errorMsg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 10),
                        SelectableText(
                          stackStr,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Column(
                children: [
                  // Restart App Button
                  ElevatedButton.icon(
                    onPressed: _restartApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    label: Text(
                      txaLang.getText('crash_restart_app'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Clear Cache Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isClearing ? null : _clearCacheAndRestart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isClearing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cleaning_services_rounded, size: 18),
                          label: Text(
                            txaLang.getText('crash_clear_cache'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Copy Log Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyLogToClipboard,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00E5FF),
                            side: const BorderSide(color: Color(0xFF00E5FF)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: Text(
                            txaLang.getText('crash_copy_log'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
