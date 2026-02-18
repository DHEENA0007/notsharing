import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Border? border;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final bool withShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.opacity = 0.1,
    this.border,
    this.padding,
    this.gradient,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
    final effectiveOpacity = isDark ? opacity : (opacity < 0.2 ? 0.6 : opacity); // Boost opacity for light mode visibility

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(effectiveOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: defaultBorderColor, width: 1.5),
            gradient: gradient,
            boxShadow: withShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }
}
