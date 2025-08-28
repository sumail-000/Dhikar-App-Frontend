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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative corners (top-left and bottom-right), no rotation
                const _CornerDecoration(
                  angleDeg: 0,
                  assetPath: 'assets/background_elements/9.png',
                  size: 0, // placeholder; replaced below using Positioned with explicit size
                ),
                Positioned(
                  top: -22 * s,
                  left: -22 * s,
                  child: _CornerDecoration(
                    angleDeg: 0,
                    assetPath: 'assets/background_elements/9.png',
                    size: 62 * s,
                  ),
                ),
                Positioned(
                  bottom: -22 * s,
                  right: -22 * s,
                  child: _CornerDecoration(
                    angleDeg: 180,
                    assetPath: 'assets/background_elements/9.png',
                    size: 62 * s,
                  ),
                ),

                // English name (Manrope, Medium 22)
                Positioned(
                  left: 16 * s,
                  top: 34 * s,
                  width: 177 * s,
                  child: Text(
                    englishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 22 * s,
                      color: titleColor,
                    ),
                  ),
                ),

                // Arabic name (Amiri Regular 24)
                Positioned(
                  left: 301 * s,
                  top: 28 * s,
                  width: 91 * s,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      arabicName,
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

                // Avatars stack (50px circles)
                Positioned(
                  left: 16 * s,
                  top: 80 * s,
                  child: _AvatarsStack(
                    avatars: memberAvatars,
                    size: 50 * s,
                    overlap: 14 * s,
                    borderWidth: 2 * s,
                  ),
                ),

                // +N circle (50px)
                if (plusCount > 0)
                  Positioned(
                    left: 198 * s,
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
                        '+$plusCount',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 15 * s,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Chevron button (36px with 1.5px border)
                Positioned(
                  right: 16 * s,
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
                        Icons.chevron_right,
                        size: 27 * s,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),

                // Progress bar (334x10), left aligned
                Positioned(
                  left: 16 * s,
                  top: 152 * s,
                  width: 334 * s,
                  height: 10 * s,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100 * s),
                    child: Stack(
                      children: [
                        Container(color: progressTrack),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _percent,
                          child: Container(color: progressFill),
                        ),
                      ],
                    ),
                  ),
                ),

                // Percent text exact positioning per spec
                Positioned(
                  left: 358 * s,
                  top: 145 * s,
                  width: 34 * s,
                  child: Text(
                    '${(_percent * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                      fontSize: 16 * s,
                      color: Color(0xFF392852),
                      height: 1.0,
                    ),
                  ),
                ),

                // "X out of Y" label (centered)
                Positioned(
                  left: 125 * s,
                  top: 170 * s,
                  width: 116 * s,
                  child: Text(
                    '${_formatInt(completed)} out of ${_formatInt(total)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                      fontSize: 12 * s,
                      color: percentTextColor,
                    ),
                  ),
                ),
              ],
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

