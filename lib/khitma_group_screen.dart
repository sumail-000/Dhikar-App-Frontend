import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'profile_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'khitma_screen.dart';
import 'dhikr_screen.dart';
import 'bottom_nav_bar.dart';
import 'khitma_newgroup_screen.dart';
import 'services/api_client.dart';
import 'widgets/group_card.dart';
import 'group_khitma_info_screen.dart';

// Small chip helper for cozy density
Widget _chip(String label, bool isLightMode, Color greenColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isLightMode ? const Color(0xFFDAF1DE) : Colors.white10,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isLightMode ? const Color(0xFFB6D1C2) : Colors.white24),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: isLightMode ? greenColor : Colors.white),
    ),
  );
}

// Helpers for list building from API data
bool _isMemberOf(Map<String, dynamic> g, int? myUserId) {
  if (myUserId == null) return false;
  final isMemberVal = g['is_member'];
  if (isMemberVal is bool) return isMemberVal;
  if (g['my_membership'] != null) return true;
  final members = g['members'];
  if (members is List) {
    for (final m in members) {
      if (m is Map) {
        final id = (m['id'] ?? m['user_id']);
        if (id is int && id == myUserId) return true;
        if (id is String && int.tryParse(id) == myUserId) return true;
      }
    }
  }
  final memberIds = g['member_ids'];
  if (memberIds is List) {
    for (final id in memberIds) {
      if (id is int && id == myUserId) return true;
      if (id is String && int.tryParse(id) == myUserId) return true;
    }
  }
  // Creator is always a member of their group
  final creatorId = g['creator_id'];
  if (creatorId is int && creatorId == myUserId) return true;
  if (creatorId is String && int.tryParse(creatorId) == myUserId) return true;
  return false;
}

int _compareByRecent(Map<String, dynamic> a, Map<String, dynamic> b) {
  DateTime? parse(dynamic v) {
    if (v is String) {
      try {
        return DateTime.tryParse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  final ad = parse(a['created_at']);
  final bd = parse(b['created_at']);
  if (ad != null && bd != null) return bd.compareTo(ad); // newest first
  // Fallback: sort by id desc if available
  int idOf(Map<String, dynamic> m) {
    final v = m['id'];
    if (v is int) return v;
    return int.tryParse('${v ?? 0}') ?? 0;
  }
  return idOf(b).compareTo(idOf(a));
}

Widget buildJoinedList({
  required bool loading,
  required String? error,
  required List<Map<String, dynamic>> groups,
  required bool isLightMode,
  required Color greenColor,
  required Color creamColor,
  required int? myUserId,
  required Future<List<MemberAvatar>> Function(int groupId) membersPreviewFetcher,
  required bool isArabicLocale,
}) {
  // Loading & error states
  if (loading) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
  if (error != null && error.trim().isNotEmpty) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(child: Text(error)),
      ],
    );
  }

  // These groups are already scoped by the API to the current user (created or joined)
  final joined = groups;

  return ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: joined.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final g = joined[index];
      final String name = (g['name'] as String?) ?? '';
      final int membersCount = (g['members_count'] as int?) ?? 0;
      final int membersTarget = (g['members_target'] as int?) ?? 0;
      return FutureBuilder<List<MemberAvatar>>(
        future: membersPreviewFetcher((g['id'] as int)),
        builder: (context, snap) {
          final avatars = snap.data ?? const <MemberAvatar>[];
          return GroupCard(
            englishName: isArabicLocale ? '' : name,
            arabicName: isArabicLocale ? name : '',
            completed: membersCount,
            total: membersTarget,
            memberAvatars: avatars,
            plusCount: membersCount > 5 ? (membersCount - 5) : 0,
          );
        },
      );
    },
  );
}

