import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/reverse_generator.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../widgets/banner_ad_wrapper.dart';
import '../widgets/txa_toast.dart';
import 'game_board_screen.dart';

/// Màn hình chọn Level trong Campaign (100 Level)
class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  void _startLevel(BuildContext context, WidgetRef ref, int levelId) {
    // Độ khó tăng dần theo level
    int size = 3;
    int maxK = 3;
    int reverseSteps = 3;

    if (levelId <= 10) {
      size = 3;
      maxK = 3;
      reverseSteps = 2 + (levelId ~/ 3);
    } else if (levelId <= 30) {
      size = 3;
      maxK = 4;
      reverseSteps = 4 + (levelId ~/ 5);
    } else if (levelId <= 60) {
      size = 4;
      maxK = 4;
      reverseSteps = 5 + (levelId ~/ 8);
    } else {
      size = 5;
      maxK = 4;
      reverseSteps = 6 + (levelId ~/ 10);
    }

    final generated = ReverseGenerator.generate(
      levelId: levelId,
      size: size,
      maxK: maxK,
      reverseSteps: reverseSteps,
    );

    ref.read(gameStateProvider.notifier).loadLevel(generated, GameMode.campaign);
    final langCode = ref.read(languageProvider);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameBoardScreen(title: '${TxaLanguage.tr('sector_label', langCode)} $levelId')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final storage = ref.watch(storageServiceProvider);
    final langCode = ref.watch(languageProvider);

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
          TxaLanguage.tr('campaign_title', langCode),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: palette.accentNeon,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD600), size: 22),
                const SizedBox(width: 4),
                ValueListenableBuilder<int>(
                  valueListenable: storage.totalStarsNotifier,
                  builder: (context, stars, _) {
                    return Text(
                      '$stars',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: storage.progressNotifier,
        builder: (context, _, __) {
          final curUnlockedLevel = storage.unlockedCampaignLevel;

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    final levelId = index + 1;
                    final isUnlocked = levelId <= curUnlockedLevel;
                    final stars = storage.getLevelStars(levelId);

                    return _LevelTile(
                      levelId: levelId,
                      isUnlocked: isUnlocked,
                      stars: stars,
                      palette: palette,
                      onTap: () {
                        if (isUnlocked) {
                          _startLevel(context, ref, levelId);
                        } else {
                          TxaToast.warning(context, TxaLanguage.tr('level_locked', langCode));
                        }
                      },
                    );
                  },
                ),
              ),
              const BannerAdWrapper(),
            ],
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int levelId;
  final bool isUnlocked;
  final int stars;
  final dynamic palette;
  final VoidCallback onTap;

  const _LevelTile({
    required this.levelId,
    required this.isUnlocked,
    required this.stars,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isUnlocked ? palette.boardFrame : palette.cellInactive.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? palette.accentNeon.withValues(alpha: 0.4) : palette.cellInactive,
            width: isUnlocked ? 1.5 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: palette.accentNeon.withValues(alpha: 0.12),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                '$levelId',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (starIndex) {
                  return Icon(
                    starIndex < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 14,
                    color: starIndex < stars ? const Color(0xFFFFD600) : palette.cellInactive,
                  );
                }),
              ),
            ] else
              Icon(
                Icons.lock_outline_rounded,
                size: 24,
                color: palette.textSecondary.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}
