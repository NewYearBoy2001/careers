import 'package:dio/dio.dart';
import '../models/college_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/network/api_error_handler.dart';
import '../../utils/prefs/auth_local_storage.dart';

class SavedCollegesPageResult {
  final List<CollegeModel> colleges;
  final int currentPage;
  final int lastPage;

  SavedCollegesPageResult({
    required this.colleges,
    required this.currentPage,
    required this.lastPage,
  });
}

class SavedCollegesListApiService {
  final BaseDioClient _dioClient;
  final AuthLocalStorage _authStorage; // ADD
  static const int _perPage = 10;

  SavedCollegesListApiService(AuthLocalStorage authStorage)
      : _dioClient = BaseDioClient(),  // CHANGE: no authStorage needed
        _authStorage = authStorage;    // ADD

  Future<SavedCollegesPageResult> getSavedColleges({int page = 1}) async {
    try {
      final phone = await _authStorage.getPhone(); // ADD

      final response = await _dioClient.dio.post( // CHANGE: GET -> POST
        ApiConstants.savedColleges,
        queryParameters: {
          'page': page,
          'per_page': _perPage,
        },
        data: {'phone': phone ?? ''}, // ADD
      );

      if (response.statusCode == 200 && response.data['status'] == "1") {
        final data = response.data['data'];
        final List<dynamic> collegesJson = data['colleges'] ?? [];

        return SavedCollegesPageResult(
          colleges: collegesJson.map((json) => CollegeModel.fromJson(json)).toList(),
          currentPage: int.tryParse(data['current_page'].toString()) ?? page,
          lastPage: int.tryParse(data['last_page'].toString()) ?? 1,
        );
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