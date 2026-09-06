import 'package:flutter/foundation.dart';

/// Đại diện cho trạng thái bất biến (Immutable) của bàn cờ Quantum Shift.
@immutable
class BoardState {
  final int size; // N x N (3x3, 4x4, 5x5)
  final int maxK; // Giá trị K tối đa (mặc định K = 4)
  final List<List<int>> grid;

  const BoardState({
    required this.size,
    required this.maxK,
    required this.grid,
  });

  /// Khởi tạo bàn cờ toàn số 0
  factory BoardState.allZero(int size, {int maxK = 4}) {
    return BoardState(
      size: size,
      maxK: maxK,
      grid: List.generate(size, (_) => List.filled(size, 0)),
    );
  }

  /// Khởi tạo từ danh sách 2D sẵn có
  factory BoardState.fromGrid(List<List<int>> grid, {int maxK = 4}) {
    final size = grid.length;
    final copy = List.generate(size, (r) => List<int>.from(grid[r]));
    return BoardState(size: size, maxK: maxK, grid: copy);
  }

  /// Lấy giá trị tại ô (r, c)
  int getValue(int r, int c) {
    if (r < 0 || r >= size || c < 0 || c >= size) return 0;
    return grid[r][c];
  }

  /// Kiểm tra xem toàn bộ bàn cờ đã về 0 (Win Condition) hay chưa
  bool isCleared() {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] != 0) return false;
      }
    }
    return true;
  }

  /// Đếm số ô đang có giá trị 0
  int countZeros() {
    int count = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) count++;
      }
    }
    return count;
  }

  /// Tổng giá trị hiện tại của toàn bộ bàn cờ
  int totalSum() {
    int sum = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        sum += grid[r][c];
      }
    }
    return sum;
  }

  /// Thực hiện 1 nước đi chạm vào ô (r, c).
  /// Quy tắc:
  /// 1. Ô (r, c) giảm 1: (v - 1) với clamp >= 0 hoặc mod (maxK + 1).
  /// 2. 4 ô lân cận Von Neumann (trên, dưới, trái, phải) giảm 1.
  /// Trả về MoveResult chứa BoardState mới và số lượng ô vừa chuyển về 0 (cho Combo).
  MoveResult applyMove(int r, int c) {
    final newGrid = List.generate(size, (row) => List<int>.from(grid[row]));
    int newlyZeroedCount = 0;

    // Danh sách tọa độ chịu tác động: chính ô đó + 4 ô lân cận
    final targetCoords = [
      (r, c),
      (r - 1, c), // Trên
      (r + 1, c), // Dưới
      (r, c - 1), // Trái
      (r, c + 1), // Phải
    ];

    for (final coord in targetCoords) {
      final cr = coord.$1;
      final cc = coord.$2;

      // Bỏ qua nếu ra ngoài biên
      if (cr < 0 || cr >= size || cc < 0 || cc >= size) continue;

      final oldValue = newGrid[cr][cc];
      if (oldValue > 0) {
        final newValue = oldValue - 1;
        newGrid[cr][cc] = newValue;
        if (newValue == 0) {
          newlyZeroedCount++;
        }
      }
    }

    final nextState = BoardState(size: size, maxK: maxK, grid: newGrid);
    return MoveResult(
      newState: nextState,
      newlyZeroedCount: newlyZeroedCount,
      tappedRow: r,
      tappedCol: c,
    );
  }

  /// Nước đi nghịch đảo (áp dụng trong Reverse Generation để sinh đề)
  /// Tăng ô (r, c) và 4 ô lân cận lên +1 (modulo maxK + 1)
  BoardState applyInverseMove(int r, int c) {
    final newGrid = List.generate(size, (row) => List<int>.from(grid[row]));
    final targetCoords = [
      (r, c),
      (r - 1, c),
      (r + 1, c),
      (r, c - 1),
      (r, c + 1),
    ];

    final modulo = maxK + 1;
    for (final coord in targetCoords) {
      final cr = coord.$1;
      final cc = coord.$2;
      if (cr < 0 || cr >= size || cc < 0 || cc >= size) continue;

      newGrid[cr][cc] = (newGrid[cr][cc] + 1) % modulo;
    }

    return BoardState(size: size, maxK: maxK, grid: newGrid);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardState || other.size != size || other.maxK != maxK) {
      return false;
    }
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] != other.grid[r][c]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(size, maxK, grid.toString());
}

/// Kết quả của một nước đi
class MoveResult {
  final BoardState newState;
  final int newlyZeroedCount; // Số ô vừa chạm mốc 0 (để tính Combo x2, x3, x5)
  final int tappedRow;
  final int tappedCol;

  const MoveResult({
    required this.newState,
    required this.newlyZeroedCount,
    required this.tappedRow,
    required this.tappedCol,
  });
}
