import '../api/career_child_nodes_api_service.dart';
import '../models/career_node_model.dart';

class CareerChildNodesRepository {
  final CareerChildNodesApiService _apiService;

  CareerChildNodesRepository(this._apiService);

  Future<CareerChildNodesResponse> getChildNodes(
      String parentId, {
        int page = 1,
        int perPage = 10,
      }) async {
    return await _apiService.fetchChildNodes(
      parentId,
      page: page,
      perPage: perPage,
    );
  }
}