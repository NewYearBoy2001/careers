import 'package:dio/dio.dart';
import '../models/college_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/network/api_error_handler.dart';
import '../../utils/prefs/auth_local_storage.dart';

class SavedCollegesListApiService {
  final BaseDioClient _dioClient;

  SavedCollegesListApiService(AuthLocalStorage authStorage)
      : _dioClient = BaseDioClient(authStorage: authStorage);

  Future<List<CollegeModel>> getSavedColleges() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.savedColleges);

      if (response.statusCode == 200 && response.data['status'] == "1") {
        final List<dynamic> collegesJson = response.data['data']['colleges'] ?? [];
        return collegesJson.map((json) => CollegeModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch saved colleges');
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}