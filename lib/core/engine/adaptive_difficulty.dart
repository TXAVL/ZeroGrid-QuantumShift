import 'dart:math';

/// Dữ liệu thống kê để tính toán Adaptive Difficulty
class PlayerPerformanceMetrics {
  final int totalGamesPlayed;
  final int totalWins;
  final double averageTimePerLevelSeconds;
  final int currentWinStreak;

  const PlayerPerformanceMetrics({
    required this.totalGamesPlayed,
    required this.totalWins,
    required this.averageTimePerLevelSeconds,
    required this.currentWinStreak,
  });

  double get winRate =>
      totalGamesPlayed == 0 ? 0.5 : totalWins / totalGamesPlayed;
}

/// Cấu hình độ khó được điều chỉnh động
class AdaptiveDifficultyConfig {
  final int boardSize;
  final int reverseSteps; // Tham số M
  final int maxK; // Giá trị số lớn nhất
  final double targetTimeSeconds;

  const AdaptiveDifficultyConfig({
    required this.boardSize,
    required this.reverseSteps,
    required this.maxK,
    required this.targetTimeSeconds,
  });
}

/// Engine tính toán Adaptive Difficulty cho Endless Mode & Dynamic Challenges
class AdaptiveDifficultyEngine {
  /// Cân chỉnh độ khó tiếp theo dựa trên chỉ số thực chiến của người chơi
  static AdaptiveDifficultyConfig calculateNextConfig(
    PlayerPerformanceMetrics metrics,
  ) {
    final winRate = metrics.winRate;
    final streak = metrics.currentWinStreak;
    final avgTime = metrics.averageTimePerLevelSeconds;

    int size = 3;
    int maxK = 3;
    int reverseSteps = 3;
    double targetTime = 30.0;

    // Người chơi xuất sắc: Win streak cao (>3) hoặc Win rate > 75%
    if (streak >= 5 || (metrics.totalGamesPlayed >= 5 && winRate >= 0.8)) {
      if (streak >= 10 || avgTime < 15.0) {
        size = 4;
        maxK = 4;
        reverseSteps = min(12, 5 + (streak ~/ 2));
        targetTime = 45.0;
      } else {
        size = 3;
        maxK = 4;
        reverseSteps = min(8, 4 + streak);
        targetTime = 35.0;
      }
    } else if (metrics.totalGamesPlayed >= 3 && winRate < 0.4) {
      // Người chơi đang gặp khó: Giảm số bước đảo để khích lệ
      size = 3;
      maxK = 3;
      reverseSteps = 3;
      targetTime = 25.0;
    } else {
      // Mức độ tiêu chuẩn cân bằng
      size = 3;
      maxK = 4;
      reverseSteps = 4;
      targetTime = 30.0;
    }

    return AdaptiveDifficultyConfig(
      boardSize: size,
      reverseSteps: reverseSteps,
      maxK: maxK,
      targetTimeSeconds: targetTime,
    );
  }
}
