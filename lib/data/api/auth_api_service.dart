import 'package:dio/dio.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/network/api_error_handler.dart';
import '../../constants/api_constants.dart';
import '../models/login_response_model.dart';
import '../models/api_response.dart';
import '../models/signup_response_model.dart';

class AuthApiService extends BaseDioClient {
  Future<ApiResponse<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      final json = response.data;
      final success = json['status'] == "1";

      return ApiResponse<LoginResponseModel>(
        success: success,
        statusCode: response.statusCode ?? 0,
        message: json['message'] ?? '',
        data: success
            ? LoginResponseModel.fromJson(json['data'])
            : null,
      );
    } on DioException catch (e) {
      return ApiResponse<LoginResponseModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: ApiErrorHandler.handleDioError(e),
      );
    }
  }

  Future<ApiResponse<SignupResponseModel>> signup({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.signup,
        data: body,
      );

      final json = response.data;
      final success = json['status'] == "1";

      return ApiResponse<SignupResponseModel>(
        success: success,
        statusCode: response.statusCode ?? 0,
        message: json['message'] ?? '',
        data: success
            ? SignupResponseModel.fromJson(json['data'])
            : null,
      );
    } on DioException catch (e) {
      return ApiResponse<SignupResponseModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: ApiErrorHandler.handleDioError(e),
      );
    }
  }

}
