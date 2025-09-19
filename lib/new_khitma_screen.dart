import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'wered_reading_screen.dart';
import 'services/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewKhitmaScreen extends StatefulWidget {
  const NewKhitmaScreen({super.key});

  @override
  State<NewKhitmaScreen> createState() => _NewKhitmaScreenState();
}

class _NewKhitmaScreenState extends State<NewKhitmaScreen> {
  int? selectedDays;
  bool agreedToTerms = false;
  final TextEditingController daysController = TextEditingController();
  bool isCustomInputActive = false;

  final List<Map<String, dynamic>> khitmaOptions = [
    {'days': 1, 'juzzDaily': 30},
    {'days': 2, 'juzzDaily': 15},
    {'days': 3, 'juzzDaily': 10},
    {'days': 5, 'juzzDaily': 6},
    {'days': 6, 'juzzDaily': 5},
    {'days': 10, 'juzzDaily': 3},
    {'days': 15, 'juzzDaily': 2},
    {'days': 30, 'juzzDaily': 1},
  ];

  @override
  void initState() {
    super.initState();
    _checkForActiveKhitma();
    // Listen to changes in custom input
    daysController.addListener(() {
      setState(() {
        isCustomInputActive = daysController.text.isNotEmpty;
        if (isCustomInputActive) {
          selectedDays = null; // Clear predefined selection
        }
      });
    });
  }

  /// Check if user already has an active personal khitma
  Future<void> _checkForActiveKhitma() async {
    try {
      final response = await ApiClient.instance.getActivePersonalKhitma();
      
      if (response.ok && mounted) {
        final activeKhitma = response.data['active_khitma'];
        
        if (activeKhitma != null) {
          // User has an active khitma, show dialog
          _showActiveKhitmaDialog(activeKhitma);
        }
      }
    } catch (e) {
      // Ignore errors for now, user can proceed with creating new khitma
      print('Error checking for active khitma: $e');
    }
  }

  /// Show dialog informing user about existing active khitma
  void _showActiveKhitmaDialog(Map<String, dynamic> activeKhitma) {
    if (!mounted) return;
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final String khitmaName = activeKhitma['khitma_name'] ?? 'Personal Khitma';
    final double completionPercentage = (activeKhitma['completion_percentage'] as num?)?.toDouble() ?? 0.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode
            ? const Color(0xFF2D1B69)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          languageProvider.isArabic
              ? '⚠️ ختمة جارية'
              : '⚠️ Active Khitma',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? Colors.white
                : const Color(0xFF2D1B69),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.isArabic
                  ? 'لديك ختمة نشطة بالفعل:'
                  : 'You already have an active khitma:',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    khitmaName,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : const Color(0xFF2D1B69),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider.isArabic
                        ? 'مكتمل ${completionPercentage.toStringAsFixed(1)}%'
                        : '${completionPercentage.toStringAsFixed(1)}% Complete',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              languageProvider.isArabic
                  ? 'لا يمكنك بدء ختمة جديدة حتى تكمل الختمة الحالية أو توقفها مؤقتاً.'
                  : 'You cannot start a new khitma until you complete or pause your current one.',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _continueActiveKhitma(activeKhitma);
            },
            child: Text(
              languageProvider.isArabic
                  ? 'متابعة القراءة'
                  : 'Continue Reading',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF2D5A27),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: Text(
              languageProvider.isArabic
                  ? 'العودة للرئيسية'
                  : 'Back to Home',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to continue reading the active khitma
  void _continueActiveKhitma(Map<String, dynamic> activeKhitma) {
    final int khitmaId = activeKhitma['id'] as int;
    final int currentPage = activeKhitma['current_page'] as int;
    final int totalDays = activeKhitma['total_days'] as int;
    
    // Navigate to WeredReadingScreen with current position
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WeredReadingScreen(
          selectedSurahs: ['Al-Fatihah'], // Start from beginning (will be corrected by currentPage)
          pages: '604', // Total Quran pages
          isPersonalKhitma: true, // Personal Khitma mode
          khitmaDays: totalDays, // Selected days
          personalKhitmaId: khitmaId, // Pass the khitma ID
          startFromPage: currentPage, // Continue from current page
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        MediaQuery.of(context);
        final isLightMode = !themeProvider.isDarkMode;
        final greenColor = const Color(0xFF205C3B);
        final creamColor = const Color(0xFFF7F3E8);
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  // Dark theme background with gradient and image
                  if (themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                          ),
                        ),
                        child: Opacity(
                          opacity: 0.03,
                          child: SvgPicture.asset(
                            'assets/background_elements/3_background.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  // Background image for light mode only (SVG overlay with tint)
                  if (!themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: SvgPicture.asset(
                          'assets/background_elements/3_background.svg',
                          fit: BoxFit.cover,
                          colorFilter: const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  // Main content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            // Header
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                    size: 22,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'ختمة جديدة'
                                        : 'New Khitma',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? greenColor
                                          : creamColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Info icon
                                IconButton(
                                  onPressed: () {
                                    _showKhitmaInfoDialog(context, themeProvider, languageProvider);
                                  },
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: isLightMode
                                        ? greenColor
                                        : creamColor,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Custom days input
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: daysController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: languageProvider.isArabic
                                      ? 'عدد الأيام'
                                      : 'No. of Days',
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Predefined options
                            ...khitmaOptions.map((option) {
                              final isSelected = selectedDays == option['days'];
                              final isDisabled = isCustomInputActive && !isSelected;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: isDisabled ? null : () {
                                    setState(() {
                                      selectedDays = option['days'];
                                      daysController.clear(); // Clear custom input
                                      isCustomInputActive = false;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (themeProvider.isDarkMode
                                                ? const Color(0xFF8B5CF6)
                                                : const Color(0xFF2D5A27))
                                          : (themeProvider.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFFE8F5E8)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? (themeProvider.isDarkMode
                                                  ? const Color(0xFF8B5CF6)
                                                  : const Color(0xFF2D5A27))
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          option['days'] == 1
                                              ? (languageProvider.isArabic
                                                    ? 'يوم واحد'
                                                    : '1 Day')
                                              : (languageProvider.isArabic
                                                    ? '${option['days']} أيام'
                                                    : '${option['days']} Days'),
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF2D1B69),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          languageProvider.isArabic
                                              ? '${option['juzzDaily']} جزء يومياً'
                                              : '${option['juzzDaily']} Juzz Daily',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.9)
                                                : const Color(
                                                    0xFF2D1B69,
                                                  ).withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 15),

                            // Privacy policy checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      agreedToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: themeProvider.isDarkMode
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF2D5A27),
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
                                        : 'Agree to our Privacy Policy & Terms and Conditions',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // Start Khitma button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed:
                                    agreedToTerms &&
                                        (selectedDays != null ||
                                            daysController.text.isNotEmpty)
                                        ? () async {
                                        // Get selected days - either from preset or custom input
                                        final int totalDays = selectedDays ?? 
                                            (int.tryParse(daysController.text) ?? 30);
                                        
                                        // Show loading
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              languageProvider.isArabic
                                                  ? 'جاري إنشاء الختمة...'
                                                  : 'Creating khitma...',
                                            ),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                        
                                        try {
                                          // Create personal khitma via API
                                          final response = await ApiClient.instance.createPersonalKhitma(
                                            khitmaName: languageProvider.isArabic
                                                ? 'ختمة شخصية - $totalDays يوم'
                                                : 'Personal Khitma - $totalDays days',
                                            totalDays: totalDays,
                                          );
                                          
                                          if (response.ok && mounted) {
                                            final khitmaData = response.data['khitma'] as Map<String, dynamic>;
                                            final int khitmaId = khitmaData['id'] as int;
                                            
                                            // Show success message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  languageProvider.isArabic
                                                      ? 'تم بدء الختمة بنجاح!'
                                                      : 'Personal Khitma started successfully!',
                                                ),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                            
                                            // Navigate to WeredReadingScreen in Personal Khitma mode
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => WeredReadingScreen(
                                                  selectedSurahs: ['Al-Fatihah'], // Start from beginning
                                                  pages: '604', // Total Quran pages
                                                  isPersonalKhitma: true, // Personal Khitma mode
                                                  khitmaDays: totalDays, // Selected days
                                                  personalKhitmaId: khitmaId, // Pass the created khitma ID
                                                ),
                                              ),
                                            );
                                          } else if (mounted) {
                                            // Show error message
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    response.error ?? (languageProvider.isArabic
                                                        ? 'فشل في إنشاء الختمة'
                                                        : 'Failed to create khitma'),
                                                  ),
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  languageProvider.isArabic
                                                      ? 'خطأ في الاتصال. يرجى المحاولة مرة أخرى.'
                                                      : 'Connection error. Please try again.',
                                                ),
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF2D5A27),
                                  foregroundColor: themeProvider.isDarkMode
                                      ? const Color(0xFF2D1B69)
                                      : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  disabledBackgroundColor:
                                      themeProvider.isDarkMode
                                      ? Colors.white
                                      : const Color.fromARGB(255, 16, 34, 13),
                                ),
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'بدء الختمة'
                                      : 'Start Khitma',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode
                                        ? const Color(0xFF2D1B69)
                                        : Colors.white,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  void _showKhitmaInfoDialog(BuildContext context, ThemeProvider themeProvider, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF2D1B69)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            languageProvider.isArabic
                ? 'معلومات الختمة الجديدة'
                : 'New Khitma Information',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.white
                  : const Color(0xFF2D1B69),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.isArabic
                      ? 'الختمة هي قراءة القرآن الكريم كاملاً في فترة زمنية محددة. يمكنك اختيار عدد الأيام أو إدخال رقم مخصص.'
                      : 'A Khitma is completing the entire Quran within a specific time period. You can choose from preset days or enter a custom number.',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  languageProvider.isArabic
                      ? 'الخيارات المتاحة:'
                      : 'Available Options:',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : const Color(0xFF2D1B69),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  {'days': '1', 'juzz': '30'},
                  {'days': '2', 'juzz': '15'},
                  {'days': '3', 'juzz': '10'},
                  {'days': '30', 'juzz': '1'},
                ].map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        languageProvider.isArabic
                            ? '• ${option['days']} ${option['days'] == '1' ? 'يوم' : 'أيام'}: ${option['juzz']} ${option['juzz'] == '1' ? 'جزء' : 'جزء'} يومياً'
                            : '• ${option['days']} ${option['days'] == '1' ? 'Day' : 'Days'}: ${option['juzz']} Juzz daily',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                languageProvider.isArabic ? 'حسناً' : 'OK',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF2D5A27),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    daysController.dispose();
    super.dispose();
  }
}
