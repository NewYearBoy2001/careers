import '../api/career_home_api_service.dart';
import '../models/career_node_home_model.dart';

class CareerHomeRepository {
  final CareerHomeApiService _apiService;

  CareerHomeRepository(this._apiService);

  Future<List<CareerNodeHomeModel>> getCareerNodes() async {
    return await _apiService.fetchCareerNodes();
  }
}