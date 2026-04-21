import 'package:dio/dio.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/constants/api_constants.dart';
import 'package:careers/utils/network/api_error_handler.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';

class CareerGuidanceRegisterApiService {
  late final Dio _dio;

  CareerGuidanceRegisterApiService(AuthLocalStorage authStorage) {
    _dio = BaseDioClient(authStorage: authStorage).dio;
  }

  Future<String> register({
    required String bannerId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.careerGuidanceRegister,
        data: {
          'banner_id': int.parse(bannerId),
          'name': name,
          'email': email,
          'phone': phone,
        },
      );
      return response.data['data']['registration_id'].toString();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}