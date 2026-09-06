import 'dart:math';

/// Bộ tính điểm và xếp hạng sao chuyên sâu cho Zero Grid
class ScoreCalculator {
  /// Tính số sao đạt được (1 đến 3 sao) dựa trên số bước đi thực tế vs số bước tối thiểu
  static int calculateStars({
    required int actualMoves,
    required int minMoves,
  }) {
    if (actualMoves <= minMoves) {
      return 3; // Hoàn hảo (Perfect Clear)
    } else if (actualMoves <= minMoves + (minMoves * 0.5).ceil()) {
      return 2; // Rất tốt (Great Clear)
    } else {
      return 1; // Đã vượt qua (Cleared)
    }
  }

  /// Tính tổng điểm chung cuộc (Final Score)
  static int calculateScore({
    required int actualMoves,
    required int minMoves,
    required int durationSeconds,
    required int totalComboZeros,
    required int maxComboMultiplier,
  }) {
    const int baseClearScore = 1000;

    // Điểm thưởng hiệu quả nước đi
    final int moveBonus = max<int>(0, (minMoves * 2 - actualMoves)) * 120;

    // Điểm thưởng tốc độ (nhanh hơn 60s nhận thêm điểm)
    final int timeBonus = max<int>(0, (60 - durationSeconds)) * 25;

    // Điểm thưởng Combo
    final int comboBonus = totalComboZeros * 150 * max<int>(1, maxComboMultiplier);

    return baseClearScore + moveBonus + timeBonus + comboBonus;
  }
}
