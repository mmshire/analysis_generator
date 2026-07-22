import 'package:shared_preferences/shared_preferences.dart';

/// Saves and loads the user's login token so they stay logged in
/// between app restarts.
class StorageService {
  static const _tokenKey = 'auth_token';
  static const _nameKey  = 'user_name';
  static const _phoneKey = 'user_phone';

  static Future<void> saveAuth({
    required String token,
    required String phone,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
    if (name != null) await prefs.setString(_nameKey, name);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
