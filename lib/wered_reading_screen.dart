import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'dart:math' as math;
import 'app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeredReadingScreen extends StatefulWidget {
  final List<String> selectedSurahs;
  final String pages;
  final bool isPersonalKhitma;
  final int? khitmaDays;
  final int? personalKhitmaId; // ID of the personal khitma record
  final int? startFromPage; // Page number to start from (for continuing khitma)
  // Group reading mode properties
  final bool isGroupKhitma; // Flag for group reading mode
  final int? groupId; // ID of the group
  final List<int>?
  assignedJuz; // List of assigned Juz numbers for group reading

  const WeredReadingScreen({
    super.key,
    required this.selectedSurahs,
    required this.pages,
    this.isPersonalKhitma = false,
    this.khitmaDays,
    this.personalKhitmaId,
    this.startFromPage,
    this.isGroupKhitma = false,
    this.groupId,
    this.assignedJuz,
  });

  @override
  State<WeredReadingScreen> createState() => _WeredReadingScreenState();
}

class _WeredReadingScreenState extends State<WeredReadingScreen> {
  bool _saving = false;
  int currentPageIndex = 0;
  List<Map<String, dynamic>> surahData = [];
  bool isLoading = true;
  String? errorMessage;

  // Hardcoded surah list with Arabic names
  static const List<Map<String, String>> _surahs = [
    {'name': 'Al-Fatihah', 'arabic': 'الفاتحة', 'subtitle': 'The Opening'},
    {'name': 'Al-Baqarah', 'arabic': 'البقرة', 'subtitle': 'The Cow'},
    {
      'name': 'Al Imran',
      'arabic': 'آل عمران',
      'subtitle': 'The Family of Imran',
    },
    {'name': 'An-Nisa', 'arabic': 'النساء', 'subtitle': 'The Women'},
    {'name': 'Al-Maidah', 'arabic': 'المائدة', 'subtitle': 'The Table Spread'},
    {'name': 'Al-Anam', 'arabic': 'الأنعام', 'subtitle': 'The Cattle'},
    {'name': 'Al-Araf', 'arabic': 'الأعراف', 'subtitle': 'The Heights'},
    {'name': 'Al-Anfal', 'arabic': 'الأنفال', 'subtitle': 'The Spoils of War'},
    {'name': 'At-Tawbah', 'arabic': 'التوبة', 'subtitle': 'The Repentance'},
    {'name': 'Yunus', 'arabic': 'يونس', 'subtitle': 'Jonah'},
    {'name': 'Hud', 'arabic': 'هود', 'subtitle': 'Hud'},
    {'name': 'Yusuf', 'arabic': 'يوسف', 'subtitle': 'Joseph'},
    {'name': 'Ar-Rad', 'arabic': 'الرعد', 'subtitle': 'The Thunder'},
    {'name': 'Ibrahim', 'arabic': 'إبراهيم', 'subtitle': 'Abraham'},
    {'name': 'Al-Hijr', 'arabic': 'الحجر', 'subtitle': 'The Rocky Tract'},
    {'name': 'An-Nahl', 'arabic': 'النحل', 'subtitle': 'The Bee'},
    {'name': 'Al-Isra', 'arabic': 'الإسراء', 'subtitle': 'The Night Journey'},
    {'name': 'Al-Kahf', 'arabic': 'الكهف', 'subtitle': 'The Cave'},
    {'name': 'Maryam', 'arabic': 'مريم', 'subtitle': 'Mary'},
    {'name': 'Taha', 'arabic': 'طه', 'subtitle': 'Ta-Ha'},
    {'name': 'Al-Anbiya', 'arabic': 'الأنبياء', 'subtitle': 'The Prophets'},
    {'name': 'Al-Hajj', 'arabic': 'الحج', 'subtitle': 'The Pilgrimage'},
    {'name': 'Al-Muminun', 'arabic': 'المؤمنون', 'subtitle': 'The Believers'},
    {'name': 'An-Nur', 'arabic': 'النور', 'subtitle': 'The Light'},
    {'name': 'Al-Furqan', 'arabic': 'الفرقان', 'subtitle': 'The Criterion'},
    {'name': 'Ash-Shuara', 'arabic': 'الشعراء', 'subtitle': 'The Poets'},
    {'name': 'An-Naml', 'arabic': 'النمل', 'subtitle': 'The Ant'},
    {'name': 'Al-Qasas', 'arabic': 'القصص', 'subtitle': 'The Stories'},
    {'name': 'Al-Ankabut', 'arabic': 'العنكبوت', 'subtitle': 'The Spider'},
    {'name': 'Ar-Rum', 'arabic': 'الروم', 'subtitle': 'The Romans'},
    {'name': 'Luqman', 'arabic': 'لقمان', 'subtitle': 'Luqman'},
    {'name': 'As-Sajdah', 'arabic': 'السجدة', 'subtitle': 'The Prostration'},
    {'name': 'Al-Ahzab', 'arabic': 'الأحزاب', 'subtitle': 'The Clans'},
    {'name': 'Saba', 'arabic': 'سبأ', 'subtitle': 'Sheba'},
    {'name': 'Fatir', 'arabic': 'فاطر', 'subtitle': 'Originator'},
    {'name': 'Ya-Sin', 'arabic': 'يس', 'subtitle': 'Ya Sin'},
    {
      'name': 'As-Saffat',
      'arabic': 'الصافات',
      'subtitle': 'Those who set the Ranks',
    },
    {'name': 'Sad', 'arabic': 'ص', 'subtitle': 'The Letter "Saad"'},
    {'name': 'Az-Zumar', 'arabic': 'الزمر', 'subtitle': 'The Troops'},
    {'name': 'Ghafir', 'arabic': 'غافر', 'subtitle': 'The Forgiver'},
    {'name': 'Fussilat', 'arabic': 'فصلت', 'subtitle': 'Explained in Detail'},
    {'name': 'Ash-Shuraa', 'arabic': 'الشورى', 'subtitle': 'The Consultation'},
    {
      'name': 'Az-Zukhruf',
      'arabic': 'الزخرف',
      'subtitle': 'The Ornaments of Gold',
    },
    {'name': 'Ad-Dukhan', 'arabic': 'الدخان', 'subtitle': 'The Smoke'},
    {'name': 'Al-Jathiyah', 'arabic': 'الجاثية', 'subtitle': 'The Crouching'},
    {
      'name': 'Al-Ahqaf',
      'arabic': 'الأحقاف',
      'subtitle': 'The Wind-Curved Sandhills',
    },
    {'name': 'Muhammad', 'arabic': 'محمد', 'subtitle': 'Muhammad'},
    {'name': 'Al-Fath', 'arabic': 'الفتح', 'subtitle': 'The Victory'},
    {'name': 'Al-Hujurat', 'arabic': 'الحجرات', 'subtitle': 'The Rooms'},
    {'name': 'Qaf', 'arabic': 'ق', 'subtitle': 'The Letter "Qaf"'},
    {
      'name': 'Adh-Dhariyat',
      'arabic': 'الذاريات',
      'subtitle': 'The Winnowing Winds',
    },
    {'name': 'At-Tur', 'arabic': 'الطور', 'subtitle': 'The Mount'},
    {'name': 'An-Najm', 'arabic': 'النجم', 'subtitle': 'The Star'},
    {'name': 'Al-Qamar', 'arabic': 'القمر', 'subtitle': 'The Moon'},
    {'name': 'Ar-Rahman', 'arabic': 'الرحمن', 'subtitle': 'The Beneficent'},
    {'name': 'Al-Waqiah', 'arabic': 'الواقعة', 'subtitle': 'The Inevitable'},
    {'name': 'Al-Hadid', 'arabic': 'الحديد', 'subtitle': 'The Iron'},
    {
      'name': 'Al-Mujadila',
      'arabic': 'المجادلة',
      'subtitle': 'The Pleading Woman',
    },
    {'name': 'Al-Hashr', 'arabic': 'الحشر', 'subtitle': 'The Exile'},
    {
      'name': 'Al-Mumtahanah',
      'arabic': 'الممتحنة',
      'subtitle': 'She that is to be examined',
    },
    {'name': 'As-Saff', 'arabic': 'الصف', 'subtitle': 'The Ranks'},
    {
      'name': 'Al-Jumuah',
      'arabic': 'الجمعة',
      'subtitle': 'The Congregation, Friday',
    },
    {
      'name': 'Al-Munafiqun',
      'arabic': 'المنافقون',
      'subtitle': 'The Hypocrites',
    },
    {
      'name': 'At-Taghabun',
      'arabic': 'التغابن',
      'subtitle': 'The Mutual Disillusion',
    },
    {'name': 'At-Talaq', 'arabic': 'الطلاق', 'subtitle': 'The Divorce'},
    {'name': 'At-Tahrim', 'arabic': 'التحريم', 'subtitle': 'The Prohibition'},
    {'name': 'Al-Mulk', 'arabic': 'الملك', 'subtitle': 'The Sovereignty'},
    {'name': 'Al-Qalam', 'arabic': 'القلم', 'subtitle': 'The Pen'},
    {'name': 'Al-Haqqah', 'arabic': 'الحاقة', 'subtitle': 'The Reality'},
    {
      'name': 'Al-Maarij',
      'arabic': 'المعارج',
      'subtitle': 'The Ascending Stairways',
    },
    {'name': 'Nuh', 'arabic': 'نوح', 'subtitle': 'Noah'},
    {'name': 'Al-Jinn', 'arabic': 'الجن', 'subtitle': 'The Jinn'},
    {
      'name': 'Al-Muzzammil',
      'arabic': 'المزمل',
      'subtitle': 'The Enshrouded One',
    },
    {
      'name': 'Al-Muddaththir',
      'arabic': 'المدثر',
      'subtitle': 'The Cloaked One',
    },
    {'name': 'Al-Qiyamah', 'arabic': 'القيامة', 'subtitle': 'The Resurrection'},
    {'name': 'Al-Insan', 'arabic': 'الإنسان', 'subtitle': 'The Man'},
    {'name': 'Al-Mursalat', 'arabic': 'المرسلات', 'subtitle': 'The Emissaries'},
    {'name': 'An-Naba', 'arabic': 'النبأ', 'subtitle': 'The Tidings'},
    {
      'name': 'An-Naziat',
      'arabic': 'النازعات',
      'subtitle': 'Those who drag forth',
    },
    {'name': 'Abasa', 'arabic': 'عبس', 'subtitle': 'He Frowned'},
    {'name': 'At-Takwir', 'arabic': 'التكوير', 'subtitle': 'The Overthrowing'},
    {'name': 'Al-Infitar', 'arabic': 'الانفطار', 'subtitle': 'The Cleaving'},
    {
      'name': 'Al-Mutaffifin',
      'arabic': 'المطففين',
      'subtitle': 'The Defrauding',
    },
    {
      'name': 'Al-Inshiqaq',
      'arabic': 'الانشقاق',
      'subtitle': 'The Splitting Open',
    },
    {
      'name': 'Al-Buruj',
      'arabic': 'البروج',
      'subtitle': 'The Mansions of the Stars',
    },
    {'name': 'At-Tariq', 'arabic': 'الطارق', 'subtitle': 'The Morning Star'},
    {'name': 'Al-Ala', 'arabic': 'الأعلى', 'subtitle': 'The Most High'},
    {
      'name': 'Al-Ghashiyah',
      'arabic': 'الغاشية',
      'subtitle': 'The Overwhelming',
    },
    {'name': 'Al-Fajr', 'arabic': 'الفجر', 'subtitle': 'The Dawn'},
    {'name': 'Al-Balad', 'arabic': 'البلد', 'subtitle': 'The City'},
    {'name': 'Ash-Shams', 'arabic': 'الشمس', 'subtitle': 'The Sun'},
    {'name': 'Al-Layl', 'arabic': 'الليل', 'subtitle': 'The Night'},
    {'name': 'Ad-Duhaa', 'arabic': 'الضحى', 'subtitle': 'The Morning Hours'},
    {'name': 'Ash-Sharh', 'arabic': 'الشرح', 'subtitle': 'The Relief'},
    {'name': 'At-Tin', 'arabic': 'التين', 'subtitle': 'The Fig'},
    {'name': 'Al-Alaq', 'arabic': 'العلق', 'subtitle': 'The Clot'},
    {'name': 'Al-Qadr', 'arabic': 'القدر', 'subtitle': 'The Power, Fate'},
    {'name': 'Al-Bayyinah', 'arabic': 'البينة', 'subtitle': 'The Evidence'},
    {'name': 'Az-Zalzalah', 'arabic': 'الزلزلة', 'subtitle': 'The Earthquake'},
    {'name': 'Al-Adiyat', 'arabic': 'العاديات', 'subtitle': 'The Chargers'},
    {'name': 'Al-Qariah', 'arabic': 'القارعة', 'subtitle': 'The Calamity'},
    {
      'name': 'At-Takathur',
      'arabic': 'التكاثر',
      'subtitle': 'The Rivalry in world increase',
    },
    {
      'name': 'Al-Asr',
      'arabic': 'العصر',
      'subtitle': 'The Declining Day, Epoch',
    },
    {'name': 'Al-Humazah', 'arabic': 'الهمزة', 'subtitle': 'The Traducer'},
    {'name': 'Al-Fil', 'arabic': 'الفيل', 'subtitle': 'The Elephant'},
    {'name': 'Quraysh', 'arabic': 'قريش', 'subtitle': 'Quraysh'},
    {
      'name': 'Al-Maun',
      'arabic': 'الماعون',
      'subtitle': 'The Small kindnesses',
    },
    {'name': 'Al-Kawthar', 'arabic': 'الكوثر', 'subtitle': 'The Abundance'},
    {
      'name': 'Al-Kafirun',
      'arabic': 'الكافرون',
      'subtitle': 'The Disbelievers',
    },
    {'name': 'An-Nasr', 'arabic': 'النصر', 'subtitle': 'The Divine Support'},
    {'name': 'Al-Masad', 'arabic': 'المسد', 'subtitle': 'The Palm Fibre'},
    {'name': 'Al-Ikhlas', 'arabic': 'الإخلاص', 'subtitle': 'The Sincerity'},
    {'name': 'Al-Falaq', 'arabic': 'الفلق', 'subtitle': 'The Dawn'},
    {'name': 'An-Nas', 'arabic': 'الناس', 'subtitle': 'Mankind'},
  ];

