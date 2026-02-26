import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../../utils/prefs/auth_local_storage.dart';
import '../../utils/network/base_dio_client.dart';

class ForgotPasswordApiService {
  late final Dio _dio;

  ForgotPasswordApiService() {
    _dio = BaseDioClient().dio;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
      },
    );
    return response.data;
  }
}