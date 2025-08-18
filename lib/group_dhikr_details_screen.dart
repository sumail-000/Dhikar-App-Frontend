import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class GroupDhikrDetailsScreen extends StatefulWidget {
  final String dhikrTitle;
  final String dhikrTitleArabic;
  final String dhikrSubtitle;
  final String dhikrArabic;
  final int target;
  final int currentCount;

  const GroupDhikrDetailsScreen({
    super.key,
    required this.dhikrTitle,
    required this.dhikrTitleArabic,
    required this.dhikrSubtitle,
    required this.dhikrArabic,
    required this.target,
    this.currentCount = 0,
  });

  @override
  State<GroupDhikrDetailsScreen> createState() =>
      _GroupDhikrDetailsScreenState();
}

class _GroupDhikrDetailsScreenState extends State<GroupDhikrDetailsScreen> {
  late int _currentCount;
  final TextEditingController _addRepetitionsController =
      TextEditingController();
  final TextEditingController _yourRepetitionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentCount = widget.currentCount;
  }

  @override
  void dispose() {
    _addRepetitionsController.dispose();
    _yourRepetitionsController.dispose();
    super.dispose();
  }

  double get _progress => _currentCount / widget.target;
  int get _progressPercentage => (_progress * 100).round();

  void _showAddRepetitionsDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          final isArabic = languageProvider.isArabic;
          final isDarkMode = themeProvider.isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color(0xFF2D1B69)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isArabic ? 'إضافة تكرارات' : 'Add Repetitions',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
                fontWeight: FontWeight.bold,
                fontFamily: isArabic ? 'Amiri' : null,
              ),
            ),
            content: TextField(
              controller: _addRepetitionsController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D1B69),
              ),
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'أدخل عدد التكرارات'
                    : 'Enter number of repetitions',
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.6)
                      : const Color(0xFF2D1B69).withOpacity(0.6),
                  fontFamily: isArabic ? 'Amiri' : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : const Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addRepetitionsController.clear();
                },
                child: Text(
                  isArabic ? 'إلغاء' : 'Cancel',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF2D1B69),
                    fontFamily: isArabic ? 'Amiri' : null,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final repetitions = int.tryParse(
                    _addRepetitionsController.text,
                  );
                  if (repetitions != null && repetitions > 0) {
                    setState(() {
                      _currentCount = (_currentCount + repetitions).clamp(
                        0,
                        widget.target,
                      );
                    });
                    Navigator.of(context).pop();
                    _addRepetitionsController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.white
                      : const Color(0xFF2E7D32),
                  foregroundColor: isDarkMode
                      ? const Color(0xFF2D1B69)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isArabic ? 'إضافة' : 'Add',
                  style: TextStyle(fontFamily: isArabic ? 'Amiri' : null),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isArabic = languageProvider.isArabic;
        final isDarkMode = themeProvider.isDarkMode;
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            backgroundColor: isDarkMode
                ? const Color(0xFF1A0F3A)
                : Colors.white,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: isDarkMode
                  ? const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                      ),
                    )
                  : null,
              child: Stack(
                children: [
                  // Background image for both themes
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  // Background pattern (only in dark mode)
                  if (isDarkMode)
                    Positioned.fill(
                      child: CustomPaint(painter: GeometricPatternPainter()),
                    ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header with back button and title
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  languageProvider.isArabic
                                      ? Icons.arrow_forward_ios
                                      : Icons.arrow_back_ios,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  languageProvider.isArabic
                                      ? 'تفاصيل ذكر المجموعة'
                                      : 'Group Dhikr Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                        ),

                        // Main content - centered
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 20.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  // Dhikr card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? const Color(0xFFF7F3E8)
                                          : const Color(0xFFE8F5E8),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF2E7D32),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Top decorative element
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome,
                                              color: Color(0xFF2E7D32),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Arabic text
                                        Text(
                                          widget.dhikrArabic,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D1B69),
                                            fontFamily: 'Amiri',
                                          ),
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                        ),
                                        const SizedBox(height: 12),

                                        // Title
                                        Text(
                                          isArabic
                                              ? widget.dhikrTitleArabic
                                              : widget.dhikrTitle,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2D1B69),
                                            fontFamily: isArabic
                                                ? 'Amiri'
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),

                                        // Subtitle
                                        Text(
                                          widget.dhikrSubtitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: const Color(
                                              0xFF2D1B69,
                                            ).withOpacity(0.7),
                                            fontFamily: isArabic
                                                ? 'Amiri'
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(height: 16),
                                        // Bottom decorative element
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome,
                                              color: Color(0xFF2E7D32),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 50),

                                  // Progress circle
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Background circle
                                        Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.white.withOpacity(
                                                      0.3,
                                                    )
                                                  : const Color(0xFFE0E0E0),
                                              width: 8,
                                            ),
                                          ),
                                        ),
                                        // Progress circle
                                        SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: CircularProgressIndicator(
                                            value: _progress,
                                            strokeWidth: 8,
                                            backgroundColor: Colors.transparent,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  isDarkMode
                                                      ? Colors.white
                                                      : const Color(0xFF2E7D32),
                                                ),
                                          ),
                                        ),
                                        // Progress text
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$_progressPercentage%',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Progress text
                                  Text(
                                    '${_currentCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} out of ${widget.target.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 50),

                                  // Your Repetitions text field
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _yourRepetitionsController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: isArabic ? 'Amiri' : null,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: languageProvider.isArabic
                                            ? 'تكراراتك'
                                            : 'Your Repetitions',
                                        labelStyle: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey[600],
                                          fontFamily: isArabic ? 'Amiri' : null,
                                        ),
                                        hintText: languageProvider.isArabic
                                            ? 'أدخل عدد تكراراتك'
                                            : 'Enter your repetitions',
                                        hintStyle: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.grey[500],
                                          fontFamily: isArabic ? 'Amiri' : null,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Add Repetitions button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _showAddRepetitionsDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? const Color(0xFFF2EDE0)
                                            : const Color(0xFF235347),
                                        foregroundColor: isDarkMode
                                            ? const Color(0xFF392852)
                                            : const Color(0xFFFFFFFF),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        languageProvider.isArabic
                                            ? 'إضافة تكرارات'
                                            : 'Add Repetitions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                            ? const Color(0xFF392852)
                                            : const Color(0xFFFFFFFF),
                                          fontFamily: isArabic ? 'Amiri' : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// Custom painter for the geometric background pattern
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double spacing = 60;
    const double hexSize = 30;

    for (double x = -hexSize; x < size.width + hexSize; x += spacing) {
      for (
        double y = -hexSize;
        y < size.height + hexSize;
        y += spacing * 0.866
      ) {
        final offsetX = (y / (spacing * 0.866)).floor() % 2 == 1
            ? spacing / 2
            : 0;
        _drawHexagon(canvas, paint, Offset(x + offsetX, y), hexSize);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
