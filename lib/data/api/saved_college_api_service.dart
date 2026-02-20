import 'package:dio/dio.dart';
import '../../utils/prefs/auth_local_storage.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/network/api_error_handler.dart';
import '../../constants/api_constants.dart';

class SavedCollegeApiService {
  late final Dio dio;

  SavedCollegeApiService(AuthLocalStorage authStorage) {
    final baseDioClient = BaseDioClient(authStorage: authStorage);
    dio = baseDioClient.dio;
  }


  /// Save a college
  Future<Map<String, dynamic>> saveCollege(String collegeId) async {
    try {
      final response = await dio.post(
        ApiConstants.saveCollege,
        data: {'college_id': collegeId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Remove a saved college
  Future<Map<String, dynamic>> removeSavedCollege(String collegeId) async {
    try {
      final response = await dio.delete(
        ApiConstants.removeSavedCollege,
        data: {'college_id': collegeId},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }


}