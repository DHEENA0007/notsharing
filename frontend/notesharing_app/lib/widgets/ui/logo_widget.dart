import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool isAnimated;

  const LogoWidget({
    super.key, 
    this.size = 100,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Gradient Paint
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.accentCyan, AppTheme.accentPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    // Draw Document Shape (Rounded Rect with folded corner)
    final path = Path();
    final pad = size.width * 0.2;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final left = pad;
    final top = pad;
    final corner = w * 0.3;

    path.moveTo(left, top + corner); // Top Left (start lower for curve)
    path.quadraticBezierTo(left, top, left + corner, top); // Top Left Corner
    path.lineTo(left + w - corner, top); // Top Edge
    path.lineTo(left + w, top + corner); // Folded Corner
    path.lineTo(left + w, top + h - corner); // Right Edge
    path.quadraticBezierTo(left + w, top + h, left + w - corner, top + h); // Bottom Right
    path.lineTo(left + corner, top + h); // Bottom Edge
    path.quadraticBezierTo(left, top + h, left, top + h - corner); // Bottom Left
    path.close();

    canvas.drawPath(path, paint);

    // Draw "Nodes" inside
    final nodePaint = Paint()
      ..shader = paint.shader
      ..style = PaintingStyle.fill;

    // Central Node
    canvas.drawCircle(Offset(centerX, centerY + size.height * 0.05), size.width * 0.06, nodePaint);
    
    // Branch Nodes
    final branchPaint = Paint()
      ..shader = paint.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    // Top
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX, centerY - size.height * 0.15), branchPaint);
    canvas.drawCircle(Offset(centerX, centerY - size.height * 0.15), size.width * 0.04, nodePaint);

    // Left
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX - size.width * 0.15, centerY + size.height * 0.1), branchPaint);
    canvas.drawCircle(Offset(centerX - size.width * 0.15, centerY + size.height * 0.1), size.width * 0.04, nodePaint);

    // Right
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX + size.width * 0.15, centerY + size.height * 0.1), branchPaint);
    canvas.drawCircle(Offset(centerX + size.width * 0.15, centerY + size.height * 0.1), size.width * 0.04, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
