import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en'); // Default to English

  Locale get currentLocale => _currentLocale;

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isArabic => _currentLocale.languageCode == 'ar';

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLocale = _currentLocale.languageCode == 'en' 
        ? const Locale('ar') 
        : const Locale('en');
    notifyListeners();
  }

  // Text direction
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  // Language names
  String get currentLanguageName => isEnglish ? 'English' : 'العربية';
  String get oppositeLanguageName => isEnglish ? 'العربية' : 'English';
} 