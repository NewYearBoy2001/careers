import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import '../models/article_model.dart';

class ArticleApiService extends BaseDioClient {
  ArticleApiService(AuthLocalStorage authStorage)
      : super(authStorage: authStorage);

  Future<Map<String, dynamic>> fetchArticles({int page = 1, int perPage = 10}) async {
    final response = await dio.get(
      ApiConstants.articles,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = response.data['data'] as List;
    final total = response.data['pagination']['total'] as int;
    return {
      'articles': data.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList(),
      'total': total,
    };
  }

  Future<Map<String, dynamic>> searchArticles({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await dio.post(
      ApiConstants.searchArticles,
      queryParameters: {'page': page, 'per_page': perPage},
      data: {'query': query},
    );
    final data = response.data['data'];
    final articles = (data['articles'] as List)
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = int.parse(data['total'].toString());
    return {'articles': articles, 'total': total};
  }
}