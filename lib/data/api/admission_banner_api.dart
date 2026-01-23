import 'package:dio/dio.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/network/api_error_handler.dart';
import 'package:careers/data/models/admission_banner.dart';

class AdmissionApi {
  final Dio _dio = BaseDioClient().dio;

  Future<List<AdmissionBanner>> fetchBanners() async {
    try {
      final response = await _dio.get('/admision-banners');

      final bannersJson = response.data['data']['banners'] as List;

      return bannersJson
          .map((e) => AdmissionBanner.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
