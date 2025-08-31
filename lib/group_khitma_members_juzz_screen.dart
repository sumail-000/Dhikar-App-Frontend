import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';

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
  int? _selectedJuzNumber;
  String _selectedStatus = 'Not Started';
  final TextEditingController _pagesReadController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (widget.groupId == null) return;
    setState(() { _loading = true; _error = null; _rows = []; });

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
      bool allCompleted = true;
      bool anyAssigned = false;
      bool anyPages = false;
      for (final it in items) {
        final status = (it['status'] as String?) ?? '';
        if (status == 'assigned' || status == 'completed') {
          anyAssigned = true;
          juz.add(it['juz_number'] as int);
        }
        if (status != 'completed') {
          allCompleted = false;
        }
        final pr = it['pages_read'];
        if (pr is int && pr > 0) anyPages = true;
      }
      if (myId != null && uid == myId) {
        myAssigned = List<int>.from(juz);
      }

      // Determine status label
      String status;
      if (!anyAssigned || juz.isEmpty) {
        status = 'Not Assigned';
      } else if (allCompleted) {
        status = 'Completed';
      } else if (anyPages) {
        status = 'Pages Read';
      } else {
        status = 'Not Started';
      }

      // Member name with (You)
      String displayName = info.name.isNotEmpty ? info.name : '—';
      if (myId != null && uid == myId) {
        final isArabic = context.read<LanguageProvider>().isArabic;
        displayName = isArabic ? '$displayName (أنت)' : '$displayName (You)';
      }

      rows.add(_MemberRow(
        name: displayName,
        assignedJuz: _condenseJuz(juz),
        status: status,
      ));
    });

    // Sort by name
    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _rows = rows;
      _myAssignedJuz = myAssigned ?? [];
      if (_myAssignedJuz.isNotEmpty && (_selectedJuzNumber == null || !_myAssignedJuz.contains(_selectedJuzNumber))) {
        _selectedJuzNumber = _myAssignedJuz.first;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pagesReadController.dispose();
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
    switch (status) {
      case 'Completed':
        return const Color(0xFFC2AEEA);
      case 'Pages Read':
        return const Color(0xFFD4D400);
      case 'Not Assigned':
        return const Color(0xFFE65A5A);
      case 'Not Started':
      default:
        return const Color(0xFF8B8B8B);
    }
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

  Future<void> _saveStatus() async {
    if (_selectedJuzNumber == null) return;
    final lang = context.read<LanguageProvider>();
    final isArabic = lang.isArabic;

    int? pagesRead;
    String mappedStatus;
    switch (_selectedStatus) {
      case 'Completed':
        mappedStatus = 'completed';
        pagesRead = null;
        break;
      case 'Pages Read':
        mappedStatus = 'assigned';
        final val = int.tryParse(_pagesReadController.text.trim());
        if (val == null || val < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isArabic ? 'أدخل عدد الصفحات' : 'Enter pages read')),
          );
          return;
        }
        pagesRead = val;
        break;
      case 'Not Started':
      default:
        mappedStatus = 'assigned';
        pagesRead = 0;
        break;
    }

    setState(() { _saving = true; });
    final resp = await ApiClient.instance.khitmaUpdateAssignment(
      widget.groupId!,
      juzNumber: _selectedJuzNumber!,
      status: mappedStatus,
      pagesRead: pagesRead,
    );
    if (!mounted) return;
    setState(() { _saving = false; });

    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? (isArabic ? 'فشل الحفظ' : 'Save failed'))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isArabic ? 'تم الحفظ' : 'Saved')),
    );
    await _fetch();
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

                        // Bottom update status section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header label
                              Container(
                                height: 24,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2AEEA),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  isArabic ? 'تحديث حالة الجزء' : 'Update Your Juz Status',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: Color(0xFF2D1B69),
                                  ),
                                ),
                              ),
                              // Juz selector
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedJuzNumber,
                                    isExpanded: true,
                                    hint: Text(isArabic ? 'اختر الجزء' : 'Select Juz'),
                                    items: _myAssignedJuz
                                        .map((j) => DropdownMenuItem<int>(value: j, child: Text(j.toString())))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() { _selectedJuzNumber = val; });
                                    },
                                  ),
                                ),
                              ),
                              // Status selector
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus,
                                    isExpanded: true,
                                    items: <String>['Not Started', 'Completed', 'Pages Read']
                                        .map((s) => DropdownMenuItem<String>(
                                              value: s,
                                              child: Text(isArabic
                                                  ? (s == 'Not Started' ? 'لم يبدأ' : s == 'Completed' ? 'مكتمل' : 'صفحات مقروءة')
                                                  : s),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val == null) return;
                                      setState(() { _selectedStatus = val; });
                                    },
                                  ),
                                ),
                              ),
                              if (_selectedStatus == 'Pages Read')
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: TextField(
                                    controller: _pagesReadController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: isArabic ? 'عدد الصفحات المقروءة' : 'Pages read',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              // Save button
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: (_selectedJuzNumber == null || _saving) ? null : _saveStatus,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2EDE0),
                                    foregroundColor: const Color(0xFF2D1B69),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    elevation: 0,
                                  ),
                                  child: _saving
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                      : Text(isArabic ? 'حفظ' : 'Save', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
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
}

class _MemberInfo {
  final int id;
  final String name;
  _MemberInfo({required this.id, required this.name});
}

class _MemberRow {
  final String name;
  final String assignedJuz;
  final String status; // Completed | Not Started | Pages Read | Not Assigned
  _MemberRow({required this.name, required this.assignedJuz, required this.status});
}
