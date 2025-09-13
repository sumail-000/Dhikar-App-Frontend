import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'theme_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfileScreen extends StatefulWidget {
  final String? name; // current username (server-side uses username)
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
  String? _serverAvatarUrl; // live server avatar preview

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.name ?? '';
    _serverAvatarUrl = widget.avatarUrl;
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

  Future<void> _handleSave() async {
    final app = AppLocalizations.of(context)!;
    // Normalize: collapse multiple spaces and trim
    final name = _usernameController.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Letters+spaces only (Latin extended + Arabic blocks)
    final usernamePattern = RegExp(
        r'^[A-Za-z\u00C0-\u024F\u1E00-\u1EFF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+(?: [A-Za-z\u00C0-\u024F\u1E00-\u1EFF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+)*$',
        unicode: true);
    if (name.isEmpty || name.length > 255 || !usernamePattern.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.invalidUsername)),
      );
      return;
    }

    String? avatarPath;
    if (_picked != null) {
      final path = _picked!.path;
      final ext = path.split('.').last.toLowerCase();
      if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.invalidImageType)),
        );
        return;
      }
      final file = File(path);
      final size = await file.length();
      if (size > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.imageTooLarge)),
        );
        return;
      }
      avatarPath = path;
    }

    setState(() => _saving = true);
    final resp = await ApiClient.instance.updateProfile(
      username: name,
      avatarFilePath: avatarPath,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? 'Error')),
      );
      return;
    }

    // Update local preview from server response if available
    try {
      final data = resp.data as Map<String, dynamic>;
      final user = (data['user'] as Map<String, dynamic>?);
      final newUrl = user?['avatar_url'] as String?;
      if (newUrl != null && newUrl.isNotEmpty) {
        setState(() => _serverAvatarUrl = newUrl);
      }
    } catch (_) {}

    // Refresh shared profile state so other screens update
    await context.read<ProfileProvider>().refresh();

    Navigator.pop(context, {
      'name': name,
      'avatarChanged': _picked != null,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(app.profileUpdated)),
    );
  }

  Future<void> _handleRemovePhoto() async {
    final app = AppLocalizations.of(context)!;
    if (_picked != null) {
      setState(() => _picked = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.avatarRemoved)),
      );
      return;
    }
    final resp = await ApiClient.instance.deleteAvatar();
    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? 'Error')),
      );
      return;
    }
    // Update local preview and global state
    setState(() => _serverAvatarUrl = null);
    await context.read<ProfileProvider>().refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(app.avatarRemoved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final app = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF251629) : themeProvider.screenBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
          )
              : null,
        ),
        child: Stack(
          children: [
            // Background SVG overlay
            Positioned.fill(
              child: Opacity(
                opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                child: SvgPicture.asset(
                  'assets/background_elements/3_background.svg',
                  fit: BoxFit.cover,
                  colorFilter: themeProvider.isDarkMode ? null : const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
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
                                : (_serverAvatarUrl != null && _serverAvatarUrl!.isNotEmpty
                                ? Image.network(_serverAvatarUrl!, width: 120, height: 120, fit: BoxFit.cover)
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
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onEditingComplete: () {
                        final s = _usernameController.text.replaceAll(RegExp(r'\s+'), ' ').trim();
                        if (_usernameController.text != s) {
                          _usernameController.value = _usernameController.value.copyWith(
                            text: s,
                            selection: TextSelection.collapsed(offset: s.length),
                            composing: TextRange.empty,
                          );
                        }
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.usernameRules,
                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF205C3B), fontSize: 12),
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

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _handleSave,
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
                      onPressed: _handleRemovePhoto,
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
          ],
        ),
    ),
    );
  }
}
