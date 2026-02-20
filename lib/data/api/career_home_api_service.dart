import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../models/career_node_home_model.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/network/api_error_handler.dart';

class CareerHomeApiService {
  final Dio _dio;

  // ✅ CHANGE: Remove AuthLocalStorage parameter
  CareerHomeApiService()
      : _dio = BaseDioClient().dio; // ✅ CHANGE: Don't pass authStorage

  Future<List<CareerNodeHomeModel>> fetchCareerNodes() async {
    try {
      final response = await _dio.get(ApiConstants.careerHomeNodes);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == '1' && data['data'] != null) {
          final careerNodes = data['data']['career_nodes'] as List<dynamic>?;
          if (careerNodes != null) {
            return careerNodes
                .map((node) => CareerNodeHomeModel.fromJson(node))
                .toList();
          }
        }
      }

      throw Exception(response.data?['message'] ?? 'Failed to fetch career nodes');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}