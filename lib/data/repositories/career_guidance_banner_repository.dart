import 'package:careers/data/api/career_guidance_banner_api_service.dart';
import 'package:careers/data/models/career_guidance_banner_model.dart';

class CareerGuidanceBannerRepository {
  final CareerGuidanceBannerApiService _api;

  CareerGuidanceBannerRepository(this._api);

  Future<List<CareerGuidanceBannerModel>> fetchBanners() => _api.fetchBanners();
}