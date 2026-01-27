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
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.searchColleges,
        data: {
          'keyword': keyword ?? '',
          'location': location ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == '1') {
          // ✅ FIX: Handle null colleges data
          final collegesData = data['data']['colleges'] as List?;

          // If colleges is null or empty, return empty list
          if (collegesData == null || collegesData.isEmpty) {
            return ApiResponse(
              success: true,
              statusCode: 200,
              message: data['message'] ?? 'No colleges found',
              data: [], // Return empty list instead of crashing
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
      // ✅ FIX: Catch any other errors (like type casting)
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