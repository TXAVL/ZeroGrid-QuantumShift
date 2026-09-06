import 'dart:math';
import 'board_state.dart';

/// Lớp giải ma trận động thời gian thực tối ưu (A* / IDA* Optimal Puzzle Solver)
/// Tìm chuỗi nước đi ngắn nhất để xóa sạch toàn bộ bàn cờ về 0.
class PuzzleSolver {
  /// Kiểm tra xem chuỗi nước đi có giải quyết được bàn cờ hay không
  static bool canSolveWithSequence(BoardState current, List<(int, int)> sequence) {
    BoardState b = current;
    for (final m in sequence) {
      b = b.applyMove(m.$1, m.$2).newState;
    }
    return b.isCleared();
  }

  /// Tìm nước đi tối ưu tiếp theo (r, c) từ trạng thái bàn cờ hiện tại
  /// [remainingOptimalSolution]: Nghiệm tối ưu còn lại của màn chơi từ bộ sinh màn
  /// [lastTappedMove]: Nước đi người chơi vừa nhấn ở bước trước (để tránh lặp lại nước đã đi)
  /// Tìm nước đi tối ưu tiếp theo (r, c) từ trạng thái bàn cờ hiện tại
  /// Ưu tiên tìm đường đi ngắn nhất tuyệt đối để đảm bảo người chơi đi ít bước nhất có thể
  static ({int row, int col})? findNextMove(
    BoardState currentBoard, {
    List<(int, int)>? remainingOptimalSolution,
    (int, int)? lastTappedMove,
  }) {
    if (currentBoard.isCleared()) return null;

    // 1. Kiểm tra nghiệm còn lại từ bộ sinh màn
    final hasValidRemaining = remainingOptimalSolution != null &&
        remainingOptimalSolution.isNotEmpty &&
        canSolveWithSequence(currentBoard, remainingOptimalSolution);

    // 2. Nếu không có nghiệm hợp lệ từ trước: Tìm đường đi ngắn nhất bằng solver
    if (!hasValidRemaining) {
      final directOptimal = solveOptimal(currentBoard, maxDepthLimit: 12);
      if (directOptimal != null && directOptimal.isNotEmpty) {
        final otherMoves = directOptimal
            .where((m) => lastTappedMove == null || (m.row, m.col) != lastTappedMove)
            .toList();
        return otherMoves.isNotEmpty ? otherMoves.first : directOptimal.first;
      }
      return _smartFallback(currentBoard, lastTappedMove);
    }

    // 3. Đã có remainingOptimalSolution hợp lệ:
    // Kiểm tra xem có đường tắt STRICTLY SHORTER hơn không (độ sâu < remaining.length)
    if (remainingOptimalSolution.length > 1) {
      final shortcut = solveOptimal(currentBoard, maxDepthLimit: remainingOptimalSolution.length - 1);
      if (shortcut != null && shortcut.isNotEmpty && shortcut.length < remainingOptimalSolution.length) {
        final otherMoves = shortcut
            .where((m) => lastTappedMove == null || (m.row, m.col) != lastTappedMove)
            .toList();
        return otherMoves.isNotEmpty ? otherMoves.first : shortcut.first;
      }
    }

    // 4. Chọn nước đi tối ưu nhất trong remainingOptimalSolution (ưu tiên khác lastTappedMove)
    final otherMoves = remainingOptimalSolution
        .where((m) => lastTappedMove == null || m != lastTappedMove)
        .toList();
    final candidates = otherMoves.isNotEmpty ? otherMoves : remainingOptimalSolution;

    (int, int)? bestCandidate;
    int bestScore = -999999;
    for (final m in candidates) {
      final res = currentBoard.applyMove(m.$1, m.$2);
      final reduction = currentBoard.totalSum() - res.newState.totalSum();
      final score = (res.newlyZeroedCount * 30) + reduction;
      if (score > bestScore) {
        bestScore = score;
        bestCandidate = m;
      }
    }

    if (bestCandidate != null) {
      return (row: bestCandidate.$1, col: bestCandidate.$2);
    }

    return _smartFallback(currentBoard, lastTappedMove);
  }

  /// Tìm đường đi ngắn nhất tuyệt đối đến trạng thái toàn 0
  /// Kết hợp BFS cho độ sâu nông (<= 4 bước) và IDA* cho độ sâu lớn hơn
  static List<({int row, int col})>? solveOptimal(
    BoardState startBoard, {
    int maxDepthLimit = 15,
    int maxNodes = 25000,
  }) {
    if (startBoard.isCleared()) return [];

    // Ưu tiên chạy BFS siêu tốc nếu bàn cờ <= 4x4 và độ sâu ước tính <= 4
    if (startBoard.size <= 4 && _heuristic(startBoard) <= 4) {
      final bfsRes = _bfsSolve(startBoard, min(4, maxDepthLimit));
      if (bfsRes != null) return bfsRes;
    }

    int threshold = _heuristic(startBoard);
    final nodeCount = [0];

    while (threshold <= maxDepthLimit) {
      final visited = <String, int>{};
      final path = <({int row, int col})>[];
      final res = _idaStarSearch(startBoard, 0, threshold, path, visited, nodeCount, maxNodes);
      if (res.solved) {
        return path;
      }
      if (res.nextThreshold == 999999 || res.nextThreshold > maxDepthLimit || nodeCount[0] >= maxNodes) {
        break;
      }
      threshold = res.nextThreshold;
    }

    return null;
  }

