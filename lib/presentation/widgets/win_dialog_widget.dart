import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/engine/score_calculator.dart';
import '../../core/engine/seed_generator.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/ads/ads_service.dart';
import 'txa_toast.dart';

/// Hộp thoại chiến thắng (Level Complete) với hoạt ảnh sao, nút 2X điểm và chia sẻ thách đấu
class WinDialogWidget extends ConsumerStatefulWidget {
  final GameState gameState;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const WinDialogWidget({
    super.key,
    required this.gameState,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  ConsumerState<WinDialogWidget> createState() => _WinDialogWidgetState();
}

class _WinDialogWidgetState extends ConsumerState<WinDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  bool _isScoreDoubled = false;

  @override
  void initState() {
    super.initState();
    _isScoreDoubled = widget.gameState.isScoreDoubled;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _shareCurrentMatchChallenge() {
    final size = widget.gameState.board.size;
    final maxK = widget.gameState.board.maxK;
    final steps = widget.gameState.minMoves;
    final seed = SeedGenerator.generateRandomSeed();

    final challengeCode = SeedGenerator.encodeChallengeCode(
      size: size,
      maxK: maxK,
      reverseSteps: steps,
      seed: seed,
    );

    final shareMsg = SeedGenerator.buildChallengeShareMessage(
      challengeCode: challengeCode,
      size: size,
      reverseSteps: steps,
    );

    Share.share(shareMsg, subject: 'Zero Grid Challenge');
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);

    final stars = ScoreCalculator.calculateStars(
      actualMoves: widget.gameState.movesCount,
      minMoves: widget.gameState.minMoves,
    );

    int score = widget.gameState.customScore ??
        (widget.gameState.currentScore > 0
            ? widget.gameState.currentScore
            : ScoreCalculator.calculateScore(
                actualMoves: widget.gameState.movesCount,
                minMoves: widget.gameState.minMoves,
                durationSeconds: widget.gameState.durationSeconds,
                totalComboZeros: widget.gameState.totalComboZeros,
                maxComboMultiplier: widget.gameState.maxComboMultiplier,
              ));

    if ((_isScoreDoubled || widget.gameState.isScoreDoubled) && widget.gameState.customScore == null) {
      score *= 2;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: palette.boardFrame,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: palette.accentNeon.withValues(alpha: 0.5),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.accentNeon.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TxaLanguage.tr('level_complete', langCode),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: palette.accentNeon,
                ),
              ),

              const SizedBox(height: 20),

              // Dãy sao 1-3 sao
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final hasStar = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      hasStar ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 48,
                      color: hasStar ? const Color(0xFFFFD600) : palette.cellInactive,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Bảng tóm tắt chỉ số
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    _MetricRow(
                      label: TxaLanguage.tr('total_score', langCode),
                      value: '$score',
                      isHighlight: true,
                      palette: palette,
                      isDoubled: _isScoreDoubled || widget.gameState.isScoreDoubled,
                    ),
                    const Divider(color: Colors.white10),
                    _MetricRow(
                      label: TxaLanguage.tr('moves_taken', langCode),
                      value: '${widget.gameState.movesCount} (${TxaLanguage.tr('min_moves', langCode)} ${widget.gameState.minMoves})',
                      palette: palette,
                    ),
                    _MetricRow(
                      label: TxaLanguage.tr('play_duration', langCode),
                      value: '${widget.gameState.durationSeconds}s',
                      palette: palette,
                    ),
                    if (widget.gameState.maxComboMultiplier > 1)
                      _MetricRow(
                        label: TxaLanguage.tr('stat_max_combo', langCode),
                        value: 'x${widget.gameState.maxComboMultiplier}',
                        palette: palette,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Nút xem Rewarded Ad x2 Double Score (có hiệu ứng nhấp nháy 2X neon)
              if (!_isScoreDoubled && !widget.gameState.isScoreDoubled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glow = 0.3 + (_pulseController.value * 0.5);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD600).withValues(alpha: glow),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.videocam_rounded, color: Colors.black),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TxaLanguage.tr('btn_double_score', langCode),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '2X',
                              style: TextStyle(
                                color: Color(0xFFFFD600),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        final ads = ref.read(adsServiceProvider);
                        await ads.showRewardedAd(
                          type: RewardType.doubleDailyScore,
                          onRewardEarned: (type, amount) {
                            setState(() {
                              _isScoreDoubled = true;
                            });
                            ref.read(gameStateProvider.notifier).doubleScoreWithReward();
                            TxaToast.success(context, TxaLanguage.tr('score_doubled_toast', langCode));
                          },
                        );
                      },
                    ),
                  ),
                ),

              // Nút Thách đấu ván này (Async Challenge Share)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00E5FF),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    TxaLanguage.tr('challenge_share_match_btn', langCode),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _shareCurrentMatchChallenge,
                ),
              ),

              // Dãy nút điều hướng: Home, Ghost Replay, Next Level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_rounded, color: Colors.white70, size: 28),
                    onPressed: widget.onHome,
                  ),
                  IconButton(
                    icon: Icon(Icons.history_rounded, color: palette.accentNeon, size: 28),
                    tooltip: TxaLanguage.tr('btn_view_timelapse', langCode),
                    onPressed: widget.onReplay,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentNeon,
                      foregroundColor: palette.background,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: widget.onNextLevel,
                    child: Text(
                      TxaLanguage.tr('btn_next_level', langCode),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
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

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isDoubled;
  final dynamic palette;

  const _MetricRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isDoubled = false,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: palette.textSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isHighlight ? 18 : 14,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight ? palette.accentNeon : Colors.white,
                ),
              ),
              if (isDoubled && isHighlight) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '2X',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
