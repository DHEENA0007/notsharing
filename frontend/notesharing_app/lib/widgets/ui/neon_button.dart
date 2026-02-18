import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme.dart';

class NeonButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color? color;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.primaryColor;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        boxShadow: onPressed == null ? [] : [
          BoxShadow(
            color: baseColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: baseColor.withOpacity(0.2), // Outer glow
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed == null 
          ? null 
          : LinearGradient(
              colors: [baseColor, baseColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        color: onPressed == null ? Colors.white10 : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white24,
          highlightColor: Colors.white12,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /*
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                      ], 
                      */
                      // Simplified icon logic, using only text or icon + text
                      if (icon != null) Icon(icon, color: Colors.white, size: 20),
                      if (icon != null) const SizedBox(width: 12),
                      Text(
                        text.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
