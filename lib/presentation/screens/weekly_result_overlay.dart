import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../services/service_providers.dart';
import '../../state/theme_notifier.dart';
import '../widgets/tournament_mascot_widget.dart';

/// Màn hình Hoạt Cảnh Kết Quả Giải Đấu Tuần Mới (Thăng Hạng / Trụ Hạng / Rớt Hạng)
class WeeklyResultOverlay extends ConsumerStatefulWidget {
  final int prevRank;
  final int prevTier;
  final int newTier;
  final VoidCallback onDismiss;

  const WeeklyResultOverlay({
    super.key,
    required this.prevRank,
    required this.prevTier,
    required this.newTier,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required int prevRank,
    required int prevTier,
    required int newTier,
  }) async {
    final storage = ProviderScope.containerOf(context, listen: false).read(storageServiceProvider);
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (ctx, anim1, anim2) => WeeklyResultOverlay(
          prevRank: prevRank,
          prevTier: prevTier,
          newTier: newTier,
          onDismiss: () {
            storage.markWeeklyResultSeen();
            Navigator.of(ctx).pop();
          },
        ),
        transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  ConsumerState<WeeklyResultOverlay> createState() => _WeeklyResultOverlayState();
}

class _WeeklyResultOverlayState extends ConsumerState<WeeklyResultOverlay> {
  int _secondsLeft = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        widget.onDismiss();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  MascotMood _getMood() {
    if (widget.prevRank >= 1 && widget.prevRank <= 4) {
      return MascotMood.promoted;
    } else if (widget.prevRank >= 15) {
      return MascotMood.demoted;
    }
    return MascotMood.retained;
  }

  String _getTierName(int tier, String langCode) {
    switch (tier) {
      case 0:
        return TxaLanguage.tr('tier_bronze', langCode);
      case 1:
        return TxaLanguage.tr('tier_silver', langCode);
      case 2:
        return TxaLanguage.tr('tier_gold', langCode);
      case 3:
        return TxaLanguage.tr('tier_platinum', langCode);
      case 4:
        return TxaLanguage.tr('tier_diamond', langCode);
      case 5:
      default:
        return TxaLanguage.tr('tier_master', langCode);
    }
  }

  IconData _getTierIcon(int tier) {
    switch (tier) {
      case 0:
        return Icons.shield_outlined;
      case 1:
        return Icons.shield_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      case 4:
        return Icons.diamond_rounded;
      case 5:
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 0:
        return const Color(0xFFCD7F32); // Bronze
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFFFD700); // Gold
      case 3:
        return const Color(0xFF00E5FF); // Platinum
      case 4:
        return const Color(0xFF9D00FF); // Diamond
      case 5:
      default:
        return const Color(0xFFFF007F); // Quantum Master
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);
    final mood = _getMood();

    final Color accentColor = mood == MascotMood.promoted
        ? const Color(0xFF00FFA3)
        : (mood == MascotMood.retained ? const Color(0xFFFFD600) : const Color(0xFFFF0055));

    final String title = mood == MascotMood.promoted
        ? TxaLanguage.tr('tournament_promoted_title', langCode)
        : (mood == MascotMood.retained
            ? TxaLanguage.tr('tournament_retained_title', langCode)
            : TxaLanguage.tr('tournament_demoted_title', langCode));

    final String desc = mood == MascotMood.promoted
        ? TxaLanguage.tr('tournament_promoted_desc', langCode)
            .replaceAll('%rank%', '${widget.prevRank}')
            .replaceAll('%tier%', _getTierName(widget.newTier, langCode))
        : (mood == MascotMood.retained
            ? TxaLanguage.tr('tournament_retained_desc', langCode)
                .replaceAll('%rank%', '${widget.prevRank}')
                .replaceAll('%tier%', _getTierName(widget.newTier, langCode))
            : TxaLanguage.tr('tournament_demoted_desc', langCode)
                .replaceAll('%rank%', '${widget.prevRank}')
                .replaceAll('%tier%', _getTierName(widget.newTier, langCode)));

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Animated Mascot Widget
                  TournamentMascotWidget(
                    mood: mood,
                    size: 200,
                  ),
                  const SizedBox(height: 24),

                  // 2. Title with glowing border box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Description
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Division Transition Badge Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: palette.boardFrame,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Old Tier
                        Column(
                          children: [
                            Icon(
                              _getTierIcon(widget.prevTier),
                              color: _getTierColor(widget.prevTier),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTierName(widget.prevTier, langCode),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getTierColor(widget.prevTier),
                              ),
                            ),
                          ],
                        ),

                        // Arrow Transition Icon
                        Icon(
                          mood == MascotMood.promoted
                              ? Icons.arrow_forward_rounded
                              : (mood == MascotMood.retained
                                  ? Icons.compare_arrows_rounded
                                  : Icons.south_rounded),
                          color: accentColor,
                          size: 26,
                        ),

                        // New Tier
                        Column(
                          children: [
                            Icon(
                              _getTierIcon(widget.newTier),
                              color: _getTierColor(widget.newTier),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTierName(widget.newTier, langCode),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _getTierColor(widget.newTier),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. Button Dismiss / Continue
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                      ),
                      onPressed: widget.onDismiss,
                      child: Text(
                        TxaLanguage.tr('btn_continue_to_league', langCode),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 6. Auto-dismiss timer text
                  Text(
                    TxaLanguage.tr('tournament_autoclose_timer', langCode)
                        .replaceAll('%seconds%', '$_secondsLeft'),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
