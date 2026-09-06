import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/ads/ads_service.dart';
import 'txa_toast.dart';

/// Hộp thoại Game Over ấn tượng khi cạn lượt đi trong Endless Mode
class EndlessGameOverDialog extends ConsumerWidget {
  final GameState gameState;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const EndlessGameOverDialog({
    super.key,
    required this.gameState,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final storage = ref.watch(storageServiceProvider);
    final langCode = ref.watch(languageProvider);

    final isNewRecord = gameState.endlessScore > 0 && gameState.endlessScore >= storage.endlessHighScore;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: const Color(0xFFFF1744).withValues(alpha: 0.6),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1744).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiêu đề Run Over
            Text(
              TxaLanguage.tr('endless_game_over_title', langCode),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Color(0xFFFF1744),
              ),
            ),

            const SizedBox(height: 16),

            // Huy hiệu New Record nếu có
            if (isNewRecord)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD600), Color(0xFFFF9100)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD600).withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      TxaLanguage.tr('endless_new_record_badge', langCode),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

            // Thống kê kết quả Run
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _MetricItem(
                    label: TxaLanguage.tr('endless_final_score', langCode),
                    value: '${gameState.endlessScore}',
                    isHighlight: true,
                    highlightColor: isNewRecord ? const Color(0xFFFFD600) : palette.accentNeon,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _MetricItem(
                    label: TxaLanguage.tr('endless_wave_reached', langCode),
                    value: 'Wave #${gameState.endlessWave}',
                    highlightColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  _MetricItem(
                    label: TxaLanguage.tr('endless_best', langCode),
                    value: '${storage.endlessHighScore}',
                    highlightColor: palette.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nút Xem Ad Hồi Sinh (nếu chưa dùng trong run này)
            if (!gameState.hasUsedRevive) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.videocam_rounded, color: Colors.black),
                  label: Text(
                    TxaLanguage.tr('endless_revive_btn', langCode),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  onPressed: () async {
                    final ads = ref.read(adsServiceProvider);
                    final shown = await ads.showRewardedAd(
                      type: RewardType.bonusHint,
                      onRewardEarned: (type, amount) {
                        Navigator.of(context).pop();
                        ref.read(gameStateProvider.notifier).reviveEndlessRun();
                        TxaToast.success(context, TxaLanguage.tr('endless_revived_toast', langCode));
                      },
                    );
                    if (!shown && context.mounted) {
                      TxaToast.warning(context, TxaLanguage.tr('no_ad_available', langCode));
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Cặp nút Chơi lại và Trang chủ
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: Text(TxaLanguage.tr('home', langCode)),
                    onPressed: onHome,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentNeon,
                      foregroundColor: palette.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(
                      TxaLanguage.tr('endless_play_again', langCode),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: onPlayAgain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final Color highlightColor;

  const _MetricItem({
    required this.label,
    required this.value,
    this.isHighlight = false,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: highlightColor,
          ),
        ),
      ],
    );
  }
}
