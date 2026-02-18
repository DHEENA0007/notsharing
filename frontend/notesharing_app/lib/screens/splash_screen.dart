import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../widgets/ui/logo_widget.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    
    // Elegant Entrance Animation
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeIn))
    );
    
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic))
    );

    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    bool isLoggedIn = false;
    try {
      final authProvider = context.read<AuthProvider>();
      // Added timeout to prevent hanging
      isLoggedIn = await authProvider.checkAuth().timeout(
        const Duration(seconds: 5), 
        onTimeout: () => false,
      );
    } catch (e) {
      debugPrint('Auth Check Failed: $e');
      isLoggedIn = false;
    }
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle Pattern Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: PatternPainter()),
            ),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo without container, clean look
                    const LogoWidget(size: 100),
                    
                    const SizedBox(height: 40),
                    
                    Text(
                      'NoteShare',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E), // Dark Navy Text
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Elevate Your Learning',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.black54,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Minimal Bottom Loader
          Positioned(
             bottom: 60,
             left: 0, 
             right: 0,
             child: Center(
               child: FadeTransition(
                 opacity: _fadeAnim,
                 child: SizedBox(
                   width: 150,
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(2),
                     child: LinearProgressIndicator(
                       color: AppTheme.primaryColor,
                       backgroundColor: Colors.grey[100],
                       minHeight: 2,
                     ),
                   ),
                 ),
               ),
             ),
          ),
        ],
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if ((x + y) % (step * 2) == 0) {
           canvas.drawCircle(Offset(x, y), 1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
