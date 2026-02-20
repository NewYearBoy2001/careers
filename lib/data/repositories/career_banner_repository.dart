import '../api/career_banner_api_service.dart';
import '../models/career_banner_model.dart';

class CareerBannerRepository {
  final CareerBannerApiService _apiService;

  CareerBannerRepository(this._apiService);

  Future<CareerBannerResponse> getCareerBanners() async {
    try {
      return await _apiService.fetchCareerBanners();
    } catch (e) {
      rethrow;
    }
  }
}