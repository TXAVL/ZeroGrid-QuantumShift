import 'dart:async';
import 'package:flutter/material.dart';

enum TxaToastType {
  success,
  error,
  warning,
  info,
}

/// Hệ thống thông báo Toast phong cách Cyberpunk (TxaToast) dùng cho toàn bộ ứng dụng
class TxaToast {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext? get globalContext => navigatorKey.currentContext;

  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// Hiển thị Toast trên bất kỳ màn hình nào thông qua Navigator Key toàn cục
  static void showGlobal({
    required String message,
    TxaToastType type = TxaToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    final ctx = globalContext;
    if (ctx != null) {
      show(ctx, message: message, type: type, duration: duration);
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        final retryCtx = globalContext;
        if (retryCtx != null && retryCtx.mounted) {
          show(retryCtx, message: message, type: type, duration: duration);
        }
      });
    }
  }

  static void successGlobal(String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    showGlobal(message: message, type: TxaToastType.success, duration: duration);
  }

  static void infoGlobal(String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    showGlobal(message: message, type: TxaToastType.info, duration: duration);
  }

  static void warningGlobal(String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    showGlobal(message: message, type: TxaToastType.warning, duration: duration);
  }

  static void errorGlobal(String message, {Duration duration = const Duration(milliseconds: 3200)}) {
    showGlobal(message: message, type: TxaToastType.error, duration: duration);
  }

  static void show(
    BuildContext context, {
    required String message,
    TxaToastType type = TxaToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
    }
    _timer?.cancel();

    OverlayState? overlayState;
    try {
      overlayState = Overlay.maybeOf(context);
    } catch (_) {}
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TxaToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) {
            try {
              entry.remove();
            } catch (_) {}
          }
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    try {
      overlayState.insert(entry);
    } catch (_) {}
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: TxaToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: TxaToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: TxaToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: TxaToastType.info);
  }

  /// Hiển thị Banner Mở Khóa Thành Tựu Cyberpunk toàn cục
  static void showAchievementGlobal({
    required String title,
    required String description,
    IconData icon = Icons.emoji_events_rounded,
    Duration duration = const Duration(milliseconds: 3800),
  }) {
    final ctx = globalContext;
    if (ctx != null) {
      showAchievement(ctx, title: title, description: description, icon: icon, duration: duration);
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        final retryCtx = globalContext;
        if (retryCtx != null && retryCtx.mounted) {
          showAchievement(retryCtx, title: title, description: description, icon: icon, duration: duration);
        }
      });
    }
  }

  /// Hiển thị Banner Mở Khóa Thành Tựu Cyberpunk
  static void showAchievement(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.emoji_events_rounded,
    Duration duration = const Duration(milliseconds: 3800),
  }) {
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
    }
    _timer?.cancel();

    OverlayState? overlayState;
    try {
      overlayState = Overlay.maybeOf(context);
    } catch (_) {}
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TxaAchievementBannerWidget(
        title: title,
        description: description,
        icon: icon,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) {
            try {
              entry.remove();
            } catch (_) {}
          }
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    try {
      overlayState.insert(entry);
    } catch (_) {}
  }
}

class _TxaToastWidget extends StatefulWidget {
  final String message;
  final TxaToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TxaToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TxaToastWidget> createState() => _TxaToastWidgetState();
}

class _TxaToastWidgetState extends State<_TxaToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismissed();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData iconData;

    switch (widget.type) {
      case TxaToastType.success:
        accentColor = const Color(0xFF00FFA3);
        iconData = Icons.check_circle_rounded;
        break;
      case TxaToastType.error:
        accentColor = const Color(0xFFFF0055);
        iconData = Icons.error_outline_rounded;
        break;
      case TxaToastType.warning:
        accentColor = const Color(0xFFFFD600);
        iconData = Icons.warning_amber_rounded;
        break;
      case TxaToastType.info:
        accentColor = const Color(0xFF00E5FF);
        iconData = Icons.info_outline_rounded;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1726).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TxaAchievementBannerWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TxaAchievementBannerWidget({
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TxaAchievementBannerWidget> createState() => _TxaAchievementBannerWidgetState();
}

class _TxaAchievementBannerWidgetState extends State<_TxaAchievementBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismissed();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFD700);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D1A).withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.8),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(alpha: 0.35),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: goldColor.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: const Color(0xFF1A1200),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: goldColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACHIEVEMENT UNLOCKED',
                                    style: TextStyle(
                                      color: goldColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11.5,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

