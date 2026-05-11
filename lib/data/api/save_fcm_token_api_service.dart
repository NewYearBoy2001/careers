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
    required String fcmToken,
    required String appVersion,
    required String model,
    required String modelName,
    required String modelVersion,
  }) async {
    try {
      await dio.post(
        ApiConstants.saveFcmToken,
        data: {
          'fcm_token': fcmToken,
          'app_version': appVersion,
          'model': model,
          'model_name': modelName,
          'model_version': modelVersion,
        },
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}