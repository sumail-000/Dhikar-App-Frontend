import 'package:flutter/material.dart';

Future<Map<String, String>?> showAddCustomDhikrDialog(
    BuildContext context, {
      required bool isArabic,
    }) async {
  final enTitle = TextEditingController();
  final arTitle = TextEditingController();
  final enSubtitle = TextEditingController();
  final arSubtitle = TextEditingController();

  Map<String, String>? result;

  // Helpers for theme colors
  final isLight = Theme.of(context).brightness == Brightness.light;
  final bgColor = isLight ? const Color(0xFFDAF1DE) : const Color(0xFFE3D9F6);
  final textColor = isLight ? const Color(0xFF235347) : const Color(0xFF392852);
  final outlineColor = isLight ? const Color(0xFF051F20) : const Color(0xFF392852);

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12.5, color: textColor),
      hintText: hint,
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: outlineColor, width: 2),
      ),
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: bgColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        title: Text(
          isArabic ? 'إضافة ذكر مخصص' : 'Add Custom Dhikr',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isArabic) ...[
                TextField(
                  controller: enTitle,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: _inputDecoration(
                    label: 'Name (English) *',
                    hint: 'SubhanAllah',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: arTitle,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: _inputDecoration(
                    label: 'Name (Arabic)',
                    hint: 'سُبْحَانَ اللّٰهِ',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: enSubtitle,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: _inputDecoration(
                    label: 'Subtitle (English)',
                    hint: 'Glory be to Allah.',
                  ),
                ),
              ] else ...[
                TextField(
                  controller: arTitle,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: _inputDecoration(
                    label: 'الاسم (عربي) *',
                    hint: 'سُبْحَانَ اللّٰهِ',
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: arSubtitle,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: _inputDecoration(
                    label: 'الوصف (عربي)',
                    hint: 'تنزيه الله عن كل نقص',
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (!isArabic) {
                final titleEn = enTitle.text.trim();
                final titleAr = arTitle.text.trim();
                final subEn = enSubtitle.text.trim();
                if (titleEn.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter English name')),
                  );
                  return;
                }
                final computedArabicText = titleAr.isNotEmpty ? titleAr : titleEn;
                result = {
                  'title': titleEn,
                  'titleArabic': titleAr.isNotEmpty ? titleAr : titleEn,
                  'subtitle': subEn,
                  'subtitleArabic': subEn,
                  'arabic': computedArabicText,
                };
              } else {
                final titleAr = arTitle.text.trim();
                final subAr = arSubtitle.text.trim();
                if (titleAr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال الاسم بالعربية')),
                  );
                  return;
                }
                result = {
                  'title': titleAr,
                  'titleArabic': titleAr,
                  'subtitle': subAr,
                  'subtitleArabic': subAr,
                  'arabic': titleAr,
                };
              }
              Navigator.of(ctx).pop();
            },
            child: Text(
              isArabic ? 'إضافة' : 'Add',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );

  return result;
}
