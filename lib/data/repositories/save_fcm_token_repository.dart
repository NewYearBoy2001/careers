import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../api/save_fcm_token_api_service.dart';

class SaveFcmTokenRepository {
  final SaveFcmTokenApiService _api;

  SaveFcmTokenRepository(this._api);

  Future<void> saveFcmToken(String fcmToken) async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    String model = 'unknown';
    String modelName = 'unknown';
    String modelVersion = 'unknown';

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      model = android.model;                          // e.g. SM-A325F
      modelName = '${android.manufacturer} ${android.model}'; // e.g. Samsung SM-A325F
      modelVersion = 'Android ${android.version.release}';    // e.g. Android 13
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      model = ios.utsname.machine;                   // e.g. iPhone14,2
      modelName = ios.name;                          // e.g. John's iPhone
      modelVersion = 'iOS ${ios.systemVersion}';     // e.g. iOS 17.0
    }

    await _api.saveFcmToken(
      fcmToken: fcmToken,
      appVersion: appVersion,
      model: model,
      modelName: modelName,
      modelVersion: modelVersion,
    );
  }
}