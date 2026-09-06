import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/engine/board_state.dart';
import '../core/engine/reverse_generator.dart';
import '../core/engine/score_calculator.dart';
import '../core/engine/puzzle_solver.dart';
import '../core/engine/replay_recorder.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../services/ads/ads_service.dart';
import '../services/gpgs/gpgs_service.dart';
import '../services/supabase_service.dart';
import '../services/service_providers.dart';
import 'game_state.dart';

final gameStateProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final audio = ref.watch(audioServiceProvider);
  final haptic = ref.watch(hapticServiceProvider);
  final ads = ref.watch(adsServiceProvider);
  final gpgs = ref.watch(gpgsServiceProvider);
  final supabase = ref.watch(supabaseServiceProvider);

  return GameNotifier(
    storage: storage,
    audio: audio,
    haptic: haptic,
    ads: ads,
    gpgs: gpgs,
    supabase: supabase,
  );
});

class GameNotifier extends StateNotifier<GameState> {
  final StorageService _storage;
  final AudioService _audio;
  final HapticService _haptic;
  final AdsService _ads;
  final GpgsService _gpgs;
  final SupabaseService _supabase;

  Timer? _timer;
  ReplayRecorder? _recorder;
  bool _usedHintInThisLevel = false;

  GameNotifier({
    required StorageService storage,
    required AudioService audio,
    required HapticService haptic,
    required AdsService ads,
    required GpgsService gpgs,
    required SupabaseService supabase,
  })  : _storage = storage,
        _audio = audio,
        _haptic = haptic,
        _ads = ads,
        _gpgs = gpgs,
        _supabase = supabase,
        super(
          GameState(
            levelId: '1',
            mode: GameMode.campaign,
            board: BoardState.allZero(3),
            initialBoard: BoardState.allZero(3),
            movesCount: 0,
            minMoves: 3,
            isWon: false,
            durationSeconds: 0,
            currentCombo: 0,
            maxComboMultiplier: 1,
            totalComboZeros: 0,
            optimalSolution: const [],
            remainingOptimalSolution: const [],
            lastTappedMove: null,
            undoStack: const [],
          ),
        );

