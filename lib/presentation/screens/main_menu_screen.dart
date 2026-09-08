import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/txa_config.dart';
import '../../core/localization/txa_language.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../widgets/banner_ad_wrapper.dart';
import '../widgets/banned_notice_dialog.dart';
import '../widgets/achievements_dialog.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/profile_dialog.dart';
import '../widgets/whats_new_dialog.dart';
import '../widgets/update_history_dialog.dart';
import '../widgets/restore_purchases_dialog.dart';
import '../widgets/txa_toast.dart';
import '../../core/utils/txa_format.dart';
import 'admin_dashboard_screen.dart';
import 'game_select_screen.dart';
import 'leaderboard_screen.dart';
import 'stats_screen.dart';
import 'txa_log_viewer_screen.dart';

/// Màn hình chính Menu với bộ chọn Game, Hồ sơ người chơi, Hướng dẫn cách chơi, Cài đặt và Admin Dashboard
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> with WidgetsBindingObserver {
  int _secretTapCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBannedStatus();
      _fetchUserProfile();
      _checkWhatsNew();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Tự động kiểm tra và nhận ngay các mã đổi thưởng / gói mua ngoài CH Play
      try {
        ref.read(iapServiceProvider).restorePurchases();
      } catch (_) {}
    }
  }

  void _checkWhatsNew() {
    final storage = ref.read(storageServiceProvider);
    final currentVersion = TxaConfig.fullVersion;
    if (storage.lastSeenWhatsNewVersion != currentVersion && mounted) {
      storage.lastSeenWhatsNewVersion = currentVersion;
      final palette = ref.read(themeProvider).palette;
      final langCode = ref.read(languageProvider);
      WhatsNewDialog.show(context, palette, langCode);
    }
  }

  Future<void> _checkBannedStatus() async {
    final storage = ref.read(storageServiceProvider);
    if (!storage.isGuestMode) {
      final supabase = ref.read(supabaseServiceProvider);
      final isBanned = await supabase.checkUserBannedStatus(storage.playerId);
      if (isBanned && mounted) {
        BannedNoticeDialog.show(context, storage.playerUsername, storage.playerId);
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    final storage = ref.read(storageServiceProvider);
    if (!storage.isGuestMode) {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.fetchUserProfile(storage.playerId);
    }
  }

  Future<void> _openTxaStudioApps(BuildContext context) async {
    final Uri playStoreUri = Uri.parse(TxaConfig.playStoreDeveloperUrl);
    try {
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          TxaToast.info(context, 'TXA Studio: ${TxaConfig.playStoreDeveloperUrl}');
        }
      }
    } catch (e) {
      debugPrint("Open Developer URL error: $e");
    }
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);
    final palette = ref.read(themeProvider).palette;

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.boardFrame,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language_rounded, color: palette.accentNeon, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      TxaLanguage.tr('select_language', currentLang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...TxaLanguage.supportedLanguages.map((lang) {
                  final isSelected = (lang.code == currentLang);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.accentNeon.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? palette.accentNeon : Colors.white10,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                      title: Text(
                        lang.name,
                        style: TextStyle(
                          color: isSelected ? palette.accentNeon : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: palette.accentNeon)
                          : null,
                      onTap: () {
                        ref.read(languageProvider.notifier).setLanguage(lang.code);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final themeState = ref.watch(themeProvider);
            final palette = themeState.palette;
            final storage = ref.watch(storageServiceProvider);
            final langCode = ref.watch(languageProvider);
            final isSwipeUnlocked = storage.unlockedCampaignLevel > TxaConfig.swipeModeUnlockLevel;
            final isAdmin = storage.userRole == 'admin';

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: BoxDecoration(
                    color: palette.boardFrame,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.65,
                    minChildSize: 0.4,
                    maxChildSize: 0.92,
                    expand: false,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Drag Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Icon(Icons.settings_suggest_rounded, color: palette.accentNeon, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            TxaLanguage.tr('settings_title', langCode),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Đổi ngôn ngữ TxaLanguage
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: palette.accentNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.translate_rounded, color: palette.accentNeon, size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('btn_language', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.getCurrentLanguageName(langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _showLanguageSelector(context, ref);
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Cơ chế điều khiển: Tap vs Swipe (Chỉ hiển thị khi đã mở khóa sau màn 5)
                      if (isSwipeUnlocked) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.gesture_rounded, color: Color(0xFF00E5FF), size: 22),
                          ),
                          title: Text(
                            TxaLanguage.tr('control_mode_label', langCode),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            storage.controlMode == 'swipe'
                                ? TxaLanguage.tr('control_mode_swipe', langCode)
                                : TxaLanguage.tr('control_mode_tap', langCode),
                            style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                          ),
                          trailing: DropdownButton<String>(
                            value: storage.controlMode,
                            dropdownColor: palette.boardFrame,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                            items: [
                              DropdownMenuItem(
                                value: 'tap',
                                child: Text(
                                  TxaLanguage.tr('control_mode_tap', langCode),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'swipe',
                                child: Text(
                                  TxaLanguage.tr('control_mode_swipe', langCode),
                                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            onChanged: (newMode) {
                              if (newMode != null) {
                                storage.controlMode = newMode;
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                        const Divider(color: Colors.white10),
                      ],

                      // Âm thanh SFX
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          TxaLanguage.tr('sound_sfx', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('sound_sfx_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        value: storage.soundEnabled,
                        activeThumbColor: palette.accentNeon,
                        activeTrackColor: palette.accentNeon.withValues(alpha: 0.5),
                        onChanged: (val) {
                          storage.soundEnabled = val;
                          setModalState(() {});
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Rung phản hồi (Haptics)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          TxaLanguage.tr('haptic_feedback', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('haptic_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        value: storage.hapticEnabled,
                        activeThumbColor: palette.accentNeon,
                        activeTrackColor: palette.accentNeon.withValues(alpha: 0.5),
                        onChanged: (val) {
                          storage.hapticEnabled = val;
                          setModalState(() {});
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Chế độ mù màu (Colorblind Accessibility)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          TxaLanguage.tr('colorblind_mode', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('colorblind_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        value: themeState.isColorblind,
                        activeThumbColor: palette.accentNeon,
                        activeTrackColor: palette.accentNeon.withValues(alpha: 0.5),
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleColorblind(val);
                          setModalState(() {});
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Khôi phục giao dịch
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restore_rounded, color: Color(0xFF00FFA3), size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('restore_purchases', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('restore_purchases_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          RestorePurchasesDialog.show(context);
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Quản lý gói đăng ký & giao dịch (Google Play / App Store)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.open_in_new_rounded, color: Color(0xFF00E5FF), size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('manage_subscriptions', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('manage_subscriptions_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          TxaConfig.openStoreSubscriptions();
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Có gì mới ở phiên bản này (What's New)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: palette.accentNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.rocket_launch_rounded, color: palette.accentNeon, size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('whats_new_title', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'v${TxaConfig.version} (Build ${TxaConfig.buildNumber}) • ${TxaFormat.formatDate2Digits(TxaConfig.releaseDate)}',
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.accentNeon),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          WhatsNewDialog.show(context, palette, langCode);
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Lịch sử cập nhật (Update History)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.manage_history_rounded, color: Color(0xFF00E5FF), size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('update_history_title', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('update_history_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00E5FF)),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          UpdateHistoryDialog.show(context, palette, langCode);
                        },
                      ),
                      const Divider(color: Colors.white10),

                      // Nhật ký hệ thống (TXALogger Logs Viewer)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFFD700), size: 22),
                        ),
                        title: Text(
                          TxaLanguage.tr('system_logs_title', langCode),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          TxaLanguage.tr('system_logs_desc', langCode),
                          style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFFFD700)),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TXALogViewerScreen()),
                          );
                        },
                      ),

                      // Nút Admin Dashboard (Chỉ hiển thị cho tài khoản có quyền Admin)
                      if (isAdmin) ...[
                        const Divider(color: Colors.white10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0055).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFF0055), size: 22),
                          ),
                          title: Text(
                            TxaLanguage.tr('admin_dashboard_btn', langCode),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            TxaLanguage.tr('admin_dashboard_desc', langCode),
                            style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFFF0055)),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final palette = themeState.palette;
    final langCode = ref.watch(languageProvider);
    final storage = ref.watch(storageServiceProvider);
    final iap = ref.watch(iapServiceProvider);

    final bool shouldShowRemoveAds = !kIsWeb && Platform.isAndroid;
    final removeAdsPriceDetails = iap.getPriceDetails(TxaConfig.iapRemoveAds, langCode: langCode);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner Ad
            const BannerAdWrapper(isTop: true),

            // Top Bar: Player Profile & Quick Action Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Player Profile Badge
                  GestureDetector(
                    onTap: () => ProfileDialog.show(context, palette, langCode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: palette.boardFrame,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.accentNeon.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: storage.avatarUrlNotifier,
                            builder: (context, avatarUrl, _) {
                              if (avatarUrl.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(avatarUrl),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: palette.accentNeon.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_rounded, size: 14, color: palette.accentNeon),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<String>(
                            valueListenable: storage.usernameNotifier,
                            builder: (context, name, _) {
                              return Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 12, color: palette.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  // Action Icons
                  Row(
                    children: [
                      // How To Play Guide Button
                      IconButton(
                        icon: Icon(Icons.help_outline_rounded, color: palette.accentNeon),
                        tooltip: TxaLanguage.tr('how_to_play_title', langCode),
                        onPressed: () => HowToPlayDialog.show(context, palette, langCode),
                      ),
                      // Leaderboard
                      IconButton(
                        icon: Icon(Icons.leaderboard_rounded, color: palette.accentNeon),
                        tooltip: TxaLanguage.tr('leaderboard_title', langCode),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                          );
                        },
                      ),
                      // Achievements
                      IconButton(
                        icon: Icon(Icons.military_tech_outlined, color: palette.accentNeon),
                        tooltip: TxaLanguage.tr('achievements_title', langCode),
                        onPressed: () => AchievementsDialog.show(context, palette, langCode),
                      ),
                      // Settings
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: palette.accentNeon),
                        tooltip: TxaLanguage.tr('btn_settings', langCode),
                        onPressed: () => _showSettingsDialog(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Official App Logo
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: palette.boardFrame,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: palette.accentNeon, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accentNeon.withValues(alpha: 0.35),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/branding/logo_master.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: palette.accentNeon,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        Text(
                          TxaLanguage.tr('app_title', langCode),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: palette.accentNeon.withValues(alpha: 0.7),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          TxaLanguage.tr('app_subtitle', langCode),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                            color: palette.accentNeon,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // 1. NÚT BẮT ĐẦU (MỞ BỘ CHỌN GAME)
                        _MenuPrimaryButton(
                          icon: Icons.play_arrow_rounded,
                          title: TxaLanguage.tr('btn_start', langCode),
                          subtitle: TxaLanguage.tr('btn_start_subtitle', langCode),
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const GameSelectScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // 2. NÚT HƯỚNG DẪN CÁCH CHƠI
                        _MenuActionButton(
                          icon: Icons.lightbulb_outline_rounded,
                          title: TxaLanguage.tr('btn_how_to_play', langCode),
                          subtitle: TxaLanguage.tr('btn_how_to_play_sub', langCode),
                          palette: palette,
                          badgeColor: const Color(0xFFFFD600),
                          onTap: () => HowToPlayDialog.show(context, palette, langCode),
                        ),
                        const SizedBox(height: 14),

                        // 3. NÚT THỐNG KÊ & THEMES
                        _MenuActionButton(
                          icon: Icons.palette_outlined,
                          title: TxaLanguage.tr('stats_title', langCode),
                          subtitle: TxaLanguage.tr('stats_subtitle', langCode),
                          palette: palette,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const StatsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // 4. NÚT GỠ QUẢNG CÁO (REMOVE ADS) KÈM GIÁ TIỀN TỆ ĐỘNG
                        if (shouldShowRemoveAds) ...[
                          ValueListenableBuilder<bool>(
                            valueListenable: storage.isAdFreeNotifier,
                            builder: (context, isAdFree, _) {
                              return _MenuActionButton(
                                icon: isAdFree ? Icons.verified_rounded : Icons.block_flipped,
                                title: isAdFree
                                    ? TxaLanguage.tr('btn_ad_free_active', langCode)
                                    : TxaLanguage.tr('btn_remove_ads', langCode),
                                price: isAdFree ? null : removeAdsPriceDetails.discountedPrice,
                                originalPrice: (!isAdFree && removeAdsPriceDetails.hasDiscount)
                                    ? removeAdsPriceDetails.originalPrice
                                    : null,
                                discountBadge: (!isAdFree && removeAdsPriceDetails.hasDiscount)
                                    ? removeAdsPriceDetails.discountBadge
                                    : null,
                                subtitle: isAdFree
                                    ? TxaLanguage.tr('ad_free_pro_desc', langCode)
                                    : TxaLanguage.tr('remove_ads_desc', langCode),
                                palette: palette,
                                badgeColor: isAdFree ? const Color(0xFF00FFA3) : const Color(0xFFFFD600),
                                onTap: isAdFree
                                    ? () {
                                        TxaToast.success(context, TxaLanguage.tr('ad_free_owned_msg', langCode));
                                      }
                                    : () async {
                                        await iap.buyProduct(TxaConfig.iapRemoveAds);
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // 5. NÚT CÁC APP KHÁC (TXA STUDIO)
                        _MenuActionButton(
                          icon: Icons.apps_rounded,
                          title: TxaLanguage.tr('btn_more_apps', langCode),
                          subtitle: TxaLanguage.tr('more_apps_desc', langCode),
                          palette: palette,
                          onTap: () => _openTxaStudioApps(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer version - Tap 5 times to open Admin Dashboard
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: GestureDetector(
                onTap: () {
                  _secretTapCount++;
                  if (_secretTapCount >= 5) {
                    _secretTapCount = 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  }
                },
                child: Text(
                  '${TxaConfig.appName} v${TxaConfig.appVersion}',
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            // Banner Ad Container
            const BannerAdWrapper(),
          ],
        ),
      ),
    );
  }
}

class _MenuPrimaryButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic palette;
  final VoidCallback onTap;

  const _MenuPrimaryButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.accentNeon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.accentNeon.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: palette.accentNeon, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: palette.background,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.background.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: palette.background, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic palette;
  final Color? badgeColor;
  final String? price;
  final String? originalPrice;
  final String? discountBadge;
  final VoidCallback onTap;

  const _MenuActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.badgeColor,
    this.price,
    this.originalPrice,
    this.discountBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBadge = badgeColor ?? palette.accentNeon;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.accentNeon.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveBadge.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveBadge, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (price != null) ...[
                            const SizedBox(width: 8),
                            if (originalPrice != null) ...[
                              Text(
                                originalPrice!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Color(0xFFFF5252),
                                  decorationThickness: 2.0,
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              price!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: originalPrice != null ? palette.accentNeon : Colors.white,
                              ),
                            ),
                            if (discountBadge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF0055), Color(0xFFFF5E3A)],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF0055).withValues(alpha: 0.35),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  discountBadge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: palette.textSecondary, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
