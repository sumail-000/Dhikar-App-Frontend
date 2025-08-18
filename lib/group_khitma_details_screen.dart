import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wered/group_khitma_info_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class DhikrGroupDetailsScreen extends StatefulWidget {
  const DhikrGroupDetailsScreen({super.key});

  @override
  State<DhikrGroupDetailsScreen> createState() =>
      _DhikrGroupDetailsScreenState();
}

class _DhikrGroupDetailsScreenState extends State<DhikrGroupDetailsScreen> {
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
                                      ? 'تفاصيل ختمة المجموعة'
                                      : 'Group Khitma Details',
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

                        // Main content - centered
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Main message
                                  Text(
                                    languageProvider.isArabic
                                        ? 'لم يتم تعيين جزء لك!'
                                        : 'No juz assigned to you!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 20),

                                  // Description text
                                  Text(
                                    languageProvider.isArabic
                                        ? 'ستتمكن من رؤية تفاصيل الختمة\nعندما يقوم المشرف بتعيين جزء لك.'
                                        : 'Yiou will be able to see khitma details\nwhen admin assign you a juz.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 40),

                                  // See Group Info button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Sample members data - in a real app this would come from a database or API
                                        final sampleMembers = [
                                          {
                                            'name': 'Bint e Hawa',
                                            'juzz': '01',
                                            'status': 'Completed',
                                          },
                                          {
                                            'name': 'Muhammad Umar Farooq',
                                            'juzz': '02',
                                            'status': 'In Progress',
                                          },
                                          {
                                            'name': 'Muhammad Abu Bakar',
                                            'juzz': '03',
                                            'status': 'Completed',
                                          },
                                          {
                                            'name': 'Muhammad Hussain',
                                            'juzz': '04',
                                            'status': 'Completed',
                                          },
                                          {
                                            'name': 'Hassan Mujtaba',
                                            'juzz': '05',
                                            'status': 'Completed',
                                          },
                                          {
                                            'name': 'Ali Murtaza',
                                            'juzz': '06',
                                            'status': 'Cancelled',
                                          },
                                          {
                                            'name': 'Bint e Iqbal',
                                            'juzz': '07',
                                            'status': 'In Progress',
                                          },
                                          {
                                            'name': 'Usman Ghani',
                                            'juzz': '08',
                                            'status': 'Completed',
                                          },
                                        ];

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GroupInfoScreen(
                                                  members: sampleMembers,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? Colors.white.withOpacity(0.2)
                                            : const Color(0xFF2E7D32),
                                        foregroundColor: isDarkMode
                                            ? textColor
                                            : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          side: BorderSide(
                                            color: isDarkMode
                                                ? textColor
                                                : Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        languageProvider.isArabic
                                            ? 'عرض معلومات المجموعة'
                                            : 'See Group Info',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? textColor
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
