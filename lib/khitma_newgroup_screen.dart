import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';

class KhitmaNewgroupScreen extends StatefulWidget {
  const KhitmaNewgroupScreen({super.key});

  @override
  State<KhitmaNewgroupScreen> createState() => _KhitmaNewgroupScreenState();
}

class _KhitmaNewgroupScreenState extends State<KhitmaNewgroupScreen> {
  int? selectedDays;
  bool agreedToTerms = false;
  bool _creating = false;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupMembersController = TextEditingController();
  bool _isPublic = true;

  final List<Map<String, dynamic>> khitmaOptions = [
    {'days': 1, 'juzzDaily': 30},
    {'days': 2, 'juzzDaily': 15},
    {'days': 3, 'juzzDaily': 10},
    {'days': 4, 'juzzDaily': 8},
    {'days': 5, 'juzzDaily': 6},
    {'days': 6, 'juzzDaily': 5},
    {'days': 10, 'juzzDaily': 3},
    {'days': 15, 'juzzDaily': 2},
    {'days': 30, 'juzzDaily': 1},
  ];


  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        MediaQuery.of(context);
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);
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
                  // Background image with optimized loading (always visible)
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800, // Optimize memory usage
                        filterQuality: FilterQuality
                            .medium, // Balance quality and performance
                      ),
                    ),
                  ),
                  // Color overlay for dark mode only
                  if (themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            // Header
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                    size: 22,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'مجموعة جديدة من الخِتمة'
                                        : 'New Khitma Group',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? greenColor
                                          : creamColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: groupNameController,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: languageProvider.isArabic
                                      ? 'اسم المجموعة'
                                      : 'Group Name',
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Public/Private toggle
                            Row(
                              children: [
                                Switch(
                                  value: _isPublic,
                                  onChanged: (v) => setState(() => _isPublic = v),
                                  activeColor: isLightMode ? greenColor : creamColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  languageProvider.isArabic ? (_isPublic ? 'عام' : 'خاص') : (_isPublic ? 'Public' : 'Private'),
                                  style: TextStyle(
                                    color: isLightMode ? greenColor : creamColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // Predefined options (all day options enabled)
                            ...khitmaOptions.map((option) {
                              final int days = option['days'] as int;
                              final isSelected = selectedDays == days;
                              final baseBg = themeProvider.isDarkMode ? Colors.white : const Color(0xFFE8F5E8);
                              final selectedBg = themeProvider.isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFF2D5A27);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedDays = days;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? selectedBg : baseBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? selectedBg : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          days == 1
                                              ? (languageProvider.isArabic ? 'يوم واحد' : '1 Day')
                                              : (languageProvider.isArabic ? '$days أيام' : '$days Days'),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF2D1B69),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          languageProvider.isArabic
                                              ? '${option['juzzDaily']} جزء يومياً'
                                              : '${option['juzzDaily']} Juzz Daily',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white.withOpacity(0.9) : const Color(0xFF2D1B69).withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 15),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: groupMembersController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: languageProvider.isArabic
                                      ? 'اسم المجموعة'
                                      : 'Group Members',
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Privacy policy checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      agreedToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: themeProvider.isDarkMode
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF2D5A27),
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
                                        : 'Agree to our Privacy Policy & Terms and Conditions',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // Start Khitma button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    agreedToTerms &&
                                            selectedDays != null &&
                                            groupNameController.text.trim().isNotEmpty
                                        ? _createGroup
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF2D5A27),
                                  foregroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFF2D1B69)
                                      : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  disabledBackgroundColor:
                                      themeProvider.isDarkMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 16, 34, 13),
                                ),
                                child: _creating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        languageProvider.isArabic
                                            ? 'إنشاء مجموعة'
                                            : 'Create Group',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: themeProvider.isDarkMode
                                              ? const Color(0xFF2D1B69)
                                              : Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
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

  Future<void> _createGroup() async {
    final name = groupNameController.text.trim();
    final days = selectedDays;
    if (days == null || name.isEmpty) return;


    setState(() => _creating = true);
    final resp = await ApiClient.instance.createGroup(
      name: name,
      type: 'khitma',
      daysToComplete: days,
      membersTarget: int.tryParse(groupMembersController.text.trim()) ?? 15,
      isPublic: _isPublic,
    );
    if (!mounted) return;
    setState(() => _creating = false);

    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? 'Error')),
      );
      return;
    }

    // On success: fetch invite token and show dialog with Share/Copy
    try {
      final group = (resp.data['group'] as Map).cast<String, dynamic>();
      final gid = group['id'] as int;
      final inviteResp = await ApiClient.instance.getGroupInvite(gid);
      if (!mounted) return;
      if (!inviteResp.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(inviteResp.error ?? 'Invite error')),
        );
        Navigator.pop(context, true);
        return;
      }
      final invite = (inviteResp.data['invite'] as Map).cast<String, dynamic>();
      final token = (invite['token'] as String).trim();
      final isArabic = context.read<LanguageProvider>().isArabic;
      final message = isArabic
          ? 'استخدم هذا الرمز للانضمام إلى مجموعة الختمة: $token'
          : 'Use this token to join the Khitma group: $token';

      await showDialog(
        context: context,
        builder: (ctx) {
          final isDark = context.read<ThemeProvider>().isDarkMode;
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
    } catch (_) {
      // Fallback to simple toast if anything fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khitma group created')),
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupMembersController.dispose();
    super.dispose();
  }
}
