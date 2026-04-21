import 'package:dio/dio.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/constants/api_constants.dart';
import 'package:careers/utils/network/api_error_handler.dart';
import 'package:careers/data/models/career_guidance_banner_model.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';

class CareerGuidanceBannerApiService {
  late final Dio _dio;

  CareerGuidanceBannerApiService(AuthLocalStorage authStorage) {
    _dio = BaseDioClient(authStorage: authStorage).dio;
  }

  Future<List<CareerGuidanceBannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get(ApiConstants.careerGuidanceBanners);
      final data = response.data['data'];
      // Handle empty data object: {"data": {}} or missing 'banners' key
      if (data == null || data['banners'] == null) return [];
      final banners = data['banners'] as List;
      return banners.map((e) => CareerGuidanceBannerModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}