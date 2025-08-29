import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_client.dart';

class ManagementGroupCard extends StatelessWidget {
  final bool isArabic;
  final bool isLightMode;
  final String titleEnglish;
  final String titleArabic;
  final int membersCount; // reserved for future use
  final int membersTarget; // reserved for future use
  final bool isPublic;
  final int groupId;
  final VoidCallback? onDelete;
  final VoidCallback? onOpen;

  const ManagementGroupCard({
    super.key,
    required this.isArabic,
    required this.isLightMode,
    required this.titleEnglish,
    required this.titleArabic,
    required this.membersCount,
    required this.membersTarget,
    required this.isPublic,
    required this.groupId,
    this.onDelete,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF205C3B);
    final textColor = isLightMode ? green : Colors.white;
    final borderColor = isLightMode ? const Color(0xFFF2EDE0) : Colors.white24;
    final bg = isLightMode ? Colors.white : Colors.white10;

    final title = isArabic ? titleArabic : titleEnglish;
    final privacy = isArabic ? (isPublic ? 'عام' : 'خاص') : (isPublic ? 'Public' : 'Private');

    return Stack(
      children: [
        // Card body
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isLightMode
                ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + actions row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.isNotEmpty ? title : (isArabic ? 'مجموعة بدون اسم' : 'Untitled Group'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete
                  _iconBtn(
                    context,
                    icon: Icons.delete_outline,
                    tooltip: isArabic ? 'حذف' : 'Delete',
                    onTap: onDelete, // UI only for now
                    isLightMode: isLightMode,
                  ),
                  const SizedBox(width: 6),
                  // Invite/Share
                  _iconBtn(
                    context,
                    icon: Icons.share_rounded,
                    tooltip: isArabic ? 'دعوة' : 'Invite',
                    onTap: () => _handleInvite(context),
                    isLightMode: isLightMode,
                  ),
                  const SizedBox(width: 6),
                  // Open
                  _iconBtn(
                    context,
                    icon: Icons.arrow_forward_ios,
                    tooltip: isArabic ? 'فتح' : 'Open',
                    onTap: onOpen, // UI only for now
                    isLightMode: isLightMode,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // reserved area for future meta (kept minimal as requested)
            ],
          ),
        ),

        // Corner privacy badge (top-left)
        Positioned(
          top: 8,
          left: 8,
          child: _badge(privacy, isLightMode),
        ),
      ],
    );
  }

  Widget _badge(String label, bool isLightMode) {
    final bg = isLightMode ? const Color(0xFFDAF1DE) : Colors.white12;
    final fg = isLightMode ? const Color(0xFF205C3B) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isLightMode ? const Color(0xFFB6D1C2) : Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _iconBtn(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required bool isLightMode,
    VoidCallback? onTap,
    bool dense = false,
  }) {
    final color = isLightMode ? const Color(0xFF235347) : Colors.white;
    return InkResponse(
      onTap: onTap,
      radius: dense ? 16 : 20,
      child: Icon(icon, size: dense ? 16 : 20, color: color),
    );
  }

  Future<void> _handleInvite(BuildContext context) async {
    // Fetch invite token and show same dialog UX as creation flow
    final inviteResp = await ApiClient.instance.getGroupInvite(groupId);
    if (!inviteResp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(inviteResp.error ?? (isArabic ? 'خطأ الدعوة' : 'Invite error'))),
      );
      return;
    }

    final invite = (inviteResp.data['invite'] as Map).cast<String, dynamic>();
    final token = (invite['token'] as String).trim();
    final message = isArabic
        ? 'استخدم هذا الرمز للانضمام إلى مجموعة الختمة: $token'
        : 'Use this token to join the Khitma group: $token';

    final isDark = !isLightMode;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          title: Text(
            isArabic ? 'دعوة الأعضاء' : 'Invite members',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D1B69),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2D1B69),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        token,
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF2D1B69),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: isArabic ? 'نسخ' : 'Copy',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: isDark ? Colors.white : const Color(0xFF2D1B69),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Share.share(message);
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                isArabic ? 'مشاركة' : 'Share',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D1B69)),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                isArabic ? 'نسخ' : 'Copy',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D1B69)),
              ),
            ),
          ],
        );
      },
    );
  }
}