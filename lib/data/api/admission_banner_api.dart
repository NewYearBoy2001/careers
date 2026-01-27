import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/api_error_handler.dart';
import '../../data/models/api_response.dart';
import '../../utils/network/base_dio_client.dart';
import '../models/admission_banner.dart';

class AdmissionApiService {
  final BaseDioClient _dioClient = BaseDioClient();

  Future<ApiResponse<List<AdmissionBanner>>> getBanners() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.admissionBanners);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == '1') {
          final bannersJson = data['data']['banners'] as List;
          final banners = bannersJson
              .map((json) => AdmissionBanner.fromJson(json))
              .toList();

          return ApiResponse(
            success: true,
            statusCode: 200,
            message: data['message'] ?? 'Banners fetched successfully',
            data: banners,
          );
        }
      }

      return ApiResponse(
        success: false,
        statusCode: response.statusCode ?? 500,
        message: 'Failed to fetch banners',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        statusCode: e.response?.statusCode ?? 500,
        message: ApiErrorHandler.handleDioError(e),
      );
    }
  }
}