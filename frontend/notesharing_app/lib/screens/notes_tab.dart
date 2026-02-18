import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/ui/glass_container.dart';
import 'note_detail_screen.dart';
import 'upload_note_screen.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final _searchController = TextEditingController();
  int? _selectedSubjectId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotes() async {
    await context.read<NotesProvider>().loadNotes(
      subjectId: _selectedSubjectId,
      search: _searchController.text,
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _refreshNotes,
      color: AppTheme.accentCyan,
      backgroundColor: AppTheme.bgCard,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header & Search
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 10),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPLORE',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                            Text(
                              'Knowledge Hub',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        // Futuristic Upload Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const UploadNoteScreen()),
                            ).then((_) => _refreshNotes());
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppTheme.primaryColor,
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                   ),
                   const SizedBox(height: 24),

                   // Search Bar
                   Container(
                     decoration: BoxDecoration(
                       color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                       borderRadius: BorderRadius.circular(20),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 5),
                         ),
                       ],
                     ),
                     child: TextField(
                       controller: _searchController,
                       style: TextStyle(color: AppTheme.textPrimary),
                       decoration: InputDecoration(
                         hintText: 'Search for notes, authors...',
                         hintStyle: TextStyle(color: AppTheme.textMuted),
                         prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accentCyan),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                       ),
                       onSubmitted: (_) => _refreshNotes(),
                     ),
                   ),
                ],
              ),
            ),
              ),
            ),

          // Subjects Filters (Horizontal List)
          SliverToBoxAdapter(
            child: Consumer<NotesProvider>(
              builder: (context, provider, _) {
                if (provider.subjects.isEmpty) return const SizedBox.shrink();
                return Container(
                  height: 100, // Adjusted height for icon+text
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.subjects.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSubjectItem(null, 'All', 'dashboard', provider);
                      final subject = provider.subjects[index - 1];
                      return _buildSubjectItem(subject.id, subject.name, subject.icon, provider);
                    },
                  ),
                );
              },
            ),
          ),

          // Notes List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                children: [
                  Text(
                    'Recent Uploads',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.filter_list, size: 20, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),

          // Masonry Grid of Notes
          Consumer<NotesProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                 return const SliverFillRemaining(
                   child: Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
                 );
              }
              if (provider.notes.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: AnimationLimiter(
                  child: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Taller cards
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          columnCount: 2,
                          child: ScaleAnimation(
                            scale: 0.9,
                            child: FadeInAnimation(
                              child: _buildModernNoteCard(provider.notes[index], isDark),
                            ),
                          ),
                        );
                      },
                      childCount: provider.notes.length,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(int? subjectId, String label, String iconName, NotesProvider provider) {
    final isSelected = _selectedSubjectId == subjectId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSubjectId = subjectId);
        provider.loadNotes(subjectId: subjectId, search: _searchController.text);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             AnimatedContainer(
               duration: const Duration(milliseconds: 300),
               width: 56,
               height: 56,
               decoration: BoxDecoration(
                 color: isSelected ? AppTheme.accentCyan : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                 borderRadius: BorderRadius.circular(18),
                 border: isSelected 
                     ? Border.all(color: AppTheme.accentCyan.withOpacity(0.5), width: 2)
                     : Border.all(color: Colors.transparent),
                 boxShadow: isSelected
                     ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5))]
                     : [],
               ),
               child: Icon(
                 subjectId == null ? Icons.dashboard_outlined : Icons.book_outlined, // Placeholder for dynamic icons
                 color: isSelected ? Colors.black : AppTheme.textSecondary,
                 size: 24,
               ),
             ),
             const SizedBox(height: 8),
             Text(
               label,
               style: GoogleFonts.outfit(
                 fontSize: 12,
                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                 color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNoteCard(Note note, bool isDark) {
    final subjectColor = _getColorFromHex(note.subject?.color ?? '#6366F1');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: note.id)),
        ).then((_) => _refreshNotes());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Gradient Splash
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: subjectColor.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(color: subjectColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon / Thumbnail Area
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Container(
                               padding: const EdgeInsets.all(8),
                               decoration: BoxDecoration(
                                 color: subjectColor.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Icon(Icons.description_outlined, color: subjectColor, size: 20),
                             ),
                             Consumer<NotesProvider>(
                                builder: (context, provider, _) { 
                                  return GestureDetector(
                                    onTap: () => provider.toggleBookmark(note.id),
                                    child: Icon(
                                      note.isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded, 
                                      color: note.isBookmarked ? AppTheme.accentCyan : AppTheme.textMuted,
                                      size: 22,
                                    ),
                                  );
                                },
                             ),
                           ],
                         ),
                         const Spacer(),
                         if (note.tags != null && note.tags!.isNotEmpty)
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey[100],
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(
                               note.tags!.split(',').first.trim(),
                               style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                             ),
                           ),
                      ],
                    ),
                  ),
                ),
                
                // Content Area
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50], // Subtle difference
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.2,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: AppTheme.textMuted,
                              child: Icon(Icons.person, size: 10, color: isDark ? Colors.black : Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                note.uploadedBy?.username ?? 'Unknown',
                                style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No notes found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try filtering by a different subject',
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
