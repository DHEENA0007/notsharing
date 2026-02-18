import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../widgets/ui/glass_container.dart';
import '../widgets/ui/animated_mesh_background.dart';
import '../widgets/ui/neon_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppTheme.accentPink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Allow resizing so keyboard pushes content up/allows scrolling
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AnimatedMeshBackground(child: SizedBox.expand()),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Rotating Portal Animation (Top Section)
                      SizedBox(height: size.height * 0.1),
                      Center(
                        child: _PortalLogo(isDark: isDark),
                      ),
                      
                      const Spacer(),

                      // Bottom Content Area (Form)
                      GlassContainer(
                        borderRadius: 40,
                        blur: 20,
                        opacity: isDark ? 0.1 : 0.6,
                        border: Border(
                          top: BorderSide(color: isDark ? Colors.white12 : Colors.white.withOpacity(0.4)),
                        ),
                        padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'WELCOME BACK',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                letterSpacing: 4,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildStreamlineInput(
                                    controller: _emailController,
                                    hint: 'Email Address',
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    validator: (v) => v!.contains('@') ? null : 'Valid email required',
                                  ),
                                  const SizedBox(height: 24),
                                  _buildStreamlineInput(
                                    controller: _passwordController,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                    obscureText: _obscurePassword,
                                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                    validator: (v) => v!.length > 5 ? null : 'Min 6 chars',
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // LOGIN BUTTON
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return GestureDetector(
                                  onTap: auth.isLoading ? null : _login,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: auth.isLoading
                                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text(
                                              'LOG IN',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Register Link
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                   Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: Text(
                                  "Create New Account",
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamlineInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
      cursorColor: AppTheme.accentCyan,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          letterSpacing: 2,
        ),
        prefixIcon: Icon(icon, color: AppTheme.accentCyan, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.textMuted),
                onPressed: onTogglePassword,
              )
            : null,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: validator,
    );
  }
}

class _PortalLogo extends StatefulWidget {
  final bool isDark;
  const _PortalLogo({required this.isDark});

  @override
  State<_PortalLogo> createState() => _PortalLogoState();
}

class _PortalLogoState extends State<_PortalLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
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
          painter: _PortalPainter(
            color: widget.isDark ? AppTheme.accentCyan : AppTheme.primaryColor,
            angle: _controller.value * 2 * 3.14159,
          ),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: Icon(
                Icons.rocket_launch,
                size: 60,
                color: widget.isDark ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PortalPainter extends CustomPainter {
  final Color color;
  final double angle;

  _PortalPainter({required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer dashed ring
    for (int i = 0; i < 12; i++) {
        double startAngle = angle + (i * 30 * 3.14159 / 180);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          20 * 3.14159 / 180, // 20 degree arc
          false,
          paint..color = color.withOpacity(0.5),
        );
    }
    
    // Inner solid ring
    canvas.drawCircle(center, radius * 0.7, paint..color = color.withOpacity(0.2));

    // Rotating dot on inner ring
    double dotAngle = -angle * 2;
    canvas.drawCircle(
      Offset(
        center.dx + (radius * 0.7) * math.cos(dotAngle),
        center.dy + (radius * 0.7) * math.sin(dotAngle),
      ),
      5,
      Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_PortalPainter oldDelegate) => oldDelegate.angle != angle;
}
