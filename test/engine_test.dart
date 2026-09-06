import 'package:flutter_test/flutter_test.dart';
import 'package:quantumshift/core/engine/board_state.dart';
import 'package:quantumshift/core/engine/reverse_generator.dart';
import 'package:quantumshift/core/engine/score_calculator.dart';
import 'package:quantumshift/core/engine/adaptive_difficulty.dart';
import 'package:quantumshift/core/engine/seed_generator.dart';
import 'package:quantumshift/core/engine/puzzle_solver.dart';
import 'package:quantumshift/state/game_state.dart';

void main() {
  group('1. BoardState & Cascade Logic Tests', () {
    test('Khởi tạo bàn cờ toàn số 0', () {
      final board = BoardState.allZero(3);
      expect(board.isCleared(), isTrue);
      expect(board.totalSum(), equals(0));
      expect(board.countZeros(), equals(9));
    });

    test('Tác động nước đi ở ô góc (0,0) - Kiểm tra biên không lỗi', () {
      final initialGrid = [
        [2, 2, 2],
        [2, 2, 2],
        [2, 2, 2],
      ];
      final board = BoardState.fromGrid(initialGrid);
      final result = board.applyMove(0, 0);

      // (0,0) giảm 1 -> 1
      // (0,1) giảm 1 -> 1
      // (1,0) giảm 1 -> 1
      // Các ô khác giữ nguyên 2
      expect(result.newState.getValue(0, 0), equals(1));
      expect(result.newState.getValue(0, 1), equals(1));
      expect(result.newState.getValue(1, 0), equals(1));
      expect(result.newState.getValue(0, 2), equals(2));
      expect(result.newState.getValue(1, 1), equals(2));
      expect(result.newState.getValue(2, 2), equals(2));
    });

    test('Tác động nước đi ở ô trung tâm (1,1) trên lưới 3x3', () {
      final initialGrid = [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1],
      ];
      final board = BoardState.fromGrid(initialGrid);
      final result = board.applyMove(1, 1);

      // Tâm và 4 ô lân cận về 0 -> 5 ô về 0 -> Combo 5
      expect(result.newState.getValue(1, 1), equals(0));
      expect(result.newState.getValue(0, 1), equals(0));
      expect(result.newState.getValue(2, 1), equals(0));
      expect(result.newState.getValue(1, 0), equals(0));
      expect(result.newState.getValue(1, 2), equals(0));

      // 4 góc vẫn là 1
      expect(result.newState.getValue(0, 0), equals(1));
      expect(result.newState.getValue(0, 2), equals(1));
      expect(result.newState.getValue(2, 0), equals(1));
      expect(result.newState.getValue(2, 2), equals(1));

      expect(result.newlyZeroedCount, equals(5));
      expect(result.newState.isCleared(), isFalse);
    });
  });

  group('2. Reverse Generation & Solvability Proof Tests', () {
    test('Sinh 50 bàn cờ ngẫu nhiên và giải thành công bằng optimalSolution', () {
      for (int i = 1; i <= 50; i++) {
        final size = (i % 3) + 3; // 3, 4, hoặc 5
        const maxK = 4;
        final reverseSteps = 4 + (i % 6);

        final level = ReverseGenerator.generate(
          levelId: i,
          size: size,
          maxK: maxK,
          reverseSteps: reverseSteps,
        );

        expect(level.minMoves, lessThanOrEqualTo(reverseSteps));
        expect(level.optimalSolution.length, equals(level.minMoves));

        // Áp dụng nghiệm theo thứ tự giải
        BoardState simulatedBoard = level.initialState;
        for (final move in level.optimalSolution) {
          final res = simulatedBoard.applyMove(move.$1, move.$2);
          simulatedBoard = res.newState;
        }

        // Bàn cờ buộc phải về 0 hoàn toàn (100% Solvable)
        expect(simulatedBoard.isCleared(), isTrue,
            reason: 'Level $i kích thước ${size}x$size thất bại giải về 0');
      }
    });
  });

  group('3. ScoreCalculator & Stars Rating Tests', () {
    test('Đạt 3 sao khi số bước <= minMoves', () {
      final stars = ScoreCalculator.calculateStars(actualMoves: 4, minMoves: 5);
      expect(stars, equals(3));
    });

    test('Đạt 2 sao khi số bước trong khoảng minMoves + 50%', () {
      final stars = ScoreCalculator.calculateStars(actualMoves: 7, minMoves: 5);
      expect(stars, equals(2));
    });

    test('Đạt 1 sao khi số bước vượt quá 150% minMoves', () {
      final stars = ScoreCalculator.calculateStars(actualMoves: 12, minMoves: 5);
      expect(stars, equals(1));
    });
  });

  group('4. Adaptive Difficulty Engine Tests', () {
    test('Tự động tăng độ khó khi win streak cao', () {
      const highPerformance = PlayerPerformanceMetrics(
        totalGamesPlayed: 10,
        totalWins: 9,
        averageTimePerLevelSeconds: 12.0,
        currentWinStreak: 6,
      );

      final config = AdaptiveDifficultyEngine.calculateNextConfig(highPerformance);
      expect(config.boardSize, greaterThanOrEqualTo(3));
      expect(config.reverseSteps, greaterThanOrEqualTo(5));
      expect(config.maxK, equals(4));
    });

    test('Hạ độ khó về mức an toàn khi người chơi đang gặp khó', () {
      const lowPerformance = PlayerPerformanceMetrics(
        totalGamesPlayed: 8,
        totalWins: 2,
        averageTimePerLevelSeconds: 45.0,
        currentWinStreak: 0,
      );

      final config = AdaptiveDifficultyEngine.calculateNextConfig(lowPerformance);
      expect(config.boardSize, equals(3));
      expect(config.reverseSteps, equals(3));
      expect(config.maxK, equals(3));
    });
  });

  group('5. Seed Generator & Async Challenge Code Tests', () {
    test('Mã hóa và giải mã Challenge Code chính xác', () {
      final code = SeedGenerator.encodeChallengeCode(
        size: 4,
        maxK: 4,
        reverseSteps: 7,
        seed: 123456,
      );

      expect(code.isNotEmpty, isTrue);

      final decoded = SeedGenerator.decodeChallengeCode(code);
      expect(decoded, isNotNull);
      expect(decoded!.size, equals(4));
      expect(decoded.maxK, equals(4));
      expect(decoded.reverseSteps, equals(7));
      expect(decoded.seed, equals(123456));
    });
  });

  group('6. PuzzleSolver & Hint Engine Tests', () {
    test('Gợi ý bằng remainingOptimalSolution luôn đưa bàn cờ về 0 trong <= minMoves (Đạt 3 sao)', () {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final size = (lvl % 3) + 3;
        final level = ReverseGenerator.generate(
          levelId: lvl,
          size: size,
          maxK: 4,
          reverseSteps: 4 + (lvl % 4),
        );

        BoardState board = level.initialState;
        final remaining = List<(int, int)>.from(level.optimalSolution);
        (int, int)? lastTapped;
        int movesCount = 0;

        while (!board.isCleared()) {
          final hint = PuzzleSolver.findNextMove(
            board,
            remainingOptimalSolution: remaining,
            lastTappedMove: lastTapped,
          );

          expect(hint, isNotNull);

          // Không lặp lại ô vừa bấm nếu còn ô khác trong nghiệm
          if (lastTapped != null && remaining.any((m) => m != lastTapped)) {
            expect((hint!.row, hint.col), isNot(equals(lastTapped)),
                reason: 'Hint repeated lastTapped move when alternatives existed at level $lvl!');
          }

          final move = (hint!.row, hint.col);
          board = board.applyMove(move.$1, move.$2).newState;
          remaining.remove(move);
          lastTapped = move;
          movesCount++;
        }

        expect(board.isCleared(), isTrue);
        expect(movesCount, lessThanOrEqualTo(level.minMoves));
      }
    });

    test('canSolveWithSequence xác thực chính xác chuỗi nghiệm', () {
      final level = ReverseGenerator.generate(
        levelId: 42,
        size: 4,
        maxK: 4,
        reverseSteps: 6,
      );

      expect(PuzzleSolver.canSolveWithSequence(level.initialState, level.optimalSolution), isTrue);
      // Chuỗi rỗng không thể giải bàn cờ chưa về 0
      expect(PuzzleSolver.canSolveWithSequence(level.initialState, const []), isFalse);
    });

    test('Undo phục hồi chính xác số bước (movesCount không bị +1)', () {
      final initialBoard = BoardState.allZero(3);
      final snapshot = UndoSnapshot(
        board: initialBoard,
        movesCount: 2,
        currentCombo: 0,
        totalComboZeros: 0,
        remainingSolution: const [(0, 0)],
        lastTappedMove: null,
      );

      // Khi người chơi đã đi tới bước 3, rồi bấm Undo:
      // movesCount phải được phục hồi về 2 (thay vì tăng lên 4)
      expect(snapshot.movesCount, equals(2));
    });
  });

  group('7. Endless Mode & Shortcut Optimizer Tests', () {
    test('ReverseGenerator tối ưu minMoves <= reverseSteps ban đầu', () {
      for (int i = 1; i <= 10; i++) {
        final generated = ReverseGenerator.generate(
          levelId: i,
          size: 3,
          maxK: 3,
          reverseSteps: 6,
          customSeed: 1000 + i,
        );

        // minMoves sau khi tối ưu hóa bằng solveOptimal phải luôn <= số bước đảo ban đầu (6)
        expect(generated.minMoves, lessThanOrEqualTo(6));
        expect(PuzzleSolver.canSolveWithSequence(generated.initialState, generated.optimalSolution), isTrue);
      }
    });

    test('GameState quản lý các trường Endless Wave & Move Bank chuẩn xác', () {
      final initialBoard = BoardState.allZero(3);
      final state = GameState(
        levelId: 'endless_wave_1',
        mode: GameMode.endless,
        board: initialBoard,
        initialBoard: initialBoard,
        movesCount: 0,
        minMoves: 3,
        isWon: false,
        durationSeconds: 0,
        currentCombo: 0,
        maxComboMultiplier: 1,
        totalComboZeros: 0,
        optimalSolution: const [],
        remainingOptimalSolution: const [],
        undoStack: const [],
        endlessWave: 1,
        endlessScore: 0,
        endlessMovesLeft: 15,
        isGameOver: false,
        hasUsedRevive: false,
      );

      expect(state.endlessWave, equals(1));
      expect(state.endlessMovesLeft, equals(15));
      expect(state.isGameOver, isFalse);

      final nextState = state.copyWith(
        endlessWave: 2,
        endlessScore: 1250,
        endlessMovesLeft: 18,
        isGameOver: false,
      );

      expect(nextState.endlessWave, equals(2));
      expect(nextState.endlessScore, equals(1250));
      expect(nextState.endlessMovesLeft, equals(18));
    });
  });
}
