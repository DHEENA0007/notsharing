import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final ApiService _api = ApiService();
  final _commentController = TextEditingController();
  NoteRequest? _request;
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _request = await _api.getRequestDetail(widget.requestId);
    if (_request != null) {
      _comments = await _api.getComments(requestId: widget.requestId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await _api.createComment(
      contentType: 'request',
      requestId: widget.requestId,
      text: _commentController.text.trim(),
    );
    _commentController.clear();
    await _loadData();
  }
  
  // ... build method ...

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_request == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Request not found')),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        title: Text('Request Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  _request?.title ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _request?.description ?? '',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                Text('Responses (${_comments.length})', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                if (_comments.isEmpty)
                  Text('No responses yet.', style: TextStyle(color: AppTheme.textMuted))
                else
                  ..._comments.map((c) => _buildComment(c)).toList(),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildComment(Comment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                child: Text(c.user?.fullName.isNotEmpty == true ? c.user!.fullName[0] : '?', style: const TextStyle(color: AppTheme.primaryColor)),
              ),
              const SizedBox(width: 12),
              Text(c.user?.fullName ?? 'User', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.text, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardTheme.color,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'Add response...', hintStyle: TextStyle(color: AppTheme.textMuted), border: InputBorder.none),
            ),
          ),
          IconButton(onPressed: _sendComment, icon: const Icon(Icons.send, color: AppTheme.primaryColor)),
        ],
      ),
    );
  }
}
