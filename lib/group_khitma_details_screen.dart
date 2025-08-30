import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wered/group_khitma_assignments_screen.dart';

import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'group_khitma_info_screen.dart';

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
      _loading = false;
    });
  }

  // Manual assign dialog and submit
  Future<void> _openManualAssignDialog() async {
    if (widget.groupId == null) return;
    final isArabic = context.read<LanguageProvider>().isArabic;

    // Fetch current members to build simple selector
    final resp = await ApiClient.instance.getGroup(widget.groupId!);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'تعذر تحميل الأعضاء' : 'Failed to load members')));
      return;
    }
    final group = ((resp.data as Map)['group'] as Map?)?.cast<String, dynamic>() ?? {};
    final members = (group['members'] as List?)?.cast<dynamic>() ?? const [];
    final items = members.map((m) => (m as Map).cast<String, dynamic>()).toList();

    int? selectedUserId;
    final Set<int> selectedJuz = {};

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(isArabic ? 'تعيين الأجزاء' : 'Assign Juz'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: isArabic ? 'العضو' : 'Member'),
                        value: selectedUserId,
                        items: [
                          for (final m in items)
                            DropdownMenuItem<int>(
                              value: (m['id'] is int) ? m['id'] as int : int.tryParse('${m['id'] ?? ''}'),
                              child: Text((m['username'] as String?)?.trim().isNotEmpty == true
                                  ? (m['username'] as String)
                                  : ((m['email'] as String?) ?? 'User')),
                            )
                        ],
                        onChanged: (v) => setLocal(() => selectedUserId = v),
                      ),
                      const SizedBox(height: 12),
                      Text(isArabic ? 'اختر الأجزاء' : 'Select Juz'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (int j = 1; j <= _totalJuz; j++)
                            FilterChip(
                              label: Text(j.toString()),
                              selected: selectedJuz.contains(j),
                              onSelected: (sel) {
                                setLocal(() {
                                  if (sel) {
                                    selectedJuz.add(j);
                                  } else {
                                    selectedJuz.remove(j);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedUserId == null || selectedJuz.isEmpty)
                      ? null
                      : () async {
                          final payload = [
                            {
                              'user_id': selectedUserId,
                              'juz_numbers': selectedJuz.toList()..sort(),
                            }
                          ];
                          final r = await ApiClient.instance.khitmaManualAssign(widget.groupId!, payload);
                          if (!mounted) return;
                          if (r.ok) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'تم التعيين' : 'Assigned')));
                            await _fetch();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? (isArabic ? 'فشل التعيين' : 'Assign failed'))));
                          }
                        },
                  child: Text(isArabic ? 'تعيين' : 'Assign'),
                ),
              ],
            );
          },
        );
      },
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

                        if (_loading)
                          const Expanded(child: Center(child: CircularProgressIndicator()))
                        else if (_error != null)
                          Expanded(child: Center(child: Text(_error!, style: TextStyle(color: textColor))))
                        else if (widget.groupId == null)
                          Expanded(child: Center(child: Text(isArabic ? 'معرّف المجموعة مفقود' : 'Missing group ID', style: TextStyle(color: textColor))))
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Stat Card
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFF2EDE0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _name ?? (isArabic ? 'مجموعة بدون اسم' : 'Untitled Group'),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : const Color(0xFF2D1B69)),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(isArabic ? 'التقدم' : 'Progress', style: TextStyle(color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280))),
                                                  const SizedBox(height: 6),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: LinearProgressIndicator(
                                                      value: progress.clamp(0.0, 1.0),
                                                      minHeight: 10,
                                                      backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB),
                                                      valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? const Color(0xFFC2AEEA) : const Color(0xFF235347)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text('${_completedJuz ?? 0}/${_totalJuz} ${isArabic ? 'أجزاء مكتملة' : 'Juz completed'}',
                                                      style: TextStyle(color: isDarkMode ? Colors.white70 : const Color(0xFF374151)))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _chip(isArabic ? 'الأعضاء: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}' : 'Members: ${_membersCount}${_membersTarget != null ? '/$_membersTarget' : ''}', isDarkMode),
                                            if (_daysToComplete != null) _chip(isArabic ? 'أيام: ${_daysToComplete}' : 'Days: ${_daysToComplete}', isDarkMode),
                                            if (_startDate != null) _chip(isArabic ? 'البدء: ${_startDate}' : 'Start: ${_startDate}', isDarkMode),
                                            _chip(_isPublic ? (isArabic ? 'عام' : 'Public') : (isArabic ? 'خاص' : 'Private'), isDarkMode),
                                          ],
                                        )
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

                                  // Actions: Group Info + Assign Juz (admin-only for assign)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _actionButton(
                                          icon: Icons.info_outline,
                                          label: isArabic ? 'معلومات المجموعة' : 'Group Info',
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => GroupInfoScreen(
                                                  groupId: widget.groupId,
                                                  groupName: _name,
                                                ),
                                              ),
                                            );
                                          },
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_isAdmin)
                                        Expanded(
                                          child: _actionButton(
                                            icon: Icons.assignment_ind_outlined,
                                            label: isArabic ? 'تعيين الأجزاء' : 'Assign Juz',
                                            onTap: _openManualAssignDialog,
                                            isDarkMode: isDarkMode,
                                          ),
                                        ),
                                    ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFF2EDE0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isDarkMode ? Colors.white : const Color(0xFF2D1B69)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : const Color(0xFF2D1B69))),
          ],
        ),
      ),
    );
  }
}
