import 'package:careers/utils/network/api_error_handler.dart';
import 'package:dio/dio.dart';
import '../api/forgot_password_api_service.dart';

class ForgotPasswordRepository {
  final ForgotPasswordApiService _apiService;

  ForgotPasswordRepository(this._apiService);

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      return response['message'] ?? 'OTP sent to your email';
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await _apiService.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );
      return response['message'] ?? 'Password reset successful';
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}