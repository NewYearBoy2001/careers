import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../api/save_fcm_token_api_service.dart';

class SaveFcmTokenRepository {
  final SaveFcmTokenApiService _api;

  SaveFcmTokenRepository(this._api);

  Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return android.id;
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? 'ios_unknown';
    }
    return 'unknown';
  }

  Future<void> saveFcmToken(String fcmKey) async {
    final deviceId = await getDeviceId();
    final platform = Platform.isIOS ? 'ios' : 'android';
    await _api.saveFcmToken(
      deviceId: deviceId,
      fcmKey: fcmKey,
      platform: platform,
    );
  }
}