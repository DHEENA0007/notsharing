import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _collegeController;
  late TextEditingController _courseController;
  late TextEditingController _yearController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _collegeController = TextEditingController(text: user?.college ?? '');
    _courseController = TextEditingController(text: user?.course ?? '');
    _yearController = TextEditingController(text: user?.year ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await context.read<AuthProvider>().updateProfile({
      'username': _usernameController.text.trim(),
      'full_name': _nameController.text.trim(),
      'college': _collegeController.text.trim(),
      'course': _courseController.text.trim(),
      'year': _yearController.text.trim(),
      'bio': _bioController.text.trim(),
    });
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppTheme.error),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Full Name', _nameController, isDark),
              const SizedBox(height: 16),
              _buildField('Username', _usernameController, isDark),
              const SizedBox(height: 16),
              _buildField('College', _collegeController, isDark),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildField('Course', _courseController, isDark)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField('Year', _yearController, isDark)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Bio', _bioController, maxLines: 3, isDark),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Center(
                child: TextButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_outline, color: AppTheme.accentPink),
                  label: Text('Change Password', style: GoogleFonts.outfit(color: AppTheme.accentPink, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isDark, {int maxLines = 1}) {
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final fillColor = isDark ? const Color(0xFF2C2C2C) : Theme.of(context).cardTheme.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_newController.text != _confirmController.text) {
      setState(() => _error = "Passwords don't match");
      return;
    }
    
    setState(() { _isLoading = true; _error = null; });
    
    final result = await context.read<AuthProvider>().changePassword(
      oldPassword: _oldController.text, 
      newPassword: _newController.text, 
      confirmPassword: _confirmController.text
    );
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully'), backgroundColor: AppTheme.success),
        );
      }
    } else {
      if (mounted) setState(() => _error = result['error'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final fillColor = isDark ? const Color(0xFF3A3A3A) : null; // Slightly lighter check

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
              ),
            _buildDialogField('Current Password', _oldController, isDark),
            const SizedBox(height: 10),
            _buildDialogField('New Password', _newController, isDark),
            const SizedBox(height: 10),
            _buildDialogField('Confirm Password', _confirmController, isDark),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : null))),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  Widget _buildDialogField(String label, TextEditingController controller, bool isDark) {
      final textColor = isDark ? Colors.white : AppTheme.textPrimary;
      final fillColor = isDark ? const Color(0xFF3A3A3A) : null;

      return TextFormField(
        controller: controller,
        obscureText: true,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          filled: isDark,
          fillColor: fillColor,
          border: isDark ? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none) : null,
        ),
        validator: (v) => v?.isEmpty == true ? 'Required' : null,
      );
  }
}
