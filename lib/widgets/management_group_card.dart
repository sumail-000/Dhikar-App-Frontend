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
    final title = isArabic ? titleArabic : titleEnglish;
    final privacy = isArabic ? (isPublic ? 'عام' : 'خاص') : (isPublic ? 'Public' : 'Private');
    
    // App's theming system integration
    final primaryColor = isLightMode ? const Color(0xFF251629) : const Color(0xFF6B46C1); // App's purple theme
    final secondaryColor = isLightMode ? const Color(0xFF392852) : const Color(0xFF8B5CF6); // App's secondary purple
    final surfaceColor = isLightMode ? const Color(0xFFF2EDE0) : const Color(0xFF251629); // App's card colors
    final textPrimaryColor = isLightMode ? const Color(0xFF051F20) : Colors.white; // App's text colors
    final textSecondaryColor = isLightMode ? const Color(0xFF235347) : const Color(0xFFB0BEC5); // App's green/secondary
    final borderColor = isLightMode ? const Color(0xFF251629) : Colors.white.withOpacity(0.2); // App's border colors
    
    return Container(
      decoration: BoxDecoration(
        gradient: isLightMode 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  surfaceColor, // App's card background
                  const Color(0xFFF7F3E8), // App's cream color
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF251629), // App's dark primary
                  const Color(0xFF4C3B6E), // App's gradient secondary
                ],
              ),
        borderRadius: BorderRadius.circular(12), // App's standard radius
        border: Border.all(color: borderColor, width: 1), // App's border style
        boxShadow: [
          if (isLightMode)
            BoxShadow(
              color: primaryColor.withOpacity(0.08), // App's primary color shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          if (!isLightMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Match container radius
        child: Stack(
          children: [
            // App-themed background accent
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isLightMode ? const Color(0xFFC2AEEA) : const Color(0xFF6B46C1)).withOpacity(0.06), // App's accent colors
                ),
              ),
            ),
            
            // Privacy badge positioned at top-right
            Positioned(
              top: 8, // Reduced from 12
              right: 8, // Reduced from 12
              child: _modernBadge(privacy, isLightMode, isPublic),
            ),
            
            // Main content - Compact padding
            Padding(
              padding: const EdgeInsets.all(14), // Reduced from 20 to 14
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group icon + title - Compact version
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Changed from start to center
                    children: [
                      // Smaller group icon
                      Container(
                        width: 36, // Reduced from 48 to 36
                        height: 36, // Reduced from 48 to 36
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10), // Reduced from 14 to 10
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25), // Reduced opacity
                              blurRadius: 6, // Reduced from 8 to 6
                              offset: const Offset(0, 1), // Reduced offset
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 18, // Reduced from 24 to 18
                        ),
                      ),
                      const SizedBox(width: 12), // Reduced from 16 to 12
                      
                      // Title and subtitle area - Compact
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.isNotEmpty ? title : (isArabic ? 'مجموعة بدون اسم' : 'Untitled Group'),
                              maxLines: 1, // Reduced from 2 to 1
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16, // Reduced from 18 to 16
                                fontWeight: FontWeight.w700,
                                color: textPrimaryColor,
                                height: 1.2, // Reduced height
                                letterSpacing: -0.3, // Reduced from -0.5
                              ),
                            ),
                            const SizedBox(height: 2), // Reduced from 4 to 2
                            Text(
                              isArabic ? 'مجموعة الختمة' : 'Khitma Group',
                              style: TextStyle(
                                fontSize: 11, // Reduced from 13 to 11
                                fontWeight: FontWeight.w500,
                                color: textSecondaryColor,
                                letterSpacing: 0.1, // Reduced from 0.2
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12), // Reduced from 20 to 12
                  
                  // Compact stats row - App themed
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLightMode 
                          ? const Color(0xFFDAF1DE) // App's light accent color
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLightMode 
                            ? const Color(0xFF235347) // App's green color
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14, // Reduced from 16 to 14
                          color: textSecondaryColor,
                        ),
                        const SizedBox(width: 4), // Reduced from 6 to 4
                        Text(
                          isArabic ? 'الأعضاء: $membersCount' : 'Members: $membersCount',
                          style: TextStyle(
                            fontSize: 11, // Reduced from 12 to 11
                            fontWeight: FontWeight.w600,
                            color: textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isPublic ? const Color(0xFF235347) : const Color(0xFF392852), // App's theme colors
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10), // Reduced from 16 to 10
                  
                  // Compact action buttons row
                  Row(
                    children: [
                      // Main CTA button (Open) - Compact
                      Expanded(
                        flex: 2,
                        child: _modernButton(
                          context,
                          icon: isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                          label: isArabic ? 'فتح' : 'Open',
                          onTap: onOpen,
                          isPrimary: true,
                          isLightMode: isLightMode,
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                        ),
                      ),
                      
                      const SizedBox(width: 6), // Reduced from 8 to 6
                      
                      // App-themed secondary actions
                      _modernIconButton(
                        context,
                        icon: Icons.share_rounded,
                        tooltip: isArabic ? 'دعوة' : 'Invite',
                        onTap: () => _handleInvite(context),
                        isLightMode: isLightMode,
                        color: const Color(0xFF235347), // App's green for invite
                      ),
                      
                      const SizedBox(width: 6),
                      
                      _modernIconButton(
                        context,
                        icon: Icons.delete_outline,
                        tooltip: isArabic ? 'حذف' : 'Delete',
                        onTap: () => _confirmAndDelete(context),
                        isLightMode: isLightMode,
                        color: const Color(0xFFB91C1C), // More subdued red that matches app theme
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernBadge(String label, bool isLightMode, bool isPublic) {
    final color = isPublic 
        ? const Color(0xFF235347) // App's green for public
        : const Color(0xFF392852); // App's purple for private
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(isLightMode ? 0.15 : 0.25),
        borderRadius: BorderRadius.circular(12), // Reduced from 20 to 12
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, // Reduced from 6 to 5
            height: 5, // Reduced from 6 to 5
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3), // Reduced from 4 to 3
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // Reduced from 11 to 10
              fontWeight: FontWeight.w600,
              color: isLightMode ? color : Colors.white,
              letterSpacing: 0.2, // Reduced from 0.3
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isLightMode,
    required Color primaryColor,
    required Color secondaryColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8), // Reduced from 12 to 8
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [primaryColor, secondaryColor],
                  )
                : null,
            color: isPrimary ? null : (isLightMode ? const Color(0xFFE3D9F6) : Colors.white.withOpacity(0.1)), // App's light purple accent
            borderRadius: BorderRadius.circular(8),
            border: !isPrimary
                ? Border.all(
                    color: isLightMode ? const Color(0xFF392852) : Colors.white.withOpacity(0.2), // App's purple border
                  )
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25), // Reduced opacity
                      blurRadius: 6, // Reduced from 8 to 6
                      offset: const Offset(0, 1), // Reduced offset
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Reduced from 14 to 12
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isLightMode ? const Color(0xFF251629) : Colors.white), // App's primary dark color
                ),
              ),
              const SizedBox(width: 4), // Reduced from 6 to 4
              Icon(
                icon,
                size: 14, // Reduced from 16 to 14
                color: isPrimary
                    ? Colors.white
                    : (isLightMode ? const Color(0xFF251629) : Colors.white), // App's primary dark color
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernIconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required bool isLightMode,
    required Color color,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8), // Reduced from 10 to 8
          child: Container(
            width: 32, // Reduced from 40 to 32
            height: 32, // Reduced from 40 to 32
            decoration: BoxDecoration(
              color: color.withOpacity(isLightMode ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(8), // Reduced from 10 to 8
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16, // Reduced from 18 to 16
              color: isLightMode ? color : Colors.white,
            ),
          ),
        ),
      ),
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

  Future<void> _confirmAndDelete(BuildContext context) async {
    final isDark = !isLightMode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isArabic ? 'حذف المجموعة؟' : 'Delete group?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D1B69),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            isArabic
                ? 'سيتم حذف المجموعة وجميع التعيينات والدعوات. لا يمكن التراجع.'
                : 'This will delete the group, its assignments and invites. This action cannot be undone.',
            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF2D1B69)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                isArabic ? 'حذف' : 'Delete',
                style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final resp = await ApiClient.instance.deleteGroup(groupId);
    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? (isArabic ? 'فشل الحذف' : 'Delete failed'))),
      );
      return;
    }

    // Inform parent to refresh UI or remove this card
    if (onDelete != null) onDelete!();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isArabic ? 'تم حذف المجموعة' : 'Group deleted')),
    );
  }
}