  // Map our UI surah names to their corresponding surah numbers in the Quran
  static const Map<String, int> surahNameToNumber = {
    'Al-Fatihah': 1,
    'Al-Baqarah': 2,
    'Al Imran': 3,
    'An-Nisa': 4,
    'Al-Maidah': 5,
    'Al-Anam': 6,
    'Al-Araf': 7,
    'Al-Anfal': 8,
    'At-Tawbah': 9,
    'Yunus': 10,
    'Hud': 11,
    'Yusuf': 12,
    'Ar-Rad': 13,
    'Ibrahim': 14,
    'Al-Hijr': 15,
    'An-Nahl': 16,
    'Al-Isra': 17,
    'Al-Kahf': 18,
    'Maryam': 19,
    'Taha': 20,
    'Al-Anbiya': 21,
    'Al-Hajj': 22,
    'Al-Muminun': 23,
    'An-Nur': 24,
    'Al-Furqan': 25,
    'Ash-Shuara': 26,
    'An-Naml': 27,
    'Al-Qasas': 28,
    'Al-Ankabut': 29,
    'Ar-Rum': 30,
    'Luqman': 31,
    'As-Sajdah': 32,
    'Al-Ahzab': 33,
    'Saba': 34,
    'Fatir': 35,
    'Ya-Sin': 36,
    'As-Saffat': 37,
    'Sad': 38,
    'Az-Zumar': 39,
    'Ghafir': 40,
    'Fussilat': 41,
    'Ash-Shuraa': 42,
    'Az-Zukhruf': 43,
    'Ad-Dukhan': 44,
    'Al-Jathiyah': 45,
    'Al-Ahqaf': 46,
    'Muhammad': 47,
    'Al-Fath': 48,
    'Al-Hujurat': 49,
    'Qaf': 50,
    'Adh-Dhariyat': 51,
    'At-Tur': 52,
    'An-Najm': 53,
    'Al-Qamar': 54,
    'Ar-Rahman': 55,
    'Al-Waqiah': 56,
    'Al-Hadid': 57,
    'Al-Mujadila': 58,
    'Al-Hashr': 59,
    'Al-Mumtahanah': 60,
    'As-Saff': 61,
    'Al-Jumuah': 62,
    'Al-Munafiqun': 63,
    'At-Taghabun': 64,
    'At-Talaq': 65,
    'At-Tahrim': 66,
    'Al-Mulk': 67,
    'Al-Qalam': 68,
    'Al-Haqqah': 69,
    'Al-Maarij': 70,
    'Nuh': 71,
    'Al-Jinn': 72,
    'Al-Muzzammil': 73,
    'Al-Muddaththir': 74,
    'Al-Qiyamah': 75,
    'Al-Insan': 76,
    'Al-Mursalat': 77,
    'An-Naba': 78,
    'An-Naziat': 79,
    'Abasa': 80,
    'At-Takwir': 81,
    'Al-Infitar': 82,
    'Al-Mutaffifin': 83,
    'Al-Inshiqaq': 84,
    'Al-Buruj': 85,
    'At-Tariq': 86,
    'Al-Ala': 87,
    'Al-Ghashiyah': 88,
    'Al-Fajr': 89,
    'Al-Balad': 90,
    'Ash-Shams': 91,
    'Al-Layl': 92,
    'Ad-Duhaa': 93,
    'Ash-Sharh': 94,
    'At-Tin': 95,
    'Al-Alaq': 96,
    'Al-Qadr': 97,
    'Al-Bayyinah': 98,
    'Az-Zalzalah': 99,
    'Al-Adiyat': 100,
    'Al-Qariah': 101,
    'At-Takathur': 102,
    'Al-Asr': 103,
    'Al-Humazah': 104,
    'Al-Fil': 105,
    'Quraysh': 106,
    'Al-Maun': 107,
    'Al-Kawthar': 108,
    'Al-Kafirun': 109,
    'An-Nasr': 110,
    'Al-Masad': 111,
    'Al-Ikhlas': 112,
    'Al-Falaq': 113,
    'An-Nas': 114,
  };