Widget buildExploreJoin({
  required bool loading,
  required List<Map<String, dynamic>> groups,
  required bool isLightMode,
  required Color greenColor,
  required Color creamColor,
  required int? myUserId,
  required Future<List<MemberAvatar>> Function(int groupId) membersPreviewFetcher,
  required bool isArabicLocale,
  required Future<void> Function(int groupId, String name) openGroup,
}) {
  // Explore: all public groups, newest first (including groups I created or joined)
  final explore = groups.where((g) {
    final isPublic = (g['is_public'] == true);
    return isPublic;
  }).toList()
    ..sort(_compareByRecent);

  return ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 8),
    itemCount: explore.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final g = explore[index];
      final String name = (g['name'] as String?) ?? '';
      final int membersCount = (g['members_count'] as int?) ?? 0;
      final int membersTarget = (g['members_target'] as int?) ?? 0;
      return FutureBuilder<List<MemberAvatar>>(
        future: membersPreviewFetcher((g['id'] as int)),
        builder: (context, snap) {
          final avatars = snap.data ?? const <MemberAvatar>[];
          return GroupCard(
            englishName: isArabicLocale ? '' : name,
            arabicName: isArabicLocale ? name : '',
            completed: membersCount,
            total: membersTarget,
            memberAvatars: avatars,
            plusCount: membersCount > 5 ? (membersCount - 5) : 0,
            onTap: () async {
              final int gid = (g['id'] is int) ? g['id'] as int : int.parse('${g['id']}');
              await openGroup(gid, name);
            },
          );
        },
      );
    },
  );
}

class KhitmaGroupScreen extends StatefulWidget {
  const KhitmaGroupScreen({super.key});

  @override
  State<KhitmaGroupScreen> createState() => _KhitmaGroupScreenState();
}