  /// Thuật toán BFS tối ưu bằng con trỏ chỉ số O(1) để tìm đường đi ngắn nhất tuyệt đối
  static List<({int row, int col})>? _bfsSolve(BoardState start, int maxDepth) {
    if (start.isCleared()) return [];
    final queue = <({BoardState board, List<({int row, int col})> path})>[
      (board: start, path: <({int row, int col})>[]),
    ];
    final visited = <String>{_boardKey(start)};

    int head = 0;
    while (head < queue.length) {
      final current = queue[head++];
      if (current.path.length >= maxDepth) continue;

      final size = current.board.size;
      for (int r = 0; r < size; r++) {
        for (int c = 0; c < size; c++) {
          if (_calculateSumReduction(current.board, r, c) <= 0) continue;
          final nextBoard = current.board.applyMove(r, c).newState;
          final nextPath = [...current.path, (row: r, col: c)];
          if (nextBoard.isCleared()) {
            return nextPath;
          }
          final key = _boardKey(nextBoard);
          if (visited.add(key)) {
            queue.add((board: nextBoard, path: nextPath));
          }
        }
      }
    }
    return null;
  }

  static ({bool solved, int nextThreshold}) _idaStarSearch(
    BoardState current,
    int g,
    int threshold,
    List<({int row, int col})> path,
    Map<String, int> visited,
    List<int> nodeCount,
    int maxNodes,
  ) {
    nodeCount[0]++;
    if (nodeCount[0] >= maxNodes) {
      return (solved: false, nextThreshold: 999999);
    }

    final h = _heuristic(current);
    final f = g + h;
    if (f > threshold) return (solved: false, nextThreshold: f);
    if (current.isCleared()) return (solved: true, nextThreshold: f);

    final key = _boardKey(current);
    if (visited.containsKey(key) && visited[key]! <= g) {
      return (solved: false, nextThreshold: 999999);
    }
    visited[key] = g;

    int minNextThreshold = 999999;
    final size = current.size;

    // Sắp xếp các nước đi tiềm năng theo mức độ giảm điểm nhiều nhất
    final candidateMoves = <({int r, int c, int sumReduction})>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final sumReduction = _calculateSumReduction(current, r, c);
        if (sumReduction > 0) {
          candidateMoves.add((r: r, c: c, sumReduction: sumReduction));
        }
      }
    }

    candidateMoves.sort((a, b) => b.sumReduction.compareTo(a.sumReduction));

    for (final move in candidateMoves) {
      final nextState = current.applyMove(move.r, move.c).newState;
      path.add((row: move.r, col: move.c));

      final res = _idaStarSearch(nextState, g + 1, threshold, path, visited, nodeCount, maxNodes);
      if (res.solved) return res;

      path.removeLast();
      if (res.nextThreshold < minNextThreshold) {
        minNextThreshold = res.nextThreshold;
      }
    }

    return (solved: false, nextThreshold: minNextThreshold);
  }

  /// Hàm Heuristic Admissible:
  /// 1. Số bước tối thiểu = ceil(tổng điểm / 5) (mỗi nước tối đa giảm 5 điểm)
  /// 2. Giá trị lớn nhất của 1 ô đơn lẻ (ô có giá trị V cần ít nhất V lần tác động)
  static int _heuristic(BoardState b) {
    int maxVal = 0;
    int sum = 0;
    for (int r = 0; r < b.size; r++) {
      for (int c = 0; c < b.size; c++) {
        final val = b.grid[r][c];
        if (val > maxVal) maxVal = val;
        sum += val;
      }
    }
    final minMovesBySum = (sum / 5).ceil();
    return max(maxVal, minMovesBySum);
  }

  static int _calculateSumReduction(BoardState b, int r, int c) {
    int reduction = 0;
    final coords = [(r, c), (r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)];
    for (final coord in coords) {
      final cr = coord.$1;
      final cc = coord.$2;
      if (cr >= 0 && cr < b.size && cc >= 0 && cc < b.size) {
        if (b.grid[cr][cc] > 0) reduction++;
      }
    }
    return reduction;
  }

  static ({int row, int col}) _smartFallback(BoardState currentBoard, (int, int)? lastTappedMove) {
    final size = currentBoard.size;
    ({int row, int col})? bestMove;
    int bestScore = -999999;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final isSameAsLast = lastTappedMove != null && lastTappedMove.$1 == r && lastTappedMove.$2 == c;

        final result = currentBoard.applyMove(r, c);
        final newlyZeroed = result.newlyZeroedCount;
        final reduction = currentBoard.totalSum() - result.newState.totalSum();

        // Không bao giờ gợi ý ô không làm giảm bất kỳ số nào trên bàn cờ
        if (reduction <= 0 && newlyZeroed <= 0) continue;

        int score = (newlyZeroed * 40) + (reduction * 10);
        if (isSameAsLast) {
          score -= 100; // Phạt nặng việc lặp lại ô vừa bấm
        }

        if (score > bestScore) {
          bestScore = score;
          bestMove = (row: r, col: c);
        }
      }
    }
    return bestMove ?? (row: 0, col: 0);
  }

  static String _boardKey(BoardState b) {
    return b.grid.map((row) => row.join(',')).join(';');
  }
}
