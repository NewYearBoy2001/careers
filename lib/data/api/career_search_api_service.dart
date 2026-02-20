import 'package:dio/dio.dart';
import '../models/career_node_model.dart';
import '../../constants/api_constants.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';

class CareerSearchApiService extends BaseDioClient {
  CareerSearchApiService(AuthLocalStorage authStorage) : super(authStorage: authStorage);

  Future<SearchCareersResponse> searchCareers(String keyword) async {
    try {
      final response = await dio.post(
        ApiConstants.searchCareers,
        data: {
          'keyword': keyword,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == '1') {
        final data = response.data['data'] as Map<String, dynamic>;
        return SearchCareersResponse.fromJson(data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to search careers',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed information about a career node
  /// Returns comprehensive details including description, video, career options, etc.
  Future<CareerNodeDetails> getCareerNodeDetails(String careerNodeId) async {
    try {
      final response = await dio.post(
        ApiConstants.careerNodeDetails,
        data: {
          'id': careerNodeId,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == '1') {
        final careerdata = response.data['data']['careernode'] as Map<String, dynamic>;
        return CareerNodeDetails.fromJson(careerdata);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch career details',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}