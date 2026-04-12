import 'package:shared_preferences/shared_preferences.dart';
import '../models/region.dart';

/// Lightweight wrapper around SharedPreferences for user settings.
class PreferencesService {
  PreferencesService._();

  static const _regionKey = 'last_region';

  static Future<Region> getLastRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_regionKey);
    return Region.values.firstWhere(
      (r) => r.name == name,
      orElse: () => Region.other,
    );
  }

  static Future<void> saveLastRegion(Region region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region.name);
  }
}
