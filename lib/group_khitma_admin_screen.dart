import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'group_info_screen.dart';
import 'group_manage_members_screen.dart';
import 'khitma_juzz_assign_admin_screen.dart';

class DhikrGroupDetailsScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const DhikrGroupDetailsScreen({super.key, this.groupId, this.groupName});

  @override
  State<DhikrGroupDetailsScreen> createState() =>
      _DhikrGroupDetailsScreenState();
}

class _DhikrGroupDetailsScreenState extends State<DhikrGroupDetailsScreen> {
  bool _loading = false;
  String? _error;
  // Group fields
  String? _name;
  int? _creatorId;
  bool _isPublic = true;
  int _membersCount = 0;
  int? _membersTarget;
  int? _daysToComplete;
  String? _startDate;
  int? _completedJuz;
  int _totalJuz = 30;
  // Pages progress (Mushaf-based)
  int _pagesRead = 0;
  int _totalPagesMushaf = 604;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _name = widget.groupName;
    if (widget.groupId != null) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    final id = widget.groupId!;
    final resp = await ApiClient.instance.getGroup(id);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = resp.error ?? 'Failed to load group'; });
      return;
    }
    final data = resp.data as Map<String, dynamic>;
    final g = (data['group'] as Map?)?.cast<String, dynamic>() ?? {};

    // Parse
    final summary = (g['summary'] as Map?)?.cast<String, dynamic>();
    final membersCount = (g['members_count'] as int?) ?? 0;
    final members = (g['members'] as List?)?.cast<dynamic>() ?? const [];

    // Determine admin
    final myId = context.read<ProfileProvider?>()?.id;
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

    setState(() {
      _name = (g['name'] as String?) ?? _name;
      _creatorId = (g['creator_id'] is int) ? g['creator_id'] as int : int.tryParse('${g['creator_id'] ?? ''}');
      _isPublic = (g['is_public'] == true);
      _membersCount = membersCount;
      _membersTarget = (g['members_target'] as int?);
      _daysToComplete = (g['days_to_complete'] as int?);
      _startDate = (g['start_date'] as String?);
      _completedJuz = (summary != null) ? (summary['completed_juz'] as int?) : null;
      _totalJuz = (summary != null && summary['total_juz'] is int) ? summary['total_juz'] as int : 30;
      _isAdmin = isAdmin;
    });

    // Fetch pages progress (total pages + pages_read sum)
    int pagesTotal = 604;
    final pagesMeta = await ApiClient.instance.khitmaJuzPages();
    if (pagesMeta.ok) {
      final mp = (pagesMeta.data as Map?)?.cast<String, dynamic>();
      if (mp != null && mp['total_pages'] is int) {
        pagesTotal = mp['total_pages'] as int;
      }
    }

    int pagesRead = 0;
    final assigns = await ApiClient.instance.khitmaAssignments(id);
    if (assigns.ok) {
      final ad = (assigns.data as Map?)?.cast<String, dynamic>();
      final list = (ad?['assignments'] as List?)?.cast<dynamic>() ?? const [];
      for (final it in list) {
        final m = (it as Map).cast<String, dynamic>();
        final pr = m['pages_read'];
        if (pr is int && pr > 0) pagesRead += pr;
      }
    }

    if (!mounted) return;
    setState(() {
      _totalPagesMushaf = pagesTotal;
      _pagesRead = pagesRead;
      _loading = false;
    });
  }

  // Assign Juz now navigates to the dedicated admin screen
  void _openAssignJuzAdmin() {
    if (widget.groupId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeredScreen(
          groupId: widget.groupId,
          groupName: _name ?? widget.groupName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);
        final isArabic = languageProvider.isArabic;

        final progress = (_completedJuz ?? 0) / (_totalJuz == 0 ? 30 : _totalJuz);

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
                                icon: Icon(isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: textColor, size: 24),
                              ),
                              Expanded(
                                child: Text(
                                  isArabic ? 'تفاصيل ختمة المجموعة' : 'Group Khitma Details',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : (_error != null
                                  ? Center(child: Text(_error!, style: TextStyle(color: textColor)))
                                  : (widget.groupId == null
                                      ? Center(child: Text(isArabic ? 'معرّف المجموعة مفقود' : 'Missing group ID', style: TextStyle(color: textColor)))
                                      : RefreshIndicator(
                              onRefresh: _fetch,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
// Hero Card (modern, frosted glass)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFF2EDE0)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDarkMode
                                            ? [const Color(0xFFFFFFFF).withOpacity(0.06), const Color(0xFFFFFFFF).withOpacity(0.03)]
                                            : [const Color(0xFFFFFFFF).withOpacity(0.70), const Color(0xFFFFFFFF).withOpacity(0.55)],
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _name ?? (isArabic ? 'مجموعة بدون اسم' : 'Untitled Group'),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
                                                      ),
                                                    ),
                                                  ),
                                                  _privacyBadge(_isPublic, isDarkMode, isArabic),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              // Progress bar + percent (Juz)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(100),
                                                child: LinearProgressIndicator(
                                                  value: (progress.clamp(0.0, 1.0)).toDouble(),
                                                  minHeight: 10,
                                                  backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB),
                                                  valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? const Color(0xFFC2AEEA) : const Color(0xFF235347)),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '${_completedJuz ?? 0}/${_totalJuz} ${isArabic ? 'أجزاء مكتملة' : 'Juz completed'}',
                                                    style: TextStyle(color: isDarkMode ? Colors.white70 : const Color(0xFF374151)),
                                                  ),
                                                  Text(
                                                    '${(progress * 100).clamp(0, 100).round()}%'
                                                        '${isArabic ? '' : ''}',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : const Color(0xFF392852),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Pages progress (Mushaf)
                                              const SizedBox(height: 10),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(100),
                                                child: LinearProgressIndicator(
                                                  value: (((_totalPagesMushaf <= 0 ? 0.0 : (_pagesRead / _totalPagesMushaf)).clamp(0.0, 1.0))).toDouble(),
                                                  minHeight: 10,
                                                  backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB),
                                                  valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6)),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '${_pagesRead}/${_totalPagesMushaf} ${isArabic ? 'صفحات مقروءة' : 'Pages read'}',
                                                    style: TextStyle(color: isDarkMode ? Colors.white70 : const Color(0xFF374151)),
                                                  ),
                                                  Text(
'${(((_totalPagesMushaf <= 0 ? 0.0 : (_pagesRead / _totalPagesMushaf)) * 100).clamp(0.0, 100.0)).round()}%'
                                                        '${isArabic ? '' : ''}',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : const Color(0xFF392852),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _infoPill(Icons.people_outline, isArabic
                                                      ? 'الأعضاء: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}'
                                                      : 'Members: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}', isDarkMode),
                                                  if (_daysToComplete != null)
                                                    _infoPill(Icons.schedule, isArabic ? 'أيام: ${_daysToComplete}' : 'Days: ${_daysToComplete}', isDarkMode),
                                                  if (_startDate != null)
                                                    _infoPill(Icons.event, isArabic ? 'البدء: ${_startDate}' : 'Start: ${_startDate}', isDarkMode),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                                          if (widget.groupId == null) return;
                                          final oldVal = _isPublic;
                                          setState(() => _isPublic = val);
                                          final resp = await ApiClient.instance.updateGroupPrivacy(widget.groupId!, val);
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

                                  // Actions: vertical, full-width buttons with spacing
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,

                                    children: [
                                      _actionButton(
                                        icon: Icons.info_outline,
                                        label: isArabic ? 'معلومات المجموعة' : 'Group Info',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GroupInfoScreen(
                                                groupId: widget.groupId,
                                                groupName: _name ?? widget.groupName,
                                              ),
                                            ),
                                          );
                                        },
                                        isDarkMode: isDarkMode,
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
                                                  groupId: widget.groupId!,
                                                  groupName: _name ?? widget.groupName,
                                                ),

                                                ),
                                            );
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      if (_isAdmin) const SizedBox(height: 10),
                                                                            if (_isAdmin)
                                        _actionButton(
                                          icon: Icons.assignment_ind_outlined,
                                          label: isArabic ? 'تعيين الأجزاء' : 'Assign Juz',
                                          onTap: _openAssignJuzAdmin,
                                          isDarkMode: isDarkMode,
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ))),
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

  Widget _privacyBadge(bool isPublic, bool isDark, bool isArabic) {
    final color = isPublic ? const Color(0xFF235347) : const Color(0xFF392852);
    final label = isPublic ? (isArabic ? 'عام' : 'Public') : (isArabic ? 'خاص' : 'Private');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
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

  Widget _chip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
      ),
      child: Text(label, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D1B69), fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap, required bool isDarkMode}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
           border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFF2EDE0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: 16, color: isDarkMode ? Colors.white : const Color(0xFF2D1B69)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
