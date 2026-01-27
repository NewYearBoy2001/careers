import '../api/admission_banner_api.dart';
import '../../data/models/api_response.dart';
import '../models/admission_banner.dart';

class AdmissionRepository {
  final AdmissionApiService _apiService;

  AdmissionRepository(this._apiService);

  Future<ApiResponse<List<AdmissionBanner>>> fetchBanners() async {
    return await _apiService.getBanners();
  }
}