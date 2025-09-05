import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';
import 'services/api_client.dart';

// Manage Members screen (UI only, compact, Figma-style) now wired to real data
class GroupManageMembersScreen extends StatefulWidget {
  const GroupManageMembersScreen({super.key, required this.groupId, this.groupName, this.isDhikr = false});
  final int groupId;
  final String? groupName;
  final bool isDhikr;

  @override
  State<GroupManageMembersScreen> createState() => _GroupManageMembersScreenState();
}

class _GroupManageMembersScreenState extends State<GroupManageMembersScreen> {
  bool _loading = false;
  String? _error;
  String? _resolvedGroupName;
  final List<_Member> _members = [];
  int? _myUserId;

  @override
  void initState() {
    super.initState();
    _resolvedGroupName = widget.groupName;
    _myUserId = context.read<ProfileProvider?>()?.id;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    final resp = widget.isDhikr
        ? await ApiClient.instance.getDhikrGroup(widget.groupId)
        : await ApiClient.instance.getGroup(widget.groupId);
    if (!mounted) return;
    if (!resp.ok || resp.data is! Map<String, dynamic>) {
      setState(() { _loading = false; _error = resp.error ?? 'Failed to load group'; });
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
      final email = (m['email'] as String?)?.trim();
      final avatar = (m['avatar_url'] as String?)?.trim();
      final String? avatarUrl = (avatar != null && avatar.isNotEmpty) ? avatar : null;
      members.add(_Member(userId, username ?? '—', email ?? '', avatarUrl));
    }
    setState(() {
      _resolvedGroupName = name;
      _members
        ..clear()
        ..addAll(members);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      _resolvedGroupName ?? "",
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
                      '${_members.length} Members',
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null)
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            itemBuilder: (_, i) => _MemberRow(
                              member: _members[i],
                              isSelf: _myUserId != null && _members[i].userId == _myUserId,
                            ),
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: _members.length,
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
  const _MemberRow({required this.member, required this.isSelf});
  final _Member member;
  final bool isSelf;

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
            backgroundImage: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 18)
                : null,
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

          // Actions: delete (red) and reminder (bell) — hidden for self
          if (!isSelf)
            _IconBadgeButton(
              icon: Icons.delete_outline,
              color: const Color(0xFFEF4444),
              onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Remove member?'),
                  content: Text('Remove ${member.name} from the group?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
                  ],
                ),
              );
              if (ok != true) return;
              final state = context.findAncestorStateOfType<_GroupManageMembersScreenState>();
              if (state == null) return;
              final resp = state.widget.isDhikr
                  ? await ApiClient.instance.removeDhikrGroupMember(state.widget.groupId, member.userId)
                  : await ApiClient.instance.removeGroupMember(state.widget.groupId, member.userId);
              if (resp.ok) {
                state._fetch();
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resp.error ?? 'Failed to remove member')),
                );
              }
              },
            ),
          if (!isSelf) const SizedBox(width: 10),
          if (!isSelf)
            _IconBadgeButton(
              icon: Icons.notifications_none_rounded,
              color: Colors.white,
              onTap: () async {
                // Compose reminder message with default based on group type
                final state = context.findAncestorStateOfType<_GroupManageMembersScreenState>();
                if (state == null) return;
                final defaultMsg = state.widget.isDhikr
                    ? 'Kind reminder to contribute to the dhikr goal today.'
                    : 'Kind reminder to update your assigned Juz progress.';
                final controller = TextEditingController(text: defaultMsg);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Send Reminder'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Edit the message (optional):'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'This reminder will be sent to this member only.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
                    ],
                  ),
                );

                if (confirmed != true) return;

                final message = controller.text.trim();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sending reminder...')),
                );

                final resp = state.widget.isDhikr
                    ? await ApiClient.instance.sendDhikrGroupMemberReminder(state.widget.groupId, member.userId, message)
                    : await ApiClient.instance.sendGroupMemberReminder(state.widget.groupId, member.userId, message);

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resp.ok ? 'Reminder sent' : (resp.error ?? 'Failed to send reminder')),
                  ),
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
  final int userId;
  final String name;
  final String email;
  final String? avatarUrl;
  const _Member(this.userId, this.name, this.email, this.avatarUrl);
}

