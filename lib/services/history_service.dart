import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/material_estimate.dart';

/// Persists and retrieves the last [maxEntries] estimates locally.
class HistoryService {
  HistoryService._();

  static const _key = 'estimate_history_v1';
  static const int maxEntries = 20;

  static Future<List<MaterialEstimate>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final result = <MaterialEstimate>[];
    for (final item in raw) {
      try {
        result.add(
            MaterialEstimate.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // Skip corrupted entries silently
      }
    }
    return result;
  }

  static Future<void> save(MaterialEstimate estimate) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.insert(0, jsonEncode(estimate.toJson()));
    if (existing.length > maxEntries) {
      existing.removeRange(maxEntries, existing.length);
    }
    await prefs.setStringList(_key, existing);
  }

  static Future<void> remove(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < existing.length) {
      existing.removeAt(index);
      await prefs.setStringList(_key, existing);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
