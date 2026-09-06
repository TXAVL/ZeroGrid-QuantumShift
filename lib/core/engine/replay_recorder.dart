import 'board_state.dart';

/// Một bước đi được ghi nhận trong lịch sử Replay
class ReplayStep {
  final int row;
  final int col;
  final int timestampMs; // Thời gian kể từ lúc bắt đầu ván đấu

  const ReplayStep({
    required this.row,
    required this.col,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'timestampMs': timestampMs,
      };

  factory ReplayStep.fromJson(Map<String, dynamic> json) => ReplayStep(
        row: json['row'] as int,
        col: json['col'] as int,
        timestampMs: json['timestampMs'] as int,
      );
}

/// Dữ liệu toàn vẹn của một lượt Replay (Ghost Replay)
class GhostReplayData {
  final String levelId;
  final int boardSize;
  final int maxK;
  final List<List<int>> initialGrid;
  final List<ReplayStep> steps;
  final int totalTimeMs;
  final int totalScore;

  const GhostReplayData({
    required this.levelId,
    required this.boardSize,
    required this.maxK,
    required this.initialGrid,
    required this.steps,
    required this.totalTimeMs,
    required this.totalScore,
  });

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'boardSize': boardSize,
        'maxK': maxK,
        'initialGrid': initialGrid,
        'steps': steps.map((s) => s.toJson()).toList(),
        'totalTimeMs': totalTimeMs,
        'totalScore': totalScore,
      };

  factory GhostReplayData.fromJson(Map<String, dynamic> json) =>
      GhostReplayData(
        levelId: json['levelId'] as String,
        boardSize: json['boardSize'] as int,
        maxK: json['maxK'] as int,
        initialGrid: (json['initialGrid'] as List)
            .map((row) => (row as List).map((v) => v as int).toList())
            .toList(),
        steps: (json['steps'] as List)
            .map((s) => ReplayStep.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
        totalTimeMs: json['totalTimeMs'] as int,
        totalScore: json['totalScore'] as int,
      );
}

/// Bộ ghi và tái hiện chuỗi nước đi
class ReplayRecorder {
  final BoardState initialState;
  final List<ReplayStep> _steps = [];
  final Stopwatch _stopwatch = Stopwatch();

  ReplayRecorder({required this.initialState});

  void start() {
    _steps.clear();
    _stopwatch.reset();
    _stopwatch.start();
  }

  void recordMove(int row, int col) {
    _steps.add(ReplayStep(
      row: row,
      col: col,
      timestampMs: _stopwatch.elapsedMilliseconds,
    ));
  }

  GhostReplayData finishRecording({
    required String levelId,
    required int totalScore,
  }) {
    _stopwatch.stop();
    return GhostReplayData(
      levelId: levelId,
      boardSize: initialState.size,
      maxK: initialState.maxK,
      initialGrid: initialState.grid,
      steps: List.unmodifiable(_steps),
      totalTimeMs: _stopwatch.elapsedMilliseconds,
      totalScore: totalScore,
    );
  }
}
