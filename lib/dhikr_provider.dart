import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_client.dart';
import 'app_localizations.dart';

class DhikrData {
  final String id;
  final String title;
  final String titleArabic;
  final String subtitle;
  final String subtitleArabic;
  final String arabic;
  final int target;
  final int currentCount;
  final String status; // active | completed
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  DhikrData({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.subtitle,
    required this.subtitleArabic,
    required this.arabic,
    required this.target,
    required this.currentCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  double get progress => target > 0 ? currentCount / target : 0.0;

  bool get isCompleted => status == 'completed' || currentCount >= target;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'titleArabic': titleArabic,
        'subtitle': subtitle,
        'subtitleArabic': subtitleArabic,
        'arabic': arabic,
        'target': target,
        'currentCount': currentCount,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DhikrData.fromMap(Map<String, dynamic> map) => DhikrData(
        id: (map['id'] ?? '') as String,
        title: (map['title'] ?? '') as String,
        titleArabic: (map['titleArabic'] ?? (map['title'] ?? '')) as String,
        subtitle: (map['subtitle'] ?? '') as String,
        subtitleArabic: (map['subtitleArabic'] ?? (map['subtitle'] ?? '')) as String,
        arabic: (map['arabic'] ?? '') as String,
        target: (map['target'] ?? 0) as int,
        currentCount: (map['currentCount'] ?? 0) as int,
        status: (map['status'] ?? 'active') as String,
        createdAt: DateTime.tryParse((map['createdAt'] ?? '') as String) ?? DateTime.now(),
        updatedAt: DateTime.tryParse((map['updatedAt'] ?? '') as String) ?? DateTime.now(),
        completedAt: ((map['completedAt'] ?? '') as String).isNotEmpty
            ? DateTime.tryParse((map['completedAt'] as String))
            : null,
      );
}

class DhikrProvider with ChangeNotifier {
  static const String _storageKey = 'personal_dhikr_history_v1';

  final List<DhikrData> _history = [];

  List<DhikrData> get history => List.unmodifiable(_history);
  List<DhikrData> get ongoing => _history.where((e) => e.status == 'active').toList();
  List<DhikrData> get completed => _history.where((e) => e.status == 'completed').toList();

  int get aggregateCurrent => _history.fold(0, (sum, e) => sum + e.currentCount);
  int get aggregateTarget => _history.fold(0, (sum, e) => sum + (e.target > 0 ? e.target : 0));
  double get aggregateProgress => aggregateTarget > 0 ? aggregateCurrent / aggregateTarget : 0.0;

  // Backwards-compat helpers for existing screens
  DhikrData? get currentDhikr => ongoing.isNotEmpty ? ongoing.last : null;
  bool get hasSavedDhikr => ongoing.isNotEmpty;
  double get dhikrProgress => currentDhikr?.progress ?? 0.0;
  String dhikrProgressText(BuildContext context) {
    final app = AppLocalizations.of(context)!;
    if (currentDhikr == null) return '0 ${app.outOfWord} 0';
    return '${currentDhikr!.currentCount} ${app.outOfWord} ${currentDhikr!.target}';
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      // Backward compatibility: migrate single-slot storage if present
      final legacy = prefs.getString('personal_dhikr_v1');
      if (legacy != null && legacy.isNotEmpty) {
        try {
          final map = jsonDecode(legacy) as Map<String, dynamic>;
          final legacyEntry = DhikrData(
            id: _genId(),
            title: (map['title'] ?? '') as String,
            titleArabic: (map['titleArabic'] ?? (map['title'] ?? '')) as String,
            subtitle: (map['subtitle'] ?? '') as String,
            subtitleArabic: (map['subtitleArabic'] ?? (map['subtitle'] ?? '')) as String,
            arabic: (map['arabic'] ?? '') as String,
            target: (map['target'] ?? 0) as int,
            currentCount: (map['currentCount'] ?? 0) as int,
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            completedAt: null,
          );
          _history.add(legacyEntry);
          await prefs.remove('personal_dhikr_v1');
          await _persist();
        } catch (_) {}
      }
      notifyListeners();
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _history
        ..clear()
        ..addAll(list.map(DhikrData.fromMap));
      notifyListeners();
    } catch (_) {
      // ignore parse errors
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_history.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }

  String _genId() => DateTime.now().millisecondsSinceEpoch.toString();

  // Create or update a personal dhikr entry
  Future<String> upsertDhikr({
    String? id,
    required String title,
    required String titleArabic,
    required String subtitle,
    required String subtitleArabic,
    required String arabic,
    required int target,
    required int currentCount,
  }) async {
    final now = DateTime.now();
    if (id == null || !_history.any((e) => e.id == id)) {
      final entry = DhikrData(
        id: id ?? _genId(),
        title: title,
        titleArabic: titleArabic,
        subtitle: subtitle,
        subtitleArabic: subtitleArabic,
        arabic: arabic,
        target: target,
        currentCount: currentCount,
        status: currentCount >= target ? 'completed' : 'active',
        createdAt: now,
        updatedAt: now,
        completedAt: currentCount >= target ? now : null,
      );
      _history.add(entry);
      await _persist();
      // ignore: unawaited_futures
      ApiClient.instance.activityReading();
      notifyListeners();
      return entry.id;
    } else {
      final idx = _history.indexWhere((e) => e.id == id);
      final existing = _history[idx];
      final newCount = currentCount;
      final completed = newCount >= existing.target;
      _history[idx] = DhikrData(
        id: existing.id,
        title: title,
        titleArabic: titleArabic,
        subtitle: subtitle,
        subtitleArabic: subtitleArabic,
        arabic: arabic,
        target: target,
        currentCount: newCount,
        status: completed ? 'completed' : 'active',
        createdAt: existing.createdAt,
        updatedAt: now,
        completedAt: completed ? (existing.completedAt ?? now) : null,
      );
      await _persist();
      // ignore: unawaited_futures
      ApiClient.instance.activityReading();
      notifyListeners();
      return id;
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history.clear();
    await _persist();
    await prefs.remove('personal_dhikr_v1'); // cleanup legacy
    notifyListeners();
  }

  // Backwards-compat: clear the last ongoing entry
  Future<void> clearDhikr() async {
    if (currentDhikr != null) {
      await removeEntry(currentDhikr!.id);
    }
  }

  Future<void> removeEntry(String id) async {
    _history.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }
}