  void loadLevel(GeneratedLevel level, GameMode mode) {
    _timer?.cancel();
    _usedHintInThisLevel = false;

    _recorder = ReplayRecorder(initialState: level.initialState);
    _recorder?.start();

    state = GameState(
      levelId: level.levelId.toString(),
      mode: mode,
      board: level.initialState,
      initialBoard: level.initialState,
      movesCount: 0,
      minMoves: level.minMoves,
      isWon: false,
      durationSeconds: 0,
      currentCombo: 0,
      maxComboMultiplier: 1,
      totalComboZeros: 0,
      optimalSolution: level.optimalSolution,
      remainingOptimalSolution: List<(int, int)>.from(level.optimalSolution),
      lastTappedMove: null,
      undoStack: const [],
      endlessWave: mode == GameMode.endless ? 1 : 1,
      endlessScore: 0,
      endlessMovesLeft: mode == GameMode.endless ? 15 : 15,
      isGameOver: false,
      hasUsedRevive: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isWon && !state.isGameOver) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
      }
    });
  }

  /// Bắt đầu một Run Endless Vượt Sóng hoàn toàn mới
  void startEndlessRun() {
    _timer?.cancel();
    _usedHintInThisLevel = false;

    // Wave 1 khởi đầu: 3x3, maxK 3, reverseSteps 2, seed ngẫu nhiên
    final seed = DateTime.now().millisecondsSinceEpoch;
    final level = ReverseGenerator.generate(
      levelId: 1,
      size: 3,
      maxK: 3,
      reverseSteps: 2,
      customSeed: seed,
    );

    _recorder = ReplayRecorder(initialState: level.initialState);
    _recorder?.start();

    state = GameState(
      levelId: 'endless_wave_1',
      mode: GameMode.endless,
      board: level.initialState,
      initialBoard: level.initialState,
      movesCount: 0,
      minMoves: level.minMoves,
      isWon: false,
      durationSeconds: 0,
      currentCombo: 0,
      maxComboMultiplier: 1,
      totalComboZeros: 0,
      optimalSolution: level.optimalSolution,
      remainingOptimalSolution: List<(int, int)>.from(level.optimalSolution),
      lastTappedMove: null,
      undoStack: const [],
      endlessWave: 1,
      endlessScore: 0,
      endlessMovesLeft: 15,
      isGameOver: false,
      hasUsedRevive: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isWon && !state.isGameOver) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
      }
    });
  }

  void tapCell(int r, int c) {
    if (state.isWon || state.isGameOver) return;

    final prevBoard = state.board;
    final prevRemaining = state.remainingOptimalSolution;
    final prevLastTapped = state.lastTappedMove;

    final moveResult = prevBoard.applyMove(r, c);
    final isBoardCleared = moveResult.newState.isCleared();

    _recorder?.recordMove(r, c);
    _haptic.tap();
    _audio.playTap();

    // Tính toán Combo
    final newlyZeros = moveResult.newlyZeroedCount;
    int nextCombo = state.currentCombo;
    int maxCombo = state.maxComboMultiplier;

    if (newlyZeros >= 2) {
      nextCombo = newlyZeros;
      maxCombo = max(maxCombo, nextCombo);
      _haptic.combo(nextCombo);
      _audio.playCombo(nextCombo);

      if (nextCombo >= 3) {
        _gpgs.unlockAchievement(GpgsAchievementIds.achCombo3);
      }
      if (nextCombo >= 5) {
        _gpgs.unlockAchievement(GpgsAchievementIds.achComboMasterX5);
      }
      if (nextCombo >= 8) {
        _gpgs.unlockAchievement(GpgsAchievementIds.achCombo8);
      }
    }

    // Cập nhật remainingOptimalSolution (loại bỏ 1 lần xuất hiện của nước vừa bấm nếu có)
    final newRemaining = List<(int, int)>.from(prevRemaining);
    final tapped = (r, c);
    final matchIdx = newRemaining.indexWhere((m) => m == tapped);
    if (matchIdx != -1) {
      newRemaining.removeAt(matchIdx);
    }

    final newUndoStack = List<UndoSnapshot>.from(state.undoStack)
      ..add(UndoSnapshot(
        board: prevBoard,
        movesCount: state.movesCount,
        currentCombo: state.currentCombo,
        totalComboZeros: state.totalComboZeros,
        remainingSolution: prevRemaining,
        lastTappedMove: prevLastTapped,
        currentScore: state.currentScore,
        endlessScore: state.endlessScore,
        endlessMovesLeft: state.endlessMovesLeft,
      ));

    // Xử lý riêng cho Endless Mode
    if (state.mode == GameMode.endless) {
      final newMovesLeft = state.endlessMovesLeft - 1;
      final int endlessMoveScore = (newlyZeros > 0)
          ? (newlyZeros * 100 * max<int>(1, nextCombo)) + 10
          : 10;
      final int newEndlessScore = state.endlessScore + endlessMoveScore;

      // Cập nhật kỷ lục high score real-time nếu vượt qua kỷ lục cũ
      _storage.updateEndlessHighScore(newEndlessScore);

      // Nếu cạn lượt đi mà bàn cờ chưa về 0: Kích hoạt GAME OVER
      if (!isBoardCleared && newMovesLeft <= 0) {
        state = state.copyWith(
          board: moveResult.newState,
          movesCount: state.movesCount + 1,
          endlessMovesLeft: 0,
          endlessScore: newEndlessScore,
          isGameOver: true,
          clearHint: true,
        );
        _haptic.tap();
        _storage.updateEndlessHighScore(newEndlessScore);
        _storage.updateEndlessMaxWave(state.endlessWave);
        _supabase.submitScore(
          mode: 'endless',
          levelId: 'wave_${state.endlessWave}',
          score: newEndlessScore,
          moves: state.movesCount,
          durationSeconds: state.durationSeconds,
          stars: 0,
          comboMultiplier: state.maxComboMultiplier,
        );
        return;
      }

      state = state.copyWith(
        board: moveResult.newState,
        movesCount: state.movesCount + 1,
        isWon: isBoardCleared,
        currentCombo: nextCombo,
        maxComboMultiplier: maxCombo,
        totalComboZeros: state.totalComboZeros + newlyZeros,
        remainingOptimalSolution: newRemaining,
        lastTappedMove: (r, c),
        undoStack: newUndoStack,
        clearHint: true,
        endlessMovesLeft: newMovesLeft,
        endlessScore: newEndlessScore,
      );

      if (isBoardCleared) {
        _onEndlessWaveCleared(newMovesLeft);
      }
      return;
    }

    // Các chế độ Campaign / Daily / Custom: Cộng điểm real-time theo bước đi & số 0 tạo được
    final int campaignMoveScore = (newlyZeros > 0)
        ? (newlyZeros * 150 * max<int>(1, nextCombo)) + 10
        : 10;
    final int newCurrentScore = state.currentScore + campaignMoveScore;

    state = state.copyWith(
      board: moveResult.newState,
      movesCount: state.movesCount + 1,
      isWon: isBoardCleared,
      currentCombo: nextCombo,
      maxComboMultiplier: maxCombo,
      totalComboZeros: state.totalComboZeros + newlyZeros,
      remainingOptimalSolution: newRemaining,
      lastTappedMove: (r, c),
      undoStack: newUndoStack,
      clearHint: true,
      currentScore: newCurrentScore,
    );

    if (isBoardCleared) {
      _onGameWon();
    }
  }

  /// Xử lý dọn sạch 1 Wave trong Endless Mode: Tích lũy điểm và chuyển Wave liền mạch
  void _onEndlessWaveCleared(int remainingMoves) {
    _haptic.win();
    _audio.playWin();

    // 1. Tính điểm thưởng dọn sạch wave này (combo đã được cộng real-time trong từng nước đi):
    final baseScore = 600 + (state.endlessWave * 150);
    final remainingMovesBonus = remainingMoves * 120;
    final wavePoints = baseScore + remainingMovesBonus;
    final int totalEndlessScore = state.endlessScore + wavePoints;

    _storage.updateEndlessHighScore(totalEndlessScore);
    _storage.updateEndlessMaxWave(state.endlessWave);

    // Kích hoạt GPGS Milestones cho Endless
    if (totalEndlessScore >= 100) _gpgs.unlockAchievement(GpgsAchievementIds.achEndless100);
    if (totalEndlessScore >= 500) _gpgs.unlockAchievement(GpgsAchievementIds.achEndless500);
    if (totalEndlessScore >= 1000) _gpgs.unlockAchievement(GpgsAchievementIds.achEndless1000);

    // 2. Chuẩn bị Wave tiếp theo với độ khó tăng dần
    final nextWave = state.endlessWave + 1;
    int nextSize = 3;
    int nextMaxK = 3;
    int nextSteps = 3;

    if (nextWave <= 3) {
      nextSize = 3;
      nextMaxK = 3;
      nextSteps = 2 + nextWave;
    } else if (nextWave <= 7) {
      nextSize = 3;
      nextMaxK = 4;
      nextSteps = 4 + (nextWave - 3);
    } else if (nextWave <= 12) {
      nextSize = 4;
      nextMaxK = 3;
      nextSteps = 4 + (nextWave - 7);
    } else {
      nextSize = 4;
      nextMaxK = 4;
      nextSteps = min(10, 5 + ((nextWave - 12) ~/ 2));
    }

    final nextSeed = DateTime.now().millisecondsSinceEpoch + (nextWave * 1007);
    final nextLevel = ReverseGenerator.generate(
      levelId: nextWave,
      size: nextSize,
      maxK: nextMaxK,
      reverseSteps: nextSteps,
      customSeed: nextSeed,
    );

    // Thưởng thêm lượt đi cho wave kế tiếp: giữ lượt còn dư + số bước màn mới + 2 (tối đa 25)
    final awardedMoves = min(25, remainingMoves + nextLevel.minMoves + 2);

    state = state.copyWith(
      levelId: 'endless_wave_$nextWave',
      board: nextLevel.initialState,
      initialBoard: nextLevel.initialState,
      movesCount: 0,
      minMoves: nextLevel.minMoves,
      isWon: false,
      currentCombo: 0,
      totalComboZeros: 0,
      optimalSolution: nextLevel.optimalSolution,
      remainingOptimalSolution: List<(int, int)>.from(nextLevel.optimalSolution),
      clearLastTappedMove: true,
      undoStack: const [],
      clearHint: true,
      endlessWave: nextWave,
      endlessScore: totalEndlessScore,
      endlessMovesLeft: awardedMoves,
    );
  }

  /// Hồi sinh Endless Run bằng Rewarded Ad (+5 lượt đi)
  void reviveEndlessRun() {
    if (!state.isGameOver || state.hasUsedRevive) return;
    state = state.copyWith(
      endlessMovesLeft: 5,
      isGameOver: false,
      hasUsedRevive: true,
    );
    _haptic.tap();
  }

  void _onGameWon() {
    _timer?.cancel();
    _haptic.win();
    _audio.playWin();

    final stars = ScoreCalculator.calculateStars(
      actualMoves: state.movesCount,
      minMoves: state.minMoves,
    );

    final score = ScoreCalculator.calculateScore(
      actualMoves: state.movesCount,
      minMoves: state.minMoves,
      durationSeconds: state.durationSeconds,
      totalComboZeros: state.totalComboZeros,
      maxComboMultiplier: state.maxComboMultiplier,
    );

    // Ghi nhận chỉ số thống kê cục bộ
    _storage.recordGameEnd(won: true, durationSeconds: state.durationSeconds);

    // Lưu kết quả theo từng Mode & Kích hoạt GPGS Milestones
    if (state.mode == GameMode.campaign) {
      final levelNum = int.tryParse(state.levelId) ?? 1;
      _storage.saveLevelResult(levelNum, stars, score);

      // 1. Campaign Progression Milestones
      _gpgs.unlockAchievement(GpgsAchievementIds.achFirstClear);
      if (levelNum >= 10) _gpgs.unlockAchievement(GpgsAchievementIds.achSector10);
      if (levelNum >= 25) _gpgs.unlockAchievement(GpgsAchievementIds.achSector25);
      if (levelNum >= 50) _gpgs.unlockAchievement(GpgsAchievementIds.achSector50);
      if (levelNum >= 75) _gpgs.unlockAchievement(GpgsAchievementIds.achSector75);
      if (levelNum >= 100) _gpgs.unlockAchievement(GpgsAchievementIds.achSector100);

      // 2. Stars Collection Milestones
      final totalStars = _storage.totalCampaignStars;
      if (totalStars >= 10) _gpgs.unlockAchievement(GpgsAchievementIds.achStars10);
      if (totalStars >= 50) _gpgs.unlockAchievement(GpgsAchievementIds.achStars50);
      if (totalStars >= 100) _gpgs.unlockAchievement(GpgsAchievementIds.achStars100);
      if (totalStars >= 200) _gpgs.unlockAchievement(GpgsAchievementIds.achStars200);
      if (totalStars >= 300) _gpgs.unlockAchievement(GpgsAchievementIds.achStars300);

      if (stars == 3) {
        _gpgs.unlockAchievement(GpgsAchievementIds.achPerfectionist20);
      }
      if (!_usedHintInThisLevel && levelNum >= 50) {
        _gpgs.unlockAchievement(GpgsAchievementIds.achNoHintRun);
      }
    }

    // Nộp kết quả lên Supabase nếu có mạng
    final ghostReplay = _recorder?.finishRecording(
      levelId: state.levelId,
      totalScore: score,
    ).toJson();

    _supabase.submitScore(
      mode: state.mode.name,
      levelId: state.levelId,
      score: score,
      moves: state.movesCount,
      durationSeconds: state.durationSeconds,
      stars: stars,
      comboMultiplier: state.maxComboMultiplier,
      ghostReplay: ghostReplay,
    );

    // Cập nhật điểm chung cuộc vào state để hiển thị trên HUD và popup
    state = state.copyWith(currentScore: score);

    // Hiển thị Interstitial Ad nếu thỏa điều kiện throttle
    _ads.showInterstitialIfAllowed();
  }

  void undo() {
    if (state.undoStack.isEmpty || state.isWon) return;

    final newStack = List<UndoSnapshot>.from(state.undoStack);
    final snapshot = newStack.removeLast();

    _haptic.tap();
    _audio.playUndo();
    state = state.copyWith(
      board: snapshot.board,
      movesCount: snapshot.movesCount,
      currentCombo: snapshot.currentCombo,
      totalComboZeros: snapshot.totalComboZeros,
      remainingOptimalSolution: snapshot.remainingSolution,
      lastTappedMove: snapshot.lastTappedMove,
      clearLastTappedMove: snapshot.lastTappedMove == null,
      undoStack: newStack,
      clearHint: true,
      currentScore: snapshot.currentScore,
      endlessScore: snapshot.endlessScore,
      endlessMovesLeft: snapshot.endlessMovesLeft,
    );
  }

  bool requestHint() {
    if (state.isWon || state.isGameOver || state.board.isCleared()) return false;

    final nextMove = PuzzleSolver.findNextMove(
      state.board,
      remainingOptimalSolution: state.remainingOptimalSolution,
      lastTappedMove: state.lastTappedMove,
    );
    if (nextMove == null) return false;

    // Sử dụng 1 gợi ý
    final used = _storage.useHint();
    if (!used) return false;

    _usedHintInThisLevel = true;
    state = state.copyWith(activeHint: (nextMove.row, nextMove.col));
    _haptic.tap();
    _audio.playHint();
    return true;
  }

  void doubleScoreWithReward() {
    if (!state.isWon || state.isScoreDoubled) return;

    final originalScore = state.currentScore > 0
        ? state.currentScore
        : ScoreCalculator.calculateScore(
            actualMoves: state.movesCount,
            minMoves: state.minMoves,
            durationSeconds: state.durationSeconds,
            totalComboZeros: state.totalComboZeros,
            maxComboMultiplier: state.maxComboMultiplier,
          );

    final doubled = originalScore * 2;
    state = state.copyWith(
      isScoreDoubled: true,
      customScore: doubled,
      currentScore: doubled,
    );

    // Cập nhật điểm đã nhân đôi vào storage nếu là campaign
    if (state.mode == GameMode.campaign) {
      final levelNum = int.tryParse(state.levelId) ?? 1;
      final stars = ScoreCalculator.calculateStars(
        actualMoves: state.movesCount,
        minMoves: state.minMoves,
      );
      _storage.saveLevelResult(levelNum, stars, doubled);
    }
  }

  void restart() {
    if (state.mode == GameMode.endless) {
      startEndlessRun();
      return;
    }

    _timer?.cancel();
    _recorder = ReplayRecorder(initialState: state.initialBoard);
    _recorder?.start();

    state = state.copyWith(
      board: state.initialBoard,
      movesCount: 0,
      isWon: false,
      durationSeconds: 0,
      currentCombo: 0,
      totalComboZeros: 0,
      remainingOptimalSolution: List<(int, int)>.from(state.optimalSolution),
      clearLastTappedMove: true,
      undoStack: [],
      clearHint: true,
      currentScore: 0,
      isScoreDoubled: false,
      customScore: null,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isWon) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
