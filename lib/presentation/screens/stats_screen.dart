import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/txa_config.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_time.dart';
import '../../services/service_providers.dart';
import '../../state/theme_notifier.dart';
import '../theme/cyber_palette.dart';
import '../widgets/banner_ad_wrapper.dart';
import '../widgets/restore_purchases_dialog.dart';
import '../widgets/txa_toast.dart';

/// Màn hình Thống kê chi tiết, Cửa hàng Themes & Mua gói IAP
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final themeState = ref.watch(themeProvider);
    final palette = themeState.palette;
    final iap = ref.watch(iapServiceProvider);
    final langCode = ref.watch(languageProvider);

    final winRate = storage.totalGamesPlayed == 0
        ? 0
        : ((storage.totalWins / storage.totalGamesPlayed) * 100).toInt();

    final themes = [
      GameColorPalette.cyberNeon,
      GameColorPalette.cyberMagenta,
      GameColorPalette.monokaiDark,
      GameColorPalette.zenGold,
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          TxaLanguage.tr('stats_title', langCode),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: palette.accentNeon,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // THỐNG KÊ CHI TIẾT
                  Text(
                    TxaLanguage.tr('stats_title', langCode),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: palette.accentNeon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.boardFrame,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          label: TxaLanguage.tr('stat_total_games', langCode),
                          value: '${storage.totalGamesPlayed}',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_total_wins', langCode),
                          value: '${storage.totalWins}',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_win_rate', langCode),
                          value: '$winRate%',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_current_streak', langCode),
                          value: '${storage.currentWinStreak}',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_max_streak', langCode),
                          value: '${storage.maxWinStreak}',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_endless_score', langCode),
                          value: '${storage.endlessHighScore}',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_total_stars', langCode),
                          value: '${storage.totalCampaignStars} ★',
                          palette: palette,
                        ),
                        const Divider(color: Colors.white10),
                        _StatRow(
                          label: TxaLanguage.tr('stat_total_time', langCode),
                          value: TxaTime.formatDuration(storage.totalPlayTimeSeconds),
                          palette: palette,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CỬA HÀNG THEMES
                  Text(
                    TxaLanguage.tr('themes_section', langCode),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: palette.accentNeon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: themes.map((t) {
                      final isSelected = t.id == palette.id;
                      final isUnlocked = storage.unlockedThemes.contains(t.id);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isUnlocked) {
                              ref.read(themeProvider.notifier).setTheme(t.id);
                              TxaToast.success(context, '${t.name}: ${TxaLanguage.tr('theme_active', langCode)}');
                            } else {
                              TxaToast.warning(context, TxaLanguage.tr('theme_pro_locked_toast', langCode));
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: t.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? t.accentNeon : t.boardFrame,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  isUnlocked
                                      ? (isSelected ? Icons.check_circle_rounded : Icons.palette_outlined)
                                      : Icons.lock_outline_rounded,
                                  color: t.accentNeon,
                                  size: 22,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.name.split(' ').first,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // GÓI MUA IN-APP PURCHASE
                  Text(
                    TxaLanguage.tr('iap_section_title', langCode),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _IapTile(
                    title: TxaLanguage.tr('btn_remove_ads', langCode),
                    subtitle: TxaLanguage.tr('remove_ads_desc', langCode),
                    price: iap.getProductPrice(TxaConfig.iapRemoveAds, defaultPrice: '25.000 ₫'),
                    icon: Icons.block_flipped,
                    palette: palette,
                    isOwned: storage.isAdFree,
                    ownedLabel: TxaLanguage.tr('iap_owned', langCode),
                    onBuy: () => iap.buyProduct(TxaConfig.iapRemoveAds),
                  ),
                  const SizedBox(height: 10),

                  _IapTile(
                    title: TxaLanguage.tr('iap_hints_10_title', langCode),
                    subtitle: TxaLanguage.tr('iap_hints_10_desc', langCode),
                    price: iap.getProductPrice(TxaConfig.iapHints10, defaultPrice: '12.000 ₫'),
                    icon: Icons.lightbulb_outline_rounded,
                    palette: palette,
                    isOwned: false,
                    ownedLabel: TxaLanguage.tr('iap_owned', langCode),
                    onBuy: () => iap.buyProduct(TxaConfig.iapHints10),
                  ),
                  const SizedBox(height: 10),

                  _IapTile(
                    title: TxaLanguage.tr('iap_pro_themes_title', langCode),
                    subtitle: TxaLanguage.tr('iap_pro_themes_desc', langCode),
                    price: iap.getProductPrice(TxaConfig.iapProThemes, defaultPrice: '25.000 ₫'),
                    icon: Icons.auto_awesome_rounded,
                    palette: palette,
                    isOwned: storage.unlockedThemes.length >= 4,
                    ownedLabel: TxaLanguage.tr('iap_owned', langCode),
                    onBuy: () => iap.buyProduct(TxaConfig.iapProThemes),
                  ),

                  const SizedBox(height: 18),

                  // Nút Restore Purchases
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.restore_rounded, color: Colors.white70),
                      label: Text(
                        TxaLanguage.tr('restore_purchases', langCode),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onPressed: () {
                        RestorePurchasesDialog.show(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const BannerAdWrapper(),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final dynamic palette;

  const _StatRow({
    required this.label,
    required this.value,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: palette.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _IapTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final dynamic palette;
  final bool isOwned;
  final String ownedLabel;
  final VoidCallback onBuy;

  const _IapTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.palette,
    required this.isOwned,
    required this.ownedLabel,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.accentNeon.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.accentNeon, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwned ? palette.cellInactive : palette.accentNeon,
              foregroundColor: isOwned ? Colors.white54 : palette.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isOwned ? null : onBuy,
            child: Text(
              isOwned ? ownedLabel : price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
