import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_format.dart';
import '../../state/game_notifier.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/ads/ads_service.dart';
import 'txa_toast.dart';
import 'floating_score_delta_widget.dart';

/// HUD thông tin trạng thái ván đấu & các nút điều khiển
class ScoreHudWidget extends ConsumerWidget {
  const ScoreHudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final storage = ref.watch(storageServiceProvider);
    final langCode = ref.watch(languageProvider);

    return Column(
      children: [
        // Thanh thống kê trên cùng: [Moves (Trái) | Score Real-time (Giữa) | Timer (Phải)]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Moves / Target (Bên Trái)
              _StatItem(
                label: TxaLanguage.tr('moves', langCode),
                value: '${gameState.movesCount}',
                subValue: '/ ${gameState.minMoves}',
                palette: palette,
              ),

              // 2. Điểm số Real-time thời gian thực (Ở Giữa - Nổi Bật)
              _StatItem(
                label: TxaLanguage.tr('score', langCode),
                value: '${gameState.currentScore}',
                palette: palette,
                isHighlight: true,
                floatingOverlay: FloatingScoreDeltaWidget(
                  scoreDelta: gameState.lastScoreDelta,
                  trigger: gameState.scoreDeltaTrigger,
                  isCombo: gameState.isComboDelta,
                  comboCount: gameState.currentCombo,
                  palette: palette,
                ),
              ),

              // 3. Timer tự động mm:ss / hh:mm:ss khi >= 60m (Bên Phải)
              _StatItem(
                label: TxaLanguage.tr('time', langCode),
                value: TxaFormat.formatMatchDuration(gameState.durationSeconds),
                palette: palette,
              ),
            ],
          ),
        ),

        // Combo Badge động nếu đang có chuỗi
        if (gameState.currentCombo >= 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF007F), palette.accentNeon],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'COMBO x${gameState.currentCombo}!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Cụm nút điều khiển: Undo, Hint, Restart (Tự động co giãn theo kích thước màn hình)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Undo
                _ActionButton(
                  icon: Icons.undo_rounded,
                  label: TxaLanguage.tr('undo', langCode),
                  isEnabled: gameState.undoStack.isNotEmpty && !gameState.isWon,
                  palette: palette,
                  onTap: () => ref.read(gameStateProvider.notifier).undo(),
                ),
                const SizedBox(width: 8),

                // Hint (Có số lượng hoặc Xem Ad nhận thưởng)
                ValueListenableBuilder<int>(
                  valueListenable: storage.hintsCountNotifier,
                  builder: (context, hintsLeft, _) {
                    return _ActionButton(
                      icon: Icons.lightbulb_outline_rounded,
                      label: hintsLeft > 0
                          ? '${TxaLanguage.tr('hint', langCode)} ($hintsLeft)'
                          : 'Ad (+1)',
                      isEnabled: !gameState.isWon,
                      palette: palette,
                      badgeColor: hintsLeft > 0 ? null : const Color(0xFFFFD600),
                      onTap: () async {
                        if (hintsLeft > 0) {
                          ref.read(gameStateProvider.notifier).requestHint();
                        } else {
                          // Xem Rewarded Ad để nhận thêm gợi ý
                          final ads = ref.read(adsServiceProvider);
                          final shown = await ads.showRewardedAd(
                            type: RewardType.bonusHint,
                            onRewardEarned: (type, amount) {
                              storage.addHints(amount);
                              ref.read(gameStateProvider.notifier).requestHint();
                              TxaToast.success(context, '+ $amount ${TxaLanguage.tr('hint', langCode)}!');
                            },
                          );
                          if (!shown && context.mounted) {
                            TxaToast.warning(context, TxaLanguage.tr('no_ad_available', langCode));
                          }
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Restart
                _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: TxaLanguage.tr('reset', langCode),
                  isEnabled: !gameState.isWon,
                  palette: palette,
                  onTap: () => ref.read(gameStateProvider.notifier).restart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final dynamic palette;
  final bool isHighlight;
  final Widget? floatingOverlay;

  const _StatItem({
    required this.label,
    required this.value,
    this.subValue,
    required this.palette,
    this.isHighlight = false,
    this.floatingOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isHighlight
              ? palette.accentNeon.withValues(alpha: 0.6)
              : palette.accentNeon.withValues(alpha: 0.25),
          width: isHighlight ? 1.4 : 1.0,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: palette.accentNeon.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isHighlight ? palette.accentNeon : palette.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? palette.accentNeon : Colors.white,
                    ),
                  ),
                  if (subValue != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      subValue!,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (floatingOverlay != null)
            Positioned(
              top: -16,
              right: -8,
              child: floatingOverlay!,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final dynamic palette;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.palette,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isEnabled
        ? (badgeColor ?? palette.accentNeon)
        : palette.textSecondary.withValues(alpha: 0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: palette.boardFrame,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveColor.withValues(alpha: isEnabled ? 0.4 : 0.1),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: effectiveColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : palette.textSecondary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
