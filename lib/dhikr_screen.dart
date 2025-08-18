import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'khitma_screen.dart';
import 'bottom_nav_bar.dart';
import 'app_localizations.dart';
import 'start_dhikr_screen.dart';
import 'dhikr_group_screen.dart';

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

  final List<Map<String, String>> _dhikrList = [
    {
      'title': 'Astaghfirullah',
      'titleArabic': 'أستغفر الله',
      'subtitle': 'I seek forgiveness from Allah.',
      'subtitleArabic': 'أطلب المغفرة من الله',
      'arabic': 'أَسْتَغْفِرُ اللّٰه',
    },
    {
      'title': 'SubhanAllah',
      'titleArabic': 'سبحان الله',
      'subtitle': 'Glory to be Allah.',
      'subtitleArabic': 'تنزيه الله عن كل نقص',
      'arabic': 'سُبْحَانَ اللّٰه',
    },
    {
      'title': 'Salat on Prophet (PBUH)',
      'titleArabic': 'الصلاة على النبي ﷺ',
      'subtitle': 'Sending Blessings upon the Prophet ﷺ.',
      'subtitleArabic': 'إرسال البركات على النبي ﷺ',
      'arabic': 'صَلَاةٌ عَلَى النَّبِيِّ ﷺ',
    },
  ];

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
            backgroundColor: themeProvider.screenBackgroundColor,
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Stack(
              children: [
                // Background images for both themes
                // Background image
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: isLightMode ? greenColor : creamColor,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 88),
                              Text(
                                appLocalizations.dhikr,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode ? greenColor : creamColor,
                                  fontFamily: amiriFont,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isArabic ? 'نوع الذكر' : 'Dhikr Type',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isLightMode ? greenColor : creamColor,
                              fontFamily: amiriFont,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? 'اشغل قلبك بذكر الله. اختر ذكرًا لبدء اتصالك الروحي وسلامك.'
                                : 'Engage your heart in the remembrance of Allah. Select a Dhikr to begin your spiritual connection and peace.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isLightMode
                                  ? fadedTextColor
                                  : creamColor.withOpacity(0.7),
                              fontFamily: amiriFont,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor, width: 1.2),
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
                                          _selectedDhikr != null
                                              ? (isArabic
                                                    ? (_dhikrList.firstWhere(
                                                            (dhikr) =>
                                                                dhikr['title'] ==
                                                                _selectedDhikr,
                                                            orElse: () => {
                                                              'titleArabic': '',
                                                            },
                                                          )['titleArabic'] ??
                                                          '')
                                                    : _selectedDhikr!)
                                              : (isArabic
                                                    ? 'اختر الذكر'
                                                    : 'Choose Dhikr'),
                                          style: TextStyle(
                                            color: dhikrCardTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily:
                                                isArabic &&
                                                    _selectedDhikr != null
                                                ? 'Amiri'
                                                : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textDirection:
                                              isArabic && _selectedDhikr != null
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                        ),
                                        Text(
                                          _selectedDhikr != null
                                              ? (isArabic
                                                    ? (_dhikrList.firstWhere(
                                                            (dhikr) =>
                                                                dhikr['title'] ==
                                                                _selectedDhikr,
                                                            orElse: () => {
                                                              'subtitleArabic':
                                                                  '',
                                                            },
                                                          )['subtitleArabic'] ??
                                                          '')
                                                    : (_dhikrList.firstWhere(
                                                            (dhikr) =>
                                                                dhikr['title'] ==
                                                                _selectedDhikr,
                                                            orElse: () => {
                                                              'subtitle': '',
                                                            },
                                                          )['subtitle'] ??
                                                          ''))
                                              : (isArabic
                                                    ? 'انقر لاختيار الذكر'
                                                    : 'Tap to select dhikr'),
                                          style: TextStyle(
                                            color: dhikrCardTextColor
                                                .withOpacity(0.7),
                                            fontSize: 12,
                                            fontFamily:
                                                isArabic &&
                                                    _selectedDhikr != null
                                                ? 'Amiri'
                                                : null,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textDirection:
                                              isArabic && _selectedDhikr != null
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      _showDhikrCards
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: dhikrCardTextColor,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _showDhikrCards = !_showDhikrCards;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_showDhikrCards)
                            ..._dhikrList.map(
                              (dhikr) => Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: borderColor,
                                    width: 1.2,
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
                                              isArabic
                                                  ? (dhikr['titleArabic'] ??
                                                        dhikr['title']!)
                                                  : dhikr['title']!,
                                              style: TextStyle(
                                                color: dhikrCardTextColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontFamily: isArabic
                                                    ? 'Amiri'
                                                    : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: isArabic
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                            ),
                                            Text(
                                              isArabic
                                                  ? (dhikr['subtitleArabic'] ??
                                                        dhikr['subtitle']!)
                                                  : dhikr['subtitle']!,
                                              style: TextStyle(
                                                color: dhikrCardTextColor
                                                    .withOpacity(0.7),
                                                fontSize: 12,
                                                fontFamily: isArabic
                                                    ? 'Amiri'
                                                    : null,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: isArabic
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          dhikr['arabic']!,
                                          style: TextStyle(
                                            color: dhikrCardTextColor,
                                            fontSize: 22,
                                            fontFamily: 'Amiri',
                                          ),
                                          textDirection: TextDirection.rtl,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedDhikr = dhikr['title'];
                                      _showDhikrCards = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor, width: 1.2),
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
                                          isArabic
                                              ? 'أضف ذكر مخصص'
                                              : 'Add Custom Dhikr',
                                          style: TextStyle(
                                            color: dhikrCardTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          locale: const Locale('en'),
                                        ),
                                        Text(
                                          isArabic
                                              ? 'انقر لإضافة ذكر جديد'
                                              : 'Tap to add new dhikr',
                                          style: TextStyle(
                                            color: dhikrCardTextColor
                                                .withOpacity(0.7),
                                            fontSize: 12,
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
                                      color: dhikrCardTextColor,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) => Theme(
                                    data: Theme.of(context).copyWith(
                                      dialogBackgroundColor: isLightMode 
                                          ? Colors.white 
                                          : const Color(0xFF2A2A2A),
                                    ),
                                    child: AlertDialog(
                                      backgroundColor: isLightMode 
                                          ? Colors.white 
                                          : const Color(0xFF2A2A2A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isLightMode 
                                              ? borderColor 
                                              : darkBorderColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      elevation: isLightMode ? 8 : 12,
                                      shadowColor: isLightMode 
                                          ? Colors.black26 
                                          : Colors.black54,
                                      title: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isLightMode 
                                                  ? greenColor.withOpacity(0.1) 
                                                  : creamColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.add_circle_outline,
                                              color: isLightMode ? greenColor : creamColor,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              isArabic
                                                  ? 'أضف ذكر مخصص'
                                                  : 'Add Custom Dhikr',
                                              style: TextStyle(
                                                color: isLightMode 
                                                    ? dhikrCardTextColor 
                                                    : creamColor,
                                                fontFamily: amiriFont,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isArabic
                                                ? 'أدخل النص المخصص للذكر الذي تريد إضافته'
                                                : 'Enter the custom text for the dhikr you want to add',
                                            style: TextStyle(
                                              color: isLightMode 
                                                  ? dhikrCardTextColor.withOpacity(0.7) 
                                                  : creamColor.withOpacity(0.8),
                                              fontFamily: amiriFont,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isLightMode 
                                                  ? cardColor 
                                                  : darkCardColor,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isLightMode 
                                                    ? borderColor 
                                                    : darkBorderColor,
                                                width: 1.2,
                                              ),
                                            ),
                                            child: TextField(
                                              controller: _customDhikrController,
                                              maxLines: 3,
                                              minLines: 1,
                                              textDirection: isArabic 
                                                  ? TextDirection.rtl 
                                                  : TextDirection.ltr,
                                              decoration: InputDecoration(
                                                hintText: isArabic
                                                    ? 'مثال: لا إله إلا الله'
                                                    : 'Example: La ilaha illa Allah',
                                                hintStyle: TextStyle(
                                                  color: isLightMode 
                                                      ? dhikrCardTextColor.withOpacity(0.5) 
                                                      : creamColor.withOpacity(0.5),
                                                  fontFamily: amiriFont,
                                                  fontSize: 14,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.all(16),
                                              ),
                                              style: TextStyle(
                                                color: isLightMode 
                                                    ? dhikrCardTextColor 
                                                    : creamColor,
                                                fontFamily: amiriFont,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                                      actions: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: isLightMode 
                                                        ? dhikrCardTextColor.withOpacity(0.3) 
                                                        : creamColor.withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                  foregroundColor: isLightMode 
                                                      ? dhikrCardTextColor 
                                                      : creamColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                onPressed: () {
                                                  _customDhikrController.clear();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  isArabic ? 'إلغاء' : 'Cancel',
                                                  style: TextStyle(
                                                    fontFamily: amiriFont,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isLightMode 
                                                      ? greenColor 
                                                      : creamColor,
                                                  foregroundColor: isLightMode 
                                                      ? Colors.white 
                                                      : dhikrCardTextColor,
                                                  elevation: isLightMode ? 2 : 4,
                                                  shadowColor: isLightMode 
                                                      ? Colors.black26 
                                                      : Colors.black45,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                onPressed: () {
                                                  if (_customDhikrController.text.trim().isNotEmpty) {
                                                    setState(() {
                                                      _dhikrList.add({
                                                        'title': _customDhikrController.text.trim(),
                                                        'titleArabic': _customDhikrController.text.trim(),
                                                        'subtitle': isArabic ? 'ذكر مخصص' : 'Custom Dhikr',
                                                        'subtitleArabic': 'ذكر مخصص',
                                                        'arabic': _customDhikrController.text.trim(),
                                                      });
                                                      _customDhikrController.clear();
                                                    });
                                                    Navigator.of(context).pop();
                                                    // Show success feedback
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          isArabic 
                                                              ? 'تم إضافة الذكر المخصص بنجاح' 
                                                              : 'Custom dhikr added successfully',
                                                          style: TextStyle(fontFamily: amiriFont),
                                                        ),
                                                        backgroundColor: isLightMode 
                                                            ? greenColor 
                                                            : creamColor,
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        margin: const EdgeInsets.all(16),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 18,
                                                      color: isLightMode 
                                                          ? Colors.white 
                                                          : dhikrCardTextColor,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      isArabic ? 'إضافة' : 'Add',
                                                      style: TextStyle(
                                                        fontFamily: amiriFont,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isArabic ? 'الهدف' : 'Target',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLightMode ? greenColor : creamColor,
                              fontFamily: amiriFont,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: isLightMode ? greenColor : creamColor,
                              fontFamily: amiriFont,
                            ),
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'أدخل هدفك'
                                  : 'Enter your target',
                              hintStyle: TextStyle(
                                color: isLightMode
                                    ? fadedTextColor
                                    : creamColor,
                                fontFamily: amiriFont,
                              ),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLightMode
                                  ? greenColor
                                  : creamColor,
                              foregroundColor: isLightMode
                                  ? Colors.white
                                  : themeProvider.primaryColor,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              if (_selectedDhikr != null &&
                                  _targetController.text.isNotEmpty) {
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartDhikrScreen(
                                      dhikrTitle: selectedDhikrData['title']!,
                                      dhikrTitleArabic:
                                          selectedDhikrData['titleArabic'] ??
                                          selectedDhikrData['title']!,
                                      dhikrSubtitle:
                                          selectedDhikrData['subtitle']!,
                                      dhikrSubtitleArabic:
                                          selectedDhikrData['subtitleArabic'] ??
                                          selectedDhikrData['subtitle']!,
                                      dhikrArabic: selectedDhikrData['arabic']!,
                                      target: int.parse(_targetController.text),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              isArabic ? 'ابدأ الذكر' : 'Start Dhikr',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLightMode
                                    ? Colors.white
                                    : themeProvider.primaryColor,
                                fontFamily: amiriFont,
                              ),
                            ),
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
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLightMode ? greenColor : creamColor,
                                fontFamily: amiriFont,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
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
