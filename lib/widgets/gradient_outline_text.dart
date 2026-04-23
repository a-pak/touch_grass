import 'package:flutter/material.dart';

class GradientOutlineText extends StatelessWidget {
  const GradientOutlineText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
    this.strokeWidth = 6,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark green outline layer
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = const Color(0xFF1B5E20),
          ),
        ),
        // Gradient fill layer
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFAEEA00), Color(0xFF57C785)],
          ).createShader(bounds),
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
