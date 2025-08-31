import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'wered_reading_screen.dart';

class DailyWeredScreen extends StatefulWidget {
  // Updated with real Quran data integration
  const DailyWeredScreen({super.key});

  @override
  State<DailyWeredScreen> createState() => _DailyWeredScreenState();
}

class _DailyWeredScreenState extends State<DailyWeredScreen> {
  final TextEditingController _pagesController = TextEditingController();
  String? _selectedSurahName;
  Map<String, dynamic>? _selectedSurahMetadata;
  bool _agreedToTerms = false;
  bool _showAllSurahs = false;
  
  // Real Quran data variables
  bool _isLoadingQuranData = false;
  String? _quranDataError;
  List<Map<String, dynamic>> _realSurahMetadata = [];
  Map<String, Map<String, dynamic>> _surahMetadataByName = {};

  final List<Map<String, String>> _surahs = [
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
    {'name': 'Al-Adiyat', 'arabic': 'العاديات', 'subtitle': 'The Courser'},
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

  @override
  void initState() {
    super.initState();
    _loadQuranMetadata();
  }

  Future<void> _loadQuranMetadata() async {
    setState(() {
      _isLoadingQuranData = true;
      _quranDataError = null;
    });

    try {
      print('🚀 DEBUG: Loading Quran metadata for surah selection...');
      
      final String jsonString = await rootBundle.loadString('assets/hafsData_v2-0.json');
      final List<dynamic> data = json.decode(jsonString);
      
      print('🚀 DEBUG: JSON data loaded, total entries: ${data.length}');
      
      // Process data to extract surah metadata
      final Map<int, Set<int>> pagesBySurah = {};
      final Map<int, String> englishNamesBySurah = {};
      final Map<int, String> arabicNamesBySurah = {};
      
      for (final item in data) {
        final Map<String, dynamic> verse = item as Map<String, dynamic>;
        final int surahNo = verse['sura_no'] as int;
        final String englishName = (verse['sura_name_en'] as String).trim();
        final String arabicName = (verse['sura_name_ar'] as String).trim();
        final int page = verse['page'] as int;
        
        pagesBySurah.putIfAbsent(surahNo, () => <int>{}).add(page);
        englishNamesBySurah[surahNo] = englishName;
        arabicNamesBySurah[surahNo] = arabicName;
      }
      
      print('🚀 DEBUG: Found data for ${pagesBySurah.length} surahs');
      
      // Build metadata list and mapping using our UI names
      final List<Map<String, dynamic>> metadataList = [];
      final Map<String, Map<String, dynamic>> metadataByName = {};
      
      // Map our UI surah names to their corresponding surah numbers
      final Map<String, int> surahNameToNumber = {
        'Al-Fatihah': 1, 'Al-Baqarah': 2, 'Al Imran': 3, 'An-Nisa': 4, 'Al-Maidah': 5,
        'Al-Anam': 6, 'Al-Araf': 7, 'Al-Anfal': 8, 'At-Tawbah': 9, 'Yunus': 10,
        'Hud': 11, 'Yusuf': 12, 'Ar-Rad': 13, 'Ibrahim': 14, 'Al-Hijr': 15,
        'An-Nahl': 16, 'Al-Isra': 17, 'Al-Kahf': 18, 'Maryam': 19, 'Taha': 20,
        'Al-Anbiya': 21, 'Al-Hajj': 22, 'Al-Muminun': 23, 'An-Nur': 24, 'Al-Furqan': 25,
        'Ash-Shuara': 26, 'An-Naml': 27, 'Al-Qasas': 28, 'Al-Ankabut': 29, 'Ar-Rum': 30,
        'Luqman': 31, 'As-Sajdah': 32, 'Al-Ahzab': 33, 'Saba': 34, 'Fatir': 35,
        'Ya-Sin': 36, 'As-Saffat': 37, 'Sad': 38, 'Az-Zumar': 39, 'Ghafir': 40,
        'Fussilat': 41, 'Ash-Shuraa': 42, 'Az-Zukhruf': 43, 'Ad-Dukhan': 44, 'Al-Jathiyah': 45,
        'Al-Ahqaf': 46, 'Muhammad': 47, 'Al-Fath': 48, 'Al-Hujurat': 49, 'Qaf': 50,
        'Adh-Dhariyat': 51, 'At-Tur': 52, 'An-Najm': 53, 'Al-Qamar': 54, 'Ar-Rahman': 55,
        'Al-Waqiah': 56, 'Al-Hadid': 57, 'Al-Mujadila': 58, 'Al-Hashr': 59, 'Al-Mumtahanah': 60,
        'As-Saff': 61, 'Al-Jumuah': 62, 'Al-Munafiqun': 63, 'At-Taghabun': 64, 'At-Talaq': 65,
        'At-Tahrim': 66, 'Al-Mulk': 67, 'Al-Qalam': 68, 'Al-Haqqah': 69, 'Al-Maarij': 70,
        'Nuh': 71, 'Al-Jinn': 72, 'Al-Muzzammil': 73, 'Al-Muddaththir': 74, 'Al-Qiyamah': 75,
        'Al-Insan': 76, 'Al-Mursalat': 77, 'An-Naba': 78, 'An-Naziat': 79, 'Abasa': 80,
        'At-Takwir': 81, 'Al-Infitar': 82, 'Al-Mutaffifin': 83, 'Al-Inshiqaq': 84, 'Al-Buruj': 85,
        'At-Tariq': 86, 'Al-Ala': 87, 'Al-Ghashiyah': 88, 'Al-Fajr': 89, 'Al-Balad': 90,
        'Ash-Shams': 91, 'Al-Layl': 92, 'Ad-Duhaa': 93, 'Ash-Sharh': 94, 'At-Tin': 95,
        'Al-Alaq': 96, 'Al-Qadr': 97, 'Al-Bayyinah': 98, 'Az-Zalzalah': 99, 'Al-Adiyat': 100,
        'Al-Qariah': 101, 'At-Takathur': 102, 'Al-Asr': 103, 'Al-Humazah': 104, 'Al-Fil': 105,
        'Quraysh': 106, 'Al-Maun': 107, 'Al-Kawthar': 108, 'Al-Kafirun': 109, 'An-Nasr': 110,
        'Al-Masad': 111, 'Al-Ikhlas': 112, 'Al-Falaq': 113, 'An-Nas': 114,
      };
      
      // For each surah in our UI list, get its metadata from the JSON
      for (final surah in _surahs) {
        final String uiName = surah['name']!;
        final int? surahNumber = surahNameToNumber[uiName];
        
        if (surahNumber != null && pagesBySurah.containsKey(surahNumber)) {
          final pages = pagesBySurah[surahNumber]!;
          final sortedPages = pages.toList()..sort();
          
          final metadata = {
            'surahNo': surahNumber,
            'englishName': uiName,  // Use our UI name
            'arabicName': surah['arabic']!,  // Use our UI Arabic name
            'firstPage': sortedPages.first,
            'lastPage': sortedPages.last,
            'totalPages': pages.length,
            'pages': sortedPages,
          };
          
          metadataList.add(metadata);
          metadataByName[uiName] = metadata;
          
          print('🔍 DEBUG: Mapped "$uiName" (surah #$surahNumber) -> ${pages.length} pages');
        } else {
          print('⚠️ DEBUG: Could not find data for "$uiName" (surah #$surahNumber)');
        }
      }
      
      // Sort by surah number
      metadataList.sort((a, b) => (a['surahNo'] as int).compareTo(b['surahNo'] as int));
      
      print('✅ DEBUG: Successfully loaded metadata for ${metadataList.length} surahs');
      
      setState(() {
        _realSurahMetadata = metadataList;
        _surahMetadataByName = metadataByName;
        _isLoadingQuranData = false;
      });
    } catch (e, stackTrace) {
      print('❌ DEBUG: Error loading Quran metadata: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      setState(() {
        _quranDataError = 'Failed to load Quran data: $e';
        _isLoadingQuranData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            backgroundColor: Colors.white,
            body: themeProvider.isDarkMode
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF251629),
                          Color(0xFF4C3B6E),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background image with full height coverage
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'assets/background_elements/3_background.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              cacheWidth: 800,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                        // Main content
                        SingleChildScrollView(
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Color(0xFFF7F3E8),
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          languageProvider.isArabic
                                              ? 'الورد اليومي'
                                              : 'Daily Wered',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFF7F3E8),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 48),
                                    ],
                                  ),
                                ),
                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    languageProvider.isArabic
                                        ? 'اشغل قلبك بذكر الله. اختر سورة لتبدأ رحلتك الروحية والسلام.'
                                        : 'Engage your heart in the remembrance of Allah. Select a Surah to begin your spiritual journey and peace.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFF7F3E8,
                                      ).withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Content
                                _buildContent(themeProvider, languageProvider),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/background_elements/3_background.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Color(0xFF205C3B),
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'الورد اليومي'
                                          : 'Daily Wered',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF205C3B),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            // Subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                languageProvider.isArabic
                                    ? 'اشغل قلبك بذكر الله. اختر سورة لتبدأ رحلتك الروحية والسلام.'
                                    : 'Engage your heart in the remembrance of Allah. Select a Surah to begin your spiritual journey and peace.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(
                                    0xFF205C3B,
                                  ).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Content
                            _buildContent(themeProvider, languageProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Choose surah input (moved to top)
          InkWell(
            onTap: () {
              setState(() {
                _showAllSurahs = !_showAllSurahs;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? const Color(0xFFB9A9D0).withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFB9A9D0).withOpacity(0.35)
                      : const Color(0xFFB6D1C2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSurahName == null
                        ? (languageProvider.isArabic
                              ? 'اختر السورة'
                              : 'Choose surah')
                        : languageProvider.isArabic
                        ? _selectedSurahMetadata!['arabicName']
                        : _selectedSurahName!,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFFF7F3E8).withOpacity(0.7)
                          : const Color(0xFF205C3B).withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    _showAllSurahs
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFF7F3E8).withOpacity(0.7)
                        : const Color(0xFF205C3B).withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Surah list
          if (_showAllSurahs)
            Builder(
              builder: (context) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _surahs.length,
                  itemBuilder: (context, index) {
                    final surah = _surahs[index];
                    final isSelected = _selectedSurahName == surah['name'];
                    
                    // Get real metadata for this surah if available
                    final realMetadata = _surahMetadataByName[surah['name']];
                    final pageCount = realMetadata?['totalPages'] ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (_selectedSurahName == surah['name']) {
                              // Deselect if already selected
                              _selectedSurahName = null;
                              _selectedSurahMetadata = null;
                            } else {
                              // Select new surah
                              _selectedSurahName = surah['name']!;
                              _selectedSurahMetadata = realMetadata;
                            }
                            // Clear pages input when selection changes
                            _pagesController.clear();
                            // Close dropdown after selection
                            _showAllSurahs = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4A148C)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      languageProvider.isArabic
                                          ? surah['arabic']!
                                          : surah['name']!,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF4A148C) : const Color(0xFF4A148C),
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      languageProvider.isArabic
                                          ? surah['name']!
                                          : surah['subtitle']!,
                                      style: TextStyle(
                                        color: const Color(0xFF4A148C).withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    languageProvider.isArabic
                                        ? surah['name']!
                                        : surah['arabic']!,
                                    style: const TextStyle(
                                      color: Color(0xFF4A148C),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (pageCount > 0)
                                    Text(
                                      languageProvider.isArabic
                                          ? '$pageCount صفحة'
                                          : '$pageCount pages',
                                      style: TextStyle(
                                        color: const Color(0xFF4A148C).withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4A148C),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 16),
          // Number of pages input with inline max pages display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? const Color(0xFFB9A9D0).withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? const Color(0xFFB9A9D0).withOpacity(0.35)
                    : const Color(0xFFB6D1C2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _pagesController,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? const Color(0xFFF7F3E8)
                    : const Color(0xFF205C3B),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: languageProvider.isArabic
                    ? 'عدد الصفحات'
                    : 'No. of pages',
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFF7F3E8).withOpacity(0.7)
                      : const Color(0xFF205C3B).withOpacity(0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                // Show max pages inline when surah is selected
                suffixText: () {
                  print('🔍 DEBUG: Suffix check - _selectedSurahMetadata != null: ${_selectedSurahMetadata != null}');
                  if (_selectedSurahMetadata != null) {
                    print('🔍 DEBUG: Selected metadata: ${_selectedSurahMetadata!['totalPages']}');
                    return languageProvider.isArabic
                        ? 'أقصى: ${_selectedSurahMetadata!['totalPages']}'
                        : 'Max: ${_selectedSurahMetadata!['totalPages']}';
                  }
                  return null;
                }(),
                suffixStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFF7F3E8).withOpacity(0.5)
                      : const Color(0xFF205C3B).withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                // Add validation to prevent exceeding max pages
                if (_selectedSurahMetadata != null)
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final int? value = int.tryParse(newValue.text);
                    if (value == null) return oldValue;
                    final int maxPages = _selectedSurahMetadata!['totalPages'] as int;
                    if (value > maxPages) {
                      return TextEditingValue(
                        text: maxPages.toString(),
                        selection: TextSelection.collapsed(offset: maxPages.toString().length),
                      );
                    }
                    return newValue;
                  }),
              ],
            ),
          ),
          // Privacy policy checkbox
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  activeColor: themeProvider.isDarkMode
                      ? const Color(0xFFF7F3E8)
                      : const Color(0xFF205C3B),
                  checkColor: themeProvider.isDarkMode
                      ? const Color(0xFF2D1B69)
                      : const Color(0xFFF7F3E8),
                  side: BorderSide(
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFF7F3E8).withOpacity(0.5)
                        : const Color(0xFF205C3B).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                Expanded(
                  child: Text(
                    languageProvider.isArabic
                        ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
                        : 'Agree to our Privacy Policy & Terms and Conditions',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFFF7F3E8).withOpacity(0.8)
                          : const Color(0xFF205C3B).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Start Wered button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _agreedToTerms && _selectedSurahName != null && _pagesController.text.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeredReadingScreen(
                              selectedSurahs: [_selectedSurahName!],
                              pages: _pagesController.text,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode
                      ? const Color(0xFFF7F3E8)
                      : const Color(0xFF205C3B),
                  disabledBackgroundColor: themeProvider.isDarkMode
                      ? const Color(0xFFF7F3E8).withOpacity(0.5)
                      : const Color(0xFF205C3B).withOpacity(0.5),
                  foregroundColor: themeProvider.isDarkMode
                      ? const Color(0xFF2D1B69)
                      : const Color(0xFFF7F3E8),
                  disabledForegroundColor: themeProvider.isDarkMode
                      ? const Color(0xFF2D1B69)
                      : const Color(0xFFF7F3E8),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  languageProvider.isArabic ? 'ابدأ الورد' : 'Start Wered',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }
}
