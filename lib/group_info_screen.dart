import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'language_provider.dart';
import 'app_localizations.dart';

// Functional Group Info screen with real API data
class GroupInfoScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const GroupInfoScreen({super.key, this.groupId, this.groupName});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool _loading = false;
  String? _error;
  String? _groupName;
  int _membersCount = 0;
  List<_Member> _members = [];

  @override
  void initState() {
    super.initState();
    _groupName = widget.groupName;
    if (widget.groupId != null) {
      _fetchGroupData();
    }
  }

  Future<void> _fetchGroupData() async {
    if (widget.groupId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch group details and assignments in parallel
      final groupFuture = ApiClient.instance.getGroup(widget.groupId!);
      final assignmentsFuture = ApiClient.instance.khitmaAssignments(widget.groupId!);

      final results = await Future.wait([groupFuture, assignmentsFuture]);
      final groupResp = results[0];
      final assignmentsResp = results[1];

      if (!mounted) return;

      if (!groupResp.ok) {
        setState(() {
          _loading = false;
          _error = groupResp.error ?? 'Failed to load group';
        });
        return;
      }

      if (!assignmentsResp.ok) {
        setState(() {
          _loading = false;
          _error = assignmentsResp.error ?? 'Failed to load assignments';
        });
        return;
      }

      // Process group data
      final groupData = (groupResp.data['group'] as Map).cast<String, dynamic>();
      final groupName = groupData['name'] as String? ?? widget.groupName ?? "The Qur'an Circle";
      final members = (groupData['members'] as List?)?.cast<dynamic>() ?? [];
      final membersCount = members.length;

      // Process assignments data
      final assignmentsData = (assignmentsResp.data['assignments'] as List?)?.cast<dynamic>() ?? [];
      final memberAssignments = _processAssignments(assignmentsData, members);

      setState(() {
        _groupName = groupName;
        _membersCount = membersCount;
        _members = memberAssignments;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Error loading data: $e';
        });
      }
    }
  }

  List<_Member> _processAssignments(List<dynamic> assignments, List<dynamic> members) {
    // Create a map of user_id -> user info
    final Map<int, Map<String, dynamic>> userMap = {};
    for (final member in members) {
      final memberData = (member as Map).cast<String, dynamic>();
      final userId = memberData['id'] as int? ?? 0;
      userMap[userId] = memberData;
    }

    // Group assignments by user
    final Map<int, List<Map<String, dynamic>>> userAssignments = {};
    for (final assignment in assignments) {
      final assignmentData = (assignment as Map).cast<String, dynamic>();
      final user = (assignmentData['user'] as Map?)?.cast<String, dynamic>();
      final userId = user?['id'] as int?;
      
      if (userId != null && assignmentData['status'] != 'unassigned') {
        userAssignments.putIfAbsent(userId, () => []).add(assignmentData);
      }
    }

    // Convert to _Member objects
    final List<_Member> membersList = [];
    
    for (final entry in userAssignments.entries) {
      final userId = entry.key;
      final assignments = entry.value;
      final userData = userMap[userId];
      
      if (userData != null) {
        final name = userData['username'] as String? ?? 'Unknown User';
        final avatarUrl = userData['avatar_url'] as String?;
        
        // Extract Juz numbers and determine status
        final juzNumbers = <int>[];
        var allCompleted = true;
        var hasProgress = false;
        
        for (final assignment in assignments) {
          final juzNumber = assignment['juz_number'] as int? ?? 0;
          final status = assignment['status'] as String? ?? 'unassigned';
          final pagesRead = assignment['pages_read'] as int? ?? 0;
          
          juzNumbers.add(juzNumber);
          
          if (status != 'completed') {
            allCompleted = false;
          }
          
          if (pagesRead > 0 || status == 'completed') {
            hasProgress = true;
          }
        }
        
        // Determine overall status
        final _Status memberStatus;
        if (allCompleted) {
          memberStatus = _Status.completed;
        } else if (hasProgress) {
          memberStatus = _Status.inProgress;
        } else {
          memberStatus = _Status.notStarted;
        }
        
        juzNumbers.sort(); // Ensure sorted for proper formatting
        
        membersList.add(_Member(
          juzNumbers: juzNumbers,
          name: name,
          status: memberStatus,
          avatarUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
        ));
      }
    }
    
    // Sort members by name
    membersList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    return membersList;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.isArabic;
    
    final membersToDisplay = _members;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF251629), Color(0xFF4C3B6E)]
                : const [Color(0xFF163832), Color(0xFF235347)],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/background_elements/3_background.png'),
            fit: BoxFit.cover,
            opacity: 0.22,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header (more compact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: languageProvider.isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Titles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.groupInfoTitle,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
Text(
                      _groupName ?? AppLocalizations.of(context)!.quranCircle,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
Text(
                      '$_membersCount ' + AppLocalizations.of(context)!.members,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Members List label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  AppLocalizations.of(context)!.membersList,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Members list (compact density)
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  style: GoogleFonts.manrope(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _fetchGroupData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.tryAgain,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : membersToDisplay.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noMemberAssignments,
                                  style: GoogleFonts.manrope(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                itemBuilder: (context, index) => _MemberTile(
                                  member: membersToDisplay[index],
                                  isArabic: isArabic,
                                ),
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemCount: membersToDisplay.length,
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.isArabic});
  final _Member member;
  final bool isArabic;

  String _formatJuzNumbers(List<int> juzNumbers) {
    if (juzNumbers.isEmpty) return '';
    if (juzNumbers.length == 1) return juzNumbers.first.toString();
    
    // Sort to ensure proper order
    final sorted = List<int>.from(juzNumbers)..sort();
    
    // Check if consecutive for range formatting
    bool isConsecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) {
        isConsecutive = false;
        break;
      }
    }
    
    if (isConsecutive) {
      // Format as range: "1-6" or "5-6"
      return '${sorted.first}-${sorted.last}';
    } else {
      // Format with commas: "2,4,5,6,8"
      return sorted.join(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white.withOpacity(0.05);
    final borderColor = Colors.white.withOpacity(0.18);

final app = AppLocalizations.of(context)!;
    final statusText = switch (member.status) {
      _Status.completed => app.completed,
      _Status.inProgress => app.inProgress,
      _Status.notStarted => app.notStarted,
    };

    final statusColor = switch (member.status) {
      _Status.completed => Colors.white.withOpacity(0.85),
      _Status.inProgress => const Color(0xFFF1C40F),
      _Status.notStarted => const Color(0xFFEF4444),
    };
    
    final formattedJuz = _formatJuzNumbers(member.juzNumbers);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar (smaller)
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.18),
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 18)
                : null,
          ),
          const SizedBox(width: 10),

          // Name + Juz pill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Juz pill (smaller)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.45), width: 1),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Text(
                    formattedJuz.isEmpty
                        ? AppLocalizations.of(context)!.unassigned
                        : '${AppLocalizations.of(context)!.juzShort} $formattedJuz',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Name
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Status (right side; smaller text)
          Text(
            statusText,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Member {
  final List<int> juzNumbers;
  final String name;
  final _Status status;
  final String? avatarUrl;
  const _Member({required this.juzNumbers, required this.name, required this.status, this.avatarUrl});
}

enum _Status { completed, inProgress, notStarted }


