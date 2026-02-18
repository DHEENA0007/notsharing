import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';
import '../widgets/ui/glass_container.dart';
import '../widgets/ui/animated_mesh_background.dart';
import 'notes_tab.dart';
import 'requests_tab.dart';
import 'bookmarks_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // Use unique keys to preserve state if needed, but IndexedStack handles it.
  final List<Widget> _tabs = [
    const NotesTab(),
    const RequestsTab(),
    const BookmarksTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final notesProvider = context.read<NotesProvider>();
    final requestsProvider = context.read<RequestsProvider>();
    
    // Load concurrently for speed
    await Future.wait([
      notesProvider.loadSubjects(),
      notesProvider.loadNotes(),
      notesProvider.loadDashboard(),
      requestsProvider.loadRequests(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating nav bar
      body: AnimatedMeshBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: GlassContainer(
        borderRadius: 30,
        blur: 20,
        opacity: isDark ? 0.1 : 0.7,
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.grid_view_rounded, 'Notes'),
            _navItem(1, Icons.question_answer_rounded, 'Ask'),
            _navItem(2, Icons.bookmark_rounded, 'Saved'),
            _navItem(3, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white54 : AppTheme.textSecondary),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
