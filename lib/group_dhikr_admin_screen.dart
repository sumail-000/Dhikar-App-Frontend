import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'group_info_screen.dart';
import 'group_manage_members_screen.dart';
import 'group_dhikr_info_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupDhikrAdminScreen extends StatefulWidget {
  final int groupId;
  final String? groupName;
  const GroupDhikrAdminScreen({super.key, required this.groupId, this.groupName});

  @override
  State<GroupDhikrAdminScreen> createState() => _GroupDhikrAdminScreenState();
}

class _GroupDhikrAdminScreenState extends State<GroupDhikrAdminScreen> {
  bool _loading = false;
  String? _error;

  // Group fields
  String? _name;
  int? _creatorId;
  bool _isPublic = true;
  int _membersCount = 0;
  int? _membersTarget;
  int? _daysToComplete;

  // Dhikr goal/progress
  int _dhikrTarget = 0;
  int _dhikrCurrent = 0;

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _name = widget.groupName;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    final resp = await ApiClient.instance.getDhikrGroup(widget.groupId);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = resp.error ?? 'Failed to load group'; });
      return;
    }

    final data = resp.data as Map<String, dynamic>;
    final g = (data['group'] as Map?)?.cast<String, dynamic>() ?? {};
    final members = (g['members'] as List?)?.cast<dynamic>() ?? const [];
    final myId = context.read<ProfileProvider?>()?.id;

    // Determine admin (creator or role=admin)
    bool isAdmin = false;
    if (myId != null) {
      final cid = (g['creator_id'] is int) ? g['creator_id'] as int : int.tryParse('${g['creator_id'] ?? ''}');
      if (cid != null && cid == myId) {
        isAdmin = true;
      } else {
        for (final m in members) {
          final mm = (m as Map).cast<String, dynamic>();
          final uid = (mm['id'] is int) ? mm['id'] as int : int.tryParse('${mm['id'] ?? ''}');
          final role = (mm['role'] as String?)?.toLowerCase();
          if (uid == myId && role == 'admin') { isAdmin = true; break; }
        }
      }
    }

    // Extract summary and dhikr metrics (best-effort keys)
    final summary = (g['summary'] as Map?)?.cast<String, dynamic>();
    int target = 0;
    int current = 0;
    if (summary != null) {
      // Try common keys
      target = _coerceInt(summary['dhikr_target']) ?? _coerceInt(summary['target']) ?? 0;
      current = _coerceInt(summary['dhikr_completed']) ?? _coerceInt(summary['completed']) ?? _coerceInt(summary['count']) ?? 0;
    }
    // Fallback direct group fields
    target = target != 0 ? target : (_coerceInt(g['dhikr_target']) ?? 0);
    current = current != 0 ? current : (_coerceInt(g['dhikr_count']) ?? 0);

    setState(() {
      _name = (g['name'] as String?) ?? _name;
      _creatorId = (g['creator_id'] is int) ? g['creator_id'] as int : int.tryParse('${g['creator_id'] ?? ''}');
      _isPublic = (g['is_public'] == true);
      _membersCount = (g['members_count'] as int?) ?? members.length;
      _membersTarget = (g['members_target'] as int?);
      _daysToComplete = (g['days_to_complete'] as int?);
      _dhikrTarget = target;
      _dhikrCurrent = current;
      _isAdmin = isAdmin;
      _loading = false;
    });
  }

  int? _coerceInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final textColor = isDark ? Colors.white : const Color(0xFF2D1B69);
        final accent = const Color(0xFF8B5CF6);

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
                      opacity: isDark ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        colorFilter: isDark ? null : const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: TextStyle(color: textColor)))
                            : Column(
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => Navigator.pop(context),
                                          icon: Icon(isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: textColor, size: 24),
                                        ),
                                        Expanded(
                                          child: Text(
                                            isArabic ? 'تفاصيل مجموعة الذكر' : 'Group Dhikr Details',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(width: 48),
                                      ],
                                    ),
                                  ),

                                  // Content
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Card: Group header and progress
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _name ?? (isArabic ? 'مجموعة بدون اسم' : 'Untitled Group'),
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
                                                ),
                                                const SizedBox(height: 8),
                                                // Dhikr goal progress
                                                Builder(builder: (_) {
                                                  final target = _dhikrTarget;
                                                  final current = _dhikrCurrent;
                                                  final double value = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(100),
                                                        child: LinearProgressIndicator(
                                                          value: value,
                                                          minHeight: 10,
                                                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                                                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            isArabic
                                                                ? 'الذكر: $current/$target'
                                                                : 'Dhikr: $current/$target',
                                                            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF374151)),
                                                          ),
                                                          Text(
                                                            '${(value * 100).round()}%',
                                                            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    _infoPill(Icons.people_outline, isArabic
                                                        ? 'الأعضاء: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}'
                                                        : 'Members: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}', isDark),
                                                    if (_daysToComplete != null)
                                                      _infoPill(Icons.calendar_today_outlined, isArabic
                                                          ? 'الأيام: ${_daysToComplete}'
                                                          : 'Days: ${_daysToComplete}', isDark),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          // Privacy toggle
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(isArabic ? 'حالة الخصوصية' : 'Privacy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                                              Switch.adaptive(
                                                value: _isPublic,
                                                onChanged: !_isAdmin ? null : (val) async {
                                                  final oldVal = _isPublic;
                                                  setState(() => _isPublic = val);
                                                  final resp = await ApiClient.instance.updateDhikrGroupPrivacy(widget.groupId, val);
                                                  if (!mounted) return;
                                                  if (!resp.ok) {
                                                    setState(() => _isPublic = oldVal);
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'فشل تحديث الخصوصية' : 'Failed to update privacy')));
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // Actions
                                          _actionButton(
                                            icon: Icons.info_outline,
                                            label: isArabic ? 'معلومات المجموعة' : 'Group Info',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => GroupDhikrInfoScreen(
                                                    groupId: widget.groupId,
                                                    groupName: _name ?? widget.groupName,
                                                  ),
                                                ),
                                              );
                                            },
                                            isDarkMode: isDark,
                                          ),
                                          const SizedBox(height: 10),
                                          if (_isAdmin)
                                            _actionButton(
                                              icon: Icons.group_outlined,
                                              label: isArabic ? 'إدارة الأعضاء' : 'Manage Members',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                  builder: (_) => GroupManageMembersScreen(
                                                    groupId: widget.groupId,
                                                    groupName: _name ?? widget.groupName,
                                                    isDhikr: true,
                                                  ),
                                                  ),
                                                );
                                              },
                                              isDarkMode: isDark,
                                            ),
                                        ],
                                      ),
                                    ),
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

  Widget _infoPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : const Color(0xFF2D1B69)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D1B69), fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
          foregroundColor: isDarkMode ? const Color(0xFF2D1B69) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