class _KhitmaGroupScreenState extends State<KhitmaGroupScreen> {
  final Map<int, List<MemberAvatar>> _memberInitialsCache = {};
  int _selectedIndex = 1;
  int _selectedTab = 0; // 0 for Joined, 1 for Explore
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _explore = [];
  final TextEditingController _inviteController = TextEditingController();

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
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final resp = await ApiClient.instance.getGroups();
    final respExplore = await ApiClient.instance.getGroupsExplore();
    if (!mounted) return;
    if (resp.ok && resp.data is Map && respExplore.ok && respExplore.data is Map) {
      final list = (resp.data['groups'] as List).cast<dynamic>();
      final filtered = list
          .map((e) => (e as Map).cast<String, dynamic>())
          .where((g) => (g['type'] as String?) == 'khitma')
          .toList();
      final exploreList = (respExplore.data['groups'] as List).cast<dynamic>();
      final exploreFiltered = exploreList
          .map((e) => (e as Map).cast<String, dynamic>())
          .where((g) => (g['type'] as String?) == 'khitma')
          .toList();
      setState(() {
        _groups = filtered;
        _explore = exploreFiltered;
        _loading = false;
      });
    } else {
      setState(() {
        _error = resp.error ?? (respExplore.error ?? 'Failed to load groups');
        _loading = false;
      });
    }
  }

  Future<List<MemberAvatar>> _membersPreview(int groupId) async {
    if (_memberInitialsCache.containsKey(groupId)) {
      return _memberInitialsCache[groupId]!;
    }
    final resp = await ApiClient.instance.getGroup(groupId);
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

            String? username = (m['username'] as String?)?.trim();
            String? fullName = (m['name'] as String?)?.trim();

            String pickForInitials = '';
            if (username != null && username.isNotEmpty) {
              pickForInitials = username;
            } else if (fullName != null && fullName.isNotEmpty) {
              pickForInitials = fullName;
            }

            String initials = '?';
            if (pickForInitials.isNotEmpty) {
              // First alphanumeric only
              final m = RegExp(r'[A-Za-z0-9]').firstMatch(pickForInitials);
              if (m != null) {
                initials = pickForInitials[m.start].toUpperCase();
              }
            }
            return MemberAvatar(initials: initials);
          })
          .toList();

      // Fallback: if API returns no members but the current user is the creator, show the creator avatar
      if (items.isEmpty) {
        final my = context.read<ProfileProvider?>();
        final myId = my?.id;
        final creatorId = group['creator_id'];
        int? cid = (creatorId is int) ? creatorId : int.tryParse('${creatorId ?? ''}');
        if (myId != null && cid == myId) {
          if ((my?.avatarUrl ?? '').isNotEmpty) {
            items = [MemberAvatar(imageUrl: my!.avatarUrl!)];
          } else {
            final dn = (my?.displayName ?? '').trim();
            String initials = '?';
            if (dn.isNotEmpty) {
              final m = RegExp(r'[A-Za-z0-9]').firstMatch(dn);
              if (m != null) {
                initials = dn[m.start].toUpperCase();
              }
            }
            items = [MemberAvatar(initials: initials)];
          }
        }
      }

      if (items.length > 5) items = items.sublist(0, 5);
      _memberInitialsCache[groupId] = items;
      return items;
    }
    return const <MemberAvatar>[];
  }

  Future<void> _joinWithToken() async {
    final token = _inviteController.text.trim();
    if (token.isEmpty) return;
    setState(() => _loading = true);
    final resp = await ApiClient.instance.joinGroup(token: token);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? 'Error')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joined group successfully')),
    );
    _inviteController.clear();
    await _loadGroups();
  }

  @override
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
                // Background image
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
                if (!isLightMode)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
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
                                isArabic ? ' مجموعة خاتمة' : 'Khitma Groups',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final created = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const KhitmaNewgroupScreen(),
                                  ),
                                );
                                if (created == true) {
                                  await _loadGroups();
                                }
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
                        const SizedBox(height: 16),
                        // Tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isLightMode ? const Color(0xFFDAF1DE) : const Color(0xFFE3D9F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedTab = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0
                                          ? (isLightMode ? const Color(0xFF235347) : const Color(0xFFF2EDE0))
                                          : (isLightMode ? const Color(0xFFCCCCCC) : const Color(0xFFFFFFFF)),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        bottomLeft: Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'منضم' : 'Joined',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 0
                                              ? (isLightMode ? const Color(0xFFFFFFFF) : const Color.fromARGB(255, 57, 40, 82))
                                              : (isLightMode ? const Color.fromARGB(255, 5, 31, 32) : const Color.fromARGB(255, 204, 204, 204)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedTab = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1
                                          ? (isLightMode ? const Color(0xFF235347) : const Color(0xFFF2EDE0))
                                          : (isLightMode ? const Color(0xFFCCCCCC) : const Color(0xFFFFFFFF)),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(18),
                                        bottomRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'استكشاف' : 'Explore',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 1
                                              ? (isLightMode ? const Color(0xFFFFFFFF) : const Color.fromARGB(255, 57, 40, 82))
                                              : (isLightMode ? const Color.fromARGB(255, 5, 31, 32) : const Color.fromARGB(255, 204, 204, 204)),
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
                        // Content area
                        Expanded(
                          child: _selectedTab == 0
                              ? RefreshIndicator(
                                  onRefresh: _loadGroups,
                                  child: buildJoinedList(
                                    loading: _loading,
                                    error: _error,
                                    groups: _groups,
                                    isLightMode: isLightMode,
                                    greenColor: greenColor,
                                    creamColor: creamColor,
                                    myUserId: context.read<ProfileProvider?>()?.id,
                                    membersPreviewFetcher: _membersPreview,
                                    isArabicLocale: languageProvider.isArabic,
                                  ),
                                )
                              : buildExploreJoin(
                                  loading: _loading,
                                  groups: _explore,
                                  isLightMode: isLightMode,
                                  greenColor: greenColor,
                                  creamColor: creamColor,
                                  myUserId: context.read<ProfileProvider?>()?.id,
                                  membersPreviewFetcher: _membersPreview,
                                  isArabicLocale: languageProvider.isArabic,
                                  openGroup: (gid, name) async {
                                    final changed = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupInfoScreen(groupId: gid, groupName: name),
                                      ),
                                    );
                                    if (changed == true) {
                                      setState(() => _memberInitialsCache.clear());
                                      await _loadGroups();
                                    }
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
