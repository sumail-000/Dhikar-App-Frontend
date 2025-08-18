import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dhikr_provider.dart';

class StartDhikrScreen extends StatefulWidget {
  final String dhikrTitle;
  final String dhikrTitleArabic;
  final String dhikrSubtitle;
  final String dhikrSubtitleArabic;
  final String dhikrArabic;
  final int target;

  const StartDhikrScreen({
    super.key,
    required this.dhikrTitle,
    required this.dhikrTitleArabic,
    required this.dhikrSubtitle,
    required this.dhikrSubtitleArabic,
    required this.dhikrArabic,
    required this.target,
  });

  @override
  State<StartDhikrScreen> createState() => _StartDhikrScreenState();
}

class _StartDhikrScreenState extends State<StartDhikrScreen> {
  int _currentCount = 0;

  void _incrementCounter() {
    if (_currentCount < widget.target) {
      setState(() {
        _currentCount++;
      });
    }
  }

  void _decrementCounter() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _currentCount = 0;
    });
  }

  void _saveDhikr() {
    final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    dhikrProvider.saveDhikr(
      title: widget.dhikrTitle,
      titleArabic: widget.dhikrTitleArabic,
      subtitle: widget.dhikrSubtitle,
      subtitleArabic: widget.dhikrSubtitleArabic,
      arabic: widget.dhikrArabic,
      target: widget.target,
      currentCount: _currentCount,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageProvider.isArabic
              ? 'تم حفظ الذكر بنجاح'
              : 'Dhikr saved successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isLightMode = !themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;

        // Theme colors
        final greenColor = const Color(0xFF2E7D32);
        final creamColor = const Color(0xFFF5F5DC);
        final textColor = isLightMode ? greenColor : creamColor;

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            backgroundColor: Colors.transparent,
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
                      opacity: !isLightMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
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
                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.arrow_back, color: textColor),
                              ),
                              Expanded(
                                child: Text(
                                  isArabic ? 'الذكر' : 'Dhikr',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: amiriFont,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                        ),
                        // Descriptive text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            isArabic
                                ? 'اشغل قلبك بذكر الله. اختر ذكراً لتبدأ رحلتك الروحانية والسكينة.'
                                : 'Engage your heart in the remembrance of Allah. Select a Dhikr to begin your spiritual connection and peace.',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                              fontFamily: amiriFont,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Dhikr Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E8),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Arabic text
                                      Text(
                                        widget.dhikrArabic,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontFamily: 'Amiri',
                                          color: isLightMode ? const Color(0xFF1F1F1F) : const Color(0xFF392852),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 16),
                                      // Title
                                      Text(
                                        isArabic
                                            ? widget.dhikrTitleArabic
                                            : widget.dhikrTitle,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isLightMode ? const Color(0xFF1F1F1F) : const Color(0xFF392852),
                                          fontFamily: amiriFont,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      // Subtitle
                                      Text(
                                        isArabic
                                            ? widget.dhikrSubtitleArabic
                                            : widget.dhikrSubtitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isLightMode ? const Color(0xFF1F1F1F).withOpacity(0.7) : const Color(0xFF392852).withOpacity(0.7),
                                          fontFamily: amiriFont,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Counter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Minus button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFF051F20) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: _decrementCounter,
                                        icon: Icon(
                                          Icons.remove,
                                          color: isLightMode ? Colors.white : const Color(0xFF392852),
                                          size: 24,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    // Counter display
                                    Text(
                                      _currentCount.toString(),
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: isLightMode ? const Color(0xFF1F1F1F) : Colors.white,
                                        fontFamily: amiriFont,
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    // Plus button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFF051F20) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: _incrementCounter,
                                        icon: Icon(
                                          Icons.add,
                                          color: isLightMode ? Colors.white : const Color(0xFF392852),
                                          size: 24,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                // Action buttons
                                Column(
                                  children: [
                                    // Save Dhikr button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLightMode ? const Color(0xFF051F20) : Colors.white,
                        foregroundColor: isLightMode ? Colors.white : const Color(0xFF392852),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            24,
                          ),
                        ),
                      ),
                      onPressed: _saveDhikr,
                      child: Text(
                        isArabic ? 'احفظ الذكر' : 'Save Dhikr',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: amiriFont,
                        ),
                      ),
                    ),
                                    const SizedBox(height: 12),
                                    // Reset button
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: isLightMode ? const Color(0xFF051F20) : Colors.white,
                                          width: 1.5,
                                        ),
                                        foregroundColor: isLightMode ? const Color(0xFF051F20) : Colors.white,
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      onPressed: _resetCounter,
                                      child: Text(
                                        isArabic ? 'إعادة تعيين' : 'Reset',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: isLightMode ? const Color(0xFF051F20) : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
