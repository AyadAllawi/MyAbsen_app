import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _keyLogin = "isLogin";

  // Simpan status login
  static Future<void> setLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, value);
  }

  // Ambil status login
  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin);
  }

  // Hapus status login
  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogin);
  }
}
