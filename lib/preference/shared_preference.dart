import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String tokenKey = "token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  static const String userNameKey = "user_name";
  static const String batchKey = "batch";
  static const String loginKey = "login";

  static Future<void> saveUserData(
    String token,
    int userId,
    String email,
    String name,
    String batch,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userNameKey, name);
    await prefs.setString(batchKey, batch);
    await prefs.setBool(loginKey, true);
  }

  static void saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  static Future<String?> getBatch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(batchKey);
  }

  static Future<void> setBatch(String batch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(batchKey, batch);
  }

  static Future<bool?> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userNameKey);
    await prefs.setBool(loginKey, false);
  }
}