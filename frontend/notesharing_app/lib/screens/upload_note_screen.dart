import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _customSubjectController = TextEditingController();
  int? _selectedSubjectId;
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Determine subject ID or Name
    int? subjectId;
    String? subjectName;
    
    if (_selectedSubjectId == -1) {
      subjectName = _customSubjectController.text.trim();
    } else {
      subjectId = _selectedSubjectId;
    }

    final success = await context.read<NotesProvider>().uploadNote(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      file: _selectedFile!,
      subjectId: subjectId,
      subjectName: subjectName,
      tags: _tagsController.text.trim().isNotEmpty ? _tagsController.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note uploaded successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload failed. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Upload Note',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Picker
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedFile != null 
                            ? AppTheme.success 
                            : (_selectedFile == null && isDark ? AppTheme.primaryColor.withOpacity(0.5) : AppTheme.textSecondary.withOpacity(0.2)),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                            color: _selectedFile != null ? AppTheme.success : AppTheme.primaryColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFile != null ? _fileName! : 'Tap to select file',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedFile != null ? AppTheme.success : AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF, DOC, PPT, Images (Max 50MB)',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                _buildLabel('Title'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Enter note title',
                  theme: theme,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a title';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Subject Dropdown
                _buildLabel('Subject'),
                const SizedBox(height: 8),
                Consumer<NotesProvider>(
                  builder: (context, provider, _) {
                    final otherSubject = Subject(
                      id: -1,
                      name: 'Other',
                      icon: 'add_circle_outline',
                      color: '#808080',
                      notesCount: 0,
                      createdAt: DateTime.now(),
                    );
                    
                    final subjects = [...provider.subjects, otherSubject];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedSubjectId,
                            decoration: InputDecoration(
                              hintText: 'Select subject',
                              hintStyle: TextStyle(color: AppTheme.textMuted),
                              prefixIcon: const Icon(Icons.category_outlined, color: AppTheme.primaryLight),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            dropdownColor: theme.cardTheme.color,
                            style: TextStyle(color: AppTheme.textPrimary),
                            items: subjects.map((subject) {
                              return DropdownMenuItem<int>(
                                value: subject.id,
                                child: Row(
                                  children: [
                                    if (subject.id == -1) 
                                      const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryColor)
                                    else
                                      Text(subject.name),
                                    if (subject.id == -1) ...[
                                      const SizedBox(width: 8),
                                      const Text('Other', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                    ]
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubjectId = value;
                                if (value != -1) {
                                  _customSubjectController.clear();
                                }
                              });
                            },
                            validator: (v) => v == null ? 'Please select a subject' : null,
                          ),
                        ),
                        
                        if (_selectedSubjectId == -1) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _customSubjectController,
                            hint: 'Enter new subject name',
                            theme: theme,
                            validator: (v) => (_selectedSubjectId == -1 && (v == null || v.isEmpty)) ? 'Subject name required' : null,
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('Description'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe what this note covers...',
                  maxLines: 4,
                  theme: theme,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a description';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tags
                _buildLabel('Tags (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _tagsController,
                  hint: 'e.g., exam, notes, chapter1 (comma separated)',
                  theme: theme,
                ),
                const SizedBox(height: 32),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cloud_upload, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Upload Note',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ThemeData theme,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }
}
