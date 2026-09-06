import 'dart:math';
import 'package:flutter/material.dart';

enum MascotMood { promoted, retained, demoted }

/// Widget Linh Vật Lượng Tử Vector với 3 trạng thái hoạt ảnh sống động
class TournamentMascotWidget extends StatefulWidget {
  final MascotMood mood;
  final double size;

  const TournamentMascotWidget({
    super.key,
    required this.mood,
    this.size = 180,
  });

  @override
  State<TournamentMascotWidget> createState() => _TournamentMascotWidgetState();
}

class _TournamentMascotWidgetState extends State<TournamentMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _MascotPainter(
            mood: widget.mood,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotMood mood;
  final double progress;

  _MascotPainter({
    required this.mood,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Hiệu ứng nhảy (Jump / Bobbing) theo trạng thái
    double offsetY = 0;
    double scaleX = 1.0;
    double scaleY = 1.0;

    if (mood == MascotMood.promoted) {
      // Nhảy cẫng lên mừng rỡ
      offsetY = -sin(progress * pi * 2).abs() * 24;
      scaleY = 1.0 + sin(progress * pi * 2) * 0.08;
      scaleX = 1.0 - sin(progress * pi * 2) * 0.05;
    } else if (mood == MascotMood.retained) {
      // Thở hổn hển (co giãn ngực)
      scaleY = 1.0 + sin(progress * pi * 2) * 0.06;
      scaleX = 1.0 - sin(progress * pi * 2) * 0.04;
    } else if (mood == MascotMood.demoted) {
      // Run rẩy, cụp xuống
      offsetY = sin(progress * pi * 8) * 3 + 8;
    }

    final mascotCenter = Offset(center.dx, center.dy + offsetY);

    // 1. Vòng sáng Neon Aura nền
    final auraColor = mood == MascotMood.promoted
        ? const Color(0xFF00FFA3)
        : (mood == MascotMood.retained ? const Color(0xFFFFD600) : const Color(0xFFFF0055));

    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.25 + 0.15 * sin(progress * pi * 2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(mascotCenter, radius * 1.15, auraPaint);

    // 2. Vẽ Tai (Ears)
    final earPaint = Paint()..color = const Color(0xFF16213E);
    final earInnerPaint = Paint()..color = auraColor;

    // Tai Trái
    final earLeftPath = Path()
      ..moveTo(mascotCenter.dx - radius * 0.7, mascotCenter.dy - radius * 0.3)
      ..lineTo(mascotCenter.dx - radius * 0.9, mascotCenter.dy - radius * (mood == MascotMood.demoted ? 0.7 : 1.15))
      ..lineTo(mascotCenter.dx - radius * 0.2, mascotCenter.dy - radius * 0.75)
      ..close();
    canvas.drawPath(earLeftPath, earPaint);

    final earInnerLeft = Path()
      ..moveTo(mascotCenter.dx - radius * 0.65, mascotCenter.dy - radius * 0.35)
      ..lineTo(mascotCenter.dx - radius * 0.82, mascotCenter.dy - radius * (mood == MascotMood.demoted ? 0.65 : 1.05))
      ..lineTo(mascotCenter.dx - radius * 0.25, mascotCenter.dy - radius * 0.7)
      ..close();
    canvas.drawPath(earInnerLeft, earInnerPaint);

    // Tai Phải
    final earRightPath = Path()
      ..moveTo(mascotCenter.dx + radius * 0.7, mascotCenter.dy - radius * 0.3)
      ..lineTo(mascotCenter.dx + radius * 0.9, mascotCenter.dy - radius * (mood == MascotMood.demoted ? 0.7 : 1.15))
      ..lineTo(mascotCenter.dx + radius * 0.2, mascotCenter.dy - radius * 0.75)
      ..close();
    canvas.drawPath(earRightPath, earPaint);

    final earInnerRight = Path()
      ..moveTo(mascotCenter.dx + radius * 0.65, mascotCenter.dy - radius * 0.35)
      ..lineTo(mascotCenter.dx + radius * 0.82, mascotCenter.dy - radius * (mood == MascotMood.demoted ? 0.65 : 1.05))
      ..lineTo(mascotCenter.dx + radius * 0.25, mascotCenter.dy - radius * 0.7)
      ..close();
    canvas.drawPath(earInnerRight, earInnerPaint);

    // 3. Đầu Mascot (Head Circle)
    final headPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF1F2E54),
          Color(0xFF0F172A),
        ],
      ).createShader(Rect.fromCircle(center: mascotCenter, radius: radius));

    canvas.save();
    canvas.translate(mascotCenter.dx, mascotCenter.dy);
    canvas.scale(scaleX, scaleY);
    canvas.drawCircle(Offset.zero, radius, headPaint);

    // Viền đầu phát sáng
    final headBorder = Paint()
      ..color = auraColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset.zero, radius, headBorder);

    // 4. Mắt & Miệng theo Trạng thái
    final featurePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    if (mood == MascotMood.promoted) {
      // Mắt cười híp tít (^ ^)
      final eyeLeft = Path()
        ..moveTo(-radius * 0.45, -radius * 0.05)
        ..quadraticBezierTo(-radius * 0.3, -radius * 0.28, -radius * 0.15, -radius * 0.05);
      final eyeRight = Path()
        ..moveTo(radius * 0.15, -radius * 0.05)
        ..quadraticBezierTo(radius * 0.3, -radius * 0.28, radius * 0.45, -radius * 0.05);
      canvas.drawPath(eyeLeft, featurePaint);
      canvas.drawPath(eyeRight, featurePaint);

      // Má hồng phát sáng
      final blushPaint = Paint()..color = const Color(0xFFFF007F).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(-radius * 0.5, radius * 0.15), radius * 0.14, blushPaint);
      canvas.drawCircle(Offset(radius * 0.5, radius * 0.15), radius * 0.14, blushPaint);

      // Miệng cười mở to (D)
      final mouthPath = Path()
        ..moveTo(-radius * 0.2, radius * 0.18)
        ..quadraticBezierTo(0, radius * 0.55, radius * 0.2, radius * 0.18)
        ..close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF3366));
    } else if (mood == MascotMood.retained) {
      // Mắt to tròn mở to chớp chớp
      final eyeFill = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(-radius * 0.3, -radius * 0.1), radius * 0.14, eyeFill);
      canvas.drawCircle(Offset(radius * 0.3, -radius * 0.1), radius * 0.14, eyeFill);
      canvas.drawCircle(Offset(-radius * 0.28, -radius * 0.1), radius * 0.07, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(radius * 0.28, -radius * 0.1), radius * 0.07, Paint()..color = Colors.black);

      // Miệng thở phào méo mó (~ )
      final mouthPath = Path()
        ..moveTo(-radius * 0.15, radius * 0.25)
        ..quadraticBezierTo(0, radius * 0.15, radius * 0.15, radius * 0.25);
      canvas.drawPath(mouthPath, featurePaint);

      // Giọt mồ hôi rơi trán
      final dropProgress = (progress * 2) % 1.0;
      final sweatPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.85);
      canvas.drawCircle(Offset(radius * 0.55, -radius * 0.4 + dropProgress * 25), 4.5, sweatPaint);
      canvas.drawCircle(Offset(-radius * 0.5, -radius * 0.35 + dropProgress * 20), 3.5, sweatPaint);
    } else if (mood == MascotMood.demoted) {
      // Mắt mếu mếu (T T) khóc
      final eyePaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-radius * 0.4, -radius * 0.15), Offset(-radius * 0.2, -radius * 0.15), eyePaint);
      canvas.drawLine(Offset(radius * 0.2, -radius * 0.15), Offset(radius * 0.4, -radius * 0.15), eyePaint);

      // Dòng nước mắt chảy dài
      final tearPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8);
      final tearY = (progress * 30) % 30.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(-radius * 0.3, radius * 0.1 + tearY), width: 6, height: 12), tearPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(radius * 0.3, radius * 0.1 + tearY), width: 6, height: 12), tearPaint);

      // Miệng mếu cong xuống (︵)
      final mouthPath = Path()
        ..moveTo(-radius * 0.2, radius * 0.38)
        ..quadraticBezierTo(0, radius * 0.22, radius * 0.2, radius * 0.38);
      canvas.drawPath(mouthPath, featurePaint);
    }

    canvas.restore();

    // 5. Pháo hoa Confetti bay lơ lửng nếu Thăng Hạng
    if (mood == MascotMood.promoted) {
      final confettiColors = [
        const Color(0xFFFFD600),
        const Color(0xFF00FFA3),
        const Color(0xFFFF007F),
        const Color(0xFF00E5FF),
      ];
      final rand = Random(42);
      for (int i = 0; i < 12; i++) {
        final angle = (i / 12) * pi * 2 + progress * pi;
        final dist = radius * 1.3 + sin(progress * pi * 4 + i) * 15;
        final p = Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist);
        final color = confettiColors[i % confettiColors.length];
        canvas.drawCircle(p, rand.nextDouble() * 3 + 2.5, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => true;
}
