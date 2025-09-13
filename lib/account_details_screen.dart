import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'theme_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String? name; // treated as username in current backend
  final String? email;
  final String? avatarUrl;
  final String? joinedAt;

  const AccountDetailsScreen({super.key, this.name, this.email, this.avatarUrl, this.joinedAt});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  String? _name;
  String? _email;
  String? _avatarUrl;
  String? _joinedAt; // ISO string

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _avatarUrl = widget.avatarUrl;
    _joinedAt = widget.joinedAt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final app = AppLocalizations.of(context)!;

    // Fallback demo data to ensure complete UI rendering if nothing is passed
    final displayName = (_name != null && _name!.trim().isNotEmpty) ? _name!.trim() : 'Ali Reahan';
    final displayEmail = (_email != null && _email!.trim().isNotEmpty) ? _email!.trim() : 'ali@example.com';
    final joinedDate = _joinedAt != null && _joinedAt!.isNotEmpty
        ? _joinedAt!.substring(0, 10)
        : '2025-01-01';

    return Scaffold(
      body: Stack(
        children: [
          // Base background: gradient in dark, solid in light
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: theme.isDarkMode
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                      )
                    : null,
                color: theme.isDarkMode ? null : theme.screenBackgroundColor,
              ),
            ),
          ),
          // Background SVG overlay
          Positioned.fill(
            child: Opacity(
              opacity: theme.isDarkMode ? 0.03 : 0.12,
              child: SvgPicture.asset(
                'assets/background_elements/3_background.svg',
                fit: BoxFit.cover,
                colorFilter: theme.isDarkMode ? null : const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn),
              ),
            ),
          ),

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
                            child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? Image.network(_avatarUrl!, width: 110, height: 110, fit: BoxFit.cover)
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
                            color: theme.isDarkMode ? Colors.white : const Color(0xFF205C3B),
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

                  const SizedBox(height: 12),

                  // Member since (joined at)
                  _InfoTile(
                    icon: Icons.event_available_outlined,
                    label: app.memberSince,
                    value: joinedDate,
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
                        color: theme.isDarkMode ? Colors.white70 : const Color(0xFF2D1B69),
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
        color: isLight ? Colors.white : theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? const Color(0xFFB6D1C2) : theme.borderColor),
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
            child: Icon(icon, color: isLight ? const Color(0xFF205C3B) : theme.primaryTextColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.isDarkMode ? Colors.white70 : const Color(0xFF2D1B69),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF2D1B69) : theme.primaryTextColor,
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
