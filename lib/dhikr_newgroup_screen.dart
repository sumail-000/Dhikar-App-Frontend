import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'group_dhikr_details_screen.dart';

class DhikrNewGroupScreen extends StatefulWidget {
  const DhikrNewGroupScreen({super.key});

  @override
  State<DhikrNewGroupScreen> createState() => _DhikrNewGroupScreenState();
}

class _DhikrNewGroupScreenState extends State<DhikrNewGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String? _selectedDhikr;
  bool _isDropdownExpanded = false;
  bool _agreeToTerms = false;

  final List<Map<String, String>> _dhikrOptions = [
    {
      'title': 'Astaghfirullah',
      'titleArabic': 'أَسْتَغْفِرُ اللّٰهَ',
      'subtitle': 'I seek forgiveness from Allah.',
    },
    {
      'title': 'SubhanAllah',
      'titleArabic': 'سُبْحَانَ اللّٰهِ',
      'subtitle': 'Glory to be Allah.',
    },
    {
      'title': 'Salat on Prophet (PBUH)',
      'titleArabic': 'صَلَاةٌ عَلَى النَّبِيِّ ﷺ',
      'subtitle': 'Sending Blessings upon the Prophet ﷺ.',
    },
  ];

  @override
  void dispose() {
    _groupNameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: isLightMode
                ? Colors.white
                : themeProvider.backgroundColor,
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Stack(
              children: [
                // Background images covering entire screen
                // Background image for both themes
                Positioned.fill(
                  child: Opacity(
                    opacity: !isLightMode ? 0.5 : 1.0,
                    child: Image.asset(
                      themeProvider.backgroundImage3,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                // Color overlay for dark mode only
                if (!isLightMode)
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                // Main content with SafeArea
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // Header
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
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        isArabic
                                            ? 'مجموعة ذكر جديدة'
                                            : 'New Dhikr Group',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isLightMode
                                              ? greenColor
                                              : creamColor,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 48,
                                    ), // Balance the back button
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Group Name Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLightMode
                                          ? Colors.grey[300]!
                                          : Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _groupNameController,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic
                                          ? 'اسم المجموعة'
                                          : 'Group Name',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        fontFamily: amiriFont,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Choose Dhikr Dropdown
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownExpanded =
                                          !_isDropdownExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8E8F0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedDhikr ??
                                                (isArabic
                                                    ? 'اختر الذكر'
                                                    : 'Choose Dhikr'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _selectedDhikr != null
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                              fontFamily: amiriFont,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          _isDropdownExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dhikr Options
                                if (_isDropdownExpanded) ...[
                                  const SizedBox(height: 12),
                                  ..._dhikrOptions.map(
                                    (dhikr) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDhikr = dhikr['title'];
                                            _isDropdownExpanded = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8E8F0),
                                            borderRadius: BorderRadius.circular(
                                              12,
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
                                                      dhikr['title']!,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      dhikr['subtitle']!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                dhikr['titleArabic']!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontFamily: 'Amiri',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Add Custom Dhikr Option
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle custom dhikr addition
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8E8F0),
                                          borderRadius: BorderRadius.circular(
                                            12,
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
                                                    isArabic
                                                        ? 'إضافة ذكر مخصص'
                                                        : 'Add Custom Dhikr',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.add,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Target Field
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLightMode
                                          ? Colors.grey[300]!
                                          : Colors.grey[600]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _targetController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : creamColor,
                                      fontFamily: amiriFont,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic ? 'الهدف' : 'Target',
                                      hintStyle: TextStyle(
                                        color: isLightMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        fontFamily: amiriFont,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Privacy Policy Checkbox
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _agreeToTerms = !_agreeToTerms;
                                        });
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: _agreeToTerms
                                              ? const Color(0xFF4CAF50)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: _agreeToTerms
                                                ? const Color(0xFF4CAF50)
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: _agreeToTerms
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isArabic
                                            ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
                                            : 'Agree to our Privacy Policy & Terms and Conditions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isLightMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Create Group Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLightMode
                                          ? const Color(0xFF205C3B)
                                          : Colors.white,
                                      disabledBackgroundColor: isLightMode
                                          ? const Color(
                                              0xFF205C3B,
                                            ).withOpacity(0.6)
                                          : Colors.white,
                                      foregroundColor: isLightMode
                                          ? Colors.white
                                          : const Color(0xFF6B46C1),
                                      disabledForegroundColor: isLightMode
                                          ? Colors.white.withOpacity(0.6)
                                          : const Color(
                                              0xFF6B46C1,
                                            ).withOpacity(0.6),
                                      minimumSize: const Size.fromHeight(56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        _agreeToTerms &&
                                            _groupNameController
                                                .text
                                                .isNotEmpty &&
                                            _selectedDhikr != null &&
                                            _targetController.text.isNotEmpty
                                        ? () {
                                            // Get selected dhikr data
                                            final selectedDhikrData =
                                                _dhikrOptions.firstWhere(
                                                  (dhikr) =>
                                                      dhikr['title'] ==
                                                      _selectedDhikr,
                                                  orElse: () => {
                                                    'title': _selectedDhikr!,
                                                    'titleArabic':
                                                        _selectedDhikr!,
                                                    'subtitle': '',
                                                  },
                                                );

                                            // Navigate to group dhikr details screen
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => GroupDhikrDetailsScreen(
                                                  dhikrTitle:
                                                      selectedDhikrData['title']!,
                                                  dhikrTitleArabic:
                                                      selectedDhikrData['titleArabic'] ??
                                                      selectedDhikrData['title']!,
                                                  dhikrSubtitle:
                                                      selectedDhikrData['subtitle']!,
                                                  dhikrArabic:
                                                      selectedDhikrData['titleArabic'] ??
                                                      selectedDhikrData['title']!,
                                                  target: int.parse(
                                                    _targetController.text,
                                                  ),
                                                  currentCount:
                                                      0, // Will be fetched from server in the future
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      isArabic
                                          ? 'إنشاء مجموعة'
                                          : 'Create Group',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: amiriFont,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