  /// Get Arabic surah name from hardcoded list
  String? _getArabicSurahName(String englishName) {
    for (final surah in _surahs) {
      if (surah['name'] == englishName) {
        return surah['arabic'];
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  Future<void> _loadSurahData() async {
    try {
      print('🚀 DEBUG: Starting to load surah data...');
      print('🚀 DEBUG: Selected surahs: ${widget.selectedSurahs}');
      print('🚀 DEBUG: Requested pages: ${widget.pages}');
      print('🚀 DEBUG: Is Personal Khitma: ${widget.isPersonalKhitma}');
      print('🚀 DEBUG: Is Group Khitma: ${widget.isGroupKhitma}');
      if (widget.isGroupKhitma) {
        print('🚀 DEBUG: Assigned Juz: ${widget.assignedJuz}');
      }

      print('📁 DEBUG: Attempting to load asset: assets/hafsData_v2-0.json');
      final String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/hafsData_v2-0.json');
        print(
          '📁 DEBUG: Asset loaded successfully, string length: ${jsonString.length}',
        );
      } catch (assetError) {
        print('❌ DEBUG: Asset loading failed: $assetError');
        setState(() {
          errorMessage =
              'Failed to load Quran data file. Please ensure the app is properly installed and try restarting the app.';
          isLoading = false;
        });
        return;
      }

      if (jsonString.isEmpty) {
        print('❌ DEBUG: JSON string is empty');
        setState(() {
          errorMessage = 'Quran data file is empty. Please reinstall the app.';
          isLoading = false;
        });
        return;
      }

      print('📊 DEBUG: Parsing JSON data...');
      final List<dynamic> jsonData;
      try {
        jsonData = json.decode(jsonString) as List<dynamic>;
        print(
          '📊 DEBUG: JSON data parsed successfully, total entries: ${jsonData.length}',
        );
      } catch (parseError) {
        print('❌ DEBUG: JSON parsing failed: $parseError');
        setState(() {
          errorMessage =
              'Failed to parse Quran data. The data file may be corrupted.';
          isLoading = false;
        });
        return;
      }

      List<dynamic> relevantVerses;

      if (widget.isPersonalKhitma) {
        // Personal Khitma: Load all verses from all surahs (entire Quran)
        print('📖 DEBUG: Loading entire Quran for Personal Khitma...');
        relevantVerses = jsonData;
      } else if (widget.isGroupKhitma) {
        // Group Khitma: Load verses for assigned Juz only
        print('🤝 DEBUG: Loading assigned Juz for Group Khitma...');
        print('🤝 DEBUG: Assigned Juz: ${widget.assignedJuz}');

        if (widget.assignedJuz == null || widget.assignedJuz!.isEmpty) {
          setState(() {
            errorMessage = 'No assigned Juz found for group reading.';
            isLoading = false;
          });
          return;
        }

        // Filter verses for assigned Juz pages
        final assignedPages = _getPagesForJuz(widget.assignedJuz!);
        print(
          '🤝 DEBUG: Assigned pages: ${assignedPages.take(10).toList()}${assignedPages.length > 10 ? '...' : ''}',
        );

        relevantVerses = jsonData.where((verse) {
          final Map<String, dynamic> v = verse as Map<String, dynamic>;
          final int page = v['page'] as int;
          return assignedPages.contains(page);
        }).toList();
      } else {
        // Daily Wered: Load only selected surah
        final selectedSurahName = widget.selectedSurahs.first;
        final int? surahNumber = surahNameToNumber[selectedSurahName];

        print('🔍 DEBUG: Selected surah name: "$selectedSurahName"');
        print('🔍 DEBUG: Mapped to surah number: $surahNumber');

        if (surahNumber == null) {
          setState(() {
            errorMessage =
                'Could not find surah number for "$selectedSurahName". Please check the surah name.';
            isLoading = false;
          });
          return;
        }

        // Filter verses for the selected surah by number
        relevantVerses = jsonData.where((verse) {
          final Map<String, dynamic> v = verse as Map<String, dynamic>;
          final int surahNo = v['sura_no'] as int;
          return surahNo == surahNumber;
        }).toList();
      }

      print('🚀 DEBUG: Found ${relevantVerses.length} verses');

      if (relevantVerses.isEmpty) {
        setState(() {
          errorMessage = widget.isPersonalKhitma
              ? 'No Quran data found'
              : 'No verses found for the selected surah';
          isLoading = false;
        });
        return;
      }

      // Debug: Show some sample verses
      if (relevantVerses.isNotEmpty) {
        final sampleVerse = relevantVerses.first;
        print('🔍 DEBUG: Sample verse data:');
        print('   - Surah number: ${sampleVerse['sura_no']}');
        print('   - Surah name (EN): ${sampleVerse['sura_name_en']}');
        print('   - Surah name (AR): ${sampleVerse['sura_name_ar']}');
        print('   - Page: ${sampleVerse['page']}');
        print('   - Verse number: ${sampleVerse['aya_no']}');
      }

      // Group verses by page
      final Map<int, List<Map<String, dynamic>>> versesByPage = {};
      for (final verse in relevantVerses) {
        final Map<String, dynamic> v = verse as Map<String, dynamic>;
        final int page = v['page'] as int;
        versesByPage.putIfAbsent(page, () => []).add(v);
      }

      print('🚀 DEBUG: Verses grouped into ${versesByPage.length} pages');
      print('🚀 DEBUG: Available pages: ${versesByPage.keys.toList()..sort()}');

      // Determine which pages to load
      final sortedPages = versesByPage.keys.toList()..sort();
      List<int> requestedPages;

      if (widget.isPersonalKhitma) {
        // Personal Khitma: Load all pages sequentially (1-604)
        requestedPages = sortedPages;
        print(
          '📖 DEBUG: Personal Khitma - Loading all ${requestedPages.length} pages',
        );
      } else if (widget.isGroupKhitma) {
        // Group Khitma: Load all assigned pages
        requestedPages = sortedPages;
        print(
          '🤝 DEBUG: Group Khitma - Loading all assigned ${requestedPages.length} pages',
        );
      } else {
        // Daily Wered: Load requested number of pages from selected surah
        final requestedPageCount = int.tryParse(widget.pages) ?? 1;
        requestedPages = sortedPages.take(requestedPageCount).toList();
        print(
          '📄 DEBUG: Daily Wered - Loading $requestedPageCount pages from selected surah',
        );
      }

      print(
        '🚀 DEBUG: Selected pages: ${requestedPages.take(10).toList()}${requestedPages.length > 10 ? '...' : ''}',
      );

      if (requestedPages.isEmpty) {
        setState(() {
          errorMessage = 'No pages available for the requested configuration';
          isLoading = false;
        });
        return;
      }

      // Build page data structure
      final List<Map<String, dynamic>> pagesData = [];
      for (final pageNum in requestedPages) {
        final verses = versesByPage[pageNum]!;
        verses.sort(
          (a, b) => (a['aya_no'] as int).compareTo(b['aya_no'] as int),
        );

        // Get the main surah for this page (first verse's surah)
        final mainSurah = verses.first;

        pagesData.add({
          'pageNumber': pageNum,
          'verses': verses,
          'surahName': mainSurah['sura_name_en'],
          'surahNameAr': mainSurah['sura_name_ar'],
        });
      }

      print('✅ DEBUG: Successfully loaded ${pagesData.length} pages of data');
      print(
        '📊 DEBUG: Page range: ${pagesData.first['pageNumber']} to ${pagesData.last['pageNumber']}',
      );

      setState(() {
        surahData = pagesData;
        isLoading = false;

        // Set starting page if specified
        if (widget.startFromPage != null) {
          _setInitialPageIndex(widget.startFromPage!);
        }
      });
    } catch (e, stackTrace) {
      print('❌ DEBUG: Error loading surah data: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Failed to load Quran data: $e';
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _getCurrentPageContent() {
    if (surahData.isEmpty || currentPageIndex >= surahData.length) return null;
    return surahData[currentPageIndex];
  }

  void _previousPage() {
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
    }
  }

  void _nextPage() {
    if (currentPageIndex < surahData.length - 1) {
      setState(() {
        currentPageIndex++;
      });
    }
  }

  /// Set initial page index based on page number from backend
  void _setInitialPageIndex(int targetPageNumber) {
    print('🎯 DEBUG: Looking for page $targetPageNumber in loaded data');

    // Find the index of the page with the target page number
    for (int i = 0; i < surahData.length; i++) {
      final pageData = surahData[i];
      final int pageNumber = pageData['pageNumber'] as int;

      if (pageNumber == targetPageNumber) {
        print('🎯 DEBUG: Found target page $targetPageNumber at index $i');
        setState(() {
          currentPageIndex = i;
        });
        return;
      }
    }

    // If target page not found, try to find the closest page
    int closestIndex = 0;
    int minDiff = ((surahData[0]['pageNumber'] as int) - targetPageNumber)
        .abs();

    for (int i = 1; i < surahData.length; i++) {
      final pageData = surahData[i];
      final int pageNumber = pageData['pageNumber'] as int;
      final int diff = (pageNumber - targetPageNumber).abs();

      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }

    print(
      '🎯 DEBUG: Target page $targetPageNumber not found exactly, using closest page at index $closestIndex (page ${surahData[closestIndex]['pageNumber']})',
    );
    setState(() {
      currentPageIndex = closestIndex;
    });
  }

  /// Clean verse text by removing verse ending markers
  String _cleanVerseText(String originalText) {
    // Remove verse ending markers - these are special Unicode characters
    String cleanedText = originalText;

    // Simple and effective approach: Remove the specific verse ending markers
    // that we see in the JSON data: ﰀ ﰁ ﰂ ﰃ ﰄ ﰅ ﰆ ﰇ
    final List<String> verseEndingMarkers = [
      'ﰀ',
      'ﰁ',
      'ﰂ',
      'ﰃ',
      'ﰄ',
      'ﰅ',
      'ﰆ',
      'ﰇ',
      'ﰈ',
      'ﰉ',
      'ﰊ',
      'ﰋ',
      'ﰌ',
      'ﰍ',
      'ﰎ',
      'ﰏ',
      'ﰐ',
      'ﰑ',
      'ﰒ',
      'ﰓ',
      'ﰔ',
      'ﰕ',
      'ﰖ',
      'ﰗ',
      'ﰘ',
      'ﰙ',
      'ﰚ',
      'ﰛ',
      'ﰜ',
      'ﰝ',
    ];

    // Remove each marker
    for (final marker in verseEndingMarkers) {
      cleanedText = cleanedText.replaceAll(marker, '');
    }

    // Also use a broader regex to catch any remaining verse markers in the range
    // U+FC00 to U+FDFF (Arabic Presentation Forms-A)
    cleanedText = cleanedText.replaceAll(RegExp(r'[\uFC00-\uFDFF]'), '');

    // Trim any extra whitespace
    cleanedText = cleanedText.trim();

    // Only print if something was actually cleaned
    if (cleanedText != originalText) {
      print('🧹 DEBUG: Cleaned verse text: "$originalText" -> "$cleanedText"');
    }

    return cleanedText;
  }

  /// Build TextSpans for verses with inline numbers in a continuous flow
  List<TextSpan> _buildVerseSpans(List<dynamic> verses) {
    List<TextSpan> spans = [];

    // Check if this is Al-Fatihah (surah 1)
    final isAlFatihah =
        verses.isNotEmpty && (verses.first['sura_no'] as int) == 1;

    int displayVerseNumber = 1; // Counter for display numbering

    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final String verseText = _cleanVerseText(verse['aya_text']);
      final int originalVerseNumber = verse['aya_no'] as int;

      // Special handling for Al-Fatihah: skip verse 1 (which is Bismillah)
      if (isAlFatihah && originalVerseNumber == 1) {
        print('🔍 DEBUG: Skipping Al-Fatihah verse 1 (Bismillah): $verseText');
        continue;
      }

      // Skip Bismillah verses for other surahs
      if (!isAlFatihah && _isBismillahVerse(verseText)) {
        print('🔍 DEBUG: Skipping Bismillah verse: $verseText');
        continue;
      }

      // Add the verse text with Amiri font
      spans.add(
        TextSpan(
          text: verseText,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            height: 1.5,
            // 100% line height
            letterSpacing: 0,
            color: Color(0xFF1F1F1F),
            // #392852
            fontWeight: FontWeight.w400,
          ),
        ),
      );

      // Add verse number in parentheses
      // For Al-Fatihah, use adjusted numbering (1, 2, 3, etc.)
      // For other surahs, use original numbering
      final int displayNumber = isAlFatihah
          ? displayVerseNumber
          : originalVerseNumber;
      spans.add(
        TextSpan(
          text: ' ($displayNumber) ',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            // Slightly smaller for verse numbers
            height: 1.0,
            color: Color(0xFF392852),
            // add color gpt
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      // Increment display counter for Al-Fatihah
      if (isAlFatihah) {
        displayVerseNumber++;
      }

      // Add space before next verse (except for the last verse)
      if (i < verses.length - 1) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 16, height: 1.0),
          ),
        );
      }
    }

    return spans;
  }

