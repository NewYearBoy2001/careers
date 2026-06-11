import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:careers/utils/prefs/auth_local_storage.dart'; // adjust path as needed

// If you already import dart:io somewhere, you can also use Platform.isIOS.
// This approach uses Flutter's TargetPlatform to avoid dart:io dependency.

class IosStoreGuard {
  static bool get _isIos =>
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns true only when: platform is iOS AND stored flag is "1"
  static Future<bool> isIosStoredMode(AuthLocalStorage storage) async {
    if (!_isIos) return false;
    final flag = await storage.getStoredFlag();
    return flag == '1';
  }
}