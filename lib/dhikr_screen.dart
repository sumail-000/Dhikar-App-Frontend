import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'khitma_screen.dart';
import 'bottom_nav_bar.dart';
import 'app_localizations.dart';
import 'start_dhikr_screen.dart';
import 'dhikr_group_screen.dart';
import 'dhikr_presets.dart';
import 'services/api_client.dart';
import 'widgets/add_custom_dhikr_dialog.dart';
import 'dhikr_provider.dart';
import 'app_localizations.dart';
import 'personal_dhikr_history_screen.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  int _selectedIndex = 1;
  String? _selectedDhikr;
  bool _showDhikrCards = false;
  final TextEditingController _customDhikrController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  // Use shared presets for dhikr list
  final List<Map<String, String>> _dhikrList = List<Map<String, String>>.from(
    DhikrPresets.presets,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomDhikr();
    // Ensure any saved personal Dhikr session is restored on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<DhikrProvider>(context, listen: false);
      p.loadFromStorage();
    });
  }

  Future<void> _loadCustomDhikr() async {
    final resp = await ApiClient.instance.getCustomDhikr();
    if (!mounted) return;
    if (resp.ok && resp.data is Map && resp.data['custom_dhikr'] is List) {
      final List list = resp.data['custom_dhikr'] as List;
      final mapped = list
          .map<Map<String, String>>((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return {
              'title': (m['title'] ?? '').toString(),
              'titleArabic': (m['title_arabic'] ?? m['title'] ?? '').toString(),
              'subtitle': (m['subtitle'] ?? '').toString(),
              'subtitleArabic': (m['subtitle_arabic'] ?? m['subtitle'] ?? '')
                  .toString(),
              'arabic': (m['arabic_text'] ?? '').toString(),
            };
          })
          .where((m) => m['title']!.isNotEmpty && m['arabic']!.isNotEmpty)
          .toList();
      setState(() {
        _dhikrList.addAll(mapped);
      });
    }
  }

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
          // Already on Dhikr
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
        final appLocalizations = AppLocalizations.of(context)!;
        final fadedTextColor = themeProvider.primaryTextColor.withOpacity(0.7);
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final darkCardColor = const Color(0xFFB9A9D0).withOpacity(0.18);
        final darkBorderColor = const Color(0xFFB9A9D0).withOpacity(0.35);
        final creamColor = const Color(0xFFF7F3E8);
        final cardColor = isLightMode ? const Color(0xFFE6F2E8) : darkCardColor;
        final borderColor = isLightMode
            ? const Color(0xFFB6D1C2)
            : darkBorderColor;
        final dhikrCardTextColor = const Color(0xFF2D1B69);
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
                  // Background SVG (subtle): 3% (dark), 4% (light). Light mode tinted to #8EB69B
                  Positioned.fill(
                    child: Opacity(
                      // In light mode, optionally boost opacity for debugging visibility (same as Home)
                      opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        colorFilter: isLightMode
                            ? const ColorFilter.mode(
                                Color(0xFF8EB69B),
                                BlendMode.srcIn,
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Color overlay for dark mode only
                  if (themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  // Main content with SafeArea
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 88),
                                Text(
                                  appLocalizations.dhikr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                    fontFamily: amiriFont,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appLocalizations.dhikrType,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLightMode ? greenColor : creamColor,
                                fontFamily: amiriFont,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appLocalizations.dhikrIntro,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLightMode
                                    ? const Color(0xFF235347).withOpacity(0.8)
                                    : creamColor.withOpacity(0.7),
                                fontFamily: amiriFont,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDhikrCards = !_showDhikrCards;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isLightMode
                                      ? Color(0xFFDAF1DE)
                                      : const Color(0xFFE3D9F6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isLightMode
                                        ? const Color(0xFFB6D1C2)
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDhikr ?? appLocalizations.chooseDhikr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedDhikr != null
                                              ? (isLightMode
                                              ? const Color(
                                            0xFF235347,
                                          )
                                              : Color(0xFF392852))
                                              : (isLightMode
                                                    ? const Color(
                                                        0xFF235347,
                                                      ).withOpacity(0.6)
                                                    : Color(0xFF392852)),
                                          fontFamily: amiriFont,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      _showDhikrCards
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: isLightMode
                                          ? const Color(
                                        0xFF235347,
                                      ).withOpacity(0.6)
                                          : Color(0xFF392852),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_showDhikrCards) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 240,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _dhikrList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final dhikr = _dhikrList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDhikr = dhikr['title'];
                                          _showDhikrCards = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isLightMode
                                              ? Color(0xFFDAF1DE)
                                              : const Color(0xFFE3D9F6),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isLightMode
                                                ? const Color(0xFFB6D1C2)
                                                : Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    dhikr['title'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isLightMode
                                                          ? const Color(
                                                        0xFF235347,
                                                      )
                                                          : Color(0xFF392852),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    dhikr['subtitle'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isLightMode
                                                          ? const Color(
                                                        0xFF235347,
                                                      ).withOpacity(0.6)
                                                          : Color(0xFF392852),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              dhikr['titleArabic'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isLightMode
                                                    ? const Color(
                                                  0xFF235347,
                                                )
                                                    : Color(0xFF392852),
                                                fontFamily: 'Amiri',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            Card(

                              color: isLightMode
                                  ? Color(0xFFDAF1DE)
                                  : const Color(0xFFE3D9F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            appLocalizations.addCustomDhikr,
                                            style: TextStyle(
                                              color: isLightMode
                                                  ? const Color(
                                                      0xFF235347,
                                                    ).withOpacity(0.6)
                                                  : Color(0xFF392852),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            locale: const Locale('en'),
                                          ),
                                          Text(
                                            appLocalizations.tapToAddDhikr,
                                            style: TextStyle(
                                              color: isLightMode
                                                  ? const Color(
                                                      0xFF235347,
                                                    ).withOpacity(0.6)
                                                  : Color(0xFF392852),

                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            locale: const Locale('en'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.add,
                                        color: isLightMode
                                            ? const Color(
                                          0xFF235347,
                                        ).withOpacity(0.6)
                                            : Color(0xFF392852),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  final result = await showAddCustomDhikrDialog(
                                    context,
                                    isArabic: isArabic,
                                  );
                                  if (result != null) {
                                    final resp = await ApiClient.instance
                                        .createCustomDhikr(
                                          title: result['title']!,
                                          titleArabic: result['titleArabic']!,
                                          subtitle: result['subtitle'],
                                          subtitleArabic:
                                              result['subtitleArabic'],
                                          arabic: result['arabic']!,
                                        );
                                    if (!mounted) return;
                                    if (resp.ok) {
                                      setState(() {
                                        _dhikrList.add({
                                          'title': result['title']!,
                                          'titleArabic': result['titleArabic']!,
                                          'subtitle': result['subtitle'] ?? '',
                                          'subtitleArabic':
                                              result['subtitleArabic'] ??
                                              (result['subtitle'] ?? ''),
                                          'arabic': result['arabic']!,
                                        });
                                        _selectedDhikr = result['title'];
                                        _showDhikrCards = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            appLocalizations.dhikrAdded,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            resp.error ?? appLocalizations.addFailed,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appLocalizations.target,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isLightMode ? greenColor : creamColor,
                                fontFamily: amiriFont,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _targetController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: isLightMode
                                    ? const Color(0xFF235347).withOpacity(0.6)
                                    : Color(0xFF392852),
                                fontFamily: amiriFont,
                              ),
                              decoration: InputDecoration(
                                hintText: appLocalizations.enterTarget,
                                hintStyle: TextStyle(
                                  color: isLightMode
                                      ? const Color(0xFF235347).withOpacity(0.6)
                                      : Color(0xFF392852).withOpacity(0.6),
                                  fontFamily: amiriFont,
                                ),
                                filled: true,
                                fillColor: isLightMode
                                    ? Color(0xFFDAF1DE)               // light mode background
                                    : const Color(0xFFE3D9F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isLightMode ? const Color(0xFF8EB69B) : creamColor,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isLightMode ? const Color(0xFF8EB69B) : creamColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(   // 👈 Add this
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: isLightMode ? greenColor : creamColor, // your custom color
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),

                            ),
                            const SizedBox(height: 16),
                            Consumer<DhikrProvider>(
                              builder: (context, dhikrProvider, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Start always starts a new session
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isLightMode ? greenColor : creamColor,
                                        foregroundColor: isLightMode ? Colors.white : themeProvider.primaryColor,
                                        minimumSize: const Size.fromHeight(44),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      onPressed: () async {
                                        if (_selectedDhikr == null || _targetController.text.trim().isEmpty) return;
                                        final selectedDhikrData = _dhikrList.firstWhere(
                                          (dhikr) => dhikr['title'] == _selectedDhikr,
                                          orElse: () => {
                                            'title': _selectedDhikr!,
                                            'titleArabic': _selectedDhikr!,
                                            'subtitle': '',
                                            'subtitleArabic': '',
                                            'arabic': _selectedDhikr!,
                                          },
                                        );
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => StartDhikrScreen(
                                              dhikrTitle: selectedDhikrData['title']!,
                                              dhikrTitleArabic: selectedDhikrData['titleArabic'] ?? selectedDhikrData['title']!,
                                              dhikrSubtitle: selectedDhikrData['subtitle']!,
                                              dhikrSubtitleArabic: selectedDhikrData['subtitleArabic'] ?? selectedDhikrData['subtitle']!,
                                              dhikrArabic: selectedDhikrData['arabic']!,
                                              target: int.tryParse(_targetController.text.trim()) ?? 0,
                                              initialCount: 0,
                                            ),
                                          ),
                                        );
                                        if (mounted) setState(() {});
                                      },
                                      child: Text(
AppLocalizations.of(context)!.startDhikr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isLightMode ? Colors.white : themeProvider.primaryColor,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // View history navigates to history screen to continue any dhikr
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: isLightMode ? greenColor : creamColor, width: 1.5),
                                        foregroundColor: isLightMode ? greenColor : creamColor,
                                        minimumSize: const Size.fromHeight(44),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const PersonalDhikrHistoryScreen()),
                                        );
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.viewHistory,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isLightMode ? greenColor : creamColor,
                                  width: 1.5,
                                ),
                                foregroundColor: isLightMode
                                    ? greenColor
                                    : creamColor,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DhikrGroupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                isArabic ? 'مجموعات الذكر' : 'Dhikr Groups',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
