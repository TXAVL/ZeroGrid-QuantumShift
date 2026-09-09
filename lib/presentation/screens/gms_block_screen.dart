import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../services/gms_service.dart';
import '../theme/cyber_palette.dart';
import '../widgets/txa_toast.dart';
import 'main_menu_screen.dart';

/// Màn hình chặn toàn diện khi thiết bị Android thiếu Google Play Services (GMS)
/// Cung cấp đầy đủ Đa ngôn ngữ TxaLanguage và nút chuyển đổi ngôn ngữ trực tiếp
class GmsBlockScreen extends ConsumerStatefulWidget {
  const GmsBlockScreen({super.key});

  @override
  ConsumerState<GmsBlockScreen> createState() => _GmsBlockScreenState();
}

class _GmsBlockScreenState extends ConsumerState<GmsBlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRechecking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleRecheck() async {
    if (_isRechecking) return;
    setState(() => _isRechecking = true);

    final langCode = ref.read(languageProvider);
    final result = await GmsService.checkAvailability();

    if (!mounted) return;
    setState(() => _isRechecking = false);

    if (result.isAvailable) {
      TxaToast.success(
        context,
        TxaLanguage.tr('gms_recheck_success', langCode),
      );
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainMenuScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      TxaToast.error(
        context,
        TxaLanguage.tr('gms_recheck_failed', langCode),
      );
    }
  }

  Future<void> _handleInstallOrUpdate() async {
    final opened = await GmsService.openPlayServicesStore();
    if (!opened && mounted) {
      final langCode = ref.read(languageProvider);
      TxaToast.warning(
        context,
        TxaLanguage.tr('gms_recheck_failed', langCode),
      );
    }
  }

  void _handleExit() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void _toggleLanguage() {
    final currentLang = ref.read(languageProvider);
    final newLang = (currentLang == 'vi') ? 'en' : 'vi';
    ref.read(languageProvider.notifier).setLanguage(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(languageProvider);
    const palette = GameColorPalette.cyberNeon;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Background Glow
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                ),
              ),
            ),

            // Top Language Toggle Button
            Positioned(
              top: 12,
              right: 16,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _toggleLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        langCode == 'vi' ? 'EN' : 'VI',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Warning Pulsing Badge
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5252).withValues(alpha: 0.14),
                          border: Border.all(
                            color: const Color(0xFFFF5252).withValues(alpha: 0.7),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5252).withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.g_mobiledata_rounded,
                            size: 68,
                            color: Color(0xFFFF5252),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      TxaLanguage.tr('gms_missing_title', langCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      TxaLanguage.tr('gms_missing_subtitle', langCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF8A80),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: palette.boardFrame.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Text(
                        TxaLanguage.tr('gms_missing_desc', langCode),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Button 1: Install / Update Google Play Services
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5252),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.download_rounded, size: 22),
                        label: Text(
                          TxaLanguage.tr('btn_install_gms', langCode),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        onPressed: _handleInstallOrUpdate,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Button 2: Recheck Status
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.accentNeon,
                          side: BorderSide(
                            color: palette.accentNeon.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: _isRechecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 20),
                        label: Text(
                          TxaLanguage.tr('btn_recheck_gms', langCode),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: _isRechecking ? null : _handleRecheck,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Button 3: Exit App
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                      label: Text(
                        TxaLanguage.tr('btn_exit_game', langCode),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _handleExit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
