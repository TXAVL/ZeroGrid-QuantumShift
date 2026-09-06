import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_notifier.dart';
import '../../state/theme_notifier.dart';

/// Ô vuông ma trận Quantum với hiệu ứng lan tỏa (Ripple/Cross Cascade) và preview gợi ý trực quan
class GridCellWidget extends ConsumerWidget {
  final int row;
  final int col;
  final VoidCallback onTap;

  const GridCellWidget({
    super.key,
    required this.row,
    required this.col,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Chỉ rebuild khi giá trị của ô (row, col) thay đổi
    final cellValue = ref.watch(
      gameStateProvider.select((state) => state.board.getValue(row, col)),
    );

    // Kiểm tra xem ô này có đang được gợi ý (Direct Hint) hay không
    final isHinted = ref.watch(
      gameStateProvider.select((state) {
        final hint = state.activeHint;
        return hint != null && hint.$1 == row && hint.$2 == col;
      }),
    );

    // Kiểm tra xem ô này có nằm trong vùng lan tỏa của gợi ý (Hint Cross-influence Preview) hay không
    final isHintNeighbor = ref.watch(
      gameStateProvider.select((state) {
        final hint = state.activeHint;
        if (hint == null) return false;
        final isAdj = (hint.$1 == row && (hint.$2 - col).abs() == 1) ||
                      (hint.$2 == col && (hint.$1 - row).abs() == 1);
        return isAdj;
      }),
    );

    final themeState = ref.watch(themeProvider);
    final palette = themeState.palette;
    final isColorblind = themeState.isColorblind;

    final cellColor = palette.getColorForValue(cellValue, isColorblind: isColorblind);
    final isInactive = (cellValue == 0);

    // Tính toán màu viền và đổ bóng tương ứng với trạng thái
    Color borderColor;
    double borderWidth;
    List<BoxShadow> shadows = [];

    if (isHinted) {
      borderColor = const Color(0xFFFFD600);
      borderWidth = 3.2;
      shadows = [
        const BoxShadow(
          color: Color(0xFFFFD600),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ];
    } else if (isHintNeighbor) {
      borderColor = const Color(0xFFFFD600).withValues(alpha: 0.7);
      borderWidth = 1.8;
      shadows = [
        BoxShadow(
          color: const Color(0xFFFFD600).withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isInactive) {
      borderColor = palette.cellInactive;
      borderWidth = 1.0;
    } else {
      borderColor = cellColor;
      borderWidth = 2.0;
      shadows = [
        BoxShadow(
          color: cellColor.withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(4.5),
        decoration: BoxDecoration(
          color: isInactive
              ? palette.cellInactive.withValues(alpha: 0.45)
              : (isHinted
                  ? const Color(0xFFFFD600).withValues(alpha: 0.25)
                  : cellColor.withValues(alpha: 0.18)),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: shadows,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hiển thị số lượng tử ở trung tâm
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                );
              },
              child: Text(
                '$cellValue',
                key: ValueKey<int>(cellValue),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isInactive
                      ? palette.textSecondary.withValues(alpha: 0.35)
                      : (isColorblind ? Colors.white : cellColor),
                  shadows: [
                    if (!isInactive)
                      Shadow(
                        color: cellColor.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                  ],
                ),
              ),
            ),

            // Icon chỉ báo giảm (-1) trên các ô lân cận khi bật Gợi ý
            if (isHintNeighbor && !isInactive)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    size: 11,
                    color: Color(0xFFFFD600),
                  ),
                ),
              ),

            // Icon Ngôi sao trên ô Gợi ý chính
            if (isHinted)
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: Color(0xFFFFD600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
