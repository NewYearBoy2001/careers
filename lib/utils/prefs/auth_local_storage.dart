import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _userIdKey = 'user_id';
  static const _nameKey = 'name';
  static const _emailKey = 'email';
  static const _phoneKey = 'phone';
<<<<<<< HEAD
=======
  static const _onboardingKey = 'onboarding_complete';
>>>>>>> origin/careersguest

  Future<void> saveUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    if (name != null) await prefs.setString(_nameKey, name);
    if (email != null) await prefs.setString(_emailKey, email);
    if (phone != null) await prefs.setString(_phoneKey, phone);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async => null; // No auth token anymore

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<void> updateUserProfile({String? name, String? email, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_nameKey, name);
    if (phone != null) await prefs.setString(_phoneKey, phone);

    if (email != null && email.isNotEmpty) {
      await prefs.setString(_emailKey, email);
    } else {
      await prefs.remove(_emailKey);
    }
  }

  Future<Map<String, String?>> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString(_userIdKey),
      'name': prefs.getString(_nameKey),
      'email': prefs.getString(_emailKey),
      'phone': prefs.getString(_phoneKey),
    };
  }
<<<<<<< HEAD
=======

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
>>>>>>> origin/careersguest
}