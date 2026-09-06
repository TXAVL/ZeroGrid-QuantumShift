import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/reverse_generator.dart';
import '../../core/localization/txa_language.dart';
import '../../state/game_notifier.dart';
import '../../state/game_state.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/ads/ads_service.dart';
import '../widgets/quantum_board_widget.dart';
import '../widgets/score_hud_widget.dart';
import '../widgets/endless_hud_widget.dart';
import '../widgets/endless_game_over_dialog.dart';
import '../widgets/win_dialog_widget.dart';
import '../widgets/replay_viewer_widget.dart';
import '../widgets/banner_ad_wrapper.dart';

/// Màn hình chơi game chính (Gameplay Board)
class GameBoardScreen extends ConsumerStatefulWidget {
  final String title;

  const GameBoardScreen({super.key, required this.title});

  @override
  ConsumerState<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends ConsumerState<GameBoardScreen> {
  bool _hasShownWinDialog = false;
  bool _hasShownGameOverDialog = false;

  void _handleNextLevel() {
    Navigator.of(context).pop(); // Đóng WinDialog
    final gameState = ref.read(gameStateProvider);

    if (gameState.mode == GameMode.campaign) {
      final currentLevel = int.tryParse(gameState.levelId) ?? 1;
      final nextLevelId = currentLevel + 1;

      int size = 3;
      int maxK = 3;
      int reverseSteps = 3;
      if (nextLevelId <= 10) {
        size = 3;
        maxK = 3;
        reverseSteps = 2 + (nextLevelId ~/ 3);
      } else if (nextLevelId <= 30) {
        size = 3;
        maxK = 4;
        reverseSteps = 4 + (nextLevelId ~/ 5);
      } else if (nextLevelId <= 60) {
        size = 4;
        maxK = 4;
        reverseSteps = 5 + (nextLevelId ~/ 8);
      } else {
        size = 5;
        maxK = 4;
        reverseSteps = 6 + (nextLevelId ~/ 10);
      }

      final generated = ReverseGenerator.generate(
        levelId: nextLevelId,
        size: size,
        maxK: maxK,
        reverseSteps: reverseSteps,
      );

      setState(() => _hasShownWinDialog = false);
      ref.read(gameStateProvider.notifier).loadLevel(generated, GameMode.campaign);
    } else {
      Navigator.of(context).pop(); // Thoát về menu cho Custom/Daily
    }
  }

  void _showGhostReplay() {
    final gameState = ref.read(gameStateProvider);
    final storage = ref.read(storageServiceProvider);
    final langCode = ref.read(languageProvider);
    final replay = storage.getReplay(gameState.levelId);

    if (replay != null) {
      showDialog(
        context: context,
        builder: (_) => ReplayViewerModal(replay: replay),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TxaLanguage.tr('replay_no_data', langCode))),
      );
    }
  }

  void _showSkipLevelDialog() {
    final ads = ref.read(adsServiceProvider);
    final langCode = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          TxaLanguage.tr('skip_level_title', langCode),
          style: const TextStyle(color: Color(0xFF00E5FF)),
        ),
        content: Text(
          TxaLanguage.tr('skip_level_desc', langCode),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              TxaLanguage.tr('cancel', langCode),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
            icon: const Icon(Icons.videocam_rounded, color: Colors.black),
            label: Text(
              TxaLanguage.tr('watch_ad_btn', langCode),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ads.showRewardedAd(
                type: RewardType.skipLevel,
                onRewardEarned: (type, amount) {
                  _handleNextLevel();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);
    final isEndless = gameState.mode == GameMode.endless;

    // 1. Hiển thị Win Dialog khi hoàn thành (chỉ cho Campaign / Daily / Custom)
    if (!isEndless && gameState.isWon && !_hasShownWinDialog) {
      _hasShownWinDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WinDialogWidget(
            gameState: gameState,
            onNextLevel: _handleNextLevel,
            onReplay: () {
              Navigator.of(ctx).pop();
              _showGhostReplay();
            },
            onHome: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      });
    }

    // 2. Hiển thị Game Over Dialog khi cạn lượt đi trong Endless Mode
    if (isEndless && gameState.isGameOver && !_hasShownGameOverDialog) {
      _hasShownGameOverDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => EndlessGameOverDialog(
            gameState: gameState,
            onPlayAgain: () {
              Navigator.of(ctx).pop();
              setState(() => _hasShownGameOverDialog = false);
              ref.read(gameStateProvider.notifier).startEndlessRun();
            },
            onHome: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      });
    }

    // Reset cờ Game Over khi đã hồi sinh hoặc khởi động run mới
    if (!gameState.isGameOver && _hasShownGameOverDialog) {
      _hasShownGameOverDialog = false;
    }

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
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: palette.accentNeon,
          ),
        ),
        actions: [
          // Nút Skip Level qua Rewarded Ad (chỉ cho Campaign)
          if (!isEndless && !gameState.isWon)
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Color(0xFFFFD600)),
              tooltip: TxaLanguage.tr('skip_level_tooltip', langCode),
              onPressed: _showSkipLevelDialog,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HUD thông số: EndlessHudWidget cho Endless, ScoreHudWidget cho các chế độ khác
            if (isEndless)
              const EndlessHudWidget()
            else
              const ScoreHudWidget(),

            const Spacer(),

            // Bàn cờ trung tâm
            const Center(
              child: QuantumBoardWidget(),
            ),

            const Spacer(),

            // Banner Ad neo dưới cùng
            const BannerAdWrapper(),
          ],
        ),
      ),
    );
  }
}
