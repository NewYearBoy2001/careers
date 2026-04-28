import '../api/saved_college_api_service.dart';

class SavedCollegeRepository {
  final SavedCollegeApiService _apiService;

  SavedCollegeRepository(this._apiService);

  Future<String> saveCollege(String collegeId, String phone) async {
    try {
      final response = await _apiService.saveCollege(collegeId, phone);
      return response['message'] ?? 'College saved successfully';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> removeSavedCollege(String collegeId, String phone) async {
    try {
      final response = await _apiService.removeSavedCollege(collegeId, phone);
      return response['message'] ?? 'College removed from saved list';
    } catch (e) {
      throw e.toString();
    }
  }

}