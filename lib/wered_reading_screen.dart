import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class WeredReadingScreen extends StatefulWidget {
  final List<String> selectedSurahs;
  final String pages;

  const WeredReadingScreen({
    super.key,
    required this.selectedSurahs,
    required this.pages,
  });

  @override
  State<WeredReadingScreen> createState() => _WeredReadingScreenState();
}

class _WeredReadingScreenState extends State<WeredReadingScreen> {
  int currentSurahIndex = 0;
  List<Map<String, dynamic>> surahData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  Future<void> _loadSurahData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/surah_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        surahData = jsonData.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load Surah data: $e';
        isLoading = false;
      });
    }
  }

  Map<String, String>? _getCurrentSurahContent() {
    if (surahData.isEmpty) return null;

    final currentSurahName = widget.selectedSurahs[currentSurahIndex];
    final surah = surahData.firstWhere(
      (s) => s['name'] == currentSurahName,
      orElse: () => {},
    );

    if (surah.isEmpty) return null;

    return {
      'title': surah['title'] ?? currentSurahName,
      'arabic': surah['arabic'] ?? 'Content not available',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        // Handle loading state
        if (isLoading) {
          return Scaffold(
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
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A148C)),
              ),
            ),
          );
        }

        // Handle error state
        if (errorMessage != null) {
          return Scaffold(
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFF4A148C),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF4A148C),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        languageProvider.isArabic ? 'العودة' : 'Go Back',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final currentSurah = widget.selectedSurahs[currentSurahIndex];
        final content = _getCurrentSurahContent();

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
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
                  // Background image
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
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
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: themeProvider.isDarkMode
                                      ? const Color(0xFFF7F3E8)
                                      : const Color(0xFF205C3B),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'الورد اليومي'
                                      : 'Daily Wered',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? const Color(0xFFF7F3E8)
                                        : const Color(0xFF205C3B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                        ),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            languageProvider.isArabic
                                ? 'اشغل قلبك بذكر الله. اختر ذكراً لتبدأ اتصالك الروحي والسلام.'
                                : 'Engage your heart in the remembrance of Allah. Select a Dhikr to begin your spiritual connection and peace.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? const Color(0xFFF7F3E8).withOpacity(0.8)
                                  : const Color(0xFF205C3B).withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Pages info
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            languageProvider.isArabic
                                ? 'عدد الصفحات: ${widget.pages}'
                                : 'No. of Pages: ${widget.pages}',
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? const Color(0xFFF7F3E8)
                                  : const Color(0xFF205C3B),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Surah content
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Surah title
                                  Text(
                                    content?['title'] ?? currentSurah,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A148C),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // Arabic text
                                  Text(
                                    content?['arabic'] ??
                                        'Content for $currentSurah will be displayed here.',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      height: 2.0,
                                      color: Color(0xFF2D1B69),
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Save Wered button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle save wered
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          languageProvider.isArabic
                                              ? 'تم حفظ الورد بنجاح!'
                                              : 'Wered saved successfully!',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF7F3E8),
                                    foregroundColor: const Color(0xFF2D1B69),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'حفظ الورد'
                                        : 'Save Wered',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Change Surah button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF7F3E8),
                                    foregroundColor: const Color(0xFF2D1B69),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'تغيير السورة'
                                        : 'Change Surah',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Add Surah button (if multiple surahs selected)
                              if (widget.selectedSurahs.length > 1)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (currentSurahIndex <
                                          widget.selectedSurahs.length - 1) {
                                        setState(() {
                                          currentSurahIndex++;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              languageProvider.isArabic
                                                  ? 'لقد وصلت إلى السورة الأخيرة!'
                                                  : 'You have reached the last surah!',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2D1B69),
                                      side: const BorderSide(
                                        color: Color(0xFF2D1B69),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'السورة التالية (${currentSurahIndex + 1}/${widget.selectedSurahs.length})'
                                          : 'Next Surah (${currentSurahIndex + 1}/${widget.selectedSurahs.length})',
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
