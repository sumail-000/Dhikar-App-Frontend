import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class GroupInfoScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? members;

  const GroupInfoScreen({super.key, this.members});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);

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
                      opacity: isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800, // Optimize memory usage
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header with back button and title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  languageProvider.isArabic
                                      ? Icons.arrow_forward_ios
                                      : Icons.arrow_back_ios,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'معلومات المجموعة'
                                      : 'Group Info.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Group Name
                        Text(
                          languageProvider.isArabic
                              ? 'دائرة القرآن'
                              : 'The Qur\'an Circle',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Members count
                        Text(
                          languageProvider.isArabic
                              ? '${widget.members?.length ?? 0} عضو'
                              : '${widget.members?.length ?? 0} Members',
                          style: TextStyle(fontSize: 16, color: textColor),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Members List title (but no actual list as requested)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: languageProvider.isArabic
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              languageProvider.isArabic
                                  ? 'قائمة الأعضاء'
                                  : 'Members List',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Empty space where members list would be
                        Expanded(
                          child: Center(
                            child: Text(
                              languageProvider.isArabic
                                  ? 'لا توجد تفاصيل أعضاء للعرض'
                                  : 'No member details to display',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.7)
                                    : textColor.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
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
}
