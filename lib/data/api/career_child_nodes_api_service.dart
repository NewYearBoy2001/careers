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

  Future<List<CareerNode>> fetchChildNodes(String parentId) async {
    try {
      final response = await _dio.post(
        ApiConstants.careerChildNodes,
        data: {'id': parentId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == '1' && data['data'] != null) {
          final childNodes = data['data']['child_nodes'] as List<dynamic>?;
          if (childNodes != null) {
            return childNodes
                .map((node) => CareerNode.fromJson(node))
                .toList();
          }
        }
      }

      throw Exception(response.data?['message'] ?? 'Failed to fetch child nodes');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}