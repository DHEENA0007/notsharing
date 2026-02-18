import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AnimatedMeshBackground extends StatefulWidget {
  final Widget? child; // Made optional to fit diverse usages
  const AnimatedMeshBackground({super.key, this.child});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Smooth, slow animation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define palette based on theme
    // Speed up slightly
    _controller.duration = const Duration(seconds: 10);

    final Color bgBase = isDark ? const Color(0xFF050510) : const Color(0xFFEFF3F8); // Slightly richer base
    final List<Color> orbs = isDark 
        ? [
            const Color(0xFF7000FF).withOpacity(0.5), // Electric Violet
            const Color(0xFF00F0FF).withOpacity(0.4), // Cyber Cyan
            const Color(0xFFFF0080).withOpacity(0.4), // Neon Pink
            const Color(0xFF4A00E0).withOpacity(0.4), // Deep Purple
          ]
        : [
            const Color(0xFF7000FF).withOpacity(0.4), // More visible Violet
            const Color(0xFF00C9FF).withOpacity(0.4), // More visible Cyan
            const Color(0xFFFF5E99).withOpacity(0.4), // More visible Pink
            const Color(0xFF8E2DE2).withOpacity(0.4), // More visible Purple
          ];

    return Stack(
      children: [
        // Solid Base
        Container(color: bgBase),
        
        // Animated Nebula Painter
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _NebulaPainter(
                animationValue: _controller.value,
                colors: orbs,
                isDark: isDark,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),

        // Glass Overlay (Blur) to smooth everything out
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),

        // Optional Noise Overlay (Simulated with simple pattern or ignored for performance)
        // Kept simple for now.
        
        // Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _NebulaPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final bool isDark;

  _NebulaPainter({required this.animationValue, required this.colors, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // We draw large blurred circles moving around
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final double t = animationValue * 2 * math.pi;
    final double w = size.width;
    final double h = size.height;

    // Helper to draw orb
    void drawOrb(Color color, double dx, double dy, double radius) {
      paint.color = color;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }

    // Orb 1: Top Left - Circular motion
    drawOrb(colors[0], 
      w * 0.2 + math.cos(t) * 50, 
      h * 0.3 + math.sin(t) * 50, 
      w * 0.6
    );

    // Orb 2: Bottom Right - Elliptical motion
    drawOrb(colors[1], 
      w * 0.8 + math.sin(t) * 60, 
      h * 0.7 + math.cos(t) * 40, 
      w * 0.5
    );

    // Orb 3: Center Top - Floating
    drawOrb(colors[2], 
      w * 0.5 + math.sin(t * 0.5) * 80, 
      h * 0.2 + math.cos(t * 0.5) * 30, 
      w * 0.4
    );

    // Orb 4: Bottom Left - Slow varied motion
    drawOrb(colors[3], 
      w * 0.2 + math.cos(t * 0.7) * 40, 
      h * 0.8 + math.sin(t * 0.8) * 40, 
      w * 0.55
    );
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isDark != isDark; // Repaint on animation or theme change
  }
}