  /// Check if a verse is Bismillah
  bool _isBismillahVerse(String verseText) {
    // Common variations of Bismillah
    final bismillahPatterns = [
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Full diacritics
      'بسم الله الرحمن الرحيم', // Without diacritics
    ];

    for (final pattern in bismillahPatterns) {
      if (verseText.contains(pattern)) {
        return true;
      }
    }

    // Also check if it starts with bismillah-like pattern
    return verseText.startsWith('بِسْمِ') || verseText.startsWith('بسم');
  }

  /// Get Bismillah text for surah header
  String? _getBismillahForSurah(List<dynamic> verses) {
    for (final verse in verses) {
      final String verseText = _cleanVerseText(verse['aya_text']);
      if (_isBismillahVerse(verseText)) {
        return verseText;
      }
    }
    return null;
  }

  /// Determine if Bismillah should be shown for the current page
  bool _shouldShowBismillah(Map<String, dynamic> pageContent) {
    final verses = pageContent['verses'] as List<dynamic>;
    if (verses.isEmpty) return false;

    final currentSurahNumber = verses.first['sura_no'] as int;

    // Special case: At-Tawbah (Surah 9) never has Bismillah
    if (currentSurahNumber == 9) {
      return false;
    }

    // Check if this is the beginning of a new surah
    // We show Bismillah if:
    // 1. This is the first page of the session and we're starting from page 1
    // 2. OR this page starts a new surah (first verse is verse 1 of the surah)

    final firstVerse = verses.first;
    final firstVerseNumber = firstVerse['aya_no'] as int;

    // If the first verse on this page is verse 1, it's the start of a surah
    if (firstVerseNumber == 1) {
      print(
        '📖 DEBUG: Showing Bismillah for start of Surah $currentSurahNumber',
      );
      return true;
    }

    // For continuing khitma: Show Bismillah only if starting from page 1 of first surah
    if (currentPageIndex == 0 &&
        (widget.startFromPage == null || widget.startFromPage == 1)) {
      print('📖 DEBUG: Showing Bismillah for first page of session');
      return true;
    }

    return false;
  }

