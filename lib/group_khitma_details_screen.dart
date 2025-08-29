import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wered/group_khitma_info_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class DhikrGroupDetailsScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const DhikrGroupDetailsScreen({super.key, this.groupId, this.groupName});

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
                                        // Prefer real backend data if groupId is available
                                        if (widget.groupId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GroupInfoScreen(
                                                groupId: widget.groupId,
                                                groupName: widget.groupName,
                                              ),
                                            ),
                                          ).then((changed) async {
                                            if (changed == true) {
                                              // On returning after join, you may want to refresh upstream lists/screens.
                                              // This screen does not own the lists; parent screens will handle refresh.
                                            }
                                          });
                                          return;
                                        }

                                        // Fallback: if no groupId provided, keep previous behavior but inform developer
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Group ID not provided. Cannot load real group info.'),
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
