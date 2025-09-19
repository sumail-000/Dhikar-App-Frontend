import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart';
import 'dart:math' as math;
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dhikr_provider.dart';
import 'app_localizations.dart';
import 'services/api_client.dart';
import 'khitma_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_screen.dart';
import 'notification_screen.dart';
import 'profile_provider.dart';
import 'wered_reading_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_ProgressSectionState> _progressKey =
      GlobalKey<_ProgressSectionState>();
  final GlobalKey<_PersonalKhitmaSectionState> _personalKey =
      GlobalKey<_PersonalKhitmaSectionState>();

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
                  // Background SVG with subtle opacity (3% dark, 4% light)
                  Positioned.fill(
                    child: Opacity(
                      // In light mode, optionally boost opacity for debugging visibility
                      opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        // Light mode tint for SVG background on Home screen only
                        colorFilter: themeProvider.isDarkMode
                            ? null
                            : const ColorFilter.mode(
                                Color(0xFF8EB69B),
                                BlendMode.srcIn,
                              ),
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
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _progressKey.currentState?.refresh() ??
                                Future.value(),
                            _personalKey.currentState?.refresh() ??
                                Future.value(),
                            // Optionally refresh profile in place
                            context.read<ProfileProvider?>()?.refresh() ??
                                Future.value(),
                          ]);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              // Profile & Notification
                              const _ProfileSection(),
                              const SizedBox(height: 14),
                              // Overall Progress
                              _ProgressSection(key: _progressKey),
                              const SizedBox(height: 14),
                              // Personal Khitma (progress + continue button)
                              _PersonalKhitmaSection(key: _personalKey),
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
                      ? ((Localizations.localeOf(context).languageCode == 'ar'
                      ? 'سلام، '
                      : 'Salaam, ') +
                      ((name.contains(' '))
                          ? name.split(' ').first
                          : name))
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
                    ? const Color(0xFFF2EDE0) // Replaced white with beige
                    : const Color(0xFF051F20), // Dark teal in light mode
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
  const _ProgressSection({Key? key}) : super(key: key);

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  Map<String, dynamic>? groupKhitmaStats;
  bool isLoadingGroupStats = true;
  String? groupStatsError;

  // Dhikr groups aggregate (joined groups)
  int dhikrTotalTarget = 0;
  int dhikrTotalCount = 0;
  bool isLoadingDhikr = true;
  String? dhikrError;

  @override
  void initState() {
    super.initState();
    _loadGroupKhitmaStats();
    _loadDhikrAggregate();
  }

  int _pagesInJuz(int j) {
    const Map<int, int> sizes = {
      1: 21,
      2: 20,
      3: 21,
      4: 20,
      5: 20,
      6: 20,
      7: 20,
      8: 20,
      9: 20,
      10: 20,
      11: 20,
      12: 20,
      13: 20,
      14: 20,
      15: 20,
      16: 20,
      17: 20,
      18: 20,
      19: 20,
      20: 20,
      21: 20,
      22: 20,
      23: 20,
      24: 20,
      25: 20,
      26: 20,
      27: 20,
      28: 20,
      29: 20,
      30: 22,
    };
    return sizes[j] ?? 20;
  }

  String _shortNum(int n) {
    if (n >= 1000000000)
      return '${(n / 1000000000).toStringAsFixed(n % 1000000000 == 0 ? 0 : 1)}B';
    if (n >= 1000000)
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 1000)
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return n.toString();
  }

  Future<void> _loadDhikrAggregate() async {
    setState(() {
      isLoadingDhikr = true;
      dhikrError = null;
    });
    try {
      final resp = await ApiClient.instance.getDhikrGroups();
      if (!resp.ok || resp.data is! Map) {
        setState(() {
          dhikrError = resp.error ?? 'Failed to load dhikr groups';
          isLoadingDhikr = false;
        });
        return;
      }
      final List<dynamic> list = (resp.data['groups'] as List?) ?? const [];
      int totalTarget = 0;
      int totalCount = 0;
      for (final e in list) {
        final g = (e as Map).cast<String, dynamic>();
        final int t = (g['dhikr_target'] as int?) ?? 0;
        final int c = (g['dhikr_count'] as int?) ?? 0;
        totalTarget += (t > 0 ? t : 0);
        totalCount += (c > 0 ? c : 0);
      }
      setState(() {
        dhikrTotalTarget = totalTarget;
        dhikrTotalCount = totalCount;
        isLoadingDhikr = false;
      });
    } catch (e) {
      setState(() {
        dhikrError = 'Network error loading dhikr';
        isLoadingDhikr = false;
      });
    }
  }

  Future<void> _loadGroupKhitmaStats() async {
    setState(() {
      isLoadingGroupStats = true;
      groupStatsError = null;
    });
    try {
      // 1) Fetch user's joined groups
      final resp = await ApiClient.instance.getGroups();
      if (!resp.ok || resp.data is! Map) {
        if (mounted) {
          setState(() {
            groupStatsError = resp.error ?? 'Failed to load groups';
            isLoadingGroupStats = false;
          });
        }
        return;
      }

      final myId = context.read<ProfileProvider?>()?.id;
      final List<dynamic> list = (resp.data['groups'] as List?) ?? const [];
      final groups = list
          .map((e) => (e as Map).cast<String, dynamic>())
          .where((g) => (g['type'] as String?) == 'khitma')
          .toList();

      int totalRelevantGroups = 0;
      int completedContributions = 0;

      // 2) For each khitma group, load assignments and compute my contribution status
      for (final g in groups) {
        final gidRaw = g['id'];
        final int? gid = (gidRaw is int)
            ? gidRaw
            : int.tryParse('${gidRaw ?? ''}');
        if (gid == null) continue;

        final assigns = await ApiClient.instance.khitmaAssignments(gid);
        if (!assigns.ok || assigns.data is! Map) continue;
        final List<dynamic> a =
            (assigns.data['assignments'] as List?) ?? const [];

        // Filter assignments for me
        final myAsn = a
            .where((e) {
              final m = (e as Map).cast<String, dynamic>();
              final u = (m['user'] as Map?)?.cast<String, dynamic>();
              final uid = (u != null)
                  ? ((u['id'] is int)
                        ? u['id'] as int
                        : int.tryParse('${u['id'] ?? ''}'))
                  : null;
              return myId != null && uid == myId;
            })
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();

        if (myAsn.isEmpty) {
          // No contribution assigned in this group; skip from denominator
          continue;
        }

        totalRelevantGroups++;

        // Determine if my contribution is completed in this group
        bool allDone = true;
        for (final m in myAsn) {
          final status = (m['status'] as String?) ?? '';
          final int juz = (m['juz_number'] as int);
          final int pr = (m['pages_read'] is int)
              ? (m['pages_read'] as int)
              : 0;
          final int required = _pagesInJuz(juz);
          final bool done = (status == 'completed') || (pr >= required);
          if (!done) {
            allDone = false;
            break;
          }
        }
        if (allDone) completedContributions++;
      }

      if (mounted) {
        setState(() {
          groupKhitmaStats = {
            'total_groups': totalRelevantGroups,
            'completed_groups': completedContributions,
            'average_progress': totalRelevantGroups > 0
                ? (completedContributions * 100.0 / totalRelevantGroups)
                : 0.0,
          };
          isLoadingGroupStats = false;
        });
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

  Future<void> refresh() async {
    await Future.wait([_loadGroupKhitmaStats(), _loadDhikrAggregate()]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, DhikrProvider>(
      builder: (context, themeProvider, dhikrProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;
        double groupProgress = 0.0;
        String groupSubtitle = '0 ${appLocalizations.outOfWord} 0';

        if (!isLoadingGroupStats &&
            groupStatsError == null &&
            groupKhitmaStats != null) {
          final int totalGroups = groupKhitmaStats!['total_groups'] ?? 0;
          final int completedGroups =
              groupKhitmaStats!['completed_groups'] ?? 0;
          final double averageProgress =
              (groupKhitmaStats!['average_progress'] ?? 0.0).toDouble();

          if (totalGroups > 0) {
            groupProgress =
                averageProgress / 100; // Convert percentage to decimal
            groupSubtitle =
                '$completedGroups ${appLocalizations.outOfWord} $totalGroups';
          }
        } else if (isLoadingGroupStats) {
          groupSubtitle = appLocalizations.loading;
        } else if (groupStatsError != null) {
          groupSubtitle = appLocalizations.errorLoading;
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
                  child: GestureDetector(
                    onTap: () {
                      if (dhikrError != null) {
                        _loadDhikrAggregate();
                      }
                    },
                    child: _ProgressCard(
                      title: appLocalizations.dhikrGoal,
                      progress: (dhikrTotalTarget > 0)
                          ? (dhikrTotalCount / dhikrTotalTarget).clamp(0.0, 1.0)
                          : 0.0,
                      subtitle: isLoadingDhikr
                          ? appLocalizations.loading
                          : (dhikrError != null)
                          ? appLocalizations.errorLoadingDhikr
                          : '${_shortNum(dhikrTotalCount)} ${appLocalizations.outOfWord} ${_shortNum(dhikrTotalTarget)}',
                    ),
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
  const _PersonalKhitmaSection({Key? key}) : super(key: key);

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
            selectedSurahs: ['Al-Fatihah'],
            // Start from beginning (will be corrected by currentPage)
            pages: '604',
            // Total Quran pages
            isPersonalKhitma: true,
            // Personal Khitma mode
            khitmaDays: totalDays,
            // Selected days
            personalKhitmaId: khitmaId,
            // Pass the khitma ID
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
          SnackBar(content: Text('Failed to continue reading: $e')),
        );
      }
    }
  }

  Future<void> refresh() async {
    await _loadActiveKhitma();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final app = AppLocalizations.of(context)!;
        final String title = app.personalKhitma;

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

  Widget _buildKhitmaContent(
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) {
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
            AppLocalizations.of(context)!.errorLoadingData,
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
            child: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ],
      );
    }

    if (activeKhitma == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.noActiveKhitma,
            style: TextStyle(
              color: themeProvider.homeBoxTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.startNewKhitma,
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
    final double completionPercentage =
        (activeKhitma!['completion_percentage'] as num?)?.toDouble() ?? 0.0;
    final int currentJuzz = activeKhitma!['current_juzz'] as int;
    final int currentPage = activeKhitma!['current_page'] as int;
    final String khitmaName = activeKhitma!['khitma_name'] as String;

    final app = AppLocalizations.of(context)!;
    final String subtitle =
        '${app.pageShort} $currentPage - ${app.juzShort} $currentJuzz';
    final String lastReadLabel =
        '${app.lastRead}: ${app.pageShort} $currentPage';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            valueColor: AlwaysStoppedAnimation<Color>(
              themeProvider.homeProgressColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Last read label
        Text(
          lastReadLabel,
          style: TextStyle(color: themeProvider.homeBoxTextColor, fontSize: 12),
        ),
        const SizedBox(height: 10),
        // Continue button
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: _continueReading,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode
                  ? Color(0xFFF2EDE0).withOpacity(0.15)
                  : const Color(0xFF2D5A27),
              foregroundColor: themeProvider.isDarkMode
                  ? Color(0xFFF2EDE0)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.continueReading,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                height: 78,
                width: 78,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
                  width: 1,
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
                          FutureBuilder(
                            future: ApiClient.instance.getStreak(),
                            builder: (context, snapshot) {
                              String value = '0';
                              if (snapshot.hasData && snapshot.data!.ok) {
                                final s = (snapshot.data!.data['streak'] ?? 0)
                                    .toString();
                                if (Localizations.localeOf(
                                      context,
                                    ).languageCode ==
                                    'ar') {
                                  const western = [
                                    '0',
                                    '1',
                                    '2',
                                    '3',
                                    '4',
                                    '5',
                                    '6',
                                    '7',
                                    '8',
                                    '9',
                                  ];
                                  const eastern = [
                                    '٠',
                                    '١',
                                    '٢',
                                    '٣',
                                    '٤',
                                    '٥',
                                    '٦',
                                    '٧',
                                    '٨',
                                    '٩',
                                  ];
                                  final buf = StringBuffer();
                                  for (final ch in s.split('')) {
                                    final idx = western.indexOf(ch);
                                    buf.write(idx >= 0 ? eastern[idx] : ch);
                                  }
                                  value = buf.toString();
                                } else {
                                  value = s;
                                }
                              }
                              return Text(
                                '$value ${appLocalizations.days}',
                                style: TextStyle(
                                  color: themeProvider.homeBoxTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
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
class _MotivationalVerseSection extends StatefulWidget {
  const _MotivationalVerseSection();

  @override
  State<_MotivationalVerseSection> createState() =>
      _MotivationalVerseSectionState();
}

class _MotivationalVerseSectionState extends State<_MotivationalVerseSection> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _verse;

  @override
  void initState() {
    super.initState();
    _loadMotivation();
  }

  Future<void> _loadMotivation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = ApiClient.instance.getMotivation();
      final r = await resp;
      if (!mounted) return;
      if (r.ok &&
          r.data is Map &&
          (r.data['verse'] == null || r.data['verse'] is Map)) {
        setState(() {
          _verse = r.data['verse'] as Map<String, dynamic>?;
          _loading = false;
        });
      } else {
        setState(() {
          _error = r.error ?? 'Failed to load';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Network error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;
        final isArabicLocale =
            Localizations.localeOf(context).languageCode == 'ar';
        final String verseText = (() {
          final ar = (_verse?['arabic_text'] as String?)?.trim();
          final en = (_verse?['translation'] as String?)?.trim();
          final chosen = isArabicLocale
              ? (ar != null && ar.isNotEmpty ? ar : (en ?? ''))
              : (en != null && en.isNotEmpty ? en : (ar ?? ''));
          return chosen.isNotEmpty ? chosen : appLocalizations.verseText;
        })();
        final String surahName = (() {
          final sEn = (_verse?['surah_name'] as String?)?.trim();
          final sAr = (_verse?['surah_name_ar'] as String?)?.trim();
          final s = isArabicLocale ? (sAr ?? sEn) : (sEn ?? sAr);
          return (s != null && s.isNotEmpty) ? s : appLocalizations.surahAnNahl;
        })();
        final String surahNum = (_verse?['surah_number']?.toString()) ?? '16';
        final String ayahNum = (_verse?['ayah_number']?.toString()) ?? '128';

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
                    ? Color(0xFFF2EDE0)
                    : const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Color(0xFF251629)
                      : const Color(0xFF051F20),
                  width: 1,
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
                  // Corner decorations (match group cards style)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(
                          20,
                        ), // 👈 only top-left clipped
                      ),
                      child: themeProvider.isDarkMode ?Image.asset(
                        'assets/background_elements/purpleFlower.png',
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,

                      ): Image.asset(
                        'assets/background_elements/Flower.png',
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,

                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Transform.rotate(
                      angle: math.pi,
                      // 180 degrees to mirror for bottom-right corner
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            20,
                          ), // 👈 only top-left clipped
                        ),
                        child: themeProvider.isDarkMode ?Image.asset(
                          'assets/background_elements/purpleFlower.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ): Image.asset(
                          'assets/background_elements/Flower.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(35),
                    child: _loading
                        ?  Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator( color: themeProvider.isDarkMode
        ? const Color(0xFF251629)
            : const Color(0xFF163832),),
                            ),
                          )
                        : (_error != null)
                        ? Column(
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
                              const SizedBox(height: 6),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                verseText,
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
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    width: 30,
                                    height: 30,
                                    // use SvgPicture to render the diamond svg and tint it based on theme
                                    child: SvgPicture.asset(
                                      'assets/background_elements/diamond.svg', // <- ensure this path matches your asset
                                      width: 12,
                                      height: 12,

                                      color: themeProvider.isDarkMode
                                          ? const Color(0xFF251629)
                                          : const Color(0xFF051F20),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: themeProvider.isDarkMode
                                          ? const Color(0xFF251629)
                                          : const Color(0xFF051F20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                surahName,
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
                                (() {
                                  String a = '$surahNum:$ayahNum';
                                  if (isArabicLocale) {
                                    const western = [
                                      '0',
                                      '1',
                                      '2',
                                      '3',
                                      '4',
                                      '5',
                                      '6',
                                      '7',
                                      '8',
                                      '9',
                                    ];
                                    const eastern = [
                                      '٠',
                                      '١',
                                      '٢',
                                      '٣',
                                      '٤',
                                      '٥',
                                      '٦',
                                      '٧',
                                      '٨',
                                      '٩',
                                    ];
                                    final buf = StringBuffer();
                                    for (final ch in a.split('')) {
                                      final idx = western.indexOf(ch);
                                      buf.write(idx >= 0 ? eastern[idx] : ch);
                                    }
                                    a = buf.toString();
                                  }
                                  return '($a)';
                                })(),
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
