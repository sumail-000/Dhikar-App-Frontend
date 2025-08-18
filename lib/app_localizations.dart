import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // English translations
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'salaamAli': 'Salaam, Ali!',
      'overallProgress': 'Overall Progress',
      'dhikrGoal': 'Dhikr Goal',
      'khitmaGoal': 'Khitma Goal',
      'dhikrOutOf': '50 Dhikr out of 100',
      'juzzOutOf': '15 Juzz out of 30',
      'currentStreak': 'Current Streak',
      'yourCurrentStreak': 'Your Current Streak',
      'days': '5 Days',
      'motivationalVerse': 'Motivational Verse',
      'verseText': 'Indeed, Allah is with those who fear Him and those who are doers of good.',
      'surahAnNahl': 'Surah An-Nahl',
      'home': 'Home',
      'dhikr': 'Dhikr',
      'khitma': 'Khitma',
      'groups': 'Groups',
      'profile': 'Profile',
      'accountInfo': 'Account Info.',
      'accountDetails': 'Account Details',
      'editProfile': 'Edit Profile',
      'languageAndDisplay': 'Language & Display',
      'chooseLanguage': 'Choose Language',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'reminderPreference': 'Reminder Preference',
      'dhikrReminder': 'Dhikr Reminder',
      'reminderSettings': 'Reminder Settings',
      'groupManagement': 'Group Management',
      'privacyAndNotification': 'Privacy & Notification',
      'accountControl': 'Account Control',
      'accountDeletionRequest': 'Account Deletion Request',
      'logout': 'Logout',
      'english': 'English',
      'arabic': 'العربية',
    },
    'ar': {
      'salaamAli': 'السلام عليك يا علي!',
      'overallProgress': 'التقدم العام',
      'dhikrGoal': 'هدف الذكر',
      'khitmaGoal': 'هدف الختمة',
      'dhikrOutOf': '٥٠ ذكر من أصل ١٠٠',
      'juzzOutOf': '١٥ جزء من أصل ٣٠',
      'currentStreak': 'السلسلة الحالية',
      'yourCurrentStreak': 'سلسلتك الحالية',
      'days': '٥ أيام',
      'motivationalVerse': 'الآية التحفيزية',
      'verseText': 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوْا وَالَّذِينَ هُمْ مُحْسِنُونَ',
      'surahAnNahl': 'سورة النحل',
      'home': 'الرئيسية',
      'dhikr': 'الذكر',
      'khitma': 'الختمة',
      'groups': 'المجموعات',
      'profile': 'الملف الشخصي',
      'accountInfo': 'معلومات الحساب',
      'accountDetails': 'تفاصيل الحساب',
      'editProfile': 'تعديل الملف الشخصي',
      'languageAndDisplay': 'اللغة والعرض',
      'chooseLanguage': 'اختر اللغة',
      'lightMode': 'الوضع الفاتح',
      'darkMode': 'الوضع الداكن',
      'reminderPreference': 'تفضيلات التذكير',
      'dhikrReminder': 'تذكير الذكر',
      'reminderSettings': 'إعدادات التذكير',
      'groupManagement': 'إدارة المجموعات',
      'privacyAndNotification': 'الخصوصية والإشعارات',
      'accountControl': 'التحكم في الحساب',
      'accountDeletionRequest': 'طلب حذف الحساب',
      'logout': 'تسجيل الخروج',
      'english': 'English',
      'arabic': 'العربية',
    },
  };

  String get salaamAli => _localizedValues[locale.languageCode]?['salaamAli'] ?? 'Salaam, Ali!';
  String get overallProgress => _localizedValues[locale.languageCode]?['overallProgress'] ?? 'Overall Progress';
  String get dhikrGoal => _localizedValues[locale.languageCode]?['dhikrGoal'] ?? 'Dhikr Goal';
  String get khitmaGoal => _localizedValues[locale.languageCode]?['khitmaGoal'] ?? 'Khitma Goal';
  String get dhikrOutOf => _localizedValues[locale.languageCode]?['dhikrOutOf'] ?? '50 Dhikr out of 100';
  String get juzzOutOf => _localizedValues[locale.languageCode]?['juzzOutOf'] ?? '15 Juzz out of 30';
  String get currentStreak => _localizedValues[locale.languageCode]?['currentStreak'] ?? 'Current Streak';
  String get yourCurrentStreak => _localizedValues[locale.languageCode]?['yourCurrentStreak'] ?? 'Your Current Streak';
  String get days => _localizedValues[locale.languageCode]?['days'] ?? '5 Days';
  String get motivationalVerse => _localizedValues[locale.languageCode]?['motivationalVerse'] ?? 'Motivational Verse';
  String get verseText => _localizedValues[locale.languageCode]?['verseText'] ?? 'Indeed, Allah is with those who fear Him and those who are doers of good.';
  String get surahAnNahl => _localizedValues[locale.languageCode]?['surahAnNahl'] ?? 'Surah An-Nahl';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get dhikr => _localizedValues[locale.languageCode]?['dhikr'] ?? 'Dhikr';
  String get khitma => _localizedValues[locale.languageCode]?['khitma'] ?? 'Khitma';
  String get groups => _localizedValues[locale.languageCode]?['groups'] ?? 'Groups';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get accountInfo => _localizedValues[locale.languageCode]?['accountInfo'] ?? 'Account Info.';
  String get accountDetails => _localizedValues[locale.languageCode]?['accountDetails'] ?? 'Account Details';
  String get editProfile => _localizedValues[locale.languageCode]?['editProfile'] ?? 'Edit Profile';
  String get languageAndDisplay => _localizedValues[locale.languageCode]?['languageAndDisplay'] ?? 'Language & Display';
  String get chooseLanguage => _localizedValues[locale.languageCode]?['chooseLanguage'] ?? 'Choose Language';
  String get lightMode => _localizedValues[locale.languageCode]?['lightMode'] ?? 'Light Mode';
  String get darkMode => _localizedValues[locale.languageCode]?['darkMode'] ?? 'Dark Mode';
  String get reminderPreference => _localizedValues[locale.languageCode]?['reminderPreference'] ?? 'Reminder Preference';
  String get dhikrReminder => _localizedValues[locale.languageCode]?['dhikrReminder'] ?? 'Dhikr Reminder';
  String get reminderSettings => _localizedValues[locale.languageCode]?['reminderSettings'] ?? 'Reminder Settings';
  String get groupManagement => _localizedValues[locale.languageCode]?['groupManagement'] ?? 'Group Management';
  String get privacyAndNotification => _localizedValues[locale.languageCode]?['privacyAndNotification'] ?? 'Privacy & Notification';
  String get accountControl => _localizedValues[locale.languageCode]?['accountControl'] ?? 'Account Control';
  String get accountDeletionRequest => _localizedValues[locale.languageCode]?['accountDeletionRequest'] ?? 'Account Deletion Request';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get arabic => _localizedValues[locale.languageCode]?['arabic'] ?? 'العربية';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 