  /// Calculate which Juzz (Para) the current page belongs to
  int _getJuzzForPage(int page) {
    // Approximate Juzz boundaries based on page numbers
    // This is a rough mapping - for precise mapping, you'd use a proper Juzz-to-page lookup table
    if (page <= 21) return 1;
    if (page <= 41) return 2;
    if (page <= 62) return 3;
    if (page <= 82) return 4;
    if (page <= 102) return 5;
    if (page <= 122) return 6;
    if (page <= 142) return 7;
    if (page <= 162) return 8;
    if (page <= 182) return 9;
    if (page <= 202) return 10;
    if (page <= 222) return 11;
    if (page <= 242) return 12;
    if (page <= 262) return 13;
    if (page <= 282) return 14;
    if (page <= 302) return 15;
    if (page <= 322) return 16;
    if (page <= 342) return 17;
    if (page <= 362) return 18;
    if (page <= 382) return 19;
    if (page <= 402) return 20;
    if (page <= 422) return 21;
    if (page <= 442) return 22;
    if (page <= 462) return 23;
    if (page <= 482) return 24;
    if (page <= 502) return 25;
    if (page <= 522) return 26;
    if (page <= 542) return 27;
    if (page <= 562) return 28;
    if (page <= 582) return 29;
    return 30; // Pages 583-604
  }

