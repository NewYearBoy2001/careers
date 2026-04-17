import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';
import '../models/career_node_model.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/network/api_error_handler.dart';

class CareerChildNodesApiService {
  final Dio _dio;

  CareerChildNodesApiService(AuthLocalStorage authStorage)
      : _dio = BaseDioClient(authStorage: authStorage).dio;

  Future<CareerChildNodesResponse> fetchChildNodes(
      String parentId, {
        int page = 1,
        int perPage = 5,
        String? keyword,         // ADD THIS
      }) async {
    try {
      final Map<String, dynamic> body = {
        'id': int.tryParse(parentId) ?? parentId,
      };
      if (keyword != null && keyword.trim().isNotEmpty) {
        body['keyword'] = keyword.trim();           // ADD THIS
      }

      final response = await _dio.post(
        '${ApiConstants.careerChildNodes}?page=$page&per_page=$perPage',
        data: body,
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == '1') {
        return CareerChildNodesResponse.fromJson(response.data);
      }

      throw Exception(response.data?['message'] ?? 'Failed to fetch child nodes');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}