import 'package:shared_preferences/shared_preferences.dart';
import '/data/models/user_model.dart';

class AuthLocalStorage {
  static const _userIdKey = 'user_id';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _roleKey = 'role';
  static const _tokenKey = 'auth_token';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userIdKey, user.userId);
    await prefs.setString(_nameKey, user.name);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_roleKey, user.role);
    await prefs.setString(_tokenKey, user.authToken);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }
}
