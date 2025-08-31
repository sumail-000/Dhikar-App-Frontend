import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'theme_provider.dart';
import 'services/api_client.dart';

class GroupKhitmaAssignmentsAdminScreen extends StatefulWidget {
  final int groupId;
  final String? groupName;
  final bool manualMode; // when true, render manual-assign UI
  const GroupKhitmaAssignmentsAdminScreen({super.key, required this.groupId, this.groupName, this.manualMode = false});

  @override
  State<GroupKhitmaAssignmentsAdminScreen> createState() => _GroupKhitmaAssignmentsAdminScreenState();
}

class _GroupKhitmaAssignmentsAdminScreenState extends State<GroupKhitmaAssignmentsAdminScreen> {
  bool _loading = false;
  bool _saving = false;
  String? _error;

  // Admin table rows (preview mode)
  List<_AssignmentRow> _rows = [];
  int _unassignedCount = 0;

  // Manual mode state
  List<_MemberAdmin> _members = [];
  Map<int, Set<int>> _selectedByUser = {}; // userId -> set of selected juz
  Map<int, int?> _currentOwner = {}; // juz -> userId/null from server
  Map<int, List<_AssignEntry>> _userEntries = {}; // userId -> assignment entries (for status)
  int? _expandedUserId;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });

    // Fetch group members first
    final groupResp = await ApiClient.instance.getGroup(widget.groupId);
    if (!mounted) return;
    if (!groupResp.ok || groupResp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = groupResp.error ?? 'Failed to load group'; });
      return;
    }
    final g = (groupResp.data['group'] as Map).cast<String, dynamic>();
    final members = (g['members'] as List?)?.cast<dynamic>() ?? const [];
    final membersList = members.map((m) {
      final mm = (m as Map).cast<String, dynamic>();
      final id = (mm['id'] is int) ? mm['id'] as int : int.tryParse('${mm['id'] ?? ''}') ?? 0;
      final username = (mm['username'] as String?)?.trim() ?? '';
      return _MemberAdmin(id: id, name: username.isNotEmpty ? username : '—');
    }).toList();

    // Fetch assignments
    final resp = await ApiClient.instance.khitmaAssignments(widget.groupId);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = resp.error ?? 'Failed to load assignments'; });
      return;
    }

    final List<dynamic> list = (resp.data['assignments'] as List?) ?? const [];

    if (!widget.manualMode) {
      // Build preview rows grouped by user id + an Unassigned bucket
      final Map<String, List<Map<String, dynamic>>> byUser = {};
      for (final e in list) {
        final m = (e as Map).cast<String, dynamic>();
        final user = (m['user'] as Map?)?.cast<String, dynamic>();
        final uidKey = user != null ? 'u:${user['id']}' : 'unassigned';
        byUser.putIfAbsent(uidKey, () => []).add(m);
      }

      final List<_AssignmentRow> rows = [];
      byUser.forEach((uidKey, items) {
        items.sort((a, b) => ((a['juz_number'] as int).compareTo(b['juz_number'] as int)));
        final first = items.isNotEmpty ? items.first : null;
        final user = (first != null ? (first['user'] as Map?)?.cast<String, dynamic>() : null);
        final name = uidKey == 'unassigned' ? 'Unassigned' : (((user?['username'] as String?)?.trim().isNotEmpty ?? false) ? (user!['username'] as String) : '—');

        final List<int> juz = items.map((it) => it['juz_number'] as int).toList();
        int pagesSum = 0; bool anyPages = false;
        for (final it in items) { final pr = it['pages_read']; if (pr is int && pr > 0) { anyPages = true; pagesSum += pr; } }

        String statusType;
        String statusText;
        final allCompleted = items.isNotEmpty && items.every((it) => (it['status'] as String?) == 'completed');
        if (uidKey == 'unassigned') { statusType = 'not_assigned'; statusText = 'Not Assigned'; }
        else if (allCompleted) { statusType = 'completed'; statusText = 'Completed'; }
        else if (anyPages) { statusType = 'pages_read'; statusText = pagesSum > 0 ? '$pagesSum Pages Read' : 'Pages Read'; }
        else if (items.isNotEmpty) { statusType = 'not_started'; statusText = 'Not Started'; }
        else { statusType = 'not_assigned'; statusText = 'Not Assigned'; }

        rows.add(_AssignmentRow(userId: uidKey == 'unassigned' ? null : (user!['id'] as int), name: name, juz: juz, statusText: statusText, statusType: statusType));
      });

      rows.sort((a, b) {
        if (a.name == 'Unassigned' && b.name != 'Unassigned') return 1;
        if (b.name == 'Unassigned' && a.name != 'Unassigned') return -1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      int unassignedCount = 0;
      for (final r in rows) { if (r.name == 'Unassigned') { unassignedCount = r.juz.length; break; } }

      setState(() { _rows = rows; _unassignedCount = unassignedCount; _loading = false; });
      return;
    }

    // Manual mode: build member list with current selections
    final Map<int, Set<int>> sel = { for (final m in membersList) m.id: <int>{} };
    final Map<int, int?> owner = { for (int j=1; j<=30; j++) j: null };
    final Map<int, List<_AssignEntry>> entries = { for (final m in membersList) m.id: <_AssignEntry>[] };

    for (final e in list) {
      final m = (e as Map).cast<String, dynamic>();
      final jn = m['juz_number'] as int;
      final user = (m['user'] as Map?)?.cast<String, dynamic>();
      final status = (m['status'] as String?) ?? 'unassigned';
      final pages = m['pages_read'];
      final uid = (user != null) ? ((user['id'] is int) ? user['id'] as int : int.tryParse('${user['id'] ?? ''}')) : null;
      owner[jn] = uid;
      if (uid != null) {
        sel.putIfAbsent(uid, () => <int>{}).add(jn);
        entries.putIfAbsent(uid, () => <_AssignEntry>[]).add(_AssignEntry(juz: jn, status: status, pagesRead: (pages is int) ? pages : 0));
      }
    }

    setState(() {
      _members = membersList;
      _selectedByUser = sel;
      _currentOwner = owner;
      _userEntries = entries;
      _unassignedCount = owner.values.where((v) => v == null).length;
      _loading = false;
    });
  }

  // ---- Formatting helpers ----
  String _formatJuzList(List<int> juz, bool isArabic) {
    if (juz.isEmpty) return _toArabicDigits('--', isArabic);
    final s = juz.toSet().toList()..sort();
    String out;
    if (s.length == 1) {
      out = '${s.first}';
    } else if (s.length == 2) {
      out = '${s[0]} & ${s[1]}';
    } else {
      bool contiguous = true;
      for (int i = 1; i < s.length; i++) { if (s[i] != s[i-1] + 1) { contiguous = false; break; } }
      out = contiguous ? '${s.first}-${s.last}' : s.join(', ');
    }
    return _toArabicDigits(out, isArabic);
  }

  String _toArabicDigits(String t, bool isArabic) {
    if (!isArabic) return t;
    const western = ['0','1','2','3','4','5','6','7','8','9'];
    const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    final buf = StringBuffer();
    for (final ch in t.split('')) { final idx = western.indexOf(ch); buf.write(idx >= 0 ? eastern[idx] : ch); }
    return buf.toString();
  }

  Color _statusColor(String statusType) {
    switch (statusType) {
      case 'completed': return const Color(0xFFC2AEEA);
      case 'pages_read': return const Color(0xFFD4D400);
      case 'not_assigned': return const Color(0xFFE65A5A);
      case 'not_started': return const Color(0xFF8B8B8B);
      default: return const Color(0xFFC2AEEA);
    }
  }

  String _localizedStatus(LanguageProvider lang, String english) {
    if (!lang.isArabic) return english;
    switch (english) {
      case 'Not Assigned': return 'غير مُعين';
      case 'Completed': return 'مكتمل';
      case 'Pages Read': return 'صفحات مقروءة';
      case 'Not Started': return 'لم يبدأ';
      default: return english;
    }
  }

  // ---- Manual mode actions ----
  void _toggleExpand(int userId) {
    setState(() { _expandedUserId = (_expandedUserId == userId) ? null : userId; });
  }

  bool _isTakenByOther(int juz, int userId) {
    // Taken if selected by a different user in current selections
    for (final entry in _selectedByUser.entries) {
      if (entry.key != userId && entry.value.contains(juz)) return true;
    }
    return false;
  }

  Future<void> _saveManual(LanguageProvider lang) async {
    setState(() { _saving = true; });

    // Build desired mapping from selections
    final Map<int, int> desired = {}; // juz -> userId
    _selectedByUser.forEach((uid, set) { for (final j in set) { desired[j] = uid; } });

    // Current mapping from server
    final Map<int, int?> current = Map<int, int?>.from(_currentOwner);

    // Build payload for manual-assign (only assigns)
    final Map<int, List<int>> groupByUser = {};
    desired.forEach((j, uid) { groupByUser.putIfAbsent(uid, () => <int>[]).add(j); });

    // List of Juz to unassign (present before, not desired now)
    final List<int> toUnassign = [];
    for (int j = 1; j <= 30; j++) {
      final curr = current[j];
      final want = desired[j];
      if (curr != null && want == null) { toUnassign.add(j); }
    }

    // 1) Assign in bulk
    if (groupByUser.isNotEmpty) {
      final payload = groupByUser.entries.map((e) => { 'user_id': e.key, 'juz_numbers': e.value..sort() }).toList();
      final r = await ApiClient.instance.khitmaManualAssign(widget.groupId, payload);
      if (!mounted) return; 
      if (!r.ok) {
        setState(() { _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.error ?? (lang.isArabic ? 'فشل الحفظ' : 'Save failed'))));
        return;
      }
    }

    // 2) Unassign those not desired
    for (final j in toUnassign) {
      final r2 = await ApiClient.instance.khitmaUpdateAssignment(widget.groupId, juzNumber: j, status: 'unassigned');
      if (!mounted) return; 
      if (!r2.ok) {
        setState(() { _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r2.error ?? (lang.isArabic ? 'فشل الحفظ' : 'Save failed'))));
        return;
      }
    }

    setState(() { _saving = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.isArabic ? 'تم الحفظ' : 'Saved')));
    await _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);
        final titleText = widget.manualMode
            ? (isArabic ? 'تعيين الأجزاء يدوياً' : 'Manual Assign Juz')
            : (isArabic ? 'الأجزاء المعيّنة تلقائياً' : 'Auto-assigned Juz');

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
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    icon: Icon(
                                      isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                                      color: textColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    height: 1.1,
                                    letterSpacing: 0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (!widget.manualMode)
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: IconButton(
                                      onPressed: () {
                                        final title = isArabic ? 'ما هو التعيين التلقائي؟' : 'What is Auto-assign?';
                                        final msg = isArabic
                                            ? 'يقوم التعيين التلقائي بتوزيع أجزاء الختمة (30 جزءاً) بالتساوي على أعضاء المجموعة حسب ترتيب الانضمام، ويبدأ بصاحب المجموعة أولاً. إذا كان هناك هدف للأعضاء (مثل 15)، يتم توزيع جزئين لكل عضو. عند انضمام أعضاء جدد، يُعاد التوزيع تلقائياً.'
                                            : 'Auto-assign evenly distributes the 30 Juz among group members in join order, starting with the creator. If a members target is set (e.g. 15), each member gets 2 Juz. When new members join, assignments are recalculated automatically.';
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(title),
                                            content: Text(msg),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(isArabic ? 'حسناً' : 'OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: textColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Headers row
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  isArabic ? 'اسم العضو' : 'Member Name',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFFC2AEEA),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.manualMode ? (isArabic ? 'اختر الأجزاء' : 'Choose Juz') : (isArabic ? 'الأجزاء' : 'Assigned Juz'),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFFC2AEEA),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  isArabic ? 'الحالة' : 'Juz Status',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFFC2AEEA),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (!widget.manualMode)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _unassignedCount > 0 ? const Color(0xFFE65A5A).withOpacity(0.2) : const Color(0xFF235347).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _unassignedCount > 0 ? const Color(0xFFE65A5A).withOpacity(0.4) : const Color(0xFF235347).withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  _unassignedCount > 0
                                    ? (isArabic ? 'أجزاء غير مُعينة: $_unassignedCount' : 'Unassigned Juz: $_unassignedCount')
                                    : (isArabic ? 'جميع الأجزاء مُعينة' : 'All Juz assigned'),
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Content list
                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : (_error != null)
                                  ? Center(child: Text(_error!, style: TextStyle(color: textColor)))
                                  : RefreshIndicator(
                                      onRefresh: _fetch,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        itemCount: widget.manualMode ? _members.length : _rows.length,
                                        itemBuilder: (context, index) {
                                          if (!widget.manualMode) {
                                            final row = _rows[index];
                                            final statusColor = _statusColor(row.statusType);
                                            return Container(
                                              height: 28,
                                              margin: const EdgeInsets.only(bottom: 2),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      row.name,
                                                      style: const TextStyle(
                                                        fontFamily: 'Manrope', fontWeight: FontWeight.w400, fontSize: 13, height: 1.2, letterSpacing: 0, color: Colors.white,
                                                      ),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      _formatJuzList(row.juz, isArabic),
                                                      style: const TextStyle(
                                                        fontFamily: 'Manrope', fontWeight: FontWeight.w400, fontSize: 13, height: 1.2, letterSpacing: 0, color: Colors.white,
                                                      ),
                                                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      child: Container(
                                                        height: 20,
                                                        constraints: const BoxConstraints(minWidth: 60, maxWidth: 140),
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(3)),
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        child: Text(
                                                          isArabic ? _localizedStatus(languageProvider, row.statusText) : row.statusText,
                                                          style: const TextStyle(
                                                            fontFamily: 'Manrope', fontWeight: FontWeight.w500, fontSize: 11, height: 1.0, letterSpacing: 0, color: Colors.white,
                                                          ),
                                                          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            final m = _members[index];
                                            final selected = _selectedByUser[m.id] ?? <int>{};
                                            // Compute status based on current entries for this user
                                            final entries = _userEntries[m.id] ?? const <_AssignEntry>[];
                                            final allCompleted = entries.isNotEmpty && entries.every((e) => e.status == 'completed');
                                            final anyPages = entries.any((e) => e.pagesRead > 0);
                                            String statusText = entries.isEmpty ? 'Not Assigned' : (allCompleted ? 'Completed' : (anyPages ? 'Pages Read' : 'Not Started'));
                                            final statusColor = _statusColor(statusText == 'Completed' ? 'completed' : statusText == 'Pages Read' ? 'pages_read' : statusText == 'Not Assigned' ? 'not_assigned' : 'not_started');

                                            return Column(
                                              children: [
                                                Container(
                                                  height: 28,
                                                  margin: const EdgeInsets.only(bottom: 2),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          m.name,
                                                          style: const TextStyle(
                                                            fontFamily: 'Manrope', fontWeight: FontWeight.w400, fontSize: 13, height: 1.2, letterSpacing: 0, color: Colors.white,
                                                          ),
                                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: GestureDetector(
                                                          onTap: () => _toggleExpand(m.id),
                                                          child: Container(
                                                            alignment: Alignment.center,
                                                            height: 24,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.08),
                                                              border: Border.all(color: Colors.white24),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  isArabic ? 'اختر الأجزاء' : 'Choose Juz',
                                                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                                                ),
                                                                const SizedBox(width: 4),
                                                                const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.white),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          child: Container(
                                                            height: 20,
                                                            constraints: const BoxConstraints(minWidth: 60, maxWidth: 140),
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(3)),
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                            child: Text(
                                                              languageProvider.isArabic ? _localizedStatus(languageProvider, statusText) : statusText,
                                                              style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500, fontSize: 11, height: 1.0, letterSpacing: 0, color: Colors.white),
                                                              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_expandedUserId == m.id)
                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.06),
                                                      border: Border.all(color: Colors.white24),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Wrap(
                                                      spacing: 6,
                                                      runSpacing: 6,
                                                      children: [
                                                        for (int j = 1; j <= 30; j++) ...[
                                                          _buildJuzChip(j, m.id, selected)
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ),
                        ),

                        if (widget.manualMode)
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            child: SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saving ? null : () => _saveManual(languageProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2EDE0),
                                  foregroundColor: const Color(0xFF2D1B69),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: _saving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(isArabic ? 'حفظ' : 'Save', style: const TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildJuzChip(int j, int userId, Set<int> userSelected) {
    final takenByOther = _isTakenByOther(j, userId);
    final selected = userSelected.contains(j);
    return FilterChip(
      label: Text(j.toString(), style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: takenByOther
          ? null
          : (sel) {
              setState(() {
                final set = _selectedByUser.putIfAbsent(userId, () => <int>{});
                if (sel) {
                  // Unselect from any other user
                  for (final entry in _selectedByUser.entries) {
                    if (entry.key != userId) entry.value.remove(j);
                  }
                  set.add(j);
                } else {
                  set.remove(j);
                }
              });
            },
      selectedColor: const Color(0xFF8B5CF6),
      checkmarkColor: Colors.white,
      disabledColor: Colors.white24,
      backgroundColor: Colors.white10,
      side: BorderSide(color: takenByOther ? Colors.white24 : Colors.white38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}

class _MemberAdmin {
  final int id;
  final String name;
  _MemberAdmin({required this.id, required this.name});
}

class _AssignEntry {
  final int juz; final String status; final int pagesRead;
  const _AssignEntry({required this.juz, required this.status, required this.pagesRead});
}

class _AssignmentRow {
  final int? userId;
  final String name;
  final List<int> juz;
  final String statusText;
  final String statusType; // completed | pages_read | not_started | not_assigned
  _AssignmentRow({required this.userId, required this.name, required this.juz, required this.statusText, required this.statusType});
}
