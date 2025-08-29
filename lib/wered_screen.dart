import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'group_khitma_details_screen.dart';

class WeredScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const WeredScreen({super.key, this.groupId, this.groupName});

  @override
  State<WeredScreen> createState() => _WeredScreenState();
}

class _WeredScreenState extends State<WeredScreen> {
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
                    onPressed: () {
                      // Navigate to DhikrGroupDetailsScreen with groupId if available
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DhikrGroupDetailsScreen(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                          ),
                        ),
                      );
                    },
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
                    child: Text(
                      languageProvider.isArabic
                          ? 'التعيين التلقائي'
                          : 'Auto Assign',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Manual Assign Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle manual assign
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            languageProvider.isArabic
                                ? 'انتقال إلى التعيين اليدوي'
                                : 'Navigate to manual assignment',
                          ),
                        ),
                      );
                    },
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
