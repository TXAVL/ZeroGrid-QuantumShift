import 'package:flutter/foundation.dart';
import '../core/engine/board_state.dart';

enum GameMode {
  campaign,
  dailyChallenge,
  endless,
  customChallenge,
}

/// Lưu vết một bước đi để hoàn tác (Undo) hoàn hảo
@immutable
class UndoSnapshot {
  final BoardState board;
  final int movesCount;
  final int currentCombo;
  final int totalComboZeros;
  final List<(int, int)> remainingSolution;
  final (int, int)? lastTappedMove;
  final int currentScore;
  final int endlessScore;
  final int endlessMovesLeft;

  const UndoSnapshot({
    required this.board,
    required this.movesCount,
    required this.currentCombo,
    required this.totalComboZeros,
    required this.remainingSolution,
    this.lastTappedMove,
    this.currentScore = 0,
    this.endlessScore = 0,
    this.endlessMovesLeft = 15,
  });
}

@immutable
class GameState {
  final String levelId;
  final GameMode mode;
  final BoardState board;
  final BoardState initialBoard;
  final int movesCount;
  final int minMoves;
  final bool isWon;
  final int durationSeconds;
  final int currentCombo;
  final int maxComboMultiplier;
  final int totalComboZeros;
  final (int, int)? activeHint;
  final List<(int, int)> optimalSolution;
  final List<(int, int)> remainingOptimalSolution;
  final (int, int)? lastTappedMove;
  final List<UndoSnapshot> undoStack;
  final bool isScoreDoubled;
  final int? customScore;
  final int currentScore;
  final int endlessWave;
  final int endlessScore;
  final int endlessMovesLeft;
  final bool isGameOver;
  final bool hasUsedRevive;

  const GameState({
    required this.levelId,
    required this.mode,
    required this.board,
    required this.initialBoard,
    required this.movesCount,
    required this.minMoves,
    required this.isWon,
    required this.durationSeconds,
    required this.currentCombo,
    required this.maxComboMultiplier,
    required this.totalComboZeros,
    this.activeHint,
    required this.optimalSolution,
    required this.remainingOptimalSolution,
    this.lastTappedMove,
    required this.undoStack,
    this.isScoreDoubled = false,
    this.customScore,
    this.currentScore = 0,
    this.endlessWave = 1,
    this.endlessScore = 0,
    this.endlessMovesLeft = 15,
    this.isGameOver = false,
    this.hasUsedRevive = false,
  });

  GameState copyWith({
    String? levelId,
    GameMode? mode,
    BoardState? board,
    BoardState? initialBoard,
    int? movesCount,
    int? minMoves,
    bool? isWon,
    int? durationSeconds,
    int? currentCombo,
    int? maxComboMultiplier,
    int? totalComboZeros,
    (int, int)? activeHint,
    bool clearHint = false,
    List<(int, int)>? optimalSolution,
    List<(int, int)>? remainingOptimalSolution,
    (int, int)? lastTappedMove,
    bool clearLastTappedMove = false,
    List<UndoSnapshot>? undoStack,
    bool? isScoreDoubled,
    int? customScore,
    int? currentScore,
    int? endlessWave,
    int? endlessScore,
    int? endlessMovesLeft,
    bool? isGameOver,
    bool? hasUsedRevive,
  }) {
    return GameState(
      levelId: levelId ?? this.levelId,
      mode: mode ?? this.mode,
      board: board ?? this.board,
      initialBoard: initialBoard ?? this.initialBoard,
      movesCount: movesCount ?? this.movesCount,
      minMoves: minMoves ?? this.minMoves,
      isWon: isWon ?? this.isWon,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      currentCombo: currentCombo ?? this.currentCombo,
      maxComboMultiplier: maxComboMultiplier ?? this.maxComboMultiplier,
      totalComboZeros: totalComboZeros ?? this.totalComboZeros,
      activeHint: clearHint ? null : (activeHint ?? this.activeHint),
      optimalSolution: optimalSolution ?? this.optimalSolution,
      remainingOptimalSolution: remainingOptimalSolution ?? this.remainingOptimalSolution,
      lastTappedMove: clearLastTappedMove ? null : (lastTappedMove ?? this.lastTappedMove),
      undoStack: undoStack ?? this.undoStack,
      isScoreDoubled: isScoreDoubled ?? this.isScoreDoubled,
      customScore: customScore ?? this.customScore,
      currentScore: currentScore ?? this.currentScore,
      endlessWave: endlessWave ?? this.endlessWave,
      endlessScore: endlessScore ?? this.endlessScore,
      endlessMovesLeft: endlessMovesLeft ?? this.endlessMovesLeft,
      isGameOver: isGameOver ?? this.isGameOver,
      hasUsedRevive: hasUsedRevive ?? this.hasUsedRevive,
    );
  }
}
