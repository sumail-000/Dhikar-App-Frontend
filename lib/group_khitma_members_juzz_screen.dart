import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'wered_reading_screen.dart';

class GroupKhitmaJuzzScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const GroupKhitmaJuzzScreen({super.key, this.groupId, this.groupName});

  @override
  State<GroupKhitmaJuzzScreen> createState() => _GroupKhitmaJuzzScreenState();
}

class _GroupKhitmaJuzzScreenState extends State<GroupKhitmaJuzzScreen> {
  bool _loading = false;
  String? _error;
  List<_MemberRow> _rows = [];
  // Member controls
  List<int> _myAssignedJuz = [];
  int _myPagesRead = 0;
  int? _myLastSavedAbsolutePage;
  bool _myAllCompleted = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (widget.groupId == null) return;
    setState(() { _loading = true; _error = null; _rows = []; _myPagesRead = 0; _myAssignedJuz = []; _myLastSavedAbsolutePage = null; _myAllCompleted = false; });

    final groupResp = await ApiClient.instance.getGroup(widget.groupId!);
    if (!mounted) return;
    if (!groupResp.ok || groupResp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = groupResp.error ?? 'Failed to load group'; });
      return;
    }

    // Build members list
    final group = (groupResp.data['group'] as Map).cast<String, dynamic>();
    final members = (group['members'] as List?)?.cast<dynamic>() ?? const [];
    final Map<int, _MemberInfo> memberMap = {};
    for (final m in members) {
      final mm = (m as Map).cast<String, dynamic>();
      final uid = (mm['id'] is int) ? mm['id'] as int : int.tryParse('${mm['id'] ?? ''}');
      if (uid == null) continue;
      final username = (mm['username'] as String?)?.trim() ?? '';
      memberMap[uid] = _MemberInfo(id: uid, name: username);
    }

    // Fetch assignments
    final assignResp = await ApiClient.instance.khitmaAssignments(widget.groupId!);
    if (!mounted) return;
    if (!assignResp.ok || assignResp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = assignResp.error ?? 'Failed to load assignments'; });
      return;
    }

    final List<dynamic> raw = (assignResp.data['assignments'] as List?) ?? const [];
    // Group assignments by user id
    final Map<int, List<Map<String, dynamic>>> byUser = { for (final e in memberMap.keys) e: <Map<String, dynamic>>[] };
    for (final e in raw) {
      final m = (e as Map).cast<String, dynamic>();
      final user = (m['user'] as Map?)?.cast<String, dynamic>();
      final uid = (user != null)
          ? ((user['id'] is int) ? user['id'] as int : int.tryParse('${user['id'] ?? ''}'))
          : null;
      if (uid != null && memberMap.containsKey(uid)) {
        byUser[uid]!.add(m);
      }
    }

    // Build display rows for each member
    final myId = context.read<ProfileProvider?>()?.id;
    final List<_MemberRow> rows = [];
    List<int>? myAssigned;
    memberMap.forEach((uid, info) {
      final items = byUser[uid]!..sort((a, b) => ((a['juz_number'] as int).compareTo(b['juz_number'] as int)));
      // Collect assigned juz numbers
      final List<int> juz = [];
      bool anyAssigned = false;
      int pagesSum = 0;
      int? lastAbsPage;
      // Determine completion for display: status==completed OR pages_read >= required pages per Juz
      bool completedDisplay = true;
      for (final it in items) {
        final status = (it['status'] as String?) ?? '';
        final int jn = it['juz_number'] as int;
        final prRaw = it['pages_read'];
        final int pr = (prRaw is int) ? prRaw : 0;
        if (status == 'assigned' || status == 'completed') {
          anyAssigned = true;
          juz.add(jn);
        }
        final int required = _pagesInJuz(jn);
        final bool doneThisJuz = (status == 'completed') || (pr >= required);
        if (!doneThisJuz && (status == 'assigned' || status == 'completed')) {
          completedDisplay = false;
        }
        if (pr > 0) {
          pagesSum += pr;
          // Compute absolute last page within this juz
          final int? start = _getJuzStartPage(jn);
          if (start != null) {
            final cand = start + pr - 1;
            if (lastAbsPage == null || cand > lastAbsPage) lastAbsPage = cand;
          }
        }
      }
      if (myId != null && uid == myId) {
        myAssigned = List<int>.from(juz);
        _myPagesRead = pagesSum;
        _myLastSavedAbsolutePage = lastAbsPage;
        // My completion across all my assigned Juz in this group
        bool allDone = true;
        for (final it in items) {
          final status = (it['status'] as String?) ?? '';
          final int jz = it['juz_number'] as int;
          final int pr = (it['pages_read'] is int) ? (it['pages_read'] as int) : 0;
          final int required = _pagesInJuz(jz);
          if (!(status == 'completed' || pr >= required)) { allDone = false; break; }
        }
        _myAllCompleted = allDone && (myAssigned?.isNotEmpty ?? false);
      }

      final isArabic = context.read<LanguageProvider>().isArabic;
      // Determine status label (localized with count when applicable)
      String status;
      if (!anyAssigned || juz.isEmpty) {
        status = isArabic ? 'غير مُعين' : 'Not Assigned';
      } else if (completedDisplay) {
        status = isArabic ? 'مكتمل' : 'Completed';
      } else if (pagesSum > 0) {
        status = isArabic ? '$pagesSum صفحات مقروءة' : '$pagesSum Pages Read';
      } else {
        status = isArabic ? 'لم يبدأ' : 'Not Started';
      }

      // Member name with (You)
      String displayName = info.name.isNotEmpty ? info.name : '—';
      if (myId != null && uid == myId) {
        displayName = isArabic ? '$displayName (أنت)' : '$displayName (You)';
      }

      rows.add(_MemberRow(
        name: displayName,
        assignedJuz: _condenseJuz(juz),
        status: status,
        pagesRead: pagesSum,
      ));
    });

    // Sort by name
    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _rows = rows;
      _myAssignedJuz = myAssigned ?? [];
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Condense assigned Juz list according to rules
  String _condenseJuz(List<int> nums) {
    if (nums.isEmpty) return '--';
    final s = nums.toSet().toList()..sort();
    if (s.length == 1) return '${s.first}';
    if (s.length == 2) return '${s[0]} & ${s[1]}';
    bool contiguous = true;
    for (int i = 1; i < s.length; i++) {
      if (s[i] != s[i - 1] + 1) { contiguous = false; break; }
    }
    if (contiguous) return '${s.first}-${s.last}';
    return s.join(', ');
  }

  Color _statusColor(String status) {
    // Handle both English and Arabic variants, and count-containing strings
    if (status.contains('Completed') || status.contains('مكتمل')) {
      return const Color(0xFFC2AEEA);
    }
    if (status.contains('Pages Read') || status.contains('صفحات')) {
      return const Color(0xFFD4D400);
    }
    if (status.contains('Not Assigned') || status.contains('غير مُعين')) {
      return const Color(0xFFE65A5A);
    }
    // Not Started / default
    return const Color(0xFF8B8B8B);
  }

  String _localizedStatus(LanguageProvider lang, String status) {
    if (!lang.isArabic) return status;
    switch (status) {
      case 'Completed':
        return 'مكتمل';
      case 'Pages Read':
        return 'صفحات مقروءة';
      case 'Not Assigned':
        return 'غير مُعين';
      case 'Not Started':
        return 'لم يبدأ';
      default:
        return status;
    }
  }

  /// Navigate to WeredReadingScreen in Group Reading Mode
  void _continueReading() async {
    if (widget.groupId == null || _myAssignedJuz.isEmpty) return;
    
    final lang = context.read<LanguageProvider>();
    final isArabic = lang.isArabic;
    
    try {
      // Determine start page based on saved progress from backend
      final assignedPages = _getPagesForJuz(_myAssignedJuz);
      final int startFromPage;
      if (_myLastSavedAbsolutePage != null) {
        // Clamp to assigned pages just in case
        startFromPage = assignedPages.contains(_myLastSavedAbsolutePage!)
            ? _myLastSavedAbsolutePage!
            : assignedPages.first;
      } else {
        startFromPage = assignedPages.first;
      }

      // Navigate to reading screen with group reading mode
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeredReadingScreen(
            selectedSurahs: const ['Al-Fatihah'], // ignored in group mode
            pages: '0', // ignored in group mode
            isPersonalKhitma: false,
            isGroupKhitma: true,
            groupId: widget.groupId!,
            assignedJuz: _myAssignedJuz,
            startFromPage: startFromPage,
          ),
        ),
      );
      
      // Refresh data when returning from reading screen
      if (mounted) {
        await _fetch();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'فشل في فتح شاشة القراءة' : 'Failed to open reading screen',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);

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
                  // Background image
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
                        // Header - Compact
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
                                  isArabic ? 'تفاصيل الختمة' : 'Khitma Details',
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
                            ],
                          ),
                        ),

                        // Table Headers - Compact
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
                                  isArabic ? 'الأجزاء' : 'Assigned Juz',
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

                        // Members List
                        Expanded(
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : (_error != null)
                                  ? Center(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(color: textColor),
                                      ),
                                    )
                                  : RefreshIndicator(
                                          onRefresh: _fetch,
                                          child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            itemCount: _rows.length,
                                            itemBuilder: (context, index) {
                                              final row = _rows[index];
                                              final color = _statusColor(row.status);
                                              return Container(
                                                height: 28,
                                                margin: const EdgeInsets.only(bottom: 2),
                                                child: Row(
                                                  children: [
                                                    // Member name
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        row.name,
                                                        style: const TextStyle(
                                                          fontFamily: 'Manrope',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 13,
                                                          height: 1.2,
                                                          letterSpacing: 0,
                                                          color: Colors.white,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    // Assigned Juz
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        row.assignedJuz,
                                                        style: const TextStyle(
                                                          fontFamily: 'Manrope',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 13,
                                                          height: 1.2,
                                                          letterSpacing: 0,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    // Status badge
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        child: Container(
                                                          height: 20,
                                                          constraints: const BoxConstraints(minWidth: 60, maxWidth: 140),
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            color: color,
                                                            borderRadius: BorderRadius.circular(3),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          child: Text(
                                                            _localizedStatus(languageProvider, row.status),
                                                            style: const TextStyle(
                                                              fontFamily: 'Manrope',
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 11,
                                                              height: 1.0,
                                                              letterSpacing: 0,
                                                              color: Colors.white,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                        ),

                        // Continue/Start Reading Section for assigned members only
                        if (_myAssignedJuz.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: _myAllCompleted
                                  ? ElevatedButton.icon(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC2E7C9),
                                        disabledForegroundColor: const Color(0xFF2D1B69),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF2D1B69)),
                                      label: Text(
                                        isArabic ? 'مكتمل' : 'Completed',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D1B69),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () => _continueReading(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF2EDE0),
                                        foregroundColor: const Color(0xFF2D1B69),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(
                                        Icons.book_outlined,
                                        size: 20,
                                        color: Color(0xFF2D1B69),
                                      ),
                                      label: Text(
                                        _myPagesRead > 0
                                            ? (isArabic ? 'متابعة القراءة' : 'Continue Reading')
                                            : (isArabic ? 'ابدأ القراءة' : 'Start Reading'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D1B69),
                                        ),
                                      ),
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
  int? _getJuzStartPage(int j) {
    const Map<int, int> starts = {
      1: 1, 2: 22, 3: 42, 4: 63, 5: 83, 6: 103, 7: 123, 8: 143, 9: 163, 10: 183,
      11: 203, 12: 223, 13: 243, 14: 263, 15: 283, 16: 303, 17: 323, 18: 343,
      19: 363, 20: 383, 21: 403, 22: 423, 23: 443, 24: 463, 25: 483, 26: 503,
      27: 523, 28: 543, 29: 563, 30: 583,
    };
    return starts[j];
  }

  int _pagesInJuz(int j) {
    switch (j) {
      case 1:
        return 21;
      case 30:
        return 22;
      default:
        return 20;
    }
  }

  // Map Juz numbers to Mushaf page numbers
  List<int> _getPagesForJuz(List<int> juzNumbers) {
    final Map<int, List<int>> juzPageRanges = {
      1: List.generate(21, (i) => i + 1),
      2: List.generate(20, (i) => i + 22),
      3: List.generate(21, (i) => i + 42),
      4: List.generate(20, (i) => i + 63),
      5: List.generate(20, (i) => i + 83),
      6: List.generate(20, (i) => i + 103),
      7: List.generate(20, (i) => i + 123),
      8: List.generate(20, (i) => i + 143),
      9: List.generate(20, (i) => i + 163),
      10: List.generate(20, (i) => i + 183),
      11: List.generate(20, (i) => i + 203),
      12: List.generate(20, (i) => i + 223),
      13: List.generate(20, (i) => i + 243),
      14: List.generate(20, (i) => i + 263),
      15: List.generate(20, (i) => i + 283),
      16: List.generate(20, (i) => i + 303),
      17: List.generate(20, (i) => i + 323),
      18: List.generate(20, (i) => i + 343),
      19: List.generate(20, (i) => i + 363),
      20: List.generate(20, (i) => i + 383),
      21: List.generate(20, (i) => i + 403),
      22: List.generate(20, (i) => i + 423),
      23: List.generate(20, (i) => i + 443),
      24: List.generate(20, (i) => i + 463),
      25: List.generate(20, (i) => i + 483),
      26: List.generate(20, (i) => i + 503),
      27: List.generate(20, (i) => i + 523),
      28: List.generate(20, (i) => i + 543),
      29: List.generate(20, (i) => i + 563),
      30: List.generate(22, (i) => i + 583),
    };
    final Set<int> pages = {};
    for (final j in juzNumbers) {
      final p = juzPageRanges[j];
      if (p != null) pages.addAll(p);
    }
    final list = pages.toList()..sort();
    return list;
  }
}

class _MemberInfo {
  final int id;
  final String name;
  _MemberInfo({required this.id, required this.name});
}

class _MemberRow {
  final String name;
  final String assignedJuz;
  final String status; // localized display string, may include pages count
  final int pagesRead;
  _MemberRow({required this.name, required this.assignedJuz, required this.status, required this.pagesRead});
}
