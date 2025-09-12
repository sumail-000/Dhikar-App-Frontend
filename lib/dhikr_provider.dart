import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_client.dart';
import 'app_localizations.dart';

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

  Map<String, dynamic> toMap() => {
        'title': title,
        'titleArabic': titleArabic,
        'subtitle': subtitle,
        'subtitleArabic': subtitleArabic,
        'arabic': arabic,
        'target': target,
        'currentCount': currentCount,
        'savedAt': savedAt.toIso8601String(),
      };

  factory DhikrData.fromMap(Map<String, dynamic> map) => DhikrData(
        title: (map['title'] ?? '') as String,
        titleArabic: (map['titleArabic'] ?? (map['title'] ?? '')) as String,
        subtitle: (map['subtitle'] ?? '') as String,
        subtitleArabic: (map['subtitleArabic'] ?? (map['subtitle'] ?? '')) as String,
        arabic: (map['arabic'] ?? '') as String,
        target: (map['target'] ?? 0) as int,
        currentCount: (map['currentCount'] ?? 0) as int,
        savedAt: DateTime.tryParse((map['savedAt'] ?? '') as String) ?? DateTime.now(),
      );
}

class DhikrProvider with ChangeNotifier {
  static const String _storageKey = 'personal_dhikr_v1';

  DhikrData? _currentDhikr;

  DhikrData? get currentDhikr => _currentDhikr;

  bool get hasSavedDhikr => _currentDhikr != null;

  bool get isInProgress => _currentDhikr != null && !_currentDhikr!.isCompleted;

  double get dhikrProgress => _currentDhikr?.progress ?? 0.0;

  String dhikrProgressText(BuildContext context) {
    final app = AppLocalizations.of(context)!;
    if (_currentDhikr == null) return '0 ${app.outOfWord} 0';
    return '${_currentDhikr!.currentCount} ${app.outOfWord} ${_currentDhikr!.target}';
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _currentDhikr = DhikrData.fromMap(map);
      notifyListeners();
    } catch (_) {
      // ignore invalid stored state
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentDhikr == null) {
      await prefs.remove(_storageKey);
    } else {
      final raw = jsonEncode(_currentDhikr!.toMap());
      await prefs.setString(_storageKey, raw);
    }
  }

  Future<void> saveDhikr({
    required String title,
    required String titleArabic,
    required String subtitle,
    required String subtitleArabic,
    required String arabic,
    required int target,
    required int currentCount,
  }) async {
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
    await _persist();
    // Best-effort server-side reading mark (does nothing if offline)
    // ignore: unawaited_futures
    ApiClient.instance.activityReading();
    notifyListeners();
  }

  Future<void> clearDhikr() async {
    _currentDhikr = null;
    await _persist();
    notifyListeners();
  }

  Future<void> updateProgress(int newCount) async {
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
      await _persist();
      // Best-effort server-side reading mark to contribute to streaks
      // ignore: unawaited_futures
      ApiClient.instance.activityReading();
      notifyListeners();
    }
  }
}
