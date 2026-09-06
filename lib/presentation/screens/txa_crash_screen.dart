import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/txa_language.dart';
import '../../services/txa_logger.dart';
import '../widgets/txa_toast.dart';
import 'splash_screen.dart';

class TXACrashScreen extends StatefulWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final FlutterErrorDetails? details;

  const TXACrashScreen({
    super.key,
    this.error,
    this.stackTrace,
    this.details,
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (_) {
      SystemNavigator.pop();
    }
  }

  Future<void> _clearCacheAndRestart() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
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
    String recentLogs = '';
    try {
      recentLogs = await TXALogger.readLogs('all');
    } catch (_) {}

    final logText = '--- ZERO GRID CRASH LOG ---\n'
        'Error: ${_getErrorMessage()}\n\n'
        'StackTrace:\n${_getStackTraceString()}'
        '${recentLogs.isNotEmpty && recentLogs != TxaLanguage.instance.getText('log_empty') ? '\n\n--- RECENT APP & SERVICE LOGS ---\n$recentLogs' : ''}';
    await Clipboard.setData(ClipboardData(text: logText));
    if (mounted) {
      TxaToast.info(
        context,
        TxaLanguage.instance.getText('crash_toast_copied'),
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
                        Row(
                          children: [
                            const Icon(Icons.bug_report_rounded, color: Color(0xFFFF9100), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              txaLang.getText('crash_log_header'),
                              style: const TextStyle(
                                color: Color(0xFFFF9100),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
