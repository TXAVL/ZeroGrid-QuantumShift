import 'package:flutter/material.dart';
import '../theme/cyber_palette.dart';

/// Widget hiển thị hoạt ảnh điểm cộng dồn (+XXX) khi Combo hoặc ghi điểm, tự động bay lên và biến mất sau 1.2 giây
class FloatingScoreDeltaWidget extends StatefulWidget {
  final int scoreDelta;
  final int trigger;
  final bool isCombo;
  final int comboCount;
  final GameColorPalette palette;

  const FloatingScoreDeltaWidget({
    super.key,
    required this.scoreDelta,
    required this.trigger,
    this.isCombo = false,
    this.comboCount = 0,
    required this.palette,
  });

  @override
  State<FloatingScoreDeltaWidget> createState() => _FloatingScoreDeltaWidgetState();
}

class _FloatingScoreDeltaWidgetState extends State<FloatingScoreDeltaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _displayScore = 0;
  bool _displayIsCombo = false;
  int _displayComboCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
    ]).animate(_controller);

    _slideAnimation = Tween<double>(begin: 4.0, end: -28.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 65, // Giữ 100% độ rõ trong 65% thời gian đầu
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35, // Tự mờ dần và ẩn hoàn toàn
      ),
    ]).animate(_controller);

    if (widget.trigger > 0 && widget.scoreDelta > 0) {
      _startAnim();
    }
  }

  void _startAnim() {
    _displayScore = widget.scoreDelta;
    _displayIsCombo = widget.isCombo;
    _displayComboCount = widget.comboCount;
    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant FloatingScoreDeltaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.scoreDelta > 0) {
      _startAnim();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating && _controller.isCompleted) {
          return const SizedBox(height: 0, width: 0);
        }

        if (_displayScore <= 0 || _controller.value == 0.0) {
          return const SizedBox(height: 0, width: 0);
        }

        final isMegaCombo = _displayIsCombo && _displayComboCount >= 5;
        final badgeColor = isMegaCombo
            ? const Color(0xFFFFD700)
            : (_displayIsCombo ? const Color(0xFFFF007F) : widget.palette.accentNeon);

        final label = _displayIsCombo
            ? '+$_displayScore x$_displayComboCount!'
            : '+$_displayScore';

        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMegaCombo
                        ? [const Color(0xFFFF9100), const Color(0xFFFF007F)]
                        : [
                            badgeColor.withValues(alpha: 0.9),
                            widget.palette.accentNeon.withValues(alpha: 0.9),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_displayIsCombo) ...[
                      Icon(
                        isMegaCombo ? Icons.whatshot_rounded : Icons.bolt_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
