import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';

class GroupInfoScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;
  final List<Map<String, dynamic>>? members; // fallback for legacy usage

  const GroupInfoScreen({super.key, this.groupId, this.groupName, this.members});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool _loading = false;
  String? _error;
  String? _name;
  bool _isPublic = false;
  int? _creatorId;
  bool _joining = false;
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _name = widget.groupName;
    if (widget.groupId != null) {
      _fetch();
    } else {
      // Fallback to provided members and name if groupId is not provided
      _members = (widget.members ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final id = widget.groupId!;
    final resp = await ApiClient.instance.getGroup(id);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() {
        _loading = false;
        _error = resp.error ?? 'Failed to load group';
      });
      return;
    }
    final data = resp.data as Map<String, dynamic>;
    final group = (data['group'] as Map?)?.cast<String, dynamic>() ?? {};
    final ms = (group['members'] as List?)?.cast<dynamic>() ?? const [];
    setState(() {
      _name = group['name'] as String? ?? widget.groupName;
      _isPublic = (group['is_public'] == true);
      _creatorId = (group['creator_id'] is int)
          ? group['creator_id'] as int
          : int.tryParse('${group['creator_id'] ?? ''}');
      _members = ms.map((m) => (m as Map).cast<String, dynamic>()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);
        final profile = Provider.of<ProfileProvider?>(context);
        final myId = profile?.id;

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  languageProvider.isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  languageProvider.isArabic ? 'معلومات المجموعة' : 'Group Info.',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Group Name - more compact
                        Text(
                          _name ?? (languageProvider.isArabic ? 'دائرة القرآن' : "The Qur'an Circle"),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Members List title with count on right (as in UI)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                languageProvider.isArabic ? 'قائمة الأعضاء' : 'Members List',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                              ),
                              Text(
                                languageProvider.isArabic ? '${_members.length} عضو' : '${_members.length} Members',
                                style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : (_error != null)
                                  ? Center(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : textColor.withOpacity(0.8)),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      itemCount: _members.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final m = _members[index];
                                        final uid = (m['id'] is int) ? m['id'] as int : int.tryParse('${m['id'] ?? ''}');
                                        final username = (m['username'] as String?)?.trim() ?? '';
                                        final email = (m['email'] as String?)?.trim() ?? '';
                                        final avatar = (m['avatar_url'] as String?)?.trim() ?? '';

                                        String displayName = username.isNotEmpty ? username : (languageProvider.isArabic ? '—' : '—');
                                        if (myId != null && uid == myId) {
                                          displayName = languageProvider.isArabic ? '$displayName (أنت)' : '$displayName (You)';
                                        }

                                        return Container(
                                          // Figma: width: 408, height: 82
                                          height: 82,
                                          margin: const EdgeInsets.symmetric(horizontal: 0),
                                          decoration: BoxDecoration(
                                            // No background color as per Figma
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              // Figma: border: 1px solid #F2EDE0
                                              color: isDarkMode ? Colors.white.withOpacity(0.2) : const Color(0xFFF2EDE0),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              // Profile Avatar
                                              // Figma: width: 50, height: 50, left: 32px (16px margin + 16px padding)
                                              Positioned(
                                                left: 16, // 32px from screen edge - 16px container margin = 16px
                                                top: 16,  // Center vertically in 82px height: (82-50)/2 = 16
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    // Figma: background: #D9D9D9
                                                    color: isDarkMode ? const Color(0xFF4A5568) : const Color(0xFFD9D9D9),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: avatar.isNotEmpty
                                                      ? Image.network(avatar, fit: BoxFit.cover)
                                                      : Center(
                                                          child: Text(
                                                            (displayName.isNotEmpty ? displayName[0] : '?').toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              // Name and Email Column - Stacked vertically for better readability
                                              Positioned(
                                                left: 78, // Same starting position as before
                                                top: 20,  // Slightly higher to accommodate two lines
                                                right: 16, // Extend to right edge for better text space
                                                height: 42, // Enough height for both name and email
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // Name Text
                                                    Text(
                                                      displayName,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Manrope',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600, // Make name slightly bolder for hierarchy
                                                        height: 1.1,
                                                        letterSpacing: 0,
                                                        color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2), // Small gap between name and email
                                                    // Email Text
                                                    Text(
                                                      email,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Manrope',
                                                        fontSize: 14, // Slightly smaller for secondary information
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.1,
                                                        letterSpacing: 0,
                                                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280), // Lighter color for secondary info
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        // Footer join bar
                        if (widget.groupId != null)
                          Builder(
                            builder: (_) {
                              final gid = widget.groupId!;
                              final amMember = _members.any((m) {
                                final id = (m['id'] is int) ? m['id'] as int : int.tryParse('${m['id'] ?? ''}');
                                return id != null && id == myId;
                              }) || (myId != null && _creatorId == myId);
                              final showJoin = _isPublic && !amMember;
                              if (!showJoin) return const SizedBox.shrink();
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.9),
                                  border: Border(
                                    top: BorderSide(
                                      color: isDarkMode ? Colors.white24 : const Color(0xFFE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _joining
                                        ? null
                                        : () async {
                                            setState(() => _joining = true);
                                            final r = await ApiClient.instance.joinPublicGroup(gid);
                                            if (!mounted) return;
                                            setState(() => _joining = false);
                                            if (!r.ok) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(r.error ?? (languageProvider.isArabic ? 'خطأ' : 'Error'))),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(languageProvider.isArabic ? 'تم الانضمام بنجاح' : 'Joined successfully')),
                                              );
                                              Navigator.pop(context, true);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode ? Colors.white.withOpacity(0.2) : const Color(0xFF2E7D32),
                                      foregroundColor: isDarkMode ? textColor : Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        side: BorderSide(
                                          color: isDarkMode ? textColor : Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: _joining
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Text(
                                            languageProvider.isArabic ? 'انضمام إلى المجموعة' : 'Join Group',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
