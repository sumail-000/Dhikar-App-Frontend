import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dhikr_provider.dart';
import 'app_localizations.dart';
import 'khitma_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_screen.dart';
import 'notification_screen.dart';
import 'profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
  }

  
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Add navigation logic here
      switch (index) {
        case 0:
          // Already on home
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DhikrScreen()),
          );
          break;
        case 2:
          // Navigate to Khitma screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KhitmaScreen()),
          );
          break;
        case 3:
          // Navigate to Groups screen
          break;
        case 4:
          // Navigate to Profile screen
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
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: themeProvider.isDarkMode
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                      )
                    : null,
                color: themeProvider.isDarkMode
                    ? null
                    : themeProvider.screenBackgroundColor,
              ),
              child: Stack(
                children: [
                  // Background image with optimized loading (both themes)
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800, // Optimize memory usage
                        filterQuality: FilterQuality
                            .medium, // Balance quality and performance
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            // Profile & Notification
                            const _ProfileSection(),
                            const SizedBox(height: 20),
                            // Overall Progress
                            _ProgressSection(),
                            const SizedBox(height: 20),
                            // Current Streak
                            _StreakSection(),
                            const SizedBox(height: 20),
                            // Motivational Verse
                            _MotivationalVerseSection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

// Optimized Profile Section
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ProfileProvider>(
      builder: (context, themeProvider, profile, child) {
        final appLocalizations = AppLocalizations.of(context)!;
        final name = profile.displayName;
        final avatarUrl = profile.avatarUrl;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeProvider.isDarkMode
                          ? themeProvider.cardBackgroundColor
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: themeProvider.borderColor,
                        width: 2,
                      ),
                    ),
                    child: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              width: 48,
                              height: 48,
                            ),
                          )
                        : (name.isNotEmpty
                            ? Center(
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: themeProvider.primaryTextColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: themeProvider.primaryTextColor,
                                size: 24,
                              )),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  name.isNotEmpty
                      ? ((Localizations.localeOf(context).languageCode == 'ar' ? 'سلام، ' : 'Salaam, ') +
                          ((name.contains(' ')) ? name.split(' ').first : name))
                      : appLocalizations.salaamAli,
                  style: TextStyle(
                    color: themeProvider.homeUsernameColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.notifications_none,
                color: themeProvider.isDarkMode
                    ? Color(0xFFFFFFFF) // White in dark mode
                    : Color(0xFF051F20), // Dark teal in light mode
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Progress Section
class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, DhikrProvider>(
      builder: (context, themeProvider, dhikrProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.overallProgress,
              style: TextStyle(
                color: themeProvider.homeSectionTitleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProgressCard(
                    title: appLocalizations.dhikrGoal,
                    progress: dhikrProvider.dhikrProgress,
                    subtitle: dhikrProvider.hasSavedDhikr
                        ? dhikrProvider.dhikrProgressText
                        : '0 out of 0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProgressCard(
                    title: appLocalizations.khitmaGoal,
                    progress: 0.0,
                    subtitle: '0 out of 0',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Optimized Progress Card
class _ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String subtitle;

  const _ProgressCard({
    required this.title,
    required this.progress,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: themeProvider.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.homeBoxBorderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: themeProvider.homeBoxTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // const SizedBox(height: 8),
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.homeProgressColor,
                      ),
                      backgroundColor: themeProvider.progressBackgroundColor,
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        color: themeProvider.homeBoxTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(
                  color: themeProvider.homeBoxTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Optimized Streak Section
class _StreakSection extends StatelessWidget {
  const _StreakSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.currentStreak,
              style: TextStyle(
                color: themeProvider.homeSectionTitleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.homeBoxBorderColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLocalizations.yourCurrentStreak,
                            style: TextStyle(
                              color: themeProvider.homeBoxTextColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appLocalizations.days,
                            style: TextStyle(
                              color: themeProvider.homeBoxTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/background_elements/4.png',
                    width: 60,
                    height: 60,
                    cacheWidth: 120, // Optimize memory usage
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Motivational Verse Section
class _MotivationalVerseSection extends StatelessWidget {
  const _MotivationalVerseSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.motivationalVerse,
              style: TextStyle(
                color: themeProvider.homeSectionTitleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : const Color(0xFF051F20),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background images
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Image.asset(
                      'assets/background_elements/9.png',
                      width: 40,
                      height: 40,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Image.asset(
                      'assets/background_elements/8.png',
                      width: 40,
                      height: 40,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          appLocalizations.verseText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF251629)
                                : const Color(0xFF051F20),
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Decorative line with diamond
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: themeProvider.isDarkMode
                                    ? const Color(0xFF251629)
                                    : const Color(0xFF051F20),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? const Color(0xFF251629)
                                    : const Color(0xFF051F20),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: themeProvider.isDarkMode
                                    ? const Color(0xFF251629)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          appLocalizations.surahAnNahl,
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF251629)
                                : const Color(0xFF051F20),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "(16:128)",
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF251629)
                                : const Color(0xFF051F20),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
