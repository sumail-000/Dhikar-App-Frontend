import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'profile_provider.dart';
import 'widgets/management_group_card.dart';
import 'group_khitma_admin_screen.dart';

class GroupManagementGroupsScreen extends StatefulWidget {
  const GroupManagementGroupsScreen({super.key});

  @override
  State<GroupManagementGroupsScreen> createState() => _GroupManagementGroupsScreenState();
}

class _GroupManagementGroupsScreenState extends State<GroupManagementGroupsScreen> {
  // Top tabs only: 0 = Dhikr, 1 = Khitma
  int _categoryTab = 1; // default to Khitma

  // Data state (only user's groups)
  bool _loadingDhikr = false;
  bool _loadingKhitma = false;
  String? _errorDhikr;
  String? _errorKhitma;
  List<Map<String, dynamic>> _dhikrGroups = [];
  List<Map<String, dynamic>> _khitmaGroups = [];

  bool _createdByMe(Map<String, dynamic> g, int? myId) {
    if (myId == null) return false;
    final cid = g['creator_id'];
    if (cid is int) return cid == myId;
    return int.tryParse('${cid ?? ''}') == myId;
  }

  @override
  void initState() {
    super.initState();
    _loadDhikr();
    _loadKhitma();
  }

  Future<void> _loadDhikr() async {
    setState(() { _loadingDhikr = true; _errorDhikr = null; });
    final resp = await ApiClient.instance.getGroups();
    if (!mounted) return;
    if (resp.ok && resp.data is Map) {
      final list = (resp.data['groups'] as List).cast<dynamic>();
      final joined = list.map((e) => (e as Map).cast<String, dynamic>())
          .where((g) => (g['type'] as String?) == 'dhikr')
          .toList();
      // filter admin-owned (created by me)
      final myId = context.read<ProfileProvider?>()?.id;
      final mine = joined.where((g) => _createdByMe(g, myId)).toList();
      setState(() { _dhikrGroups = mine; _loadingDhikr = false; });
    } else {
      setState(() { _errorDhikr = resp.error ?? 'Failed to load dhikr groups'; _loadingDhikr = false; });
    }
  }

  Future<void> _loadKhitma() async {
    setState(() { _loadingKhitma = true; _errorKhitma = null; });
    final resp = await ApiClient.instance.getGroups();
    if (!mounted) return;
    if (resp.ok && resp.data is Map) {
      final list = (resp.data['groups'] as List).cast<dynamic>();
      final joined = list.map((e) => (e as Map).cast<String, dynamic>())
          .where((g) => (g['type'] as String?) == 'khitma')
          .toList();
      // filter admin-owned (created by me)
      final myId = context.read<ProfileProvider?>()?.id;
      final mine = joined.where((g) => _createdByMe(g, myId)).toList();
      setState(() { _khitmaGroups = mine; _loadingKhitma = false; });
    } else {
      setState(() { _errorKhitma = resp.error ?? 'Failed to load khitma groups'; _loadingKhitma = false; });
    }
  }

  Widget _buildTabsBar({required bool isLightMode, required Color greenColor}) {
    final lang = context.read<LanguageProvider>();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isLightMode ? const Color(0xFFDAF1DE) : const Color(0xFFE3D9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _categoryTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: _categoryTab == 0
                      ? (isLightMode ? const Color(0xFF235347) : const Color(0xFFF2EDE0))
                      : (isLightMode ? const Color(0xFFCCCCCC) : const Color(0xFFFFFFFF)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: Text(
                    lang.isArabic ? 'الذكر' : 'Dhikr',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _categoryTab == 0
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
              onTap: () => setState(() => _categoryTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: _categoryTab == 1
                      ? (isLightMode ? const Color(0xFF235347) : const Color(0xFFF2EDE0))
                      : (isLightMode ? const Color(0xFFCCCCCC) : const Color(0xFFFFFFFF)),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: Text(
                    lang.isArabic ? 'الختمة' : 'Khitma',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _categoryTab == 1
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);
        final amiriFont = languageProvider.isArabic ? 'Amiri' : null;

        final isDhikr = _categoryTab == 0;
        final loading = isDhikr ? _loadingDhikr : _loadingKhitma;
        final error = isDhikr ? _errorDhikr : _errorKhitma;
        final groups = isDhikr ? _dhikrGroups : _khitmaGroups;

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: isLightMode ? Colors.white : themeProvider.backgroundColor,
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Stack(
              children: [
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
                              icon: Icon(Icons.arrow_back_ios, color: isLightMode ? greenColor : creamColor),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                languageProvider.isArabic ? 'إدارة المجموعات' : 'Group Management',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTabsBar(isLightMode: isLightMode, greenColor: greenColor),
                        const SizedBox(height: 16),
                        if (loading) const Expanded(child: Center(child: CircularProgressIndicator()))
                        else if (error != null && error.trim().isNotEmpty)
                          Expanded(child: Center(child: Text(error)))
                        else if (groups.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                languageProvider.isArabic ? 'لا توجد مجموعات حتى الآن' : 'No groups yet',
                                style: TextStyle(color: isLightMode ? greenColor : Colors.white),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: groups.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final g = groups[index];
                                final String name = (g['name'] as String?) ?? '';
                                final int membersCount = (g['members_count'] as int?) ?? 0;
                                final int membersTarget = (g['members_target'] as int?) ?? 0;
                                final int gid = (g['id'] is int) ? g['id'] as int : int.tryParse('${g['id']}') ?? 0;

                                // Admin management card with actions
                                return ManagementGroupCard(
                                  isArabic: languageProvider.isArabic,
                                  isLightMode: isLightMode,
                                  titleEnglish: name,
                                  titleArabic: name,
                                  membersCount: membersCount,
                                  membersTarget: membersTarget,
                                  isPublic: (g['is_public'] == true),
                                  groupId: gid,
                                  // Open khitma group details
                                  onOpen: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DhikrGroupDetailsScreen(
                                          groupId: gid,
                                          groupName: name,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    // Remove the deleted group from list and refresh UI
                                    setState(() {
                                      _khitmaGroups.removeWhere((x) => (x['id'] as int) == gid);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
