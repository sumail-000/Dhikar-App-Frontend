import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dart:math' as math;

class WeredReadingScreen extends StatefulWidget {
  final List<String> selectedSurahs;
  final String pages;

  const WeredReadingScreen({
    super.key,
    required this.selectedSurahs,
    required this.pages,
  });

  @override
  State<WeredReadingScreen> createState() => _WeredReadingScreenState();
}

class _WeredReadingScreenState extends State<WeredReadingScreen> {
  int currentPageIndex = 0;
  List<Map<String, dynamic>> surahData = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Hardcoded surah list with Arabic names
  static const List<Map<String, String>> _surahs = [
    {'name': 'Al-Fatihah', 'arabic': 'الفاتحة', 'subtitle': 'The Opening'},
    {'name': 'Al-Baqarah', 'arabic': 'البقرة', 'subtitle': 'The Cow'},
    {'name': 'Al Imran', 'arabic': 'آل عمران', 'subtitle': 'The Family of Imran'},
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
    {'name': 'As-Saffat', 'arabic': 'الصافات', 'subtitle': 'Those who set the Ranks'},
    {'name': 'Sad', 'arabic': 'ص', 'subtitle': 'The Letter "Saad"'},
    {'name': 'Az-Zumar', 'arabic': 'الزمر', 'subtitle': 'The Troops'},
    {'name': 'Ghafir', 'arabic': 'غافر', 'subtitle': 'The Forgiver'},
    {'name': 'Fussilat', 'arabic': 'فصلت', 'subtitle': 'Explained in Detail'},
    {'name': 'Ash-Shuraa', 'arabic': 'الشورى', 'subtitle': 'The Consultation'},
    {'name': 'Az-Zukhruf', 'arabic': 'الزخرف', 'subtitle': 'The Ornaments of Gold'},
    {'name': 'Ad-Dukhan', 'arabic': 'الدخان', 'subtitle': 'The Smoke'},
    {'name': 'Al-Jathiyah', 'arabic': 'الجاثية', 'subtitle': 'The Crouching'},
    {'name': 'Al-Ahqaf', 'arabic': 'الأحقاف', 'subtitle': 'The Wind-Curved Sandhills'},
    {'name': 'Muhammad', 'arabic': 'محمد', 'subtitle': 'Muhammad'},
    {'name': 'Al-Fath', 'arabic': 'الفتح', 'subtitle': 'The Victory'},
    {'name': 'Al-Hujurat', 'arabic': 'الحجرات', 'subtitle': 'The Rooms'},
    {'name': 'Qaf', 'arabic': 'ق', 'subtitle': 'The Letter "Qaf"'},
    {'name': 'Adh-Dhariyat', 'arabic': 'الذاريات', 'subtitle': 'The Winnowing Winds'},
    {'name': 'At-Tur', 'arabic': 'الطور', 'subtitle': 'The Mount'},
    {'name': 'An-Najm', 'arabic': 'النجم', 'subtitle': 'The Star'},
    {'name': 'Al-Qamar', 'arabic': 'القمر', 'subtitle': 'The Moon'},
    {'name': 'Ar-Rahman', 'arabic': 'الرحمن', 'subtitle': 'The Beneficent'},
    {'name': 'Al-Waqiah', 'arabic': 'الواقعة', 'subtitle': 'The Inevitable'},
    {'name': 'Al-Hadid', 'arabic': 'الحديد', 'subtitle': 'The Iron'},
    {'name': 'Al-Mujadila', 'arabic': 'المجادلة', 'subtitle': 'The Pleading Woman'},
    {'name': 'Al-Hashr', 'arabic': 'الحشر', 'subtitle': 'The Exile'},
    {'name': 'Al-Mumtahanah', 'arabic': 'الممتحنة', 'subtitle': 'She that is to be examined'},
    {'name': 'As-Saff', 'arabic': 'الصف', 'subtitle': 'The Ranks'},
    {'name': 'Al-Jumuah', 'arabic': 'الجمعة', 'subtitle': 'The Congregation, Friday'},
    {'name': 'Al-Munafiqun', 'arabic': 'المنافقون', 'subtitle': 'The Hypocrites'},
    {'name': 'At-Taghabun', 'arabic': 'التغابن', 'subtitle': 'The Mutual Disillusion'},
    {'name': 'At-Talaq', 'arabic': 'الطلاق', 'subtitle': 'The Divorce'},
    {'name': 'At-Tahrim', 'arabic': 'التحريم', 'subtitle': 'The Prohibition'},
    {'name': 'Al-Mulk', 'arabic': 'الملك', 'subtitle': 'The Sovereignty'},
    {'name': 'Al-Qalam', 'arabic': 'القلم', 'subtitle': 'The Pen'},
    {'name': 'Al-Haqqah', 'arabic': 'الحاقة', 'subtitle': 'The Reality'},
    {'name': 'Al-Maarij', 'arabic': 'المعارج', 'subtitle': 'The Ascending Stairways'},
    {'name': 'Nuh', 'arabic': 'نوح', 'subtitle': 'Noah'},
    {'name': 'Al-Jinn', 'arabic': 'الجن', 'subtitle': 'The Jinn'},
    {'name': 'Al-Muzzammil', 'arabic': 'المزمل', 'subtitle': 'The Enshrouded One'},
    {'name': 'Al-Muddaththir', 'arabic': 'المدثر', 'subtitle': 'The Cloaked One'},
    {'name': 'Al-Qiyamah', 'arabic': 'القيامة', 'subtitle': 'The Resurrection'},
    {'name': 'Al-Insan', 'arabic': 'الإنسان', 'subtitle': 'The Man'},
    {'name': 'Al-Mursalat', 'arabic': 'المرسلات', 'subtitle': 'The Emissaries'},
    {'name': 'An-Naba', 'arabic': 'النبأ', 'subtitle': 'The Tidings'},
    {'name': 'An-Naziat', 'arabic': 'النازعات', 'subtitle': 'Those who drag forth'},
    {'name': 'Abasa', 'arabic': 'عبس', 'subtitle': 'He Frowned'},
    {'name': 'At-Takwir', 'arabic': 'التكوير', 'subtitle': 'The Overthrowing'},
    {'name': 'Al-Infitar', 'arabic': 'الانفطار', 'subtitle': 'The Cleaving'},
    {'name': 'Al-Mutaffifin', 'arabic': 'المطففين', 'subtitle': 'The Defrauding'},
    {'name': 'Al-Inshiqaq', 'arabic': 'الانشقاق', 'subtitle': 'The Splitting Open'},
    {'name': 'Al-Buruj', 'arabic': 'البروج', 'subtitle': 'The Mansions of the Stars'},
    {'name': 'At-Tariq', 'arabic': 'الطارق', 'subtitle': 'The Morning Star'},
    {'name': 'Al-Ala', 'arabic': 'الأعلى', 'subtitle': 'The Most High'},
    {'name': 'Al-Ghashiyah', 'arabic': 'الغاشية', 'subtitle': 'The Overwhelming'},
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
    {'name': 'At-Takathur', 'arabic': 'التكاثر', 'subtitle': 'The Rivalry in world increase'},
    {'name': 'Al-Asr', 'arabic': 'العصر', 'subtitle': 'The Declining Day, Epoch'},
    {'name': 'Al-Humazah', 'arabic': 'الهمزة', 'subtitle': 'The Traducer'},
    {'name': 'Al-Fil', 'arabic': 'الفيل', 'subtitle': 'The Elephant'},
    {'name': 'Quraysh', 'arabic': 'قريش', 'subtitle': 'Quraysh'},
    {'name': 'Al-Maun', 'arabic': 'الماعون', 'subtitle': 'The Small kindnesses'},
    {'name': 'Al-Kawthar', 'arabic': 'الكوثر', 'subtitle': 'The Abundance'},
    {'name': 'Al-Kafirun', 'arabic': 'الكافرون', 'subtitle': 'The Disbelievers'},
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
      
      final String jsonString = await rootBundle.loadString(
        'assets/hafsData_v2-0.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      print('🚀 DEBUG: JSON data loaded, total entries: ${jsonData.length}');
      
      // Get the selected surah name and find its number
      final selectedSurahName = widget.selectedSurahs.first;
      final int? surahNumber = surahNameToNumber[selectedSurahName];
      
      print('🔍 DEBUG: Selected surah name: "$selectedSurahName"');
      print('🔍 DEBUG: Mapped to surah number: $surahNumber');
      
      if (surahNumber == null) {
        setState(() {
          errorMessage = 'Could not find surah number for "$selectedSurahName". Please check the surah name.';
          isLoading = false;
        });
        return;
      }
      
      // Filter verses for the selected surah by number
      final surahVerses = jsonData.where((verse) {
        final Map<String, dynamic> v = verse as Map<String, dynamic>;
        final int surahNo = v['sura_no'] as int;
        return surahNo == surahNumber;
      }).toList();
      
      print('🚀 DEBUG: Found ${surahVerses.length} verses for surah number $surahNumber');
      
      if (surahVerses.isEmpty) {
        setState(() {
          errorMessage = 'No verses found for surah "$selectedSurahName" (number: $surahNumber)';
          isLoading = false;
        });
        return;
      }
      
      // Debug: Show some sample verses
      if (surahVerses.isNotEmpty) {
        final sampleVerse = surahVerses.first;
        print('🔍 DEBUG: Sample verse data:');
        print('   - Surah number: ${sampleVerse['sura_no']}');
        print('   - Surah name (EN): ${sampleVerse['sura_name_en']}');
        print('   - Surah name (AR): ${sampleVerse['sura_name_ar']}');
        print('   - Page: ${sampleVerse['page']}');
        print('   - Verse number: ${sampleVerse['aya_no']}');
      }
      
      // Group verses by page
      final Map<int, List<Map<String, dynamic>>> versesByPage = {};
      for (final verse in surahVerses) {
        final Map<String, dynamic> v = verse as Map<String, dynamic>;
        final int page = v['page'] as int;
        versesByPage.putIfAbsent(page, () => []).add(v);
      }
      
      print('🚀 DEBUG: Verses grouped into ${versesByPage.length} pages');
      print('🚀 DEBUG: Available pages: ${versesByPage.keys.toList()..sort()}');
      
      // Sort pages and get requested number of pages
      final sortedPages = versesByPage.keys.toList()..sort();
      final requestedPageCount = int.tryParse(widget.pages) ?? 1;
      final requestedPages = sortedPages.take(requestedPageCount).toList();
      
      print('🚀 DEBUG: Requested $requestedPageCount pages');
      print('🚀 DEBUG: Selected pages: $requestedPages');
      
      if (requestedPages.isEmpty) {
        setState(() {
          errorMessage = 'No pages available for the requested number of pages ($requestedPageCount)';
          isLoading = false;
        });
        return;
      }
      
      // Build page data structure
      final List<Map<String, dynamic>> pagesData = [];
      for (final pageNum in requestedPages) {
        final verses = versesByPage[pageNum]!;
        verses.sort((a, b) => (a['aya_no'] as int).compareTo(b['aya_no'] as int));
        
        print('🚀 DEBUG: Page $pageNum has ${verses.length} verses');
        
        pagesData.add({
          'pageNumber': pageNum,
          'verses': verses,
          'surahName': verses.first['sura_name_en'],
          'surahNameAr': verses.first['sura_name_ar'],
        });
      }
      
      print('✅ DEBUG: Successfully loaded ${pagesData.length} pages of data');
      
      setState(() {
        surahData = pagesData;
        isLoading = false;
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

  /// Clean verse text by removing verse ending markers
  String _cleanVerseText(String originalText) {
    // Remove verse ending markers - these are special Unicode characters
    String cleanedText = originalText;
    
    // Simple and effective approach: Remove the specific verse ending markers
    // that we see in the JSON data: ﰀ ﰁ ﰂ ﰃ ﰄ ﰅ ﰆ ﰇ
    final List<String> verseEndingMarkers = [
      'ﰀ', 'ﰁ', 'ﰂ', 'ﰃ', 'ﰄ', 'ﰅ', 'ﰆ', 'ﰇ', 'ﰈ', 'ﰉ',
      'ﰊ', 'ﰋ', 'ﰌ', 'ﰍ', 'ﰎ', 'ﰏ', 'ﰐ', 'ﰑ', 'ﰒ', 'ﰓ',
      'ﰔ', 'ﰕ', 'ﰖ', 'ﰗ', 'ﰘ', 'ﰙ', 'ﰚ', 'ﰛ', 'ﰜ', 'ﰝ'
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
    final isAlFatihah = verses.isNotEmpty && (verses.first['sura_no'] as int) == 1;
    
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
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            height: 1.0, // 100% line height
            letterSpacing: 0,
            color: Color(0xFF392852), // #392852
            fontWeight: FontWeight.w400,
          ),
        ),
      );
      
      // Add verse number in parentheses
      // For Al-Fatihah, use adjusted numbering (1, 2, 3, etc.)
      // For other surahs, use original numbering
      final int displayNumber = isAlFatihah ? displayVerseNumber : originalVerseNumber;
      spans.add(
        TextSpan(
          text: ' ($displayNumber) ',
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14, // Slightly smaller for verse numbers
            height: 1.0,
            color: Color(0xFF392852),
            fontWeight: FontWeight.w400,
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
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              height: 1.0,
            ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFF4A148C),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF4A148C),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        languageProvider.isArabic ? 'العودة' : 'Go Back',
                      ),
                    ),
                  ],
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
                  // Background image
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                                  languageProvider.isArabic
                                      ? 'الورد اليومي'
                                      : 'Daily Wered',
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
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous page button
                              IconButton(
                                onPressed: currentPageIndex > 0 ? _previousPage : null,
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
                                languageProvider.isArabic
                                    ? 'الصفحة ${currentPageIndex + 1} من ${surahData.length}'
                                    : 'Page ${currentPageIndex + 1} of ${surahData.length}',
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
                                onPressed: currentPageIndex < surahData.length - 1 ? _nextPage : null,
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
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                // Main content container
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
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
                                      mainAxisSize: MainAxisSize.min, // Make column size fit content
                                      children: [
                                        if (currentPageContent != null) ...[
                                          // Surah title - using hardcoded Arabic name with proper typography
                                          Text(
                                            _getArabicSurahName(widget.selectedSurahs.first) ?? currentPageContent!['surahNameAr'],
                                            style: const TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 36,
                                              height: 1.0, // 100% line height
                                              letterSpacing: 0,
                                              color: Color(0xFF392852), // #392852
                                              fontWeight: FontWeight.w400, // Regular weight
                                            ),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const SizedBox(height: 20), // Equal spacing before Bismillah
                                          
                                          // Standard Bismillah - only show on first page
                                          if (currentPageIndex == 0) const Text(
                                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                            style: TextStyle(
                                              fontFamily: 'Amiri',
                                              fontSize: 16,
                                              height: 1.0, // 100% line height
                                              letterSpacing: 0,
                                              color: Color(0xFF392852), // #392852
                                              fontWeight: FontWeight.w400, // Regular weight
                                            ),
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const SizedBox(height: 20), // Equal spacing after Bismillah
                                          
                                          // Verses - continuous flow with inline numbers and center alignment
                                          RichText(
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            text: TextSpan(
                                              children: _buildVerseSpans(currentPageContent!['verses']),
                                            ),
                                          ),
                                        ] else
                                          Text(
                                            languageProvider.isArabic
                                                ? 'لا يوجد محتوى للعرض'
                                                : 'No content to display',
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
                                const Positioned(
                                  top: -8,
                                  left: -8,
                                  child: _CornerDecoration(
                                    angleDeg: 0,
                                    assetPath: 'assets/background_elements/9.png',
                                    size: 45,
                                  ),
                                ),
                                // Top-right corner (EDGE-ALIGNED)
                                const Positioned(
                                  top: -8,
                                  right: -8,
                                  child: _CornerDecoration(
                                    angleDeg: 90,
                                    assetPath: 'assets/background_elements/9.png',
                                    size: 45,
                                  ),
                                ),
                                // Bottom-left corner (EDGE-ALIGNED)
                                const Positioned(
                                  bottom: -8,
                                  left: -8,
                                  child: _CornerDecoration(
                                    angleDeg: 270,
                                    assetPath: 'assets/background_elements/9.png',
                                    size: 45,
                                  ),
                                ),
                                // Bottom-right corner (EDGE-ALIGNED)
                                const Positioned(
                                  bottom: -8,
                                  right: -8,
                                  child: _CornerDecoration(
                                    angleDeg: 180,
                                    assetPath: 'assets/background_elements/9.png',
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                        // Action buttons - compact
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            children: [
                              // Save Wered button - hidden but not removed
                              // Expanded(
                              //   child: SizedBox(
                              //     height: 42,
                              //     child: ElevatedButton(
                              //       onPressed: () {
                              //         // Handle save wered
                              //         ScaffoldMessenger.of(context).showSnackBar(
                              //           SnackBar(
                              //             content: Text(
                              //               languageProvider.isArabic
                              //                   ? 'تم حفظ الورد بنجاح!'
                              //                   : 'Wered saved successfully!',
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: const Color(0xFFF7F3E8),
                              //         foregroundColor: const Color(0xFF2D1B69),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(10),
                              //         ),
                              //       ),
                              //       child: Text(
                              //         languageProvider.isArabic
                              //             ? 'حفظ الورد'
                              //             : 'Save Wered',
                              //         style: const TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(width: 8),
                              // Change Surah button - now takes full width
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF7F3E8),
                                      foregroundColor: const Color(0xFF2D1B69),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'تغيير السورة'
                                          : 'Change Surah',
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
