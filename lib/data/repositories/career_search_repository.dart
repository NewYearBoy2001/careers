import '../api/career_search_api_service.dart';
import '../models/career_node_model.dart';

class CareerSearchRepository {
  final CareerSearchApiService _apiService;

  CareerSearchRepository(this._apiService);

  /// Search careers by keyword
  Future<SearchCareersResponse> searchCareers(String keyword, {int page = 1, int perPage = 10}) {
    return _apiService.searchCareers(keyword, page: page, perPage: perPage);
  }

  /// Get career node details
  Future<CareerNodeDetails> getCareerNodeDetails(String careerNodeId) async {
    return await _apiService.getCareerNodeDetails(careerNodeId);
  }
}