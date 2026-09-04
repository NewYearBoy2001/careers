import 'package:careers/data/api/bottom_ads_api_service.dart';
import 'package:careers/data/models/bottom_ad_model.dart';

class BottomAdsRepository {
  final BottomAdsApiService apiService;

  BottomAdsRepository(this.apiService);

  Future<List<BottomAdModel>> getBottomAds() async {
    final raw = await apiService.fetchBottomAds();
    return raw.map((json) => BottomAdModel.fromJson(json)).toList();
  }
}