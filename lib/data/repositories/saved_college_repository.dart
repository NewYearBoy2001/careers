import '../api/saved_college_api_service.dart';

class SavedCollegeRepository {
  final SavedCollegeApiService _apiService;

  SavedCollegeRepository(this._apiService);

  /// Save a college
  Future<String> saveCollege(String collegeId) async {
    try {
      final response = await _apiService.saveCollege(collegeId);
      return response['message'] ?? 'College saved successfully';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Remove a saved college
  Future<String> removeSavedCollege(String collegeId) async {
    try {
      final response = await _apiService.removeSavedCollege(collegeId);
      return response['message'] ?? 'College removed from saved list';
    } catch (e) {
      throw e.toString();
    }
  }

}