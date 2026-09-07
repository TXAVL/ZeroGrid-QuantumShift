import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/config/txa_config.dart';
import '../../core/engine/reverse_generator.dart';
import '../../core/engine/seed_generator.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../widgets/banner_ad_wrapper.dart';
import '../widgets/txa_toast.dart';
import 'level_select_screen.dart';
import 'daily_challenge_screen.dart';
import 'game_board_screen.dart';

/// Màn hình Chọn Chế Độ Chơi (Game Selection Screen) với icon rõ ràng và khóa tiến độ
class GameSelectScreen extends ConsumerWidget {
  const GameSelectScreen({super.key});

  void _startEndlessMode(BuildContext context, WidgetRef ref) {
    final langCode = ref.read(languageProvider);
    ref.read(gameStateProvider.notifier).startEndlessRun();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameBoardScreen(title: TxaLanguage.tr('mode_endless_title', langCode)),
      ),
    );
  }

  void _showCustomChallengeDialog(BuildContext context, WidgetRef ref, String langCode) {
    final palette = ref.read(themeProvider).palette;

    showDialog(
      context: context,
      builder: (ctx) => _AsyncChallengeDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final palette = themeState.palette;
    final langCode = ref.watch(languageProvider);
    final storage = ref.watch(storageServiceProvider);

    return ValueListenableBuilder<int>(
      valueListenable: storage.progressNotifier,
      builder: (context, _, __) {
        final currentLevel = storage.unlockedCampaignLevel;
        final isDailyLocked = currentLevel < TxaConfig.dailyChallengeUnlockLevel;
        final isEndlessLocked = currentLevel < TxaConfig.endlessModeUnlockLevel;
        final isAsyncLocked = currentLevel < TxaConfig.asyncChallengeUnlockLevel;

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
              TxaLanguage.tr('select_game_title', langCode),
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
          body: SafeArea(
            child: Column(
              children: [
                const BannerAdWrapper(isTop: true),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    children: [
                      Text(
                        TxaLanguage.tr('select_game_subtitle', langCode),
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. CAMPAIGN MODE
                      _GameModeCard(
                        icon: Icons.grid_view_rounded,
                        title: TxaLanguage.tr('mode_campaign_title', langCode),
                        description: TxaLanguage.tr('mode_campaign_desc', langCode),
                        badgeText: '${storage.unlockedCampaignLevel} / 100',
                        accentColor: palette.accentNeon,
                        palette: palette,
                        isLocked: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. DAILY CHALLENGE (Mở khóa sau màn 3)
                      _GameModeCard(
                        icon: Icons.calendar_month_rounded,
                        title: TxaLanguage.tr('mode_daily_title', langCode),
                        description: TxaLanguage.tr('mode_daily_desc', langCode),
                        badgeText: isDailyLocked
                            ? TxaLanguage.tr('mode_locked_need_level', langCode)
                                .replaceAll('%level%', '${TxaConfig.dailyChallengeUnlockLevel}')
                            : 'UTC SYNC',
                        accentColor: const Color(0xFFFF007F),
                        palette: palette,
                        isLocked: isDailyLocked,
                        onTap: () {
                          if (isDailyLocked) {
                            TxaToast.info(
                              context,
                              TxaLanguage.tr('mode_locked_daily_toast', langCode)
                                  .replaceAll('%level%', '${TxaConfig.dailyChallengeUnlockLevel}'),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. ENDLESS QUANTUM (Mở khóa sau màn 5)
                      _GameModeCard(
                        icon: Icons.all_inclusive_rounded,
                        title: TxaLanguage.tr('mode_endless_title', langCode),
                        description: TxaLanguage.tr('mode_endless_desc', langCode),
                        badgeText: isEndlessLocked
                            ? TxaLanguage.tr('mode_locked_need_level', langCode)
                                .replaceAll('%level%', '${TxaConfig.endlessModeUnlockLevel}')
                            : 'ADAPTIVE AI',
                        accentColor: const Color(0xFFFFD600),
                        palette: palette,
                        isLocked: isEndlessLocked,
                        onTap: () {
                          if (isEndlessLocked) {
                            TxaToast.info(
                              context,
                              TxaLanguage.tr('mode_locked_endless_toast', langCode)
                                  .replaceAll('%level%', '${TxaConfig.endlessModeUnlockLevel}'),
                            );
                            return;
                          }
                          _startEndlessMode(context, ref);
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. ASYNC CHALLENGE (Mở khóa sau màn 8)
                      _GameModeCard(
                        icon: Icons.qr_code_2_rounded,
                        title: TxaLanguage.tr('mode_async_title', langCode),
                        description: TxaLanguage.tr('mode_async_desc', langCode),
                        badgeText: isAsyncLocked
                            ? TxaLanguage.tr('mode_locked_need_level', langCode)
                                .replaceAll('%level%', '${TxaConfig.asyncChallengeUnlockLevel}')
                            : 'SEED BATTLE',
                        accentColor: const Color(0xFF00FFA3),
                        palette: palette,
                        isLocked: isAsyncLocked,
                        onTap: () {
                          if (isAsyncLocked) {
                            TxaToast.info(
                              context,
                              TxaLanguage.tr('mode_locked_async_toast', langCode)
                                  .replaceAll('%level%', '${TxaConfig.asyncChallengeUnlockLevel}'),
                            );
                            return;
                          }
                          _showCustomChallengeDialog(context, ref, langCode);
                        },
                      ),
                    ],
                  ),
                ),
                const BannerAdWrapper(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AsyncChallengeDialog extends ConsumerStatefulWidget {
  final dynamic palette;
  final String langCode;

  const _AsyncChallengeDialog({required this.palette, required this.langCode});

  @override
  ConsumerState<_AsyncChallengeDialog> createState() => _AsyncChallengeDialogState();
}

class _AsyncChallengeDialogState extends ConsumerState<_AsyncChallengeDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _enterCodeController = TextEditingController();

  int _selectedGridSize = 4;
  int _selectedSteps = 6;
  String _generatedCode = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateNewCode();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _enterCodeController.dispose();
    super.dispose();
  }

  void _generateNewCode() {
    final seed = SeedGenerator.generateRandomSeed();
    final code = SeedGenerator.encodeChallengeCode(
      size: _selectedGridSize,
      maxK: 4,
      reverseSteps: _selectedSteps,
      seed: seed,
    );
    setState(() {
      _generatedCode = code;
    });
  }

  void _shareCode() {
    final shareText = SeedGenerator.buildChallengeShareMessage(
      challengeCode: _generatedCode,
      size: _selectedGridSize,
      reverseSteps: _selectedSteps,
    );
    Share.share(shareText, subject: 'Zero Grid Async Challenge');
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    TxaToast.success(context, TxaLanguage.tr('challenge_copied', widget.langCode));
  }

  void _playWithCode(String code) {
    final decoded = SeedGenerator.decodeChallengeCode(code);
    if (decoded != null) {
      Navigator.of(context).pop();
      final level = ReverseGenerator.generate(
        levelId: 7777,
        size: decoded.size,
        maxK: decoded.maxK,
        reverseSteps: decoded.reverseSteps,
        customSeed: decoded.seed,
      );
      ref.read(gameStateProvider.notifier).loadLevel(level, GameMode.customChallenge);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameBoardScreen(
            title: 'CHALLENGE ${decoded.size}x${decoded.size}',
          ),
        ),
      );
    } else {
      TxaToast.error(context, TxaLanguage.tr('invalid_code', widget.langCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final langCode = widget.langCode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00FFA3).withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 18, left: 20, right: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: Color(0xFF00FFA3), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        TxaLanguage.tr('challenge_dialog_title', langCode),
                        style: const TextStyle(
                          color: Color(0xFF00FFA3),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00FFA3),
              indicatorWeight: 3,
              labelColor: const Color(0xFF00FFA3),
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: TxaLanguage.tr('challenge_tab_enter', langCode)),
                Tab(text: TxaLanguage.tr('challenge_tab_create', langCode)),
              ],
            ),

            Flexible(
              child: SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Enter Code
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TxaLanguage.tr('challenge_enter_desc', langCode),
                            style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _enterCodeController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: TxaLanguage.tr('challenge_dialog_hint', langCode),
                              hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: palette.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFA3),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () => _playWithCode(_enterCodeController.text),
                              child: Text(
                                TxaLanguage.tr('play_now', langCode),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab 2: Create & Share Challenge
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TxaLanguage.tr('challenge_create_desc', langCode),
                            style: TextStyle(color: palette.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          // Kích cỡ bàn cờ
                          Row(
                            children: [
                              Text(
                                TxaLanguage.tr('challenge_grid_size', langCode),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              ...[3, 4, 5].map((size) {
                                final isSel = _selectedGridSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedGridSize = size);
                                    _generateNewCode();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFF00FFA3) : palette.background,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${size}x$size',
                                      style: TextStyle(
                                        color: isSel ? Colors.black : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Số bước Slider
                          Row(
                            children: [
                              Text(
                                '${TxaLanguage.tr('challenge_difficulty', langCode)} $_selectedSteps ${TxaLanguage.tr('challenge_steps_count', langCode)}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Slider(
                            value: _selectedSteps.toDouble(),
                            min: 3,
                            max: 12,
                            divisions: 9,
                            activeColor: const Color(0xFF00FFA3),
                            inactiveColor: Colors.white12,
                            onChanged: (val) {
                              setState(() => _selectedSteps = val.toInt());
                              _generateNewCode();
                            },
                          ),

                          // Generated Code Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: palette.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: SelectableText(
                              _generatedCode,
                              style: const TextStyle(
                                color: Color(0xFF00FFA3),
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Copy & Share buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: Text(TxaLanguage.tr('challenge_btn_copy', langCode), style: const TextStyle(fontSize: 12)),
                                  onPressed: _copyCode,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00FFA3),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.share_rounded, size: 16),
                                  label: Text(TxaLanguage.tr('challenge_btn_share', langCode), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: _shareCode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final Color accentColor;
  final dynamic palette;
  final bool isLocked;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.accentColor,
    required this.palette,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = isLocked ? const Color(0xFF6B7280) : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: palette.boardFrame,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: effectiveAccent.withValues(alpha: isLocked ? 0.2 : 0.35),
              width: 1.5,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: effectiveAccent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Icon khối phát sáng hoặc khóa
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: isLocked ? 0.1 : 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: effectiveAccent.withValues(alpha: isLocked ? 0.3 : 0.6),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline_rounded : icon,
                  size: 30,
                  color: effectiveAccent,
                ),
              ),
              const SizedBox(width: 16),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.white60 : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: effectiveAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: effectiveAccent.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: effectiveAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
