import '../api/career_child_nodes_api_service.dart';
import '../models/career_node_model.dart';

class CareerChildNodesRepository {
  final CareerChildNodesApiService _apiService;

  CareerChildNodesRepository(this._apiService);

  Future<List<CareerNode>> getChildNodes(String parentId) async {
    return await _apiService.fetchChildNodes(parentId);
  }
}