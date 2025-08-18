import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class NewKhitmaScreen extends StatefulWidget {
  const NewKhitmaScreen({super.key});

  @override
  State<NewKhitmaScreen> createState() => _NewKhitmaScreenState();
}

class _NewKhitmaScreenState extends State<NewKhitmaScreen> {
  int? selectedDays;
  bool agreedToTerms = false;
  final TextEditingController daysController = TextEditingController();

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
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/background_elements/3_background.png',
                            fit: BoxFit.cover,
                            cacheWidth: 800,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  // Background image for light mode only
                  if (!themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
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
                                const SizedBox(width: 48),
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedDays = option['days'];
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
                                    ? () {
                                        // Handle start khitma
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              languageProvider.isArabic
                                                  ? 'تم بدء الختمة بنجاح'
                                                  : 'Khitma started successfully',
                                            ),
                                          ),
                                        );
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

  @override
  void dispose() {
    daysController.dispose();
    super.dispose();
  }
}
