import 'package:flutter/material.dart';
import 'dart:math' as math;

class MemberAvatar {
  final String? imageUrl;
  final String? initials;
  const MemberAvatar({this.imageUrl, this.initials});
}

class GroupCard extends StatelessWidget {
  final String englishName;
  final String arabicName;
  final int completed;
  final int total;
  final List<MemberAvatar> memberAvatars;
  final int plusCount;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.englishName,
    required this.arabicName,
    required this.completed,
    required this.total,
    required this.memberAvatars,
    this.plusCount = 0,
    this.onTap,
  });

  double get _percent => total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

  String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    // Fixed palette and geometry per provided pixel spec
    const cardBg = Color(0xFFF2EDE0);
    const cardBorder = Color(0xFF251629);
    const titleColor = Color(0xFF051F20);
    const chipBg = Color(0xFF392852);
    const percentTextColor = Color(0xFF392852);
    const progressTrack = Color(0xFFC2AEEA);
    const progressFill = Color(0xFF392852);

    return AspectRatio(
      aspectRatio: 408 / 213, // keep card proportions consistent across widths
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / 408.0; // scale from Figma px to device px

          return Container(
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12 * s),
              border: Border.all(color: cardBorder, width: 1 * s),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12 * s),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                // Corner decorations - edge-aligned positioning (top-left and bottom-right only)
                Positioned(
                  top: -8 * s,
                  left: -8 * s,
                  child: _CornerDecoration(
                    angleDeg: 0,
                    assetPath: 'assets/background_elements/9.png',
                    size: 45 * s,
                  ),
                ),
                Positioned(
                  bottom: -8 * s,
                  right: -8 * s,
                  child: _CornerDecoration(
                    angleDeg: 180,
                    assetPath: 'assets/background_elements/9.png',
                    size: 45 * s,
                  ),
                ),

                // Helpers for localization and script detection
                ...(() {
                  final locale = Localizations.localeOf(context);
                  final isArabicLocale = locale.languageCode == 'ar';
                  bool containsArabic(String t) => RegExp(r'[\u0600-\u06FF]').hasMatch(t);
                  String toArabicDigits(String t) {
                    if (!isArabicLocale) return t;
                    const western = ['0','1','2','3','4','5','6','7','8','9'];
                    const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
                    final buf = StringBuffer();
                    for (final ch in t.split('')) {
                      final idx = western.indexOf(ch);
                      buf.write(idx >= 0 ? eastern[idx] : ch);
                    }
                    return buf.toString();
                  }
                  String fmtNum(int n) => toArabicDigits(_formatInt(n));

                  // Decide which side to render the name on, based on script
                  final rawName = (arabicName.trim().isNotEmpty ? arabicName : englishName).trim();
                  final isArabicName = containsArabic(rawName);

                  // Build positioned widgets list
                  return <Widget>[
                    if (!isArabicName)
                      // LTR name on left
                      Positioned(
                        left: 16 * s,
                        top: 34 * s,
                        width: 250 * s,
                        child: Text(
                          rawName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 22 * s,
                            color: titleColor,
                          ),
                        ),
                      ),
                    if (isArabicName)
                      // RTL name on right
                      Positioned(
                        right: 16 * s,
                        top: 28 * s,
                        width: 200 * s,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            rawName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.w400,
                              fontSize: 24 * s,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),

                    // Determine app directionality for layout mirroring
                    ...(() {
                      final isRTL = Directionality.of(context) == TextDirection.rtl;

                      return <Widget>[
                        // Avatars stack (50px circles)
                        Positioned(
                          left: isRTL ? null : 16 * s,
                          right: isRTL ? 16 * s : null,
                          top: 80 * s,
                          child: _AvatarsStack(
                            avatars: memberAvatars,
                            size: 50 * s,
                            overlap: 14 * s,
                            borderWidth: 2 * s,
                          ),
                        ),

                        // +N circle (50px) with localized digits
                        if (plusCount > 0)
                          Positioned(
                            left: isRTL ? null : 198 * s,
                            right: isRTL ? 198 * s : null,
                            top: 80 * s,
                            child: Container(
                              width: 50 * s,
                              height: 50 * s,
                              decoration: const BoxDecoration(
                                color: chipBg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+${toArabicDigits(plusCount.toString())}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15 * s,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        // Chevron button mirrors for RTL
                        Positioned(
                          left: isRTL ? 16 * s : null,
                          right: isRTL ? null : 16 * s,
                          top: 87 * s,
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              width: 36 * s,
                              height: 36 * s,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: chipBg, width: 1.5 * s),
                                color: Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isRTL ? Icons.chevron_left : Icons.chevron_right,
                                size: 27 * s,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ),

                        // Progress bar (334x10), aligned by direction
                        Positioned(
                          left: isRTL ? null : 16 * s,
                          right: isRTL ? 16 * s : null,
                          top: 152 * s,
                          width: 334 * s,
                          height: 10 * s,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100 * s),
                            child: Stack(
                              children: [
                                Container(color: progressTrack),
                                FractionallySizedBox(
                                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                                  widthFactor: _percent,
                                  child: Container(color: progressFill),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Percent text with localized digits
                        Positioned(
                          left: isRTL ? 16 * s : null,
                          right: isRTL ? null : 16 * s,
                          top: 145 * s,
                          width: 50 * s,
                          height: 20 * s,
                          child: Text(
                            '${toArabicDigits((_percent * 100).round().toString())}%',
                            textAlign: isRTL ? TextAlign.left : TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              fontSize: 16 * s,
                              color: const Color(0xFF392852),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ];
                    })(),

                    // "X out of Y" label localized
                    Positioned(
                      left: 125 * s,
                      top: 170 * s,
                      width: 160 * s,
                      child: Text(
                        isArabicLocale
                            ? '${fmtNum(completed)} \u0645\u0646 \u0623\u0635\u0644 ${fmtNum(total)}' // "من أصل"
                            : '${fmtNum(completed)} out of ${fmtNum(total)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 12 * s,
                          color: percentTextColor,
                        ),
                      ),
                    ),
                  ];
                })(),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}

class _AvatarsStack extends StatelessWidget {
  final List<MemberAvatar> avatars;
  final double size;
  final double overlap;
  final double borderWidth;
  const _AvatarsStack({
    required this.avatars,
    this.size = 50,
    this.overlap = 14,
    this.borderWidth = 2,
  });

  Color _colorFor(String key) {
    // Use the first alphanumeric character to derive a stable, distinct color per letter
    String ch = '?';
    if (key.isNotEmpty) {
      final m = RegExp(r'[A-Za-z0-9]').firstMatch(key);
      if (m != null) ch = key[m.start].toUpperCase();
    }
    int idx;
    final code = ch.codeUnitAt(0);
    if (code >= 65 && code <= 90) {
      idx = code - 65; // A-Z -> 0..25
    } else if (code >= 48 && code <= 57) {
      idx = 26 + (code - 48); // 0-9 -> 26..35
    } else {
      idx = key.codeUnits.fold<int>(0, (p, c) => p + c) % 36;
    }
    // Evenly spaced hues for distinctiveness, with balanced saturation/lightness
    const steps = 36;
    final hue = (idx % steps) * (360.0 / steps);
    return HSLColor.fromAHSL(1.0, hue, 0.52, 0.42).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final count = avatars.length.clamp(0, 5); // limit to 5 for layout
    final visible = avatars.take(count).toList();
    final width = size + (visible.length - 1) * (size - overlap);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (visible[i].imageUrl == null || visible[i].imageUrl!.isEmpty)
                      ? _colorFor((visible[i].initials ?? '?'))
                      : Colors.transparent,
                  border: Border.all(color: Colors.white, width: borderWidth),
                ),
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    final a = visible[i];
                    if (a.imageUrl != null && a.imageUrl!.isNotEmpty) {
                      return ClipOval(
                        child: Image.network(
                          a.imageUrl!,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    final text = (a.initials != null && a.initials!.isNotEmpty) ? a.initials! : '?';
                    return Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.38,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final double angleDeg;
  final String assetPath;
  final double size;
  const _CornerDecoration({required this.angleDeg, required this.assetPath, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angleDeg * math.pi / 180,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

