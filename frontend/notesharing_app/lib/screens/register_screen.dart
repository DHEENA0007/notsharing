import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../widgets/ui/glass_container.dart';
import '../widgets/ui/animated_mesh_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _selectedYear;
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your academic year')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      college: _collegeController.text.trim(),
      course: _courseController.text.trim(),
      year: _selectedYear!,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // Go back to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please log in.'),
          backgroundColor: AppTheme.accentCyan,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true, // Enable resizing
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      // Identity Construction Animation
                      Center(
                        child: _IdentityLogo(isDark: isDark),
                      ),
                      
                      const Spacer(),

                      // Bottom Content
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
                              'ESTABLISH IDENTITY',
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
                                    controller: _fullNameController,
                                    hint: 'Full Name',
                                    icon: Icons.person_outline,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStreamlineInput(
                                    controller: _usernameController,
                                    hint: 'Username',
                                    icon: Icons.alternate_email,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStreamlineInput(
                                    controller: _emailController,
                                    hint: 'Email Address',
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    validator: (v) => v!.contains('@') ? null : 'Valid email required',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStreamlineInput(
                                    controller: _passwordController,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                    obscureText: _obscurePassword,
                                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStreamlineInput(
                                          controller: _collegeController,
                                          hint: 'College',
                                          icon: Icons.school_outlined,
                                          isDark: isDark,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStreamlineInput(
                                          controller: _courseController,
                                          hint: 'Course',
                                          icon: Icons.menu_book_outlined,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildYearDropdown(isDark),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Register Button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return GestureDetector(
                                  onTap: auth.isLoading ? null : _register,
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
                                              'CREATE ACCOUNT',
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
                            const SizedBox(height: 20),
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
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      cursorColor: AppTheme.accentCyan,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          letterSpacing: 1.5,
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
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildYearDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedYear,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Academic Year',
        labelStyle: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
        prefixIcon: Icon(Icons.school, color: AppTheme.accentCyan, size: 20),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentCyan, width: 2),
        ),
      ),
      dropdownColor: isDark ? AppTheme.bgCard : Colors.white,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
      onChanged: (v) => setState(() => _selectedYear = v),
    );
  }
}

class _IdentityLogo extends StatefulWidget {
  final bool isDark;
  const _IdentityLogo({required this.isDark});

  @override
  State<_IdentityLogo> createState() => _IdentityLogoState();
}

class _IdentityLogoState extends State<_IdentityLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
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
          painter: _HexagonPainter(
            color: widget.isDark ? AppTheme.accentCyan : Colors.blueAccent,
            progress: _controller.value,
          ),
          child: SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: Icon(Icons.fingerprint, size: 60, color: widget.isDark ? Colors.white : AppTheme.primaryColor),
            ),
          ),
        );
      },
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final double progress;

  _HexagonPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    // Draw Hexagon
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i - 30) * math.pi / 180;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint..color = color.withOpacity(0.5));
    
    // Rotating Scanner Line
    final scanPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
    double scanY = center.dy - radius + (progress * 2 * radius) % (2 * radius);
    if (scanY > center.dy + radius) scanY -= 2 * radius; // Loop
    
    // Simple horizontal scan line clipped to hexagon would be complex.
    // Let's just draw a rotating ring segment
    
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.8);
    canvas.drawArc(ringRect, progress * 2 * math.pi, math.pi / 2, false, scanPaint);
    canvas.drawArc(ringRect, progress * 2 * math.pi + math.pi, math.pi / 2, false, scanPaint);
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => oldDelegate.progress != progress;
}
