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
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode 
              ? const Color(0xFF4A148C) // Deep purple for dark mode
              : Colors.white, // White for light mode
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            appLocalizations.groups,
            style: TextStyle(
              color: themeProvider.isDarkMode 
                  ? Colors.white // White text in dark mode
                  : const Color(0xFF2D5A27), // Dark green text in light mode
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dhikr Groups option
              ListTile(
                title: Text(
                  'Dhikr Groups',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? Colors.white // White text in dark mode
                        : const Color(0xFF2D5A27), // Dark green text in light mode
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DhikrGroupScreen(),
                    ),
                  );
                },
              ),
              // Khitma Groups option
              ListTile(
                title: Text(
                  'Khitma Groups',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? Colors.white // White text in dark mode
                        : const Color(0xFF2D5A27), // Dark green text in light mode
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KhitmaGroupScreen(),
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