  /// Get list of pages for given Juz numbers (for group reading mode)
  List<int> _getPagesForJuz(List<int> juzNumbers) {
    final Set<int> pages = <int>{};

    // Juz to page range mapping based on standard Mushaf
    final Map<int, List<int>> juzPageRanges = {
      1: List.generate(21, (i) => i + 1), // Pages 1-21
      2: List.generate(20, (i) => i + 22), // Pages 22-41
      3: List.generate(21, (i) => i + 42), // Pages 42-62
      4: List.generate(20, (i) => i + 63), // Pages 63-82
      5: List.generate(20, (i) => i + 83), // Pages 83-102
      6: List.generate(20, (i) => i + 103), // Pages 103-122
      7: List.generate(20, (i) => i + 123), // Pages 123-142
      8: List.generate(20, (i) => i + 143), // Pages 143-162
      9: List.generate(20, (i) => i + 163), // Pages 163-182
      10: List.generate(20, (i) => i + 183), // Pages 183-202
      11: List.generate(20, (i) => i + 203), // Pages 203-222
      12: List.generate(20, (i) => i + 223), // Pages 223-242
      13: List.generate(20, (i) => i + 243), // Pages 243-262
      14: List.generate(20, (i) => i + 263), // Pages 263-282
      15: List.generate(20, (i) => i + 283), // Pages 283-302
      16: List.generate(20, (i) => i + 303), // Pages 303-322
      17: List.generate(20, (i) => i + 323), // Pages 323-342
      18: List.generate(20, (i) => i + 343), // Pages 343-362
      19: List.generate(20, (i) => i + 363), // Pages 363-382
      20: List.generate(20, (i) => i + 383), // Pages 383-402
      21: List.generate(20, (i) => i + 403), // Pages 403-422
      22: List.generate(20, (i) => i + 423), // Pages 423-442
      23: List.generate(20, (i) => i + 443), // Pages 443-462
      24: List.generate(20, (i) => i + 463), // Pages 463-482
      25: List.generate(20, (i) => i + 483), // Pages 483-502
      26: List.generate(20, (i) => i + 503), // Pages 503-522
      27: List.generate(20, (i) => i + 523), // Pages 523-542
      28: List.generate(20, (i) => i + 543), // Pages 543-562
      29: List.generate(20, (i) => i + 563), // Pages 563-582
      30: List.generate(22, (i) => i + 583), // Pages 583-604
    };

    // Collect pages for all assigned Juz
    for (final juzNumber in juzNumbers) {
      if (juzPageRanges.containsKey(juzNumber)) {
        pages.addAll(juzPageRanges[juzNumber]!);
      }
    }

    return pages.toList()..sort();
  }

