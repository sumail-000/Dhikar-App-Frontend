import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'home_screen.dart' show HomeScreen;
import 'profile_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_screen.dart' show DhikrScreen;
import 'new_khitma_screen.dart';
import 'daily_wered_screen.dart';
import 'khitma_group_screen.dart';

class KhitmaScreen extends StatefulWidget {
  const KhitmaScreen({super.key});

  @override
  State<KhitmaScreen> createState() => _KhitmaScreenState();
}

class _KhitmaScreenState extends State<KhitmaScreen> {
  int _selectedIndex = 2; // Khitma is selected

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DhikrScreen()),
          );
          break;
        case 2:
          // Already on Khitma
          break;
        case 3:
          // Navigate to Groups screen
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final mediaQuery = MediaQuery.of(context);
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: themeProvider.screenBackgroundColor,
            body: Stack(
              children: [
                // Background image for both themes
                Positioned.fill(
                  child: Opacity(
                    opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                    child: Image.asset(
                      'assets/background_elements/5.png',
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                // Color overlay for dark mode only
                if (themeProvider.isDarkMode)
                  Positioned.fill(
                    child: Container(
                      color: themeProvider.backgroundImageOverlay,
                    ),
                  ),
                // Header (back button and title) over image
                Positioned(
                  top: mediaQuery.padding.top + 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          languageProvider.isArabic ? 'الختمة' : 'Khitma',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // To balance the back button
                    ],
                  ),
                ),
                // Khitma content box - now sized to content
                Positioned(
                  left: 0,
                  right: 0,
                  top: themeProvider.isDarkMode
                      ? mediaQuery.size.height * 0.40
                      : mediaQuery.size.height * 0.4,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                    decoration: BoxDecoration(
                      gradient: themeProvider.isDarkMode
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                            )
                          : null,
                      color: themeProvider.isDarkMode
                          ? null
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          themeProvider.isDarkMode ? 32 : 24,
                        ),
                        topRight: Radius.circular(
                          themeProvider.isDarkMode ? 32 : 24,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            themeProvider.isDarkMode ? 0.08 : 0.1,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          languageProvider.isArabic ? 'الختمة' : 'Khitma',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFFF2EDE0)
                                : const Color(0xFF051F20),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          languageProvider.isArabic
                              ? 'ابدأ رحلتك الروحية بسهولة — ابدأ ختمة جديدة، أكمل وردك اليومي، أو انضم إلى مجموعة لتلاوة جماعية.'
                              : 'Begin your spiritual journey with ease — start a new Khitma, complete your daily Werd, or join a group to recite together.',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : const Color(0xFF051F20),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Buttons
                        Column(
                          children: [
                            // New Khitma button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewKhitmaScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFFF2EDE0)
                                      : const Color(0xFF235347),
                                  foregroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFF392852)
                                      : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'ختمة جديدة'
                                      : 'New Khitma',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode
                                        ? const Color(0xFF392852)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Start Daily Werd button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DailyWeredScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF8EB69B),
                                  foregroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFF392852)
                                      : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'ابدأ الورد اليومي'
                                      : 'Start Daily Wered',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode
                                        ? const Color(0xFF392852)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Khitma Groups button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const KhitmaGroupScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      themeProvider.primaryTextColor,
                                  side: BorderSide(
                                    color: themeProvider.isDarkMode
                                        ? themeProvider.primaryTextColor
                                              .withOpacity(0.54)
                                        : const Color(0xFF2D5A27),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'مجموعات الختمة'
                                      : 'Khitma Groups',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode
                                        ? themeProvider.primaryTextColor
                                        : const Color(0xFF2D5A27),
                                  ),
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
            bottomNavigationBar: BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        );
      },
    );
  }
}
