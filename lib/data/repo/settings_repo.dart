import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepo {
  static const _darkMode = 'dark_mode';

  final SharedPreferences prefs;

  SettingsRepo(this.prefs);

  /// Dark Mode settings
  bool getDarkModeSetting() {
    return prefs.getBool(_darkMode) ?? false;
  }

  Future<void> setDarkModeSetting(bool isDarkMode) async {
    await prefs.setBool(_darkMode, isDarkMode);
  }
}