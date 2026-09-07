import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/reverse_generator.dart';
import '../../core/engine/seed_generator.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_format.dart';
import '../../core/utils/txa_time.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../widgets/banner_ad_wrapper.dart';
import 'game_board_screen.dart';
import 'leaderboard_screen.dart';

/// Màn hình Daily Challenge hỗ trợ nhiều chặng (Multi-Stage) và lưu trữ trạng thái hôm nay
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  Timer? _countdownTimer;
  String _countdownStr = '';

  @override
  void initState() {
    super.initState();
    _countdownStr = TxaTime.getTimeUntilNextUtcReset();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _countdownStr = TxaTime.getTimeUntilNextUtcReset();
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startDaily(int stageToPlay) {
    final dailySeedStr = SeedGenerator.getDailySeed();
    final seedInt = SeedGenerator.seedToInt('${dailySeedStr}_stage$stageToPlay');

    // Cấu hình độ khó theo chặng
    int size = 4;
    int reverseSteps = 6;
    int levelId = 8881;

    if (stageToPlay == 2) {
      size = 4;
      reverseSteps = 8;
      levelId = 8882;
    } else if (stageToPlay >= 3) {
      size = 5;
      reverseSteps = 10;
      levelId = 8883;
    }

    final level = ReverseGenerator.generate(
      levelId: levelId,
      size: size,
      maxK: 4,
      reverseSteps: reverseSteps,
      customSeed: seedInt,
    );

    final langCode = ref.read(languageProvider);
    final stageName = stageToPlay == 1
        ? (TxaLanguage.isVietnamese(langCode) ? 'Chặng 1 (Tiêu chuẩn)' : 'Stage 1 (Standard)')
        : (stageToPlay == 2
            ? (TxaLanguage.isVietnamese(langCode) ? 'Chặng 2 (Nâng cao)' : 'Stage 2 (Advanced)')
            : (TxaLanguage.isVietnamese(langCode) ? 'Chặng 3 (Chuyên gia)' : 'Stage 3 (Master)'));

    ref.read(gameStateProvider.notifier).loadLevel(level, GameMode.dailyChallenge);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameBoardScreen(
          title: '${TxaLanguage.tr('mode_daily_title', langCode)} - $stageName',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);
    final storage = ref.watch(storageServiceProvider);

    final localDateStr = TxaTime.getTodayLocalDisplay();
    final localResetTime = TxaTime.getDailyResetLocalTime();
    final todayUtc = TxaTime.getTodayUtcDateString();

    final isCompletedToday = storage.isDailyCompletedToday(todayUtc);
    final completedStage = storage.getDailyCompletedStage(todayUtc);
    final dailyScore = storage.getDailyScore(todayUtc);
    final dailyStars = storage.getDailyStars(todayUtc);

    final nextStageToPlay = completedStage < 3 ? completedStage + 1 : 3;

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
          TxaLanguage.tr('daily_screen_title', langCode),
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
            const BannerAdWrapper(isTop: true),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: palette.accentNeon.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.accentNeon.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accentNeon.withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 64,
                            color: palette.accentNeon,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          TxaLanguage.tr('mode_daily_title', langCode),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localDateStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: palette.accentNeon,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Countdown & Local Reset Time Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD600).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${TxaLanguage.tr('daily_reset_in', langCode)}: $_countdownStr',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD600),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                TxaLanguage.tr('daily_reset_at', langCode)
                                    .replaceAll('%time%', localResetTime),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Thẻ hiển thị trạng thái hoàn thành hôm nay
                        if (isCompletedToday) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF00FFA3).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      'TIẾN TRÌNH',
                                      style: TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Chặng $completedStage/3',
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF00FFA3), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(width: 1, height: 32, color: Colors.white12),
                                Column(
                                  children: [
                                    const Text(
                                      'ĐIỂM HÔM NAY',
                                      style: TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TxaFormat.formatScore(dailyScore),
                                      style: const TextStyle(fontSize: 14, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(width: 1, height: 32, color: Colors.white12),
                                Column(
                                  children: [
                                    const Text(
                                      'SAO ĐẠT ĐƯỢC',
                                      style: TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$dailyStars/3',
                                          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Text(
                          TxaLanguage.tr('daily_target', langCode),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.accentNeon,
                              foregroundColor: palette.background,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                            ),
                            icon: Icon(
                              completedStage >= 3 ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              size: 26,
                            ),
                            label: Text(
                              completedStage == 0
                                  ? (TxaLanguage.isVietnamese(langCode) ? 'Bắt đầu Chặng 1 (Tiêu chuẩn)' : 'Start Stage 1 (Standard)')
                                  : (completedStage == 1
                                      ? (TxaLanguage.isVietnamese(langCode) ? 'Tiếp tục Chặng 2 (Nâng cao)' : 'Play Stage 2 (Advanced)')
                                      : (completedStage == 2
                                          ? (TxaLanguage.isVietnamese(langCode) ? 'Tiếp tục Chặng 3 (Chuyên gia)' : 'Play Stage 3 (Master)')
                                          : (TxaLanguage.isVietnamese(langCode) ? 'Chơi lại lập kỷ lục mới' : 'Replay for High Score'))),
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _startDaily(nextStageToPlay),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: palette.accentNeon.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.leaderboard_rounded, size: 20),
                            label: Text(
                              TxaLanguage.tr('leaderboard_title', langCode),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const BannerAdWrapper(),
          ],
        ),
      ),
    );
  }
}
