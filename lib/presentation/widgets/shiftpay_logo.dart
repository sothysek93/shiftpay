import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ShiftPayLogo extends StatelessWidget {
  final double size;
  final bool hasBackground;
  final double? borderRadius;

  const ShiftPayLogo({
    super.key,
    this.size = 28,
    this.hasBackground = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rad = borderRadius ?? (size * 0.24);

    return Container(
      width: size,
      height: size,
      decoration: hasBackground
          ? BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(rad),
              border: Border.all(
                color: colors.border,
                width: size > 40 ? 1.0 : 0.8,
              ),
              boxShadow: size >= 48
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: context.isDark ? 0.12 : 0.08),
                        blurRadius: size * 0.3,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            )
          : null,
      padding: hasBackground ? EdgeInsets.all(size * 0.15) : EdgeInsets.zero,
      child: CustomPaint(
        size: Size.square(size),
        painter: _ShiftPayLogoPainter(colors: colors),
      ),
    );
  }
}

class _ShiftPayLogoPainter extends CustomPainter {
  final AppColorScheme colors;

  _ShiftPayLogoPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final strokeWidth = w * 0.14;

    // 1. Glowing Emerald Base Paint
    final emeraldPaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mintPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Top horizontal & left vertical bar
    final path1 = Path();
    path1.moveTo(cx + w * 0.28, cy - h * 0.28);
    path1.lineTo(cx - w * 0.18, cy - h * 0.28);
    path1.quadraticBezierTo(cx - w * 0.28, cy - h * 0.28, cx - w * 0.28, cy - h * 0.18);
    path1.lineTo(cx - w * 0.28, cy);
    path1.lineTo(cx + w * 0.18, cy);
    canvas.drawPath(path1, mintPaint);

    // Bottom right vertical & bottom horizontal bar
    final path2 = Path();
    path2.moveTo(cx - w * 0.18, cy);
    path2.lineTo(cx + w * 0.28, cy);
    path2.quadraticBezierTo(cx + w * 0.28, cy, cx + w * 0.28, cy + h * 0.12);
    path2.lineTo(cx + w * 0.28, cy + h * 0.28);
    path2.quadraticBezierTo(cx + w * 0.28, cy + h * 0.28, cx + w * 0.18, cy + h * 0.28);
    path2.lineTo(cx - w * 0.28, cy + h * 0.28);
    canvas.drawPath(path2, emeraldPaint);

    // 2. Overtime Amber Slash (Shift & Earnings Motif)
    final amberPaint = Paint()
      ..color = colors.overtime
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.55
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - w * 0.18, cy + h * 0.36),
      Offset(cx + w * 0.18, cy - h * 0.36),
      amberPaint,
    );

    // Center pivot dot for Overtime precision
    final centerDot = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), strokeWidth * 0.35, centerDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
