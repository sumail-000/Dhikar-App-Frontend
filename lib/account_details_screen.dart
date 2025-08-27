import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'theme_provider.dart';

class AccountDetailsScreen extends StatelessWidget {
  final String? name; // treated as username in current backend
  final String? email;
  final String? avatarUrl;

  const AccountDetailsScreen({super.key, this.name, this.email, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final app = AppLocalizations.of(context)!;

    // Fallback demo data to ensure complete UI rendering if nothing is passed
    final displayName = (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'Ali Reahan';
    final displayEmail = (email != null && email!.trim().isNotEmpty) ? email!.trim() : 'ali@example.com';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(width: double.infinity, height: double.infinity, color: theme.screenBackgroundColor),
          Positioned.fill(
            child: Opacity(
              opacity: theme.isDarkMode ? 0.5 : 1.0,
              child: Image.asset(theme.backgroundImage3, fit: BoxFit.cover),
            ),
          ),
          if (theme.isDarkMode)
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: theme.isDarkMode ? Colors.white : const Color(0xFF205C3B)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        app.accountDetails,
                        style: TextStyle(
                          color: theme.isDarkMode ? Colors.white : const Color(0xFF205C3B),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Profile header card (Avatar + Name)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.isDarkMode ? theme.cardBackgroundColor : Colors.grey.shade100,
                            border: Border.all(color: theme.borderColor, width: 3),
                          ),
                          child: ClipOval(
                            child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                                ? Image.network(avatarUrl!, width: 110, height: 110, fit: BoxFit.cover)
                                : Center(
                                    child: Text(
                                      (displayName.isNotEmpty ? displayName[0] : '?').toUpperCase(),
                                      style: TextStyle(
                                        color: theme.primaryTextColor,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details section title
                  Text(
                    app.accountInfo,
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.white : const Color(0xFF205C3B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Username (display as-is, including underscores/digits)
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: app.username,
                    value: displayName,
                    theme: theme,
                  ),

                  const SizedBox(height: 12),

                  // Email (read-only)
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: app.email,
                    value: displayEmail,
                    theme: theme,
                  ),

                  const Spacer(),

                  // Bottom hint (read-only)
                  Center(
                    child: Text(
                      // Simple hint without new localization keys
                      'This information is read-only. Use "${app.editProfile}" to make changes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.isDarkMode ? Colors.white70 : const Color(0xFF205C3B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeProvider theme;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = !theme.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFE8F5E8) : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.borderColor),
            ),
            child: Icon(icon, color: theme.primaryTextColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.isDarkMode ? Colors.white70 : const Color(0xFF205C3B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
