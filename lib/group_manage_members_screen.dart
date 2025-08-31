import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Manage Members screen (UI only, compact, Figma-style)
class GroupManageMembersScreen extends StatelessWidget {
  const GroupManageMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = <_Member>[
      _Member('Ali Shahwaiz', 'ali@gmail.com', _avatars[0]),
      _Member('Saba Iqbal', 'saba@gmail.com', _avatars[1]),
      _Member('Zakria', 'zakria@gmail.com', _avatars[2]),
      _Member('Aon Abbas', 'aon@gmail.com', _avatars[3]),
      _Member('Fakhar e Abid', 'fakhar@gmail.com', _avatars[4]),
      _Member('Waqas Ahmed', 'waqas@gmail.com', _avatars[5]),
      _Member('Muhammad Binyamin', 'mbd@gmail.com', _avatars[6]),
      _Member('Muhammad Abdullah', 'abdullah@gmail.com', _avatars[7]),
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
            opacity: 0.25,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header (compact)
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
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Section header with count on right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members List',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${members.length} Members',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  itemBuilder: (_, i) => _MemberRow(member: members[i]),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});
  final _Member member;

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
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          const SizedBox(width: 12),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Actions: delete (red) and reminder (bell)
          _IconBadgeButton(
            icon: Icons.delete_outline,
            color: const Color(0xFFEF4444),
            onTap: () {
              // TODO: call ApiClient.instance.removeGroupMember(groupId, userId)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete member (not wired yet)')),
              );
            },
          ),
          const SizedBox(width: 10),
          _IconBadgeButton(
            icon: Icons.notifications_none_rounded,
            color: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Send reminder (not wired yet)')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: color),
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
  final String name;
  final String email;
  final String avatarUrl;
  const _Member(this.name, this.email, this.avatarUrl);
}

const _avatars = <String>[
  'https://i.pravatar.cc/150?img=1',
  'https://i.pravatar.cc/150?img=2',
  'https://i.pravatar.cc/150?img=3',
  'https://i.pravatar.cc/150?img=4',
  'https://i.pravatar.cc/150?img=5',
  'https://i.pravatar.cc/150?img=6',
  'https://i.pravatar.cc/150?img=7',
  'https://i.pravatar.cc/150?img=8',
];

