import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/network/api_error_handler.dart';

class CourseFeeApiService {
  late final Dio _dio;

  CourseFeeApiService(AuthLocalStorage authStorage) {
    _dio = BaseDioClient(authStorage: authStorage).dio;
  }

  Future<Map<String, dynamic>> fetchCourseFeeStructure(String courseId) async {
    try {
      final response = await _dio.post(
        ApiConstants.courseFeeStructure,
        data: {'course_id': int.tryParse(courseId) ?? courseId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}