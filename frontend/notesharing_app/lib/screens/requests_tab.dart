import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'request_detail_screen.dart';
import 'create_request_screen.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    final status = _selectedStatus == 'all' ? null : _selectedStatus;
    await context.read<RequestsProvider>().loadRequests(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        color: AppTheme.accentCyan,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header (Button Removed) - Wrapped in SliverSafeArea
                SliverSafeArea(
                  bottom: false,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMMUNITY',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              color: AppTheme.accentPink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Request Board',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Ask for notes, summaries, or specific topics from the community.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                // Sticky Filter Capsules
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 80,
                          color: (Theme.of(context).brightness == Brightness.dark 
                              ? Colors.black 
                              : Colors.white).withOpacity(0.2), // More transparent for better blend
                          alignment: Alignment.centerLeft,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildFilterCapsule('All Requests', 'all'),
                          _buildFilterCapsule('Open', 'open'),
                          _buildFilterCapsule('Resolved', 'fulfilled'),
                        ],
                      ),
                    ),
                      ),
                    ),
                  ),
                ),

                // Requests List
                Consumer<RequestsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
                      );
                    }
                    
                    if (provider.requests.isEmpty) {
                      return SliverFillRemaining(child: _buildEmptyState());
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 180), // Increased bottom padding
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50,
                                child: FadeInAnimation(
                                  child: _buildTicketCard(provider.requests[index], isDark),
                                ),
                              ),
                            );
                          },
                          childCount: provider.requests.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Floating Bottom Dock (Above Bottom Nav)
            Positioned(
              left: 20,
              right: 20,
              bottom: 110, // Adjusted to sit above the nav bar (30 padding + ~60 height + buffer)
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                  ).then((_) => _loadRequests());
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cyberGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_comment_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'ASK THE COMMUNITY',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCapsule(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = value);
        _loadRequests();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppTheme.textPrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] 
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(NoteRequest request, bool isDark) {
    final isOpen = request.status == 'open';
    final statusColor = isOpen ? AppTheme.accentCyan : AppTheme.success;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RequestDetailScreen(requestId: request.id)),
        ).then((_) => _loadRequests());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Strip
              Container(
                width: 6,
                color: statusColor,
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: User & Date
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.bgLight,
                            child: Text(
                              (request.requestedBy?.username ?? 'U')[0].toUpperCase(),
                              style: TextStyle(fontSize: 10, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '@${request.requestedBy?.username ?? 'Unknown'}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(request.createdAt),
                            style: GoogleFonts.robotoMono(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      
                      // Content
                      Text(
                        request.title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        request.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Footer: Status Badge & Comments
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isOpen ? 'NEEDS HELP' : 'RESOLVED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${request.commentsCount}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textSecondary,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_chat_unread_outlined, size: 48, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No Requests Yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to ask for help!',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
              ).then((_) => _loadRequests());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Request'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return "${date.day}/${date.month}";
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
