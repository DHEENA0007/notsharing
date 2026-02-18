import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Consumer2<AuthProvider, NotesProvider>(
        builder: (context, auth, notes, _) {
          final user = auth.user;
          final stats = notes.stats;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
          final textColor = isDark ? Colors.white : AppTheme.textPrimary;
          final subTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;
          final topPadding = MediaQuery.of(context).padding.top;

          return AnimationLimiter(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 100),
              physics: const BouncingScrollPhysics(),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // 1. Header Section (Bento Grid)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Profile Card
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 220,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  child: Text(
                                    user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user?.fullName ?? 'User',
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2, color: textColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user?.username ?? ''}',
                                style: GoogleFonts.outfit(fontSize: 13, color: subTextColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user?.college ?? 'Student',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w700),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right Column: Vertical Stats
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildMiniStatCard(context, 'Uploads', '${stats?.totalUploads ?? 0}', Icons.cloud_upload_outlined, AppTheme.accentCyan, 104),
                            const SizedBox(height: 12),
                            _buildMiniStatCard(context, 'Saved', '${stats?.totalBookmarks ?? 0}', Icons.bookmark_border, AppTheme.accentAmber, 104),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 2. Stats Row (Downloads & Requests)
                   Row(
                    children: [
                      Expanded(child: _buildHorizontalStatCard(context, 'Downloads', '${stats?.totalDownloads ?? 0}', Icons.download_outlined, AppTheme.accentPink)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHorizontalStatCard(context, 'Requests', '${stats?.totalRequests ?? 0}', Icons.question_answer_outlined, AppTheme.accentPurple)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Settings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                  const SizedBox(height: 16),

                  // 3. Settings List
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(context, 'Edit Profile', Icons.person_outline, () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                        }),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1, color: isDark ? Colors.white10 : AppTheme.textMuted.withOpacity(0.1))),
                        _buildSettingTile(context, 'Notifications', Icons.notifications_outlined, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                        }),
                         Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1, color: isDark ? Colors.white10 : AppTheme.textMuted.withOpacity(0.1))),
                        _buildSecurityTile(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: TextButton(
                      onPressed: () async {
                         await auth.logout();
                         if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.error.withOpacity(0.08),
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text('Log Out', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Center(child: Text('v1.0.0', style: TextStyle(color: isDark ? Colors.white54 : AppTheme.textMuted.withOpacity(0.5), fontSize: 12))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStatCard(BuildContext context, String label, String value, IconData icon, Color color, double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: GoogleFonts.outfit(fontSize: 11, color: subTextColor)),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Text(label, style: GoogleFonts.outfit(fontSize: 11, color: subTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: textColor),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white54 : AppTheme.textMuted),
    );
  }
  
  Widget _buildSecurityTile(BuildContext context) {
      // Direct link to EditProfile for password change for now, or could show dialog
      return _buildSettingTile(context, 'Security', Icons.shield_outlined, () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
      });
  }
}
