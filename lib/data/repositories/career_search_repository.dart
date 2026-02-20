import '../api/career_search_api_service.dart';
import '../models/career_node_model.dart';

class CareerSearchRepository {
  final CareerSearchApiService _apiService;

  CareerSearchRepository(this._apiService);

  /// Search careers by keyword
  Future<SearchCareersResponse> searchCareers(String keyword) async {
    return await _apiService.searchCareers(keyword);
  }

  /// Get career node details
  Future<CareerNodeDetails> getCareerNodeDetails(String careerNodeId) async {
    return await _apiService.getCareerNodeDetails(careerNodeId);
  }
}