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
import 'wered_reading_screen.dart';
import 'services/api_client.dart';

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
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            // Profile & Notification
                            const _ProfileSection(),
                            const SizedBox(height: 14),
                            // Overall Progress
                            _ProgressSection(),
                            const SizedBox(height: 14),
                            // Personal Khitma (progress + continue button)
                            _PersonalKhitmaSection(),
                            const SizedBox(height: 14),
                            // Current Streak
                            _StreakSection(),
                            const SizedBox(height: 14),
                            // Motivational Verse
                            _MotivationalVerseSection(),
                            const SizedBox(height: 20),
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

// Optimized Progress Section with Group Khitma Data
class _ProgressSection extends StatefulWidget {
  const _ProgressSection();

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  Map<String, dynamic>? groupKhitmaStats;
  bool isLoadingGroupStats = true;
  String? groupStatsError;

  @override
  void initState() {
    super.initState();
    _loadGroupKhitmaStats();
  }

  Future<void> _loadGroupKhitmaStats() async {
    try {
      final response = await ApiClient.instance.getUserGroupKhitmaStats();
      
      if (response.ok && mounted) {
        setState(() {
          groupKhitmaStats = response.data['stats'];
          isLoadingGroupStats = false;
        });
      } else {
        if (mounted) {
          setState(() {
            groupStatsError = response.error ?? 'Failed to load group stats';
            isLoadingGroupStats = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          groupStatsError = 'Network error loading group stats';
          isLoadingGroupStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, DhikrProvider>(
      builder: (context, themeProvider, dhikrProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        // Calculate group khitma progress
        double groupProgress = 0.0;
        String groupSubtitle = '0 out of 0';
        
        if (!isLoadingGroupStats && groupStatsError == null && groupKhitmaStats != null) {
          final int totalGroups = groupKhitmaStats!['total_groups'] ?? 0;
          final int completedGroups = groupKhitmaStats!['completed_groups'] ?? 0;
          final double averageProgress = (groupKhitmaStats!['average_progress'] ?? 0.0).toDouble();
          
          if (totalGroups > 0) {
            groupProgress = averageProgress / 100; // Convert percentage to decimal
            groupSubtitle = '$completedGroups out of $totalGroups';
          }
        } else if (isLoadingGroupStats) {
          groupSubtitle = 'Loading...';
        } else if (groupStatsError != null) {
          groupSubtitle = 'Error loading';
        }

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
            const SizedBox(height: 12),
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
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to group khitma screen or refresh data
                      if (groupStatsError != null) {
                        _loadGroupKhitmaStats();
                      }
                    },
                    child: _ProgressCard(
                      title: appLocalizations.khitmaGoal,
                      progress: groupProgress,
                      subtitle: groupSubtitle,
                    ),
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

// Personal Khitma Section with Real API Data
class _PersonalKhitmaSection extends StatefulWidget {
  const _PersonalKhitmaSection();

  @override
  State<_PersonalKhitmaSection> createState() => _PersonalKhitmaSectionState();
}

class _PersonalKhitmaSectionState extends State<_PersonalKhitmaSection> {
  Map<String, dynamic>? activeKhitma;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActiveKhitma();
  }

  Future<void> _loadActiveKhitma() async {
    try {
      final response = await ApiClient.instance.getActivePersonalKhitma();
      
      if (response.ok) {
        if (mounted) {
          setState(() {
            activeKhitma = response.data['active_khitma'];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = response.error;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load khitma data';
          isLoading = false;
        });
      }
    }
  }

  void _continueReading() async {
    if (activeKhitma == null) return;
    
    try {
      final int khitmaId = activeKhitma!['id'] as int;
      final int currentPage = activeKhitma!['current_page'] as int;
      final int totalDays = activeKhitma!['total_days'] as int;
      
      // Navigate to WeredReadingScreen with current position
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeredReadingScreen(
            selectedSurahs: ['Al-Fatihah'], // Start from beginning (will be corrected by currentPage)
            pages: '604', // Total Quran pages
            isPersonalKhitma: true, // Personal Khitma mode
            khitmaDays: totalDays, // Selected days
            personalKhitmaId: khitmaId, // Pass the khitma ID
            startFromPage: currentPage, // Continue from current page
          ),
        ),
      );
      
      // Refresh active khitma data when returning from reading screen
      // This ensures the progress bar and completion percentage are updated in real-time
      if (mounted) {
        await _loadActiveKhitma();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to continue reading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final String title = languageProvider.isArabic ? 'ختمتي الشخصية' : 'Personal Khitma';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: themeProvider.homeSectionTitleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: themeProvider.cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.homeBoxBorderColor,
                  width: 1,
                ),
              ),
              child: _buildKhitmaContent(themeProvider, languageProvider),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildKhitmaContent(ThemeProvider themeProvider, LanguageProvider languageProvider) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            languageProvider.isArabic ? 'خطأ في تحميل البيانات' : 'Error loading data',
            style: TextStyle(
              color: themeProvider.homeBoxTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadActiveKhitma();
            },
            child: Text(
              languageProvider.isArabic ? 'إعادة المحاولة' : 'Try Again',
            ),
          ),
        ],
      );
    }
    
    if (activeKhitma == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            languageProvider.isArabic ? 'لا توجد ختمة نشطة' : 'No active khitma',
            style: TextStyle(
              color: themeProvider.homeBoxTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            languageProvider.isArabic 
                ? 'ابدأ ختمة جديدة للمتابعة'
                : 'Start a new khitma to continue',
            style: TextStyle(
              color: themeProvider.homeBoxTextColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    // Active khitma exists - show progress and continue button
    final double completionPercentage = (activeKhitma!['completion_percentage'] as num?)?.toDouble() ?? 0.0;
    final int currentJuzz = activeKhitma!['current_juzz'] as int;
    final int currentPage = activeKhitma!['current_page'] as int;
    final String khitmaName = activeKhitma!['khitma_name'] as String;
    
    final String subtitle = languageProvider.isArabic
        ? 'الصفحة $currentPage - الجزء $currentJuzz'
        : 'Page $currentPage - Juz $currentJuzz';
    final String lastReadLabel = languageProvider.isArabic
        ? 'آخر قراءة: الصفحة $currentPage'
        : 'Last read: Page $currentPage';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Khitma name
        Text(
          khitmaName,
          style: TextStyle(
            color: themeProvider.homeBoxTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: themeProvider.homeBoxTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${completionPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: themeProvider.homeBoxTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: (completionPercentage / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: themeProvider.progressBackgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.homeProgressColor),
          ),
        ),
        const SizedBox(height: 10),
        // Last read label
        Text(
          lastReadLabel,
          style: TextStyle(
            color: themeProvider.homeBoxTextColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        // Continue button
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: _continueReading,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : const Color(0xFF2D5A27),
              foregroundColor: themeProvider.isDarkMode
                  ? Colors.white
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              languageProvider.isArabic ? 'متابعة القراءة' : 'Continue Reading',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.all(4),
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
                height: 70,
                width: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                    width: 50,
                    height: 50,
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
            const SizedBox(height: 12),
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
                    top: 6,
                    left: 6,
                    child: Image.asset(
                      'assets/background_elements/9.png',
                      width: 32,
                      height: 32,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Image.asset(
                      'assets/background_elements/8.png',
                      width: 32,
                      height: 32,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 12),
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
