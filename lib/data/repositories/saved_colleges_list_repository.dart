import '../api/saved_colleges_list_api_service.dart';
import '../models/college_model.dart';

class SavedCollegesListRepository {
  final SavedCollegesListApiService _apiService;

  SavedCollegesListRepository(this._apiService);

  Future<List<CollegeModel>> getSavedColleges() async {
    return await _apiService.getSavedColleges();
  }
}