import 'package:flutter/material.dart';

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
    final rad = borderRadius ?? (size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rad),
        boxShadow: size >= 48
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: size * 0.25,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rad),
        child: Image.asset(
          'assets/icons/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
