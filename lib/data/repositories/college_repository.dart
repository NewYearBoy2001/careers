import '../api/college_api_service.dart';
import '../../data/models/api_response.dart';
import '../models/college_model.dart';

class CollegeRepository {
  final CollegeApiService _apiService;

  CollegeRepository(this._apiService);

  Future<ApiResponse<List<CollegeModel>>> searchColleges({
    String? keyword,
    String? location,
  }) async {
    return await _apiService.searchColleges(
      keyword: keyword,
      location: location,
    );
  }

  Future<ApiResponse<CollegeModel>> getCollegeDetails(String id) async {
    return await _apiService.getCollegeDetails(id);
  }
}