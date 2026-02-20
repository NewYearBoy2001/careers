import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../models/career_banner_model.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import '../../utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/api_error_handler.dart';

class CareerBannerApiService {
  late final BaseDioClient _dioClient;

  CareerBannerApiService(AuthLocalStorage authStorage) {
    _dioClient = BaseDioClient(authStorage: authStorage);
  }

  Future<CareerBannerResponse> fetchCareerBanners() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.careerBanners);
      return CareerBannerResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Unexpected error occurred';
    }
  }
}