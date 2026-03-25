import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/network/api_error_handler.dart';
import '../../data/models/api_response.dart';
import '../models/college_model.dart';
import '../../utils/prefs/auth_local_storage.dart';

class CollegeApiService {
  final Dio _dio;

  CollegeApiService(AuthLocalStorage authStorage)
      : _dio = BaseDioClient(authStorage: authStorage).dio;

  Future<ApiResponse<List<CollegeModel>>> searchColleges({
    String? keyword,
    String? location,
    int page = 1,
    int perPage = 7,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.searchColleges,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        data: {
          'keyword': keyword ?? '',
          'location': location ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == '1') {
          final collegesData = data['data']['colleges'] as List?;

          if (collegesData == null || collegesData.isEmpty) {
            return ApiResponse(
              success: true,
              statusCode: 200,
              message: data['message'] ?? 'No colleges found',
              data: [],
              currentPage: int.tryParse(data['data']['current_page'].toString()) ?? 1,
              lastPage: int.tryParse(data['data']['last_page'].toString()) ?? 1,
              totalColleges: int.tryParse(data['data']['total_colleges'].toString()) ?? 0,
            );
          }

          final colleges = collegesData
              .map((json) => CollegeModel.fromJson(json))
              .toList();

          return ApiResponse(
            success: true,
            statusCode: 200,
            message: data['message'] ?? 'Colleges fetched successfully',
            data: colleges,
            currentPage: int.tryParse(data['data']['current_page'].toString()) ?? 1,
            lastPage: int.tryParse(data['data']['last_page'].toString()) ?? 1,
            totalColleges: int.tryParse(data['data']['total_colleges'].toString()) ?? 0,
          );
        } else {
          return ApiResponse(
            success: false,
            statusCode: response.statusCode ?? 400,
            message: data['message'] ?? 'Failed to fetch colleges',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          statusCode: response.statusCode ?? 400,
          message: 'Failed to fetch colleges',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        statusCode: e.response?.statusCode ?? 500,
        message: ApiErrorHandler.handleDioError(e),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<CollegeModel>> getCollegeDetails(String id) async {
    try {
      final response = await _dio.post(
        ApiConstants.collegeDetails,
        data: {'id': id},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == '1') {
          final college = CollegeModel.fromJson(data['data']['college']);

          return ApiResponse(
            success: true,
            statusCode: 200,
            message: data['message'] ?? 'College details fetched successfully',
            data: college,
          );
        } else {
          return ApiResponse(
            success: false,
            statusCode: response.statusCode ?? 400,
            message: data['message'] ?? 'Failed to fetch college details',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          statusCode: response.statusCode ?? 400,
          message: 'Failed to fetch college details',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        statusCode: e.response?.statusCode ?? 500,
        message: ApiErrorHandler.handleDioError(e),
      );
    } catch (e) {
      // ✅ FIX: Catch any other errors
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}