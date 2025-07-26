import 'package:flutter/material.dart';

class GraduateCapIcon extends StatelessWidget {
  final double size;
  final Color color;

  const GraduateCapIcon({
    Key? key,
    this.size = 120.0,
    this.color = const Color(0xFF87CEEB), // Sky blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: GraduateCapPainter(color: color)),
    );
  }
}

class GraduateCapPainter extends CustomPainter {
  final Color color;

  GraduateCapPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;

    // Draw the cap base
    final Path capBase = Path()
      ..moveTo(width * 0.1, height * 0.5)
      ..lineTo(width * 0.9, height * 0.5)
      ..lineTo(width * 0.7, height * 0.7)
      ..lineTo(width * 0.3, height * 0.7)
      ..close();

    // Draw the cap top
    final Path capTop = Path()
      ..moveTo(centerX, height * 0.2)
      ..lineTo(width * 0.1, height * 0.5)
      ..lineTo(width * 0.9, height * 0.5)
      ..close();

    // Draw the tassel
    final Path tassel = Path()
      ..moveTo(width * 0.75, height * 0.5)
      ..lineTo(width * 0.75, height * 0.8)
      ..lineTo(width * 0.85, height * 0.85)
      ..lineTo(width * 0.85, height * 0.85)
      ..close();

    canvas.drawPath(capBase, paint);
    canvas.drawPath(capTop, paint);
    canvas.drawPath(tassel, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
