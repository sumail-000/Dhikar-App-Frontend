import 'package:flutter/material.dart';

Future<Map<String, String>?> showAddCustomDhikrDialog(
  BuildContext context, {
  required bool isArabic,
}) async {
  final enTitle = TextEditingController();
  final arTitle = TextEditingController();
  final enSubtitle = TextEditingController();
  final arSubtitle = TextEditingController();
  final arText = TextEditingController();

  Map<String, String>? result;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final textStyleLabel = TextStyle(fontSize: 12.5, color: Theme.of(context).textTheme.bodySmall?.color);
      final textStyleField = const TextStyle(fontSize: 14);
      final densePadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8);

      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        title: Text(
          isArabic ? 'إضافة ذكر مخصص' : 'Add Custom Dhikr',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isArabic) ...[
                // English UI: Name (EN) required, Name (AR) optional, Subtitle (EN) optional
                TextField(
                  controller: enTitle,
                  textDirection: TextDirection.ltr,
                  style: textStyleField,
                  decoration: InputDecoration(
                    labelText: 'Name (English) *',
                    labelStyle: textStyleLabel,
                    hintText: 'SubhanAllah',
                    isDense: true,
                    contentPadding: densePadding,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: arTitle,
                  textDirection: TextDirection.rtl,
                  style: textStyleField,
                  decoration: InputDecoration(
                    labelText: 'Name (Arabic)',
                    labelStyle: textStyleLabel,
                    hintText: 'سُبْحَانَ اللّٰهِ',
                    isDense: true,
                    contentPadding: densePadding,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: enSubtitle,
                  textDirection: TextDirection.ltr,
                  style: textStyleField,
                  decoration: InputDecoration(
                    labelText: 'Subtitle (English)',
                    labelStyle: textStyleLabel,
                    hintText: 'Glory be to Allah.',
                    isDense: true,
                    contentPadding: densePadding,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                // Arabic UI: Name (AR) required, Subtitle (AR) optional
                TextField(
                  controller: arTitle,
                  textDirection: TextDirection.rtl,
                  style: textStyleField,
                  decoration: InputDecoration(
                    labelText: 'الاسم (عربي) *',
                    labelStyle: textStyleLabel,
                    hintText: 'سُبْحَانَ اللّٰهِ',
                    isDense: true,
                    contentPadding: densePadding,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: arSubtitle,
                  textDirection: TextDirection.rtl,
                  style: textStyleField,
                  decoration: InputDecoration(
                    labelText: 'الوصف (عربي)',
                    labelStyle: textStyleLabel,
                    hintText: 'تنزيه الله عن كل نقص',
                    isDense: true,
                    contentPadding: densePadding,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Conditional validation and mapping based on locale
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
                  'subtitleArabic': subEn, // mirror if no Arabic subtitle provided
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
                // Mirror Arabic into English fields where needed
                result = {
                  'title': titleAr, // fallback english name to arabic
                  'titleArabic': titleAr,
                  'subtitle': subAr, // mirror arabic subtitle to english field
                  'subtitleArabic': subAr,
                  'arabic': titleAr, // display text defaults to arabic name
                };
              }
              Navigator.of(ctx).pop();
            },
            child: Text(isArabic ? 'إضافة' : 'Add', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );

  return result;
}

