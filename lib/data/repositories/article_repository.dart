import '../api/article_api_service.dart';
import '../models/article_model.dart';

class ArticleRepository {
  final ArticleApiService _api;
  ArticleRepository(this._api);

  Future<Map<String, dynamic>> fetchArticles({int page = 1, int perPage = 10}) =>
      _api.fetchArticles(page: page, perPage: perPage);

  Future<Map<String, dynamic>> searchArticles({
    required String query,
    int page = 1,
    int perPage = 10,
  }) => _api.searchArticles(query: query, page: page, perPage: perPage);
}