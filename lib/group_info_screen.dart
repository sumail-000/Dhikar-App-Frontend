import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Compact "Group Info" screen (UI only for now)
class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy members (compact list)
    final members = <_Member>[
      _Member(juz: 1, name: 'Bint e Hawa', status: _Status.completed, avatarUrl: _avatars[0]),
      _Member(juz: 2, name: 'Muhammad Umar Farooq', status: _Status.inProgress, avatarUrl: _avatars[1]),
      _Member(juz: 3, name: 'Muhammad Abu Bakar', status: _Status.completed, avatarUrl: _avatars[2]),
      _Member(juz: 4, name: 'Muhammad Hussain', status: _Status.completed, avatarUrl: _avatars[3]),
      _Member(juz: 5, name: 'Hassan Mujtaba', status: _Status.completed, avatarUrl: _avatars[4]),
      _Member(juz: 5, name: 'Ali Murtaza', status: _Status.cancelled, avatarUrl: _avatars[5]),
      _Member(juz: 6, name: 'Bint e Iqbal', status: _Status.inProgress, avatarUrl: _avatars[6]),
      _Member(juz: 7, name: 'Usman Ghani', status: _Status.completed, avatarUrl: _avatars[7]),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      icon: Icons.arrow_back_ios_new_rounded,
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
                      'Group Info.',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "The Qur'an Circle",
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '15 Members',
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
                  'Members List',
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  itemBuilder: (context, index) => _MemberTile(member: members[index]),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: members.length,
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
  const _MemberTile({required this.member});
  final _Member member;

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white.withOpacity(0.05);
    final borderColor = Colors.white.withOpacity(0.18);

    final statusText = switch (member.status) {
      _Status.completed => 'Completed',
      _Status.inProgress => 'In Progress',
      _Status.cancelled => 'Cancelled',
    };

    final statusColor = switch (member.status) {
      _Status.completed => Colors.white.withOpacity(0.85),
      _Status.inProgress => const Color(0xFFF1C40F),
      _Status.cancelled => const Color(0xFFEF4444),
    };

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
                    'Juzz#${member.juz.toString().padLeft(2, '0')}',
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
  final int juz;
  final String name;
  final _Status status;
  final String? avatarUrl;
  const _Member({required this.juz, required this.name, required this.status, this.avatarUrl});
}

enum _Status { completed, inProgress, cancelled }

// Placeholder avatars
const _avatars = <String?>[
  'https://i.pravatar.cc/150?img=1',
  'https://i.pravatar.cc/150?img=2',
  'https://i.pravatar.cc/150?img=3',
  'https://i.pravatar.cc/150?img=4',
  'https://i.pravatar.cc/150?img=5',
  'https://i.pravatar.cc/150?img=6',
  'https://i.pravatar.cc/150?img=7',
  'https://i.pravatar.cc/150?img=8',
];

