import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../services/service_providers.dart';
import 'main_menu_screen.dart';

/// Màn hình Splash khởi tạo ngầm các dịch vụ, hỗ trợ chơi offline 100% và cơ chế đồng bộ Cloud Sync
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _glowAnimation;
  String _syncStatus = '';

  @override
  void initState() {
    super.initState();
    _syncStatus = TxaLanguage.instance.getText('splash_offline_msg');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final langCode = ref.read(languageProvider);
    try {
      final ads = ref.read(adsServiceProvider);
      final gpgs = ref.read(gpgsServiceProvider);
      final iap = ref.read(iapServiceProvider);
      final update = ref.read(updateServiceProvider);

      if (mounted) {
        setState(() => _syncStatus = TxaLanguage.tr('splash_sync_msg', langCode));
      }

      // Timeout 2.5s để đảm bảo không bị treo khi offline hoặc mạng chập chờn
      await Future.wait([
        ads.initialize(),
        gpgs.initialize(),
        iap.initialize(),
        update.checkForUpdate(onFlexibleUpdateDownloaded: () {}),
      ]).timeout(const Duration(milliseconds: 2500), onTimeout: () {
        debugPrint("Splash init timeout -> Proceeding in Offline Mode");
        return [];
      });
    } catch (e) {
      debugPrint("Splash Init error (Safe Offline Fallback): $e");
    }

    if (mounted) {
      setState(() => _syncStatus = TxaLanguage.tr('splash_ready_msg', langCode));
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainMenuScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1726),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: _glowAnimation.value),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4 * _glowAnimation.value),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/branding/logo_master.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          '0',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'ZERO GRID',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QUANTUM SHIFT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              _syncStatus,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B9BB4),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
