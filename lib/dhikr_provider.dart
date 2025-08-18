import 'package:flutter/material.dart';

class DhikrData {
  final String title;
  final String titleArabic;
  final String subtitle;
  final String subtitleArabic;
  final String arabic;
  final int target;
  final int currentCount;
  final DateTime savedAt;

  DhikrData({
    required this.title,
    required this.titleArabic,
    required this.subtitle,
    required this.subtitleArabic,
    required this.arabic,
    required this.target,
    required this.currentCount,
    required this.savedAt,
  });

  double get progress => target > 0 ? currentCount / target : 0.0;

  bool get isCompleted => currentCount >= target;
}

class DhikrProvider with ChangeNotifier {
  DhikrData? _currentDhikr;

  DhikrData? get currentDhikr => _currentDhikr;

  bool get hasSavedDhikr => _currentDhikr != null;

  double get dhikrProgress => _currentDhikr?.progress ?? 0.0;

  String get dhikrProgressText {
    if (_currentDhikr == null) return '0 out of 0';
    return '${_currentDhikr!.currentCount} out of ${_currentDhikr!.target}';
  }

  void saveDhikr({
    required String title,
    required String titleArabic,
    required String subtitle,
    required String subtitleArabic,
    required String arabic,
    required int target,
    required int currentCount,
  }) {
    _currentDhikr = DhikrData(
      title: title,
      titleArabic: titleArabic,
      subtitle: subtitle,
      subtitleArabic: subtitleArabic,
      arabic: arabic,
      target: target,
      currentCount: currentCount,
      savedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void clearDhikr() {
    _currentDhikr = null;
    notifyListeners();
  }

  void updateProgress(int newCount) {
    if (_currentDhikr != null) {
      _currentDhikr = DhikrData(
        title: _currentDhikr!.title,
        titleArabic: _currentDhikr!.titleArabic,
        subtitle: _currentDhikr!.subtitle,
        subtitleArabic: _currentDhikr!.subtitleArabic,
        arabic: _currentDhikr!.arabic,
        target: _currentDhikr!.target,
        currentCount: newCount,
        savedAt: _currentDhikr!.savedAt,
      );
      notifyListeners();
    }
  }
}
