import 'dart:io';
import 'package:dio/dio.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/api_error_handler.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import '../../constants/api_constants.dart';

class SaveFcmTokenApiService extends BaseDioClient {
  SaveFcmTokenApiService(AuthLocalStorage authStorage)
      : super(authStorage: authStorage);

  Future<void> saveFcmToken({
    required String deviceId,
    required String fcmKey,
    required String platform,
  }) async {
    try {
      await dio.post(
        ApiConstants.saveFcmToken,
        data: {
          'device_id': deviceId,
          'fcm_key': fcmKey,
          'platform': platform,
        },
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}