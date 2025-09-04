import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'group_dhikr_details_screen.dart';
import 'services/api_client.dart';
import 'dhikr_group_screen.dart';
import 'dhikr_presets.dart';
import 'widgets/add_custom_dhikr_dialog.dart';

class DhikrNewGroupScreen extends StatefulWidget {
  const DhikrNewGroupScreen({super.key});

  @override
  State<DhikrNewGroupScreen> createState() => _DhikrNewGroupScreenState();
}

class _DhikrNewGroupScreenState extends State<DhikrNewGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  String? _selectedDhikr;
  bool _isDropdownExpanded = false;
  bool _agreeToTerms = false;
  bool _creating = false;

  // Use shared presets + loaded custom
  List<Map<String, String>> _dhikrOptions = List<Map<String, String>>.from(DhikrPresets.presets);

  @override
  void initState() {
    super.initState();
    _loadCustomDhikr();
  }

  Future<void> _loadCustomDhikr() async {
    final resp = await ApiClient.instance.getCustomDhikr();
    if (!mounted) return;
    if (resp.ok && resp.data is Map && resp.data['custom_dhikr'] is List) {
      final List list = resp.data['custom_dhikr'] as List;
      final mapped = list.map<Map<String, String>>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return {
          'title': (m['title'] ?? '').toString(),
          'titleArabic': (m['title_arabic'] ?? m['title'] ?? '').toString(),
          'subtitle': (m['subtitle'] ?? '').toString(),
        };
      }).where((m) => m['title']!.isNotEmpty).toList();
      setState(() {
        _dhikrOptions.addAll(mapped);
      });
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _targetController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: isLightMode
                ? Colors.white
                : themeProvider.backgroundColor,
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Stack(
              children: [
                // Background images covering entire screen
                // Background image for both themes
                Positioned.fill(
                  child: Opacity(
                    opacity: !isLightMode ? 0.5 : 1.0,
                    child: Image.asset(
                      themeProvider.backgroundImage3,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                // Color overlay for dark mode only
                if (!isLightMode)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                // Main content with SafeArea
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                // Header
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: isLightMode
                                            ? greenColor
                                            : creamColor,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        isArabic
                                            ? 'مجموعة ذكر جديدة'
                                            : 'New Dhikr Group',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isLightMode
                                              ? greenColor
                                              : creamColor,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 48,
                                    ), // Balance the back button
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Group Name Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isLightMode
                                          ? Colors.grey[300]!
                                          : Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _groupNameController,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic
                                          ? 'اسم المجموعة'
                                          : 'Group Name',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        fontFamily: amiriFont,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Choose Dhikr Dropdown
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownExpanded =
                                          !_isDropdownExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8E8F0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedDhikr ??
                                                (isArabic
                                                    ? 'اختر الذكر'
                                                    : 'Choose Dhikr'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _selectedDhikr != null
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                              fontFamily: amiriFont,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          _isDropdownExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dhikr Options
                                if (_isDropdownExpanded) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 240,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _dhikrOptions.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final dhikr = _dhikrOptions[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDhikr = dhikr['title'];
                                              _isDropdownExpanded = false;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8E8F0),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        dhikr['title'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        dhikr['subtitle'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  dhikr['titleArabic'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontFamily: 'Amiri',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Add Custom Dhikr Option
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await showAddCustomDhikrDialog(context, isArabic: isArabic);
                                        if (result != null) {
                                          final resp = await ApiClient.instance.createCustomDhikr(
                                            title: result['title']!,
                                            titleArabic: result['titleArabic']!,
                                            subtitle: result['subtitle'],
                                            subtitleArabic: result['subtitleArabic'],
                                            arabic: result['arabic']!,
                                          );
                                          if (!mounted) return;
                                          if (resp.ok) {
                                            setState(() {
                                              _dhikrOptions.add({
                                                'title': result['title']!,
                                                'titleArabic': result['titleArabic']!,
                                                'subtitle': result['subtitle'] ?? '',
                                              });
                                              _selectedDhikr = result['title'];
                                              _isDropdownExpanded = false;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(isArabic ? 'تم إضافة الذكر' : 'Dhikr added')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(resp.error ?? (isArabic ? 'فشل الإضافة' : 'Failed to add'))),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8E8F0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isArabic ? 'إضافة ذكر مخصص' : 'Add Custom Dhikr',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.add,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),

                                // Days to complete Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isLightMode
                                          ? Colors.grey[300]!
                                          : Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _daysController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic ? 'الأيام لإكمال الذكر' : 'Days to complete',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        fontFamily: amiriFont,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Target Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isLightMode
                                          ? Colors.grey[300]!
                                          : Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _targetController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic ? 'الهدف' : 'Target',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        fontFamily: amiriFont,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Privacy Policy Checkbox
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _agreeToTerms = !_agreeToTerms;
                                        });
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _agreeToTerms
                                              ? const Color(0xFF4CAF50)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: _agreeToTerms
                                                ? const Color(0xFF4CAF50)
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: _agreeToTerms
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        isArabic
                                            ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
                                            : 'Agree to our Privacy Policy & Terms and Conditions',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isLightMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Create Group Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLightMode
                                          ? const Color(0xFF205C3B)
                                          : Colors.white,
                                      disabledBackgroundColor: isLightMode
                                          ? const Color(
                                              0xFF205C3B,
                                            ).withOpacity(0.6)
                                          : Colors.white,
                                      foregroundColor: isLightMode
                                          ? Colors.white
                                          : const Color(0xFF6B46C1),
                                      disabledForegroundColor: isLightMode
                                          ? Colors.white.withOpacity(0.6)
                                          : const Color(
                                              0xFF6B46C1,
                                            ).withOpacity(0.6),
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                    ),
onPressed:
                                        _creating ||
                                        !(_agreeToTerms &&
                                            _groupNameController.text.trim().isNotEmpty &&
                                            _selectedDhikr != null &&
                                            _daysController.text.trim().isNotEmpty &&
                                            _targetController.text.trim().isNotEmpty)
                                        ? null
                                        : () async {
                                            final lang = context.read<LanguageProvider>();
                                            final theme = context.read<ThemeProvider>();
                                            final isArabic = lang.isArabic;
                                            final isDark = theme.isDarkMode;
                                            final name = _groupNameController.text.trim();
                                            final days = int.tryParse(_daysController.text.trim());
                                            final target = int.tryParse(_targetController.text.trim());

                                            setState(() => _creating = true);
                                            try {
                                              // Create a new Dhikr group
                                              if (target == null || target <= 0) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(isArabic ? 'يرجى إدخال هدف صالح' : 'Please enter a valid target')),
                                                );
                                                return;
                                              }
                                              // Resolve selected dhikr titles from options
final Map<String, String> selectedMap = _dhikrOptions.firstWhere(
                                                (m) => m['title'] == _selectedDhikr,
                                                orElse: () => <String, String>{},
                                              );
                                              final String? selTitle = selectedMap.isNotEmpty ? selectedMap['title'] : _selectedDhikr;
                                              final String? selTitleAr = selectedMap.isNotEmpty ? selectedMap['titleArabic'] : null;

                                              final resp = await ApiClient.instance.createDhikrGroup(
                                                name: name,
                                                daysToComplete: days,
                                                dhikrTarget: target,
                                                dhikrTitle: selTitle,
                                                dhikrTitleArabic: selTitleAr,
                                                isPublic: true,
                                              );
                                              if (!mounted) return;
                                              if (!resp.ok || resp.data is! Map) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(isArabic ? 'فشل إنشاء المجموعة' : 'Failed to create group')),
                                                );
                                                return;
                                              }

                                              // Success feedback
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(isArabic ? 'تم إنشاء المجموعة بنجاح' : 'Group created successfully')),
                                              );

                                              // Extract new group id
                                              Map data = resp.data as Map;
                                              final Map<String, dynamic>? group = (data['group'] as Map?)?.cast<String, dynamic>();
                                              int? gid;
                                              if (group != null) {
                                                final v = group['id'];
                                                gid = (v is int) ? v : int.tryParse('${v ?? ''}');
                                              }

                                              if (gid == null) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => const DhikrGroupScreen()),
                                                  (route) => route.isFirst,
                                                );
                                                return;
                                              }

                                              // Fetch or create invite token for this group
                                              final inviteResp = await ApiClient.instance.getDhikrGroupInvite(gid);
                                              if (!mounted) return;
                                              String? token;
                                              if (inviteResp.ok && inviteResp.data is Map) {
                                                final inv = (inviteResp.data['invite'] as Map?)?.cast<String, dynamic>();
                                                token = inv?['token'] as String?;
                                              }

                                              // Show invite dialog with copy and share options
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (ctx) {
                                                  final Color bg = isDark ? const Color(0xFF2D1B69) : Colors.white;
                                                  final Color fg = isDark ? Colors.white : const Color(0xFF2D1B69);
                                                  final Color accent = isDark ? const Color(0xFF8B5CF6) : const Color(0xFF205C3B);
                                                  final String code = token ?? (isArabic ? '—' : '—');
                                                  final String instructions = isArabic
                                                      ? 'لمشاركة المجموعة: شارك هذا الرمز مع أصدقائك. للانضمام: افتح تطبيقنا > مجموعات الذكر > تبويب منضم > اضغط على زر المفتاح لإدخال الرمز.'
                                                      : 'To share: send this code to your friends. To join: open our app > Dhikr Groups > Joined tab > tap the key button and enter the code.';
                                                  return AlertDialog(
                                                    backgroundColor: bg,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    title: Text(
                                                      isArabic ? 'تم إنشاء المجموعة' : 'Group Created',
                                                      style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          isArabic ? 'رمز الدعوة:' : 'Invite Code:',
                                                          style: TextStyle(color: fg.withOpacity(0.9), fontWeight: FontWeight.w600),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Container(
                                                          width: double.infinity,
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                          decoration: BoxDecoration(
                                                            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2),
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  code,
                                                                  style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w700),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await Clipboard.setData(ClipboardData(text: code));
                                                                  if (!mounted) return;
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text(isArabic ? 'تم نسخ الرمز' : 'Code copied')),
                                                                  );
                                                                },
                                                                icon: Icon(Icons.copy, color: fg),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 12),
                                                        Text(
                                                          instructions,
                                                          style: TextStyle(color: fg.withOpacity(0.85)),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          final text = isArabic
                                                              ? 'انضم إلى مجموعة الذكر الخاصة بي: $name\nرمز الدعوة: $code'
                                                              : 'Join my Dhikr group: $name\nInvite code: $code';
                                                          await Share.share(text);
                                                        },
                                                        child: Text(isArabic ? 'مشاركة' : 'Share', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.of(ctx).pop(),
                                                        child: Text(isArabic ? 'تم' : 'Done', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (!mounted) return;
                                              // Navigate back to list (ensure Joined tab shows new group)
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (_) => const DhikrGroupScreen()),
                                                (route) => route.isFirst,
                                              );
                                            } finally {
                                              if (mounted) setState(() => _creating = false);
                                            }
                                          },
                                    child: _creating
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(
                                            isArabic ? 'إنشاء مجموعة' : 'Create Group',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: amiriFont,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
