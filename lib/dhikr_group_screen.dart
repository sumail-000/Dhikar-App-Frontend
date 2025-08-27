import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'khitma_screen.dart';
import 'dhikr_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_newgroup_screen.dart';

class DhikrGroupScreen extends StatefulWidget {
  const DhikrGroupScreen({super.key});

  @override
  State<DhikrGroupScreen> createState() => _DhikrGroupScreenState();
}

class _DhikrGroupScreenState extends State<DhikrGroupScreen> {
  int _selectedIndex = 1;
  int _selectedTab = 0; // 0 for Joined, 1 for Explore

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KhitmaScreen()),
          );
          break;
        case 3:
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: isLightMode ? greenColor : creamColor,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Text(
                                isArabic ? 'مجموعات الذكر' : 'Dhikr Groups',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DhikrNewGroupScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? 'إضافة جديد' : 'Add New',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isLightMode
                                          ? greenColor
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tab buttons
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isLightMode
                                ? const Color(
                                    0xFFDAF1DE,
                                  ) // Light mode outer container color
                                : const Color(
                                    0xFFE3D9F6,
                                  ), // Dark mode outer container color
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0
                                          ? (isLightMode
                                                ? const Color(
                                                    0xFF235347,
                                                  ) // Light mode selected tab
                                                : const Color(
                                                    0xFFF2EDE0,
                                                  )) // Dark mode selected tab
                                          : (isLightMode
                                                ? const Color(
                                                    0xFFCCCCCC,
                                                  ) // Light mode selected tab
                                                : const Color(0xFFFFFFFF)),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        bottomLeft: const Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'منضم' : 'Joined',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 0
                                              ? (isLightMode
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color.fromARGB(
                                                        255,
                                                        57,
                                                        40,
                                                        82,
                                                      ))
                                              : (isLightMode
                                                    ? const Color.fromARGB(
                                                        255,
                                                        5,
                                                        31,
                                                        32,
                                                      )
                                                    : const Color.fromARGB(
                                                        255,
                                                        204,
                                                        204,
                                                        204,
                                                      )),
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1
                                          ? (isLightMode
                                                ? const Color(
                                                    0xFF235347,
                                                  ) // Light mode selected
                                                : const Color(
                                                    0xFFF2EDE0,
                                                  )) // Dark mode selected
                                          : (isLightMode
                                                ? const Color(
                                                    0xFFCCCCCC,
                                                  ) // Light mode selected
                                                : const Color(0xFFFFFFFF)),
                                      borderRadius: BorderRadius.only(
                                        topRight: const Radius.circular(18),
                                        bottomRight: const Radius.circular(18),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isArabic ? 'استكشاف' : 'Explore',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedTab == 1
                                              ? (isLightMode
                                                    ? const Color(0xFFFFFFFF)
                                                    : const Color.fromARGB(
                                                        255,
                                                        57,
                                                        40,
                                                        82,
                                                      ))
                                              : (isLightMode
                                                    ? const Color.fromARGB(
                                                        255,
                                                        5,
                                                        31,
                                                        32,
                                                      )
                                                    : const Color.fromARGB(
                                                        255,
                                                        204,
                                                        204,
                                                        204,
                                                      )),
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Empty space for future content
                        Expanded(
                          child: Container(
                            // Empty container for future content
                          ),
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
