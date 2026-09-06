import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/service_providers.dart';
import '../../state/game_notifier.dart';
import '../../state/theme_notifier.dart';
import 'grid_cell_widget.dart';

/// Bàn cờ Quantum Shift N x N hỗ trợ cả Chạm (Tap) và Vuốt lướt ngón tay (Swipe/Drag)
class QuantumBoardWidget extends ConsumerStatefulWidget {
  const QuantumBoardWidget({super.key});

  @override
  ConsumerState<QuantumBoardWidget> createState() => _QuantumBoardWidgetState();
}

class _QuantumBoardWidgetState extends ConsumerState<QuantumBoardWidget> {
  int? _lastSwipedRow;
  int? _lastSwipedCol;

  void _handlePan(Offset localPosition, double boardDimension, int boardSize) {
    const padding = 12.0;
    final innerDimension = boardDimension - (padding * 2);
    if (innerDimension <= 0) return;

    final cellDimension = innerDimension / boardSize;
    final adjustedX = localPosition.dx - padding;
    final adjustedY = localPosition.dy - padding;

    if (adjustedX < 0 || adjustedX >= innerDimension || adjustedY < 0 || adjustedY >= innerDimension) {
      return;
    }

    final col = (adjustedX / cellDimension).floor().clamp(0, boardSize - 1);
    final row = (adjustedY / cellDimension).floor().clamp(0, boardSize - 1);

    if (_lastSwipedRow != row || _lastSwipedCol != col) {
      _lastSwipedRow = row;
      _lastSwipedCol = col;
      ref.read(gameStateProvider.notifier).tapCell(row, col);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = ref.watch(
      gameStateProvider.select((state) => state.board.size),
    );
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final storage = ref.watch(storageServiceProvider);

    return ValueListenableBuilder<String>(
      valueListenable: storage.controlModeNotifier,
      builder: (context, controlMode, _) {
        final isSwipeMode = controlMode == 'swipe';

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxSide = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            final boardDimension = (maxSide * 0.92).clamp(260.0, 420.0);

            Widget boardContent = Container(
              width: boardDimension,
              height: boardDimension,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: palette.boardFrame,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: isSwipeMode
                      ? palette.accentNeon.withValues(alpha: 0.7)
                      : palette.accentNeon.withValues(alpha: 0.2),
                  width: isSwipeMode ? 2.2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSwipeMode
                        ? palette.accentNeon.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.4),
                    blurRadius: isSwipeMode ? 25 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(boardSize, (r) {
                  return Expanded(
                    child: Row(
                      children: List.generate(boardSize, (c) {
                        return Expanded(
                          child: GridCellWidget(
                            row: r,
                            col: c,
                            onTap: () {
                              if (!isSwipeMode) {
                                ref.read(gameStateProvider.notifier).tapCell(r, c);
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            );

            if (isSwipeMode) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  _lastSwipedRow = null;
                  _lastSwipedCol = null;
                  _handlePan(details.localPosition, boardDimension, boardSize);
                },
                onPanUpdate: (details) {
                  _handlePan(details.localPosition, boardDimension, boardSize);
                },
                onPanEnd: (_) {
                  _lastSwipedRow = null;
                  _lastSwipedCol = null;
                },
                onTapDown: (details) {
                  _lastSwipedRow = null;
                  _lastSwipedCol = null;
                  _handlePan(details.localPosition, boardDimension, boardSize);
                },
                child: boardContent,
              );
            }

            return boardContent;
          },
        );
      },
    );
  }
}
