import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'profile_provider.dart';
import 'services/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupDhikrInfoScreen extends StatefulWidget {
  const GroupDhikrInfoScreen({super.key, required this.groupId, this.groupName});
  final int groupId;
  final String? groupName;

  @override
  State<GroupDhikrInfoScreen> createState() => _GroupDhikrInfoScreenState();
}

class _GroupDhikrInfoScreenState extends State<GroupDhikrInfoScreen> {
  bool _loading = false;
  String? _error;
  String? _resolvedGroupName;
  int _membersCount = 0;
  int? _myUserId;

  final List<_Member> _members = [];

  @override
  void initState() {
    super.initState();
    _resolvedGroupName = widget.groupName;
    _myUserId = context.read<ProfileProvider?>()?.id;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await ApiClient.instance.getDhikrGroup(widget.groupId);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() {
        _loading = false;
        _error = resp.error ?? 'Failed to load group';
      });
      return;
    }

    final g = ((resp.data as Map)['group'] as Map).cast<String, dynamic>();
    final name = (g['name'] as String?) ?? _resolvedGroupName;
    final list = (g['members'] as List?)?.cast<dynamic>() ?? const [];

    final members = <_Member>[];
    for (final it in list) {
      final m = (it as Map).cast<String, dynamic>();
      final userId = (m['id'] is int) ? m['id'] as int : int.tryParse('${m['id'] ?? ''}') ?? 0;
      final username = (m['username'] as String?)?.trim();
      final avatar = (m['avatar_url'] as String?)?.trim();
      final contrib = (m['dhikr_contribution'] is int)
          ? m['dhikr_contribution'] as int
          : int.tryParse('${m['dhikr_contribution'] ?? ''}') ?? 0;
      members.add(_Member(
        userId: userId,
        name: username?.isNotEmpty == true ? username! : 'User',
        avatarUrl: (avatar != null && avatar.isNotEmpty) ? avatar : null,
        contribution: contrib,
      ));
    }

    setState(() {
      _resolvedGroupName = name;
      _members
        ..clear()
        ..addAll(members);
      _membersCount = _members.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.watch<LanguageProvider>().isArabic;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header (back only)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: isArabic ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
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
                      isArabic ? 'معلومات المجموعة' : 'Group Info.',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resolvedGroupName ?? (isArabic ? 'دائرة القرآن' : "The Qur'an Circle"),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Members List header with count on right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'قائمة الأعضاء' : 'Members List',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isArabic ? '$_membersCount عضو' : '$_membersCount Members',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Members list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: GoogleFonts.manrope(color: Colors.white.withOpacity(0.85)),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            itemBuilder: (context, index) {
                              final m = _members[index];
                              final isYou = _myUserId != null && _myUserId == m.userId;
                              return _MemberRow(
                                name: isYou ? '${m.name} (${isArabic ? 'أنت' : 'You'})' : m.name,
                                avatarUrl: m.avatarUrl,
                                contribution: m.contribution,
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: _members.length,
                          ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.name, required this.avatarUrl, required this.contribution});
  final String name;
  final String? avatarUrl;
  final int contribution;

  @override
  Widget build(BuildContext context) {
    final border = Colors.white.withOpacity(0.25);
    final fill = Colors.white.withOpacity(0.06);

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.18),
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 18)
                : null,
          ),
          const SizedBox(width: 12),

          // Name only (no email in this design)
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Contribution badge on right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.45), width: 1),
            ),
            child: Text(
              '$contribution',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
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

class _Member {
  final int userId;
  final String name;
  final String? avatarUrl;
  final int contribution;
  const _Member({required this.userId, required this.name, required this.avatarUrl, required this.contribution});
}

