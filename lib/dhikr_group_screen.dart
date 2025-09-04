import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'khitma_screen.dart';
import 'dhikr_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_newgroup_screen.dart';
import 'services/api_client.dart';
import 'widgets/management_group_card.dart';
import 'group_dhikr_admin_screen.dart';
import 'group_dhikr_details_screen.dart';
import 'group_dhikr_info_screen.dart';
import 'dhikr_presets.dart';
import 'widgets/group_card.dart';
import 'profile_provider.dart';
import 'group_khitma_info_screen.dart';

class DhikrGroupScreen extends StatefulWidget {
  const DhikrGroupScreen({super.key});

  @override
  State<DhikrGroupScreen> createState() => _DhikrGroupScreenState();
}

class _DhikrGroupScreenState extends State<DhikrGroupScreen> {
  int _selectedIndex = 1;
  int _selectedTab = 0; // 0 for Joined, 1 for Explore
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _joined = [];
  List<Map<String, dynamic>> _explore = [];

  // Cache for member avatars preview per group
  final Map<int, List<MemberAvatar>> _memberAvatarsCache = {};

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DhikrScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KhitmaScreen()),
          );
          break;
        case 3:
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadJoined();
    _loadExplore();
  }

  Future<void> _loadJoined() async {
    setState(() { _loading = true; _error = null; });
final resp = await ApiClient.instance.getDhikrGroups();
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map) {
      setState(() { _error = resp.error ?? 'Failed to load groups'; _loading = false; });
      return;
    }
final list = (resp.data['groups'] as List).cast<dynamic>();
    final groups = list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    setState(() { _joined = groups; _loading = false; });
  }

  Future<void> _loadExplore() async {
final resp = await ApiClient.instance.getDhikrGroupsExplore();
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map) {
      // keep joined visible even if explore fails
      return;
    }
    final list = (resp.data['groups'] as List).cast<dynamic>();
