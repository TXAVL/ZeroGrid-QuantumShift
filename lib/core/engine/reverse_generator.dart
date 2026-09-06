import 'dart:math';
import 'board_state.dart';
import 'puzzle_solver.dart';

/// Dữ liệu màn chơi được sinh ra qua thuật toán Reverse Generation
class GeneratedLevel {
  final int levelId;
  final String seed;
  final BoardState initialState;
  final int minMoves; // Số bước tối thiểu được đảm bảo
  final List<(int, int)> optimalSolution; // Chuỗi nước đi giải bàn cờ

  const GeneratedLevel({
    required this.levelId,
    required this.seed,
    required this.initialState,
    required this.minMoves,
    required this.optimalSolution,
  });
}

/// Bộ sinh màn chơi bằng phương pháp nghịch đảo (Reverse Generation)
/// Đảm bảo 100% bàn cờ sinh ra luôn giải được trong <= M bước
class ReverseGenerator {
  /// Sinh một màn chơi với seed cố định hoặc ngẫu nhiên
  static GeneratedLevel generate({
    required int levelId,
    required int size,
    required int maxK,
    required int reverseSteps, // M
    int? customSeed,
  }) {
    final seedValue = customSeed ?? (levelId * 10007 + reverseSteps * 31);
    final random = Random(seedValue);

    BoardState currentState = BoardState.allZero(size, maxK: maxK);
    final List<(int, int)> appliedMoves = [];

    int consecutiveSameCount = 0;
    (int, int)? lastMove;

    int attempts = 0;
    while (appliedMoves.length < reverseSteps && attempts < reverseSteps * 4) {
      attempts++;
      final r = random.nextInt(size);
      final c = random.nextInt(size);
      final move = (r, c);

      // Phòng tránh triệt tiêu: Không nhấn cùng 1 ô (maxK + 1) lần liên tiếp
      if (lastMove == move) {
        consecutiveSameCount++;
        if (consecutiveSameCount >= maxK + 1) {
          continue; // Bỏ qua nước đi triệt tiêu hoàn toàn
        }
      } else {
        consecutiveSameCount = 1;
        lastMove = move;
      }

      currentState = currentState.applyInverseMove(r, c);
      appliedMoves.add(move);
    }

    // Nếu bàn cờ sau khi sinh lại rơi vào trạng thái toàn 0 (rất hiếm), thực hiện ít nhất 1 nước nghịch đảo
    if (currentState.isCleared()) {
      final r = random.nextInt(size);
      final c = random.nextInt(size);
      currentState = currentState.applyInverseMove(r, c);
      appliedMoves.add((r, c));
    }

    // Nghiệm ban đầu theo chiều ngược lại
    var finalSolution = List<(int, int)>.from(appliedMoves.reversed);

    // Tối ưu hóa nghiệm: Chạy solver tìm xem có lối tắt ngắn hơn không
    final solved = PuzzleSolver.solveOptimal(
      currentState,
      maxDepthLimit: appliedMoves.length,
      maxNodes: 12000,
    );
    if (solved != null && solved.isNotEmpty && solved.length < finalSolution.length) {
      finalSolution = solved.map((m) => (m.row, m.col)).toList();
    }

    return GeneratedLevel(
      levelId: levelId,
      seed: "lvl_${levelId}_${size}x${size}_s$seedValue",
      initialState: currentState,
      minMoves: finalSolution.length,
      optimalSolution: finalSolution,
    );
  }
}
