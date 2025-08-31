import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'group_khitma_admin_screen.dart';
import 'services/api_client.dart';
import 'group_khitma_assignments_admin_screen.dart';

class WeredScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const WeredScreen({super.key, this.groupId, this.groupName});

  @override
  State<WeredScreen> createState() => _WeredScreenState();
}

class _WeredScreenState extends State<WeredScreen> {
  bool _busy = false;

  Future<bool> _confirmAutoAssign(LanguageProvider languageProvider) async {
    if (widget.groupId == null) return false;
    // Fetch group to detect current mode
    final resp = await ApiClient.instance.getGroup(widget.groupId!);
    if (!resp.ok) return true; // If cannot fetch, default to confirm silently
    final g = (resp.data['group'] as Map?)?.cast<String, dynamic>();
    final autoEnabled = (g != null && g['auto_assign_enabled'] == true);
    if (autoEnabled) return true; // no manual customizations active

    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(languageProvider.isArabic ? 'إعادة التعيين التلقائي؟' : 'Reset with Auto-assign?'),
          content: Text(
            languageProvider.isArabic
                ? 'سيؤدي التعيين التلقائي إلى إعادة تعيين التخصيصات اليدوية الحالية. هل تريد المتابعة؟'
                : 'Auto-assign will reset current manual customizations. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(languageProvider.isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(languageProvider.isArabic ? 'متابعة' : 'Continue'),
            ),
          ],
        );
      },
    );
    return proceed == true;
  }

  Future<void> _autoAssign(LanguageProvider languageProvider) async {
    if (widget.groupId == null) return;

    // Confirm if this will reset manual state
    final ok = await _confirmAutoAssign(languageProvider);
    if (!ok) return; // user canceled

    setState(() => _busy = true);
    final resp = await ApiClient.instance.khitmaAutoAssign(widget.groupId!);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!resp.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.error ?? (languageProvider.isArabic ? 'فشل التعيين التلقائي' : 'Auto-assign failed'))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(languageProvider.isArabic ? 'تم التعيين تلقائياً' : 'Auto-assigned successfully')),
    );
    // Navigate to assignments preview table
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GroupKhitmaAssignmentsAdminScreen(
          groupId: widget.groupId!,
          groupName: widget.groupName,
        ),
      ),
    );
  }

  Future<void> _manualAssign(LanguageProvider languageProvider) async {
    // Open the unified assignments table in manual mode (matches your Figma table UX)
    if (widget.groupId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupKhitmaAssignmentsAdminScreen(
          groupId: widget.groupId!,
          groupName: widget.groupName,
          manualMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final creamColor = const Color(0xFFF7F3E8);
        final greenColor = const Color(0xFF2E7D32);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background_elements/6.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ]
                        : [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.3),
                          ],
                  ),
                ),
                child: _buildContent(
                  languageProvider,
                  isDarkMode,
                  creamColor,
                  greenColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    LanguageProvider languageProvider,
    bool isDarkMode,
    Color creamColor,
    Color greenColor,
  ) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          // Header with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Spacer to push content to bottom
          const Spacer(),

          // Main content at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D1B69) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  languageProvider.isArabic ? 'تعيين الجزء' : 'Assign Juz',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  languageProvider.isArabic
                      ? 'إدارة توزيع الختمة بسهولة، اختر تعيين الجزء يدوياً لكل عضو أو دع التطبيق يعينها تلقائياً لك.'
                      : 'Easily manage Khitma distribution, choose to assign Juz manually to each member or let the app auto-assign them for you.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Auto Assign Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _autoAssign(languageProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? creamColor : greenColor,
                      foregroundColor: isDarkMode
                          ? const Color(0xFF2D1B69)
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            languageProvider.isArabic ? 'التعيين التلقائي' : 'Auto Assign',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Manual Assign Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _manualAssign(languageProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? creamColor : Colors.white,
                      foregroundColor: isDarkMode
                          ? const Color(0xFF2D1B69)
                          : greenColor,
                      elevation: 0,
                      side: isDarkMode
                          ? null
                          : BorderSide(color: greenColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      languageProvider.isArabic
                          ? 'التعيين اليدوي'
                          : 'Manual Assign',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
