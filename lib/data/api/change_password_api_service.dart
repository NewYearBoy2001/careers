import 'package:dio/dio.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/prefs/auth_local_storage.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/api_error_handler.dart';

class ChangePasswordApiService {
  final BaseDioClient _dioClient;

  ChangePasswordApiService(AuthLocalStorage authStorage)
      : _dioClient = BaseDioClient(authStorage: authStorage);

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }
}