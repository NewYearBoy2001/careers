import 'package:dio/dio.dart';
import '../../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/network/api_error_handler.dart';

class NotificationApiService extends BaseDioClient {
  NotificationApiService(AuthLocalStorage authStorage)
      : super(authStorage: authStorage);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}