import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String? name;
  final String? email; // read-only display
  final String? avatarUrl;
  const EditProfileScreen({super.key, this.name, this.email, this.avatarUrl});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  XFile? _picked;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.name ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _bottomSheetPick() async {
    final app = AppLocalizations.of(context)!;
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(app.camera),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(app.gallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: source, imageQuality: 85);
    if (result != null) {
      setState(() => _picked = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final app = AppLocalizations.of(context)!;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, color: themeProvider.screenBackgroundColor),
          Positioned.fill(
            child: Opacity(
              opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
              child: Image.asset(themeProvider.backgroundImage3, fit: BoxFit.cover),
            ),
          ),
          if (themeProvider.isDarkMode)
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),
          SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF205C3B)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            app.editProfile,
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF205C3B),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: themeProvider.isDarkMode ? themeProvider.cardBackgroundColor : Colors.grey.shade100,
                                border: Border.all(color: themeProvider.borderColor, width: 3),
                              ),
                              child: ClipOval(
                                child: _picked != null
                                    ? Image.file(File(_picked!.path), width: 120, height: 120, fit: BoxFit.cover)
                                    : (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                                        ? Image.network(widget.avatarUrl!, width: 120, height: 120, fit: BoxFit.cover)
                                        : Icon(Icons.person, color: themeProvider.primaryTextColor, size: 46)),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _bottomSheetPick,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.15) : const Color(0xFF205C3B),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: themeProvider.borderColor),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Username
                      Text(app.username, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF205C3B), fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: themeProvider.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: themeProvider.borderColor),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _usernameController,
                          style: TextStyle(color: themeProvider.primaryTextColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'sumail_007',
                            hintStyle: TextStyle(color: themeProvider.primaryTextColor.withOpacity(0.5)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email (read-only)
                      Text(app.email, style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF205C3B), fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: themeProvider.borderColor),
                        ),
                        child: Text(
                          widget.email ?? '-',
                          style: TextStyle(color: themeProvider.primaryTextColor, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        app.usernameRules,
                        style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF205C3B), fontSize: 12),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saving
                              ? null
                              : () {
                                  final name = _usernameController.text.trim();
                                  final valid = RegExp(r'^[A-Za-z0-9_]+$').hasMatch(name);
                                  if (name.isEmpty || !valid) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(app.invalidUsername)),
                                    );
                                    return;
                                  }

                                  setState(() => _saving = true);
                                  // Simulate client-only update for now
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (!mounted) return;
                                    setState(() => _saving = false);
                                    Navigator.pop(context, {
                                      'name': name,
                                      'avatarChanged': _picked != null,
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(app.profileUpdated)),
                                    );
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.15) : const Color(0xFF205C3B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(app.save),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Remove photo button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _picked = null),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: themeProvider.borderColor),
                            foregroundColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF205C3B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(app.removePhoto),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