final groups = list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    setState(() { _explore = groups; });
  }

  Future<List<MemberAvatar>> _membersPreview(int groupId) async {
    if (_memberAvatarsCache.containsKey(groupId)) {
      return _memberAvatarsCache[groupId]!;
    }
final resp = await ApiClient.instance.getDhikrGroup(groupId);
    if (resp.ok && resp.data is Map && (resp.data['group'] is Map)) {
      final group = (resp.data['group'] as Map).cast<String, dynamic>();
      final members = (group['members'] as List?)?.cast<dynamic>() ?? [];
      List<MemberAvatar> items = members
          .map((m) => (m as Map).cast<String, dynamic>())
          .map((m) {
            final avatar = (m['avatar_url'] as String?) ?? (m['avatar'] as String?);
            if (avatar != null && avatar.trim().isNotEmpty) {
              return MemberAvatar(imageUrl: avatar.trim());
            }
            final username = (m['username'] as String?)?.trim() ?? '';
            final initials = username.isNotEmpty ? username[0].toUpperCase() : '?';
            return MemberAvatar(initials: initials);
          })
          .toList();
      if (items.length > 5) items = items.sublist(0, 5);
      _memberAvatarsCache[groupId] = items;
      return items;
    }
    return const <MemberAvatar>[];
  }

  Future<void> _showJoinByCodeDialog() async {
    final lang = context.read<LanguageProvider>();
    final theme = context.read<ThemeProvider>();
    final isArabic = lang.isArabic;
    final isDark = theme.isDarkMode;
    final TextEditingController codeCtrl = TextEditingController();
    String? errorText;
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> doJoin() async {
              final token = codeCtrl.text.trim();
              if (token.isEmpty) {
                setLocal(() {
                  errorText = isArabic ? 'الرجاء إدخال الرمز' : 'Please enter the code';
                });
                return;
              }
              setLocal(() {
                loading = true;
                errorText = null;
              });
final resp = await ApiClient.instance.joinDhikrGroup(token: token);
              if (!mounted) return;
              if (!resp.ok) {
                final msg = resp.error?.toLowerCase() ?? '';
                String friendly;
                if (msg.contains('already')) {
                  friendly = isArabic ? 'أنت عضو بالفعل في هذه المجموعة' : 'You are already a member of this group';
                } else if (msg.contains('full') || msg.contains('limit') || msg.contains('complete')) {
                  friendly = isArabic ? 'اكتمل عدد أعضاء المجموعة' : 'Group members are complete';
                } else if (msg.contains('invalid') || msg.contains('expired') || msg.contains('not found') || msg.contains('token')) {
                  friendly = isArabic ? 'رمز الدعوة غير صالح' : 'Invalid invite code';
                } else {
                  friendly = resp.error ?? (isArabic ? 'حدث خطأ' : 'Error');
                }
                setLocal(() {
                  loading = false;
                  errorText = friendly;
                });
                return;
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'تم الانضمام إلى المجموعة بنجاح' : 'Joined group successfully')),
              );
              setState(() {
                _selectedTab = 0;
              });
              await _loadJoined();
            }

            final Color bg = isDark ? const Color(0xFF2D1B69) : Colors.white;
            final Color fg = isDark ? Colors.white : const Color(0xFF2D1B69);

            return AlertDialog(
              backgroundColor: bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              title: Text(
                isArabic ? 'الانضمام برمز' : 'Join by Code',
                style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: codeCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'أدخل رمز الدعوة' : 'Enter invite code',
                      hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: isDark ? Colors.white70 : const Color(0xFF205C3B)),
                      ),
                      errorText: errorText,
                    ),
                    style: TextStyle(color: fg, fontSize: 14),
                    onSubmitted: (_) => loading ? null : doJoin(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: TextStyle(color: fg)),
                ),
                ElevatedButton.icon(
                  onPressed: loading ? null : doJoin,
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.vpn_key_rounded, size: 18, color: Colors.white),
                  label: Text(isArabic ? 'انضم' : 'Join', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF205C3B),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _joinByToken(BuildContext context) async {
    final controller = TextEditingController();
    final isArabic = context.read<LanguageProvider>().isArabic;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'انضمام عبر رمز الدعوة' : 'Join by invite token'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: isArabic ? 'أدخل الرمز' : 'Enter token'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(onPressed: () async {
            final token = controller.text.trim();
            if (token.isEmpty) return;
            final resp = await ApiClient.instance.joinGroup(token: token);
            if (!mounted) return;
            Navigator.pop(ctx);
            if (!resp.ok) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.error ?? (isArabic ? 'فشل الانضمام' : 'Join failed'))));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'تم الانضمام' : 'Joined')));
              await _loadJoined();
            }
          }, child: Text(isArabic ? 'انضمام' : 'Join')),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: isLightMode
                ? Colors.white
                : themeProvider.backgroundColor,
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Stack(
              children: [
                // Background images covering entire screen
                // Background image for both themes
                Positioned.fill(
                  child: Opacity(
                    opacity: !isLightMode ? 0.5 : 1.0,
                    child: Image.asset(
                      themeProvider.backgroundImage3,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                // Color overlay for dark mode only
                if (!isLightMode)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                // Main content with SafeArea
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: isLightMode ? greenColor : creamColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Text(
                                isArabic ? 'مجموعات الذكر' : 'Dhikr Groups',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DhikrNewGroupScreen(),
                                      ),
                                    ).then((_) {
                                      if (mounted) _loadJoined();
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: isLightMode ? greenColor : creamColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isArabic ? 'إضافة جديد' : 'Add New',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isLightMode ? greenColor : creamColor,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tab buttons
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isLightMode
                                ? const Color(
                                    0xFFDAF1DE,
                                  ) // Light mode outer container color
                                : const Color(
                                    0xFFE3D9F6,
                                  ), // Dark mode outer container color
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0
                                          ? (isLightMode
                                                ? const Color(
                                                    0xFF235347,
                                                  ) // Light mode selected tab
                                                : const Color(
                                                    0xFFF2EDE0,
                                                  )) // Dark mode selected tab
                                          : (isLightMode
                                                ? const Color(
                                                    0xFFCCCCCC,
                                                  ) // Light mode selected tab
                                                : const Color(0xFFFFFFFF)),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        bottomLeft: const Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'منضم' : 'Joined',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 0
                                              ? (isLightMode
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color.fromARGB(
                                                        255,
                                                        57,
                                                        40,
                                                        82,
                                                      ))
                                              : (isLightMode
                                                    ? const Color.fromARGB(
                                                        255,
                                                        5,
                                                        31,
                                                        32,
                                                      )
                                                    : const Color.fromARGB(
                                                        255,
                                                        204,
                                                        204,
                                                        204,
                                                      )),
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1
                                          ? (isLightMode
                                                ? const Color(
                                                    0xFF235347,
                                                  ) // Light mode selected
                                                : const Color(
                                                    0xFFF2EDE0,
                                                  )) // Dark mode selected
                                          : (isLightMode
                                                ? const Color(
                                                    0xFFCCCCCC,
                                                  ) // Light mode selected
                                                : const Color(0xFFFFFFFF)),
                                      borderRadius: BorderRadius.only(
                                        topRight: const Radius.circular(18),
                                        bottomRight: const Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'استكشاف' : 'Explore',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 1
                                              ? (isLightMode
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color.fromARGB(
                                                        255,
                                                        57,
                                                        40,
                                                        82,
                                                      ))
                                              : (isLightMode
                                                    ? const Color.fromARGB(
                                                        255,
                                                        5,
                                                        31,
                                                        32,
                                                      )
                                                    : const Color.fromARGB(
                                                        255,
                                                        204,
                                                        204,
                                                        204,
                                                      )),
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Content list by tab
                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : (_error != null)
                                  ? Center(child: Text(_error!))
                                  : RefreshIndicator(
                                      onRefresh: () async { await _loadJoined(); await _loadExplore(); },
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        itemCount: (_selectedTab == 0 ? _joined : _explore).length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final g = (_selectedTab == 0 ? _joined : _explore)[index];
                                          final name = (g['name'] as String?) ?? '';
                                          final gid = g['id'] is int ? g['id'] as int : int.tryParse('${g['id']}') ?? 0;
                                              final membersCount = (g['members_count'] as int?) ?? 0;
                                              final membersTarget = (g['members_target'] as int?) ?? 0;
                                              final dhikrCount = (g['dhikr_count'] as int?) ?? 0;
                                              final dhikrTarget = (g['dhikr_target'] as int?) ?? 0;
                                              return FutureBuilder<List<MemberAvatar>>(
                                                future: _membersPreview(gid),
                                                builder: (context, snap) {
                                                  final avatars = snap.data ?? const <MemberAvatar>[];
final String? dhikrArabic = (g['dhikr_title_arabic'] as String?);
                                                  return GroupCard(
                                                    englishName: languageProvider.isArabic ? '' : name,
                                                    arabicName: languageProvider.isArabic ? name : '',
                                                    completed: dhikrCount,
                                                    total: dhikrTarget,
                                                    memberAvatars: avatars,
                                                    plusCount: membersCount > 5 ? (membersCount - 5) : 0,
                                                    dhikrArabicRight: dhikrArabic,
                                                    onTap: () async {
                                                  if (_selectedTab == 0) {
                                                    // Joined tab: open Dhikr details (counter) using local list data
                                                    final String title = (g['dhikr_title'] as String?)?.trim() ?? name;
                                                    final String titleAr = (g['dhikr_title_arabic'] as String?)?.trim() ?? (dhikrArabic ?? '');
                                                    final int target = (g['dhikr_target'] as int?) ?? 0;
                                                    final int current = (g['dhikr_count'] as int?) ?? 0;
                                                    String subtitle = '';
                                                    try {
                                                      final match = DhikrPresets.presets.firstWhere(
                                                        (p) => (p['title'] == title) || (p['titleArabic'] == titleAr),
                                                      );
                                                      subtitle = (match['subtitle'] ?? '').toString();
                                                    } catch (_) {}
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => GroupDhikrDetailsScreen(
                                                          groupId: gid,
                                                          dhikrTitle: title,
                                                          dhikrTitleArabic: titleAr.isNotEmpty ? titleAr : title,
                                                          dhikrSubtitle: subtitle,
                                                          dhikrArabic: titleAr.isNotEmpty ? titleAr : title,
                                                          target: target,
                                                          currentCount: current,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Explore tab: show read-only info screen with Join option
                                                    final joined = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => GroupDhikrInfoScreen(
                                                          groupId: gid,
                                                          groupName: name,
                                                        ),
                                                      ),
                                                    );
                                                    if (!mounted) return;
                                                    if (joined == true) {
                                                      // Switch to Joined tab and refresh
                                                      setState(() { _selectedTab = 0; });
                                                      await _loadJoined();
                                                    }
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: _selectedTab == 0
                ? FloatingActionButton.small(
                    onPressed: _showJoinByCodeDialog,
                    backgroundColor: isLightMode ? const Color(0xFF205C3B) : const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.vpn_key_rounded, size: 18),
                  )
                : null,
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        );
      },
    );
  }
}
