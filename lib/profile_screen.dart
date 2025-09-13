import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'app_localizations.dart';
import 'khitma_screen.dart';
import 'bottom_nav_bar.dart';
import 'dhikr_screen.dart';
import 'services/api_client.dart';
import 'account_details_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_provider.dart';
import 'group_management_groups_screen.dart';
import 'privacy_notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Profile is selected

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Add navigation logic here
      switch (index) {
        case 0:
          // Navigate to Home screen
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
          // Already on Profile
          break;
      }
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(appLocalizations.english),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: languageProvider.currentLocale.languageCode,
                  onChanged: (value) {
                    languageProvider.setLanguage(value!);
                    themeProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  languageProvider.setLanguage('en');
                  themeProvider.setLanguage('en');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(appLocalizations.arabic),
                leading: Radio<String>(
                  value: 'ar',
                  groupValue: languageProvider.currentLocale.languageCode,
                  onChanged: (value) {
                    languageProvider.setLanguage(value!);
                    themeProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  languageProvider.setLanguage('ar');
                  themeProvider.setLanguage('ar');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context)!;

    // Show confirmation dialog (localized & themed)
    final isLightMode = !themeProvider.isDarkMode;
    // Stronger contrast and solid background for dark mode
    final bgColor = themeProvider.backgroundColor;
    final titleColor = isLightMode ? const Color(0xFF205C3B) : Colors.white;
    final textColor = isLightMode ? const Color(0xFF205C3B) : Colors.white.withOpacity(0.9);
    final borderColor = isLightMode ? const Color(0xFFE0E0E0) : Colors.white.withOpacity(0.2);
    final dialogBarrierColor = isLightMode ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.6);

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: dialogBarrierColor,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: Provider.of<LanguageProvider>(context, listen: false).textDirection,
          child: AlertDialog(
            backgroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            title: Row(
              children: [
                Icon(Icons.logout, color: titleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appLocalizations.logout,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              appLocalizations.logoutConfirmMessage,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: isLightMode ? const Color(0xFF205C3B) : themeProvider.primaryTextColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(appLocalizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFB91C1C), // red-700
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(appLocalizations.logout),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true) {
      // Perform logout
      await themeProvider.logout();

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  Future<void> _handleAccountDeletion(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final app = AppLocalizations.of(context)!;
    final isLight = !themeProvider.isDarkMode;
    final bgColor = themeProvider.backgroundColor;
    final titleColor = isLight ? const Color(0xFF205C3B) : Colors.white;
    final textColor = isLight ? const Color(0xFF205C3B) : Colors.white.withOpacity(0.9);
    final borderColor = isLight ? const Color(0xFFE0E0E0) : Colors.white.withOpacity(0.2);
    final barrier = isLight ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.6);

    final passController = TextEditingController();

    // Step 1: Ask for password
    final passOk = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: barrier,
      builder: (ctx) {
        return Directionality(
          textDirection: Provider.of<LanguageProvider>(ctx, listen: false).textDirection,
          child: AlertDialog(
            backgroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            title: Row(
              children: [
                Icon(Icons.lock_outline, color: titleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    app.enterPassword,
                    style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(app.password, style: TextStyle(color: textColor, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: isLight ? const Color(0xFF205C3B) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(app.cancel),
              ),
              TextButton(
                onPressed: () async {
                  final pass = passController.text.trim();
                  if (pass.isEmpty) {
                    Navigator.of(ctx).pop(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(app.enterPassword)),
                    );
                    return;
                  }
                  final resp = await ApiClient.instance.checkDeletePassword(password: pass);
                  if (!resp.ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp.error ?? 'Error')),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isLight ? const Color(0xFF205C3B) : Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(app.continueLabel),
              ),
            ],
          ),
        );
      },
    );

    if (passOk != true) return;

    // Step 2: Final warning
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: barrier,
      builder: (ctx) {
        return Directionality(
          textDirection: Provider.of<LanguageProvider>(ctx, listen: false).textDirection,
          child: AlertDialog(
            backgroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: titleColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    app.finalWarning,
                    style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: Text(
              app.deleteAccountExplain,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: isLight ? const Color(0xFF205C3B) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(app.cancel),
              ),
              TextButton(
                onPressed: () async {
                  final pass = passController.text.trim();
                  final resp = await ApiClient.instance.deleteAccount(password: pass);
                  if (!resp.ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp.error ?? 'Error')),
                    );
                    return;
                  }
                  await ApiClient.instance.clearToken();
                  if (!mounted) return;
                  Navigator.of(ctx).pop(true);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFB91C1C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(app.confirmDelete),
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final cardBorderColor = isLightMode
            ? const Color(0xFFB6D1C2)
            : themeProvider.borderColor;
        final dividerColor = isLightMode
            ? const Color(0xFFE6F2E8)
            : themeProvider.borderColor;
        final sectionHeaderColor = isLightMode
            ? greenColor
            : themeProvider.primaryTextColor;
        final sectionCardColor = isLightMode
            ? Colors.white
            : themeProvider.cardBackgroundColor;
        final sectionTextColor = isLightMode
            ? greenColor
            : themeProvider.primaryTextColor;
        final sectionIconColor = isLightMode
            ? greenColor
            : themeProvider.primaryTextColor;
        final logoutColor = Colors.red;
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: themeProvider.screenBackgroundColor,
                ),
                // Background SVG (subtle): 3% (dark), 12% (light). Light mode tinted to #8EB69B
                Positioned.fill(
                  child: Opacity(
                    opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                    child: SvgPicture.asset(
                      'assets/background_elements/3_background.svg',
                      fit: BoxFit.cover,
                      colorFilter: isLightMode
                          ? const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn)
                          : null,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Header with Back Button and Title
                          _HeaderWithBackButton(
                            color: sectionHeaderColor,
                            isLightMode: isLightMode,
                            greenColor: greenColor,
                            creamColor: themeProvider.cardBackgroundColor,
                          ),
                          const SizedBox(height: 10),
                          // Profile Header
                          _ProfileHeader(nameColor: sectionHeaderColor),
                          const SizedBox(height: 10),
                          // Content Sections
                          _ContentSections(
                          onLanguageTap: _showLanguageDialog,
                          onLogoutTap: _handleLogout,
                          onDeleteTap: _handleAccountDeletion,
                            sectionHeaderColor: sectionHeaderColor,
                            sectionCardColor: sectionCardColor,
                            sectionTextColor: sectionTextColor,
                            sectionIconColor: sectionIconColor,
                            cardBorderColor: cardBorderColor,
                            dividerColor: dividerColor,
                            logoutColor: logoutColor,
                            isLightMode: isLightMode,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

// Header with Back Button and Title
class _HeaderWithBackButton extends StatelessWidget {
  final Color color;
  final bool isLightMode;
  final Color greenColor;
  final Color creamColor;

  const _HeaderWithBackButton({
    required this.color,
    required this.isLightMode,
    required this.greenColor,
    required this.creamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isLightMode ? greenColor : Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            const SizedBox(width: 88),
            Text(
              AppLocalizations.of(context)!.profile,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Profile Header
class _ProfileHeader extends StatelessWidget {
  final Color nameColor;

  const _ProfileHeader({required this.nameColor});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Center(
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.borderColor,
                    width: 3,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final profile = Provider.of<ProfileProvider>(context);
                    final url = profile.avatarUrl;
                    if (url != null && url.isNotEmpty) {
                      return ClipOval(
                        child: Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.cardBackgroundColor,
                        ),
                        child: Icon(
                          Icons.person,
                          color: themeProvider.primaryTextColor,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Builder(
                builder: (context) {
                  final profile = Provider.of<ProfileProvider>(context);
                  final displayName = profile.displayName;
                  return Text(
                    (displayName.isNotEmpty) ? displayName : (languageProvider.isArabic ? '—' : '—'),
                    style: TextStyle(
                      color: nameColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Optimized Content Sections
class _ContentSections extends StatelessWidget {
  final Function(BuildContext) onLanguageTap;
  final Function(BuildContext) onLogoutTap;
  final Function(BuildContext) onDeleteTap;
  final Color sectionHeaderColor;
  final Color sectionCardColor;
  final Color sectionTextColor;
  final Color sectionIconColor;
  final Color cardBorderColor;
  final Color dividerColor;
  final Color logoutColor;
  final bool isLightMode;

  const _ContentSections({
    required this.onLanguageTap,
    required this.onLogoutTap,
    required this.onDeleteTap,
    required this.sectionHeaderColor,
    required this.sectionCardColor,
    required this.sectionTextColor,
    required this.sectionIconColor,
    required this.cardBorderColor,
    required this.dividerColor,
    required this.logoutColor,
    required this.isLightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        return Column(
          children: [
            // Account Info Section
            _SectionCard(
              title: appLocalizations.accountInfo,
              items: [
                _SectionItem(
                  icon: Icons.person,
                  title: appLocalizations.accountDetails,
                  onTap: () {
                    final profile = Provider.of<ProfileProvider>(context, listen: false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen(
                          name: profile.displayName,
                          email: profile.email,
                          avatarUrl: profile.avatarUrl,
                          joinedAt: profile.joinedAt,
                        ),
                      ),
                    );
                  },
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
                _SectionItem(
                  icon: Icons.edit,
                  title: appLocalizations.editProfile,
                  onTap: () async {
                    final profile = Provider.of<ProfileProvider>(context, listen: false);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          name: profile.username ?? profile.displayName,
                          email: profile.email,
                          avatarUrl: profile.avatarUrl,
                        ),
                      ),
                    );
                    if (result is Map) {
                      await Provider.of<ProfileProvider>(context, listen: false).refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(appLocalizations.profileUpdated)),
                      );
                    }
                  },
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 20),
            // Language & Display Section
            _SectionCard(
              title: appLocalizations.languageAndDisplay,
              items: [
                _SectionItem(
                  icon: Icons.language,
                  title: appLocalizations.chooseLanguage,
                  onTap: () => onLanguageTap(context),
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
                _SectionItem(
                  icon: Icons.dark_mode,
                  title: themeProvider.isDarkMode
                      ? appLocalizations.lightMode
                      : appLocalizations.darkMode,
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setTheme(value);
                    },
                    activeColor: themeProvider.switchActiveColor,
                    activeTrackColor: themeProvider.switchActiveTrackColor,
                    inactiveThumbColor: themeProvider.switchInactiveThumbColor,
                    inactiveTrackColor: themeProvider.switchInactiveTrackColor,
                  ),
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 20),
            // Reminder Preference Section
            _SectionCard(
              title: appLocalizations.reminderPreference,
              items: [
                _SectionItem(
                  icon: Icons.notifications,
                  title: appLocalizations.dhikrReminder,
                  onTap: () {},
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
                _SectionItem(
                  icon: Icons.settings,
                  title: appLocalizations.reminderSettings,
                  onTap: () {},
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 20),
            // Notification Settings Section
            _SectionCard(
              title: appLocalizations.notificationSettings, // Localized title
              items: [
                _SectionItem(
                  icon: Icons.notifications,
                  title: appLocalizations.notificationSettings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyNotificationsScreen(),
                      ),
                    );
                  },
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 20),
            // Group Management Section
            _SectionCard(
              title: appLocalizations.groupManagement,
              items: [
                _SectionItem(
                  icon: Icons.group,
                  title: appLocalizations.groups,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupManagementGroupsScreen(),
                      ),
                    );
                  },
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 20),
            // Account Control Section
            _SectionCard(
              title: appLocalizations.accountControl,
              items: [
                _SectionItem(
                  icon: Icons.person_remove,
                  title: appLocalizations.accountDeletionRequest,
                  onTap: () => onDeleteTap(context),
                  textColor: sectionTextColor,
                  iconColor: sectionIconColor,
                ),
                _SectionItem(
                  icon: Icons.logout,
                  title: appLocalizations.logout,
                  onTap: () => onLogoutTap(context),
                  textColor: logoutColor,
                  iconColor: logoutColor,
                ),
              ],
              headerColor: sectionHeaderColor,
              cardColor: sectionCardColor,
              borderColor: cardBorderColor,
              dividerColor: dividerColor,
            ),
          ],
        );
      },
    );
  }
}

// Optimized Section Card
class _SectionCard extends StatelessWidget {
  final String title;
  final List<_SectionItem> items;
  final Color headerColor;
  final Color cardColor;
  final Color borderColor;
  final Color dividerColor;

  const _SectionCard({
    required this.title,
    required this.items,
    required this.headerColor,
    required this.cardColor,
    required this.borderColor,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: headerColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      item,
                      if (index < items.length - 1)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1,
                          color: dividerColor,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Section Item
class _SectionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Widget? trailing;

  const _SectionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? themeProvider.primaryTextColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? themeProvider.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        );
      },
    );
  }
}
