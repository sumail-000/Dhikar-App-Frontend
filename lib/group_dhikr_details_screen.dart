import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'start_dhikr_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupDhikrDetailsScreen extends StatefulWidget {
  final int? groupId; // optional for backward-compat
  final String dhikrTitle;
  final String dhikrTitleArabic;
  final String dhikrSubtitle;
  final String dhikrArabic;
  final int target;
  final int currentCount;

  const GroupDhikrDetailsScreen({
    super.key,
    this.groupId,
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
  int _target = 0;
  final TextEditingController _addRepetitionsController =
      TextEditingController();
  final TextEditingController _yourRepetitionsController =
      TextEditingController();

  Future<void> _addRepetitions() async {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;
    final text = _yourRepetitionsController.text.trim();
    final repetitions = int.tryParse(text);
    if (repetitions == null || repetitions <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'أدخل رقمًا صالحًا' : 'Enter a valid number')),
      );
      return;
    }

    if (widget.groupId != null) {
      final resp = await ApiClient.instance.saveDhikrGroupProgress(widget.groupId!, repetitions);
      if (!mounted) return;
      if (resp.ok && resp.data is Map && (resp.data['group'] is Map)) {
        final g = (resp.data['group'] as Map).cast<String, dynamic>();
        final int newCount = (g['dhikr_count'] as int?) ?? _currentCount;
        final int newTarget = (g['dhikr_target'] as int?) ?? _target;
        setState(() {
          _target = newTarget;
          _currentCount = newCount.clamp(0, _target);
        });
        _yourRepetitionsController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isArabic ? 'تمت الإضافة' : 'Repetitions added')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.error ?? (isArabic ? 'فشل الحفظ' : 'Failed to save'))),
        );
      }
    } else {
      // Fallback local update if no groupId
      setState(() {
        _currentCount = (_currentCount + repetitions).clamp(0, _target);
      });
      _yourRepetitionsController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _currentCount = widget.currentCount;
    _target = widget.target;
  }

  @override
  void dispose() {
    _addRepetitionsController.dispose();
    _yourRepetitionsController.dispose();
    super.dispose();
  }

  double get _progress => _target > 0 ? _currentCount / _target : 0.0;
  int get _progressPercentage => (_progress * 100).round();

  Future<void> _showAddRepetitionsDialog() async {
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
                onPressed: () async {
                  final repetitions = int.tryParse(
                    _addRepetitionsController.text,
                  );
                  if (repetitions != null && repetitions > 0) {
                    if (widget.groupId != null) {
                      final resp = await ApiClient.instance.saveDhikrGroupProgress(widget.groupId!, repetitions);
                      if (!mounted) return;
                      if (resp.ok && resp.data is Map && (resp.data['group'] is Map)) {
                        final g = (resp.data['group'] as Map).cast<String, dynamic>();
                        final int newCount = (g['dhikr_count'] as int?) ?? _currentCount;
                        final int newTarget = (g['dhikr_target'] as int?) ?? _target;
                        setState(() {
                          _target = newTarget;
                          _currentCount = newCount.clamp(0, _target);
                        });
                        Navigator.of(context).pop();
                        _addRepetitionsController.clear();
                      } else {
                        final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isArabic ? 'فشل الحفظ' : 'Failed to save')),
                        );
                      }
                    } else {
                      // Fallback: local-only update when groupId not provided
                      setState(() {
                        _currentCount = (_currentCount + repetitions).clamp(0, widget.target);
                      });
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _addRepetitionsController.clear();
                    }
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
        final isLightMode = !themeProvider.isDarkMode;
        final flowerAsset = isDarkMode
            ? 'assets/background_elements/purpleFlower.png'
            : 'assets/background_elements/Flower.png';
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
                  // Background SVG overlay (match Home): 3% dark, 12% light, tint in light
                  Positioned.fill(
                    child: Opacity(
                      // In light mode, optionally boost opacity for debugging visibility
                      opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        // Light mode tint for SVG background on Home screen only
                        colorFilter: themeProvider.isDarkMode
                            ? null
                            : const ColorFilter.mode(
                          Color(0xFF8EB69B),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header with back button and title
                        Padding(
                          padding: const EdgeInsets.all(12.0),
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
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  // Dhikr card
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFFDAF1DE) : const Color(0xFFF7F3E8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final s = constraints.maxWidth / 408.0; // scale similar to GroupCard
                                        final corner = 45 * s;
                                        final offset = 0 * s;
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              // Corner decorations like GroupCard
                                              Positioned(
                                                top: offset,
                                                left: offset,
                                                child: Image.asset(
                                                  flowerAsset,
                                                  width: corner,
                                                  height: corner,
                                                  fit: BoxFit.contain,
                                                  filterQuality: FilterQuality.medium,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: offset,
                                                right: offset,
                                                child: Transform.rotate(
                                                  angle: pi,
                                                  child: Image.asset(
                                                    flowerAsset,
                                                    width: corner,
                                                    height: corner,
                                                    fit: BoxFit.contain,
                                                    filterQuality: FilterQuality.medium,
                                                  ),
                                                ),
                                              ),
                                              // Centered content with inner padding like card content
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                    // Arabic text
                                                    Text(
                                                      widget.dhikrArabic,
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF2D1B69),
                                                        fontFamily: 'Amiri',
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      textDirection: TextDirection.rtl,
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // English/transliteration title
                                                    Text(
                                                      widget.dhikrTitle,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF2D1B69),
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 4),

                                                    // Subtitle if available
                                                    if (widget.dhikrSubtitle.trim().isNotEmpty)
                                                      Text(
                                                        widget.dhikrSubtitle,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF2D1B69),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Progress circle
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Background circle
                                        Container(
                                          width: 160,
                                          height: 160,
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
                                          width: 160,
                                          height: 160,
                                          child: CircularProgressIndicator(
                                            value: _progress,
                                            strokeWidth: 6,
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
                                                fontSize: 32,
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

                                  const SizedBox(height: 12),

                                  // Progress text
                                  Text(
'${_currentCount.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')} out of ${_target.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 20),

                                  // Your Repetitions text field
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
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
                                        fontSize: 14,
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
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Add Repetitions button
                                  Container(
                                    width: double.infinity,
                                    height: 44,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                      child: ElevatedButton(
                                      onPressed: _addRepetitions,
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
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        languageProvider.isArabic
                                            ? 'إضافة تكرارات'
                                            : 'Add Repetitions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                            ? const Color(0xFF392852)
                                            : const Color(0xFFFFFFFF),
                                          fontFamily: isArabic ? 'Amiri' : null,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  if (widget.groupId != null)
                                    Container(
                                      width: double.infinity,
                                      height: 44,
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => StartDhikrScreen(
                                                dhikrTitle: widget.dhikrTitle,
                                                dhikrTitleArabic: widget.dhikrTitleArabic,
                                                dhikrSubtitle: widget.dhikrSubtitle,
                                                dhikrSubtitleArabic: widget.dhikrSubtitle,
                                                dhikrArabic: widget.dhikrArabic,
                                                target: _target,
                                                isGroupMode: true,
                                                groupId: widget.groupId,
                                              ),
                                            ),
                                          );
                                          if (!mounted) return;
                                          if (res == true && widget.groupId != null) {
                                            // Refresh progress from server
                                            final pr = await ApiClient.instance.getDhikrGroupProgress(widget.groupId!);
                                            if (pr.ok && pr.data is Map && (pr.data['group'] is Map)) {
                                              final gg = (pr.data['group'] as Map).cast<String, dynamic>();
                                              final int newCount = (gg['dhikr_count'] as int?) ?? _currentCount;
                                              final int newTarget = (gg['dhikr_target'] as int?) ?? _target;
                                              setState(() {
                                                _target = newTarget;
                                                _currentCount = newCount.clamp(0, _target);
                                              });
                                            }
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: isDarkMode ? const Color(0xFFF2EDE0) : const Color(0xFF235347),
                                            width: 1.2,
                                          ),
                                          foregroundColor: isDarkMode ? const Color(0xFFF2EDE0) : const Color(0xFF235347),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: Text(
                                          isArabic ? 'ابدأ الذكر' : 'Start Dhikr',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: isArabic ? 'Amiri' : null,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 8),

                                  if (widget.groupId != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        isArabic ? 'استخدم الشاشة التالية لعد الذكر، ثم احفظ للزيادة في تقدم المجموعة' : 'Use the next screen to count dhikr, then Save to add to group progress',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode ? Colors.white70 : Colors.white.withOpacity(0.85),
                                          fontFamily: isArabic ? 'Amiri' : null,
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
