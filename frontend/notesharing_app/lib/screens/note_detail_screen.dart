import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final ApiService _api = ApiService();
  final _commentController = TextEditingController();
  Note? _note;
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    _note = await _api.getNoteDetail(widget.noteId);
    if (_note != null) {
      _comments = await _api.getComments(noteId: widget.noteId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _downloadNote() async {
    if (_note == null) return;
    await context.read<NotesProvider>().downloadNote(_note!.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started!'), backgroundColor: AppTheme.success),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    if (_note == null) return;
    final result = await context.read<NotesProvider>().toggleBookmark(_note!.id);
    setState(() => _note = _note!.copyWith(isBookmarked: result));
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await _api.createComment(contentType: 'note', noteId: widget.noteId, text: _commentController.text.trim());
    _commentController.clear();
    _comments = await _api.getComments(noteId: widget.noteId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    // Determine if header color is dark to set appropriate text color for header
    final headerColor = _getColor(_note!.subject?.color);
    final isHeaderDark = ThemeData.estimateBrightnessForColor(headerColor) == Brightness.dark;
    final headerTextColor = isHeaderDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: headerTextColor), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: Icon(_note?.isBookmarked == true ? Icons.bookmark : Icons.bookmark_border, color: headerTextColor), onPressed: _toggleBookmark),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: headerColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_note?.title ?? '', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: headerTextColor)),
                const SizedBox(height: 8),
                Text('By ${_note?.uploadedBy?.fullName ?? 'Unknown'}', style: GoogleFonts.outfit(color: headerTextColor.withOpacity(0.7))),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_note?.description ?? '', style: GoogleFonts.outfit(color: AppTheme.textSecondary, height: 1.6)),
                  const SizedBox(height: 24),
                  _buildDownloadButton(),
                  const SizedBox(height: 24),
                  Text('Comments', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 16),
                  if (_comments.isEmpty)
                     Text('No comments yet.', style: TextStyle(color: AppTheme.textMuted)),
                  ..._comments.map((c) => _buildComment(c, theme)).toList(),
                ],
              ),
            ),
          ),
          _buildCommentInput(theme),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _downloadNote,
        icon: const Icon(Icons.download),
        label: const Text('Download Note'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor, 
            padding: const EdgeInsets.all(16),
            foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildComment(Comment c, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.user?.fullName ?? 'User', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(c.text, style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardTheme.color,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'Add comment...', hintStyle: TextStyle(color: AppTheme.textMuted), border: InputBorder.none),
            ),
          ),
          IconButton(onPressed: _sendComment, icon: const Icon(Icons.send, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Color _getColor(String? hex) {
    if (hex == null) return AppTheme.primaryColor;
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  }
}