  /// Save group khitma progress to backend
  Future<void> _saveGroupKhitmaProgress() async {
    if (!widget.isGroupKhitma || widget.groupId == null) {
      print('❌ DEBUG: Not a group khitma or missing group ID');
      return;
    }

    final currentPageContent = _getCurrentPageContent();
    if (currentPageContent == null) {
      print('❌ DEBUG: No current page content available');
      return;
    }

    try {
      print('💾 DEBUG: Saving group khitma progress...');

      final verses = currentPageContent['verses'] as List<dynamic>;
      if (verses.isEmpty) {
        print('❌ DEBUG: No verses found in current page');
        return;
      }

      // Calculate progress details
      final int currentPage = currentPageContent['pageNumber'] as int;
      final int currentSurah = verses.first['sura_no'] as int;
      final int currentJuzz = _getJuzzForPage(currentPage);

      // Get first and last verse numbers
      final int? startVerse = verses.first['aya_no'] as int?;
      final int? endVerse = verses.last['aya_no'] as int?;

      print('📊 DEBUG: Group Progress details:');
      print('   - Group ID: ${widget.groupId}');
      print('   - Current Juzz: $currentJuzz');
      print('   - Current Surah: $currentSurah');
      print('   - Current Page: $currentPage');
      print('   - Start/End Verses: $startVerse-$endVerse');
      print('   - Assigned Juz: ${widget.assignedJuz}');

      // For group khitma, we'll use a specific API method for saving group progress
      // This method should be added to ApiClient
      final response = await ApiClient.instance.saveGroupKhitmaProgress(
        groupId: widget.groupId!,
        juzzRead: currentJuzz,
        surahRead: currentSurah,
        pageRead: currentPage,
        startVerse: startVerse,
        endVerse: endVerse,
        notes: null,
      );

      if (response.ok) {
        print('✅ DEBUG: Group progress saved successfully!');
        final responseData = response.data as Map<String, dynamic>;

        // Immediately update assignment pages_read across ALL assigned Juz up to current page
        try {
          final List<int> assigned =
              (widget.assignedJuz ?? const <int>[]).toList()..sort();
          if (assigned.isEmpty) {
            print(
              'ℹ️ DEBUG: No assigned Juz available on reading screen to update.',
            );
          } else {
            print(
              '🧮 DEBUG: Reconciling pages_read for assigned Juz: $assigned up to page $currentPage',
            );
            for (final j in assigned) {
              final List<int> pagesInJuz = _getPagesForJuz([j]);
              if (pagesInJuz.isEmpty) continue;
              final int first = pagesInJuz.first;
              final int last = pagesInJuz.last;
              if (currentPage < first) {
                // No progress into this Juz yet — leave as is
                continue;
              }
              if (currentPage >= last) {
                // Fully covered this Juz — set pages_read to full length and mark completed
                final int pagesRead = pagesInJuz.length;
                print(
                  '🧮 DEBUG: Juz $j fully covered. Setting pages_read=$pagesRead and status=completed',
                );
                final upd = await ApiClient.instance.khitmaUpdateAssignment(
                  widget.groupId!,
                  juzNumber: j,
                  pagesRead: pagesRead,
                );
                if (!upd.ok) {
                  print(
                    '⚠️ DEBUG: khitmaUpdateAssignment (full) failed for Juz $j: ${upd.error}',
                  );
                }
                final comp = await ApiClient.instance.khitmaUpdateAssignment(
                  widget.groupId!,
                  juzNumber: j,
                  status: 'completed',
                );
                if (!comp.ok) {
                  print(
                    '⚠️ DEBUG: Failed to set status completed for Juz $j: ${comp.error}',
                  );
                }
              } else {
                // Within this Juz — set partial pages_read up to current page
                final int pos = pagesInJuz.indexOf(currentPage);
                if (pos >= 0) {
                  final int pagesRead = pos + 1; // 1-based
                  print(
                    '🧮 DEBUG: Juz $j partial coverage. Setting pages_read=$pagesRead',
                  );
                  final upd = await ApiClient.instance.khitmaUpdateAssignment(
                    widget.groupId!,
                    juzNumber: j,
                    pagesRead: pagesRead,
                  );
                  if (!upd.ok) {
                    print(
                      '⚠️ DEBUG: khitmaUpdateAssignment (partial) failed for Juz $j: ${upd.error}',
                    );
                  }
                  if (pagesRead >= pagesInJuz.length) {
                    print(
                      '✅ DEBUG: Juz $j now complete from partial path. Marking as completed.',
                    );
                    final comp = await ApiClient.instance
                        .khitmaUpdateAssignment(
                          widget.groupId!,
                          juzNumber: j,
                          status: 'completed',
                        );
                    if (!comp.ok) {
                      print(
                        '⚠️ DEBUG: Failed to set status completed for Juz $j: ${comp.error}',
                      );
                    }
                  }
                } else {
                  print(
                    '⚠️ DEBUG: Current page $currentPage not found in page list for Juz $j',
                  );
                }
              }
            }
          }
        } catch (e, st) {
          print(
            '⚠️ DEBUG: Exception while updating assignments across Juz: $e',
          );
          print(st);
        }

        if (mounted) {
          _showGroupProgressSavedSnackbar();
        }
      } else {
        print('❌ DEBUG: Failed to save group progress: ${response.error}');
        if (mounted) {
          _showErrorSnackbar(
            response.error ??
                AppLocalizations.of(context)!.failedToSaveGroupProgress,
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception while saving group progress: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackbar(
          AppLocalizations.of(context)!.failedToSaveGroupProgress +
              '. ' +
              AppLocalizations.of(context)!.tryAgain +
              '.',
        );
      }
    }
  }

  /// Save personal khitma progress to backend
  Future<void> _savePersonalKhitmaProgress() async {
    if (!widget.isPersonalKhitma || widget.personalKhitmaId == null) {
      print('❌ DEBUG: Not a personal khitma or missing khitma ID');
      return;
    }

    final currentPageContent = _getCurrentPageContent();
    if (currentPageContent == null) {
      print('❌ DEBUG: No current page content available');
      return;
    }

    try {
      print('💾 DEBUG: Saving personal khitma progress...');

      final verses = currentPageContent['verses'] as List<dynamic>;
      if (verses.isEmpty) {
        print('❌ DEBUG: No verses found in current page');
        return;
      }

      // Calculate progress details
      final int currentPage = currentPageContent['pageNumber'] as int;
      final int currentSurah = verses.first['sura_no'] as int;
      final int currentJuzz = _getJuzzForPage(currentPage);

      // For personal khitma, we track reading from first page of current session
      final int startPage = currentPageIndex == 0 ? currentPage : currentPage;
      final int endPage = currentPage;

      // Get first and last verse numbers
      final int? startVerse = verses.first['aya_no'] as int?;
      final int? endVerse = verses.last['aya_no'] as int?;

      print('📊 DEBUG: Progress details:');
      print('   - Khitma ID: ${widget.personalKhitmaId}');
      print('   - Current Juzz: $currentJuzz');
      print('   - Current Surah: $currentSurah');
      print('   - Current Page: $currentPage');
      print('   - Start/End Pages: $startPage-$endPage');
      print('   - Start/End Verses: $startVerse-$endVerse');

      final response = await ApiClient.instance.savePersonalKhitmaProgress(
        khitmaId: widget.personalKhitmaId!,
        juzzRead: currentJuzz,
        surahRead: currentSurah,
        startPage: startPage,
        endPage: endPage,
        startVerse: startVerse,
        endVerse: endVerse,
        readingDurationMinutes: null,
        // We don't track time in this simple implementation
        notes: null,
      );

      if (response.ok) {
        print('✅ DEBUG: Progress saved successfully!');
        final responseData = response.data as Map<String, dynamic>;
        final khitmaData = responseData['khitma'] as Map<String, dynamic>;

        // Check if khitma was completed
        final bool isCompleted = khitmaData['is_completed'] == true;
        final double completionPercentage =
            (khitmaData['completion_percentage'] as num?)?.toDouble() ?? 0.0;

        if (mounted) {
          if (isCompleted) {
            _showKhitmaCompletedDialog(completionPercentage);
          } else {
            _showProgressSavedSnackbar(completionPercentage);
          }
        }
      } else {
        print('❌ DEBUG: Failed to save progress: ${response.error}');
        if (mounted) {
          _showErrorSnackbar(response.error ?? 'Failed to save progress');
        }
      }
    } catch (e, stackTrace) {
      print('❌ DEBUG: Exception while saving progress: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackbar('Failed to save progress. Please try again.');
      }
    }
  }

  /// Show khitma completed dialog
  void _showKhitmaCompletedDialog(double completionPercentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) => AlertDialog(
          title: Text(
            languageProvider.isArabic ? '🎉 تهانينا!' : '🎉 Congratulations!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.isArabic
                    ? 'لقد أكملت ختمة القرآن الكريم!'
                    : 'You have completed your Quran Khitma!',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${completionPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.isArabic ? 'مكتملة' : 'Complete',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close reading screen
              },
              child: Text(
                AppLocalizations.of(context)!.backToHome,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show group progress saved snackbar
  void _showGroupProgressSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.groupKhitmaProgressSaved),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show progress saved snackbar
  void _showProgressSavedSnackbar(double completionPercentage) {
    final text =
        AppLocalizations.of(context)!.khitmaProgressSaved +
        ' (' +
        completionPercentage.toStringAsFixed(1) +
        '% ' +
        AppLocalizations.of(context)!.completeWord +
        ')';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        // Handle loading state
        if (isLoading) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A148C)),
              ),
            ),
          );
        }

        // Handle error state
        if (errorMessage != null) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.loadingError,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              _loadSurahData();
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context)!.tryAgain),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A148C),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.goBack,
                              style: const TextStyle(color: Color(0xFF4A148C)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final currentPageContent = _getCurrentPageContent();

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  // Background SVG overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        colorFilter: themeProvider.isDarkMode
                            ? null
                            : const ColorFilter.mode(
                                Color(0xFF8EB69B),
                                BlendMode.srcIn,
                              ),
                      ),
                    ),
                  ),
                  // Color overlay for dark mode only
                  if (themeProvider.isDarkMode)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Header - compact
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: themeProvider.isDarkMode
                                      ? const Color(0xFFF7F3E8)
                                      : const Color(0xFF205C3B),
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.isPersonalKhitma
                                      ? AppLocalizations.of(
                                          context,
                                        )!.personalKhitma
                                      : widget.isGroupKhitma
                                      ? AppLocalizations.of(
                                          context,
                                        )!.groupKhitma
                                      : AppLocalizations.of(
                                          context,
                                        )!.dailyWered,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? const Color(0xFFF7F3E8)
                                        : const Color(0xFF205C3B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        // Page navigation - compact
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous page button
                              IconButton(
                                onPressed: currentPageIndex > 0
                                    ? _previousPage
                                    : null,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: currentPageIndex > 0
                                      ? (themeProvider.isDarkMode
                                            ? const Color(0xFFF7F3E8)
                                            : const Color(0xFF205C3B))
                                      : Colors.grey,
                                  size: 18,
                                ),
                              ),
                              // Page info
                              Text(
                                '${AppLocalizations.of(context)!.pageShort} ${currentPageIndex + 1} ${AppLocalizations.of(context)!.outOfWord} ${surahData.length}',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? const Color(0xFFF7F3E8)
                                      : const Color(0xFF205C3B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Next page button
                              IconButton(
                                onPressed:
                                    currentPageIndex < surahData.length - 1
                                    ? _nextPage
                                    : null,
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: currentPageIndex < surahData.length - 1
                                      ? (themeProvider.isDarkMode
                                            ? const Color(0xFFF7F3E8)
                                            : const Color(0xFF205C3B))
                                      : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Surah content - dynamic height based on content with corner decorations
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Main content container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(20,20,20,50),
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? Color(0xFFF2EDE0)
                                          : const Color(0xFFDAF1DE),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: themeProvider.isDarkMode
                                            ? Colors.transparent
                                            : const Color(0xFFB6D1C2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        // Make column size fit content
                                        children: [
                                          const SizedBox(height: 6),
                                          // Minimal top spacing for maximum content area
                                          if (currentPageContent != null) ...[
                                            // Surah title - dynamically get from current page content
                                            Text(
                                              _getArabicSurahName(
                                                    currentPageContent!['surahName'],
                                                  ) ??
                                                  currentPageContent!['surahNameAr'],
                                              style:  TextStyle(
                                                fontFamily: 'Amiri',
                                                fontSize: 36,
                                                height: 1.0,
                                                // 100% line height
                                                letterSpacing: 0,
                                                color: themeProvider.barText,
                                                // #392852
                                                fontWeight: FontWeight
                                                    .w400, // Regular weight
                                              ),
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.rtl,
                                            ),
                                            const SizedBox(height: 17),
                                            // Slightly reduced spacing before Bismillah
                                            // Show Bismillah when appropriate
                                            if (_shouldShowBismillah(
                                              currentPageContent!,
                                            ))
                                              const Text(
                                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                                style: TextStyle(
                                                  fontFamily: 'Amiri',
                                                  fontSize: 18,
                                                  height: 1.0,
                                                  // 100% line height
                                                  letterSpacing: 0,
                                                  color: Color(0xFF392852),
                                                  // #392852
                                                  fontWeight: FontWeight
                                                      .w400, // Regular weight
                                                ),
                                                textAlign: TextAlign.center,
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                            if (_shouldShowBismillah(
                                              currentPageContent!,
                                            ))
                                              const SizedBox(height: 20),
                                            // Equal spacing after Bismillah

                                            // Verses - continuous flow with inline numbers and center alignment
                                            RichText(
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.rtl,
                                              text: TextSpan(
                                                children: _buildVerseSpans(
                                                  currentPageContent!['verses'],
                                                ),
                                              ),
                                            ),
                                          ] else
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.noContentToDisplay,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Color(0xFF2D1B69),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Corner decorations - edge-aligned positioning (overlapping with card border)
                                  // Top-left corner (EDGE-ALIGNED)
                                   Positioned(
                                    top: 0,
                                    left: 0,
                                    child: _CornerDecoration(
                                      angleDeg: 0,
                                      assetPath:
                                      themeProvider.flower,
                                      size: 45,
                                    ),
                                  ),
                                  // Top-right corner (EDGE-ALIGNED)
                                   Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _CornerDecoration(
                                      angleDeg: 90,
                                      assetPath:
                                      themeProvider.flower,
                                      size: 45,
                                    ),
                                  ),
                                  // Bottom-left corner (EDGE-ALIGNED)
                                   Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: _CornerDecoration(
                                      angleDeg: 270,
                                      assetPath:
                                      themeProvider.flower,
                                      size: 45,
                                    ),
                                  ),
                                  // Bottom-right corner (EDGE-ALIGNED)
                                   Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: _CornerDecoration(
                                      angleDeg: 180,
                                      assetPath:
                                      themeProvider.flower,
                                      size: 45,
                                    ),
                                  ),

                                  // Juz information at bottom center
                                  if (currentPageContent != null)
                                    Positioned(
                                      bottom: 2,
                                      left: 0,
                                      right: 0,
                                      child: Consumer<LanguageProvider>(
                                        builder: (context, langProvider, child) {
                                          final currentPageNumber =
                                              currentPageContent!['pageNumber']
                                                  as int;
                                          final currentJuz = _getJuzzForPage(
                                            currentPageNumber,
                                          );

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              langProvider.isArabic
                                                  ? 'جُزْءُ $currentJuz'
                                                  : 'Juz $currentJuz',
                                              style: const TextStyle(
                                                fontFamily: 'Amiri',
                                                fontSize: 16,
                                                height: 1.2,
                                                letterSpacing: 0,
                                                color: Color(0xFF1F1F1F),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
                                              textDirection: langProvider.isArabic
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Action buttons - conditional based on mode
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: widget.isPersonalKhitma
                                ? [
                                    // Personal Khitma: Show Save Progress button only
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: ElevatedButton(
                                          onPressed: _saving
                                              ? null
                                              : () async {
                                                  if (_saving) return;
                                                  setState(() {
                                                    _saving = true;
                                                  });
                                                  try {
                                                    await _savePersonalKhitmaProgress();
                                                  } finally {
                                                    if (mounted)
                                                      setState(() {
                                                        _saving = false;
                                                      });
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFFF7F3E8)
                                                : const Color(0xFF235347),
                                            foregroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFF2D1B69)
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.saveProgress,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : widget.isGroupKhitma
                                ? [
                                    // Group Khitma: Show Save Progress button only
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: ElevatedButton(
                                          onPressed: _saving
                                              ? null
                                              : () async {
                                                  if (_saving) return;
                                                  setState(() {
                                                    _saving = true;
                                                  });
                                                  try {
                                                    await _saveGroupKhitmaProgress();
                                                  } finally {
                                                    if (mounted)
                                                      setState(() {
                                                        _saving = false;
                                                      });
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFFF7F3E8)
                                                : const Color(0xFF235347),
                                            foregroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFF2D1B69)
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: _saving
                                              ? const SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.saveProgress,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : [
                                    // Daily Wered: Show Change Surah button only
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFFF7F3E8)
                                                : const Color(0xFF235347),
                                            foregroundColor:
                                                themeProvider.isDarkMode
                                                ? const Color(0xFF2D1B69)
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.changeSurah,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Corner decoration widget for ornamental borders
class _CornerDecoration extends StatelessWidget {
  final double angleDeg;
  final String assetPath;
  final double size;

  const _CornerDecoration({
    required this.angleDeg,
    required this.assetPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angleDeg * math.pi / 180,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Image.asset(
              assetPath,
              width: size,
              height: size,
              fit: BoxFit.contain,

            );
          },
        ),
      ),
    );
  }
}
