import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customSubjectController = TextEditingController(); // Added
  int? _selectedSubjectId; // Changed to ID
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  Future<void> _createRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    int? subjectId;
    String? subjectName;

    if (_selectedSubjectId == -1) {
      subjectName = _customSubjectController.text.trim();
    } else {
      subjectId = _selectedSubjectId;
    }

    final success = await context.read<RequestsProvider>().createRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subjectId: subjectId,
      subjectName: subjectName,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request created!'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create request'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Request Notes', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What notes do you need?', style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              Text('Title', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Chapter 5 Physics Notes',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Text('Subject', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Consumer<NotesProvider>(
                builder: (context, provider, _) {
                  final otherSubject = Subject(
                    id: -1, 
                    name: 'Other', 
                    icon: 'add', 
                    color: '#808080', 
                    notesCount: 0,
                    createdAt: DateTime.now(),
                  );
                  final subjects = [...provider.subjects, otherSubject];

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonFormField<int>(
                          value: _selectedSubjectId,
                          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                          dropdownColor: theme.cardTheme.color,
                          style: TextStyle(color: AppTheme.textPrimary),
                          hint: Text('Select subject', style: TextStyle(color: AppTheme.textMuted)),
                          items: subjects.map((s) => DropdownMenuItem<int>(
                            value: s.id, 
                            child: Row(
                              children: [
                                if (s.id == -1) 
                                  const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryColor)
                                else
                                  Text(s.name, style: TextStyle(color: AppTheme.textPrimary)),
                                if (s.id == -1) ...[
                                  const SizedBox(width: 8),
                                  const Text('Other', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                ]
                              ],
                            ),
                          )).toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedSubjectId = v;
                              if (v != -1) _customSubjectController.clear();
                            });
                          },
                        ),
                      ),
                      if (_selectedSubjectId == -1) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customSubjectController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter Subject Name',
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            filled: true,
                            fillColor: theme.cardTheme.color,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (_selectedSubjectId == -1 && (v == null || v.isEmpty)) ? 'Required' : null,
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              Text('Description', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe what you need in detail...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Post Request', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
