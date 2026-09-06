import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/ads/ads_service.dart';
import 'txa_toast.dart';
import 'floating_score_delta_widget.dart';

/// HUD chuyên biệt cho Endless Mode: Hiển thị Wave, Ngân hàng Lượt đi (Energy/Moves), Điểm tích lũy và Kỷ lục
class EndlessHudWidget extends ConsumerWidget {
  const EndlessHudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final storage = ref.watch(storageServiceProvider);
    final langCode = ref.watch(languageProvider);

    final movesLeft = gameState.endlessMovesLeft;
    final isLowMoves = movesLeft <= 3;
    final isNewHighScore = gameState.endlessScore > 0 && gameState.endlessScore >= storage.endlessHighScore;

    return Column(
      children: [
        // Hàng 1: [Wave Badge (Trái) | Score & HighScore (Giữa) | Moves Bank (Phải)]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Wave Badge rực rỡ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.accentNeon,
                      const Color(0xFF7C4DFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: palette.accentNeon.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TxaLanguage.tr('endless_wave_badge', langCode),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '#${gameState.endlessWave}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Điểm tích lũy hiện tại & Kỷ lục
              Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${gameState.endlessScore}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isNewHighScore ? const Color(0xFFFFD600) : Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: (isNewHighScore ? const Color(0xFFFFD600) : palette.accentNeon)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                          if (isNewHighScore) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.stars_rounded, color: Color(0xFFFFD600), size: 18),
                          ],
                        ],
                      ),
                      Positioned(
                        top: -16,
                        right: -12,
                        child: FloatingScoreDeltaWidget(
                          scoreDelta: gameState.lastScoreDelta,
                          trigger: gameState.scoreDeltaTrigger,
                          isCombo: gameState.isComboDelta,
                          comboCount: gameState.currentCombo,
                          palette: palette,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${TxaLanguage.tr('endless_best', langCode)}: ',
                        style: TextStyle(fontSize: 11, color: palette.textSecondary),
                      ),
                      Text(
                        '${storage.endlessHighScore}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),

              // 3. Ngân hàng Lượt đi (Moves Bank / Energy) với cảnh báo đỏ
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isLowMoves
                      ? const Color(0xFFFF1744).withValues(alpha: 0.2)
                      : palette.boardFrame,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isLowMoves
                        ? const Color(0xFFFF1744)
                        : palette.accentNeon.withValues(alpha: 0.3),
                    width: isLowMoves ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    if (isLowMoves)
                      BoxShadow(
                        color: const Color(0xFFFF1744).withValues(alpha: 0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: isLowMoves ? const Color(0xFFFF1744) : palette.accentNeon,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          TxaLanguage.tr('endless_moves_left', langCode),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isLowMoves ? const Color(0xFFFF1744) : palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$movesLeft',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isLowMoves ? const Color(0xFFFF1744) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Combo Badge nếu đang có chuỗi
        if (gameState.currentCombo >= 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFFFFD600)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    'COMBO x${gameState.currentCombo}!',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),

        // Hàng nút điều khiển: Undo, Hint, Restart
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
                  isEnabled: gameState.undoStack.isNotEmpty && !gameState.isWon && !gameState.isGameOver,
                  palette: palette,
                  onTap: () => ref.read(gameStateProvider.notifier).undo(),
                ),
                const SizedBox(width: 8),

                // Hint
                ValueListenableBuilder<int>(
                  valueListenable: storage.hintsCountNotifier,
                  builder: (context, hintsLeft, _) {
                    return _ActionButton(
                      icon: Icons.lightbulb_outline_rounded,
                      label: hintsLeft > 0
                          ? '${TxaLanguage.tr('hint', langCode)} ($hintsLeft)'
                          : 'Ad (+1)',
                      isEnabled: !gameState.isWon && !gameState.isGameOver,
                      palette: palette,
                      badgeColor: hintsLeft > 0 ? null : const Color(0xFFFFD600),
                      onTap: () async {
                        if (hintsLeft > 0) {
                          ref.read(gameStateProvider.notifier).requestHint();
                        } else {
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

                // Restart Run
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
