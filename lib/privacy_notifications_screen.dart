import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'app_localizations.dart';
import 'services/notification_service.dart';
import 'services/api_client.dart';

class PrivacyNotificationsScreen extends StatefulWidget {
  const PrivacyNotificationsScreen({super.key});

  @override
  State<PrivacyNotificationsScreen> createState() => _PrivacyNotificationsScreenState();
}

class _PrivacyNotificationsScreenState extends State<PrivacyNotificationsScreen> {
  bool _loading = true;
  bool _pushEnabled = true;
  bool _showGroup = true;
  bool _showMotivational = true;
  bool _showPersonal = true;

  static const _kPushEnabledKey = 'push_notifications_enabled';
  static const _kShowGroupKey = 'show_group_notifications';
  static const _kShowMotivationalKey = 'show_motivational_notifications';
  static const _kShowPersonalKey = 'show_personal_reminders';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool(_kPushEnabledKey) ?? true;
      _showGroup = prefs.getBool(_kShowGroupKey) ?? true;
      _showMotivational = prefs.getBool(_kShowMotivationalKey) ?? true;
      _showPersonal = prefs.getBool(_kShowPersonalKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _togglePush(bool value) async {
    setState(() => _pushEnabled = value);
    await _setBool(_kPushEnabledKey, value);
    try {
      if (value) {
        // Request permission (iOS) then register
        await NotificationService().requestPermission();
        await NotificationService().registerWithBackend();
      } else {
        await NotificationService().unregisterDevice();
      }
    } catch (_) {
      // Ignore network or permission errors silently for now
    }
  }

  Widget _buildSwitch({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: themeProvider.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: themeProvider.primaryTextColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: themeProvider.switchActiveColor,
                activeTrackColor: themeProvider.switchActiveTrackColor,
                inactiveThumbColor: themeProvider.switchInactiveThumbColor,
                inactiveTrackColor: themeProvider.switchInactiveTrackColor,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isLight = !themeProvider.isDarkMode;
        final app = AppLocalizations.of(context)!;
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: themeProvider.screenBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: isLight ? const Color(0xFF205C3B) : Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                app.privacyAndNotification,
                style: TextStyle(
                  color: isLight ? const Color(0xFF205C3B) : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder(
                    future: ApiClient.instance.getUserPreferences(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasData && (snap.data as dynamic).ok) {
                        final prefs = (snap.data as dynamic).data['preferences'] as Map<String, dynamic>;
                        _showGroup = prefs['allow_group_notifications'] ?? _showGroup;
                        _showMotivational = prefs['allow_motivational_notifications'] ?? _showMotivational;
                        _showPersonal = prefs['allow_personal_reminders'] ?? _showPersonal;
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Master Push toggle
                            _buildSwitch(
                              icon: Icons.notifications_active,
                              title: app.pushNotifications,
                              value: _pushEnabled,
                              onChanged: (v) async => _togglePush(v),
                            ),
                            const SizedBox(height: 8),
                            // In-app visibility toggles (client-side filtering)
                            Text(
                              app.showInAppNotifications,
                              style: TextStyle(
                                color: isLight ? const Color(0xFF205C3B) : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildSwitch(
                              icon: Icons.group,
                              title: app.groupNotifications,
                              value: _showGroup,
                              onChanged: (v) async {
                                setState(() => _showGroup = v);
                                await _setBool(_kShowGroupKey, v);
                                try { await ApiClient.instance.updateUserPreferences(allowGroup: v); } catch (_) {}
                              },
                            ),
                            _buildSwitch(
                              icon: Icons.auto_awesome,
                              title: app.motivationalMessages,
                              value: _showMotivational,
                              onChanged: (v) async {
                                setState(() => _showMotivational = v);
                                await _setBool(_kShowMotivationalKey, v);
                                try { await ApiClient.instance.updateUserPreferences(allowMotivational: v); } catch (_) {}
                              },
                            ),
                            _buildSwitch(
                              icon: Icons.access_time,
                              title: app.personalReminders,
                              value: _showPersonal,
                              onChanged: (v) async {
                                setState(() => _showPersonal = v);
                                await _setBool(_kShowPersonalKey, v);
                                try { await ApiClient.instance.updateUserPreferences(allowPersonal: v); } catch (_) {}
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Note: These toggles hide or show items in the app’s Notifications screen. The master Push toggle controls whether your device receives any push notifications.',
                              style: TextStyle(
                                color: themeProvider.primaryTextColor.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

