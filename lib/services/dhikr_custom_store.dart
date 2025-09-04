import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrCustomStore {
  static const String _storageKey = 'custom_dhikr_presets_v1';

  // Load custom dhikr presets from local storage
  static Future<List<Map<String, String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save custom dhikr presets to local storage
  static Future<void> save(List<Map<String, String>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items);
    await prefs.setString(_storageKey, raw);
  }

  // Append a single custom item
  static Future<void> add(Map<String, String> item) async {
    final list = await load();
    list.add(item);
    await save(list);
  }

  // Clear all custom items (not used, but handy for maintenance)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

