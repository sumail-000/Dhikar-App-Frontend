import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_localizations.dart';
import 'dhikr_group_screen.dart';
import 'khitma_group_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  void _showGroupsDialog(BuildContext context, ThemeProvider themeProvider) {
    final appLocalizations = AppLocalizations.of(context)!;
    final isLightMode = !themeProvider.isDarkMode;
    const greenColor = Color(0xFF205C3B);
    const creamColor = Color(0xFFF7F3E8);
    final cardColor = isLightMode ? const Color(0xFFE6F2E8) : const Color(0xFFB9A9D0).withOpacity(0.18);
    final borderColor = isLightMode ? const Color(0xFFB6D1C2) : const Color(0xFFB9A9D0).withOpacity(0.35);
    final textColor = isLightMode ? const Color(0xFF2D1B69) : creamColor;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: Directionality.of(context),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            backgroundColor: isLightMode ? Colors.white : const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title row with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isLightMode ? greenColor.withOpacity(0.08) : creamColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.group, color: isLightMode ? greenColor : creamColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appLocalizations.groups,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20, color: textColor.withOpacity(0.8)),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Options
                    _GroupChoiceTile(
                      icon: Icons.menu_book,
                      label: appLocalizations.khitmaGroups,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const KhitmaGroupScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _GroupChoiceTile(
                      icon: Icons.favorite_outline,
                      label: appLocalizations.dhikrGroups,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DhikrGroupScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appLocalizations = AppLocalizations.of(context)!;

        return Container(
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            border: Border(
              top: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: appLocalizations.home,
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                  ),
                  _NavItem(
                    icon: Icons.favorite,
                    label: appLocalizations.dhikr,
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                  ),
                  _NavItem(
                    icon: Icons.menu_book,
                    label: appLocalizations.khitma,
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemTapped(2),
                  ),
                  _NavItem(
                    icon: Icons.group,
                    label: appLocalizations.groups,
                    isSelected: selectedIndex == 3,
                    onTap: () => _showGroupsDialog(context, themeProvider),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    label: appLocalizations.profile,
                    isSelected: selectedIndex == 4,
                    onTap: () => onItemTapped(4),
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

class _GroupChoiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _GroupChoiceTile({
    required this.icon,
    required this.label,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: textColor.withOpacity(0.8), size: 22),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final selectedColor = themeProvider.bottomNavSelectedColor;
        final unselectedColor = themeProvider.bottomNavUnselectedColor;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
