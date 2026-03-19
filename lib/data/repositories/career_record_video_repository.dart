import '../models/career_record_video_model.dart';
import '../api/career_record_video_api_service.dart';
import '../../utils/network/api_error_handler.dart';

class CareerRecordVideoRepository {
  final CareerRecordVideoApiService _apiService;

  CareerRecordVideoRepository(this._apiService);

  /// Returns the short home list (no pagination).
  Future<List<CareerRecordVideoModel>> fetchHomeVideos() async {
    try {
      final response = await _apiService.fetchHomeVideos();
      final data = response.data as Map<String, dynamic>;
      final videos = data['data']['videos'] as List<dynamic>;
      return videos
          .map((v) => CareerRecordVideoModel.fromJson(v as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e as dynamic));
    }
  }

  /// Returns one page of the full video list plus pagination meta.
  Future<CareerRecordVideoPageResult> fetchVideos({
    int page = 1,
    int perPage = 8,
  }) async {
    try {
      final response = await _apiService.fetchVideos(page: page, perPage: perPage);
      final data = response.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>;

      final videos = (inner['videos'] as List<dynamic>)
          .map((v) => CareerRecordVideoModel.fromJson(v as Map<String, dynamic>))
          .toList();

      return CareerRecordVideoPageResult(
        videos: videos,
        currentPage: int.parse(inner['current_page'].toString()),
        lastPage: int.parse(inner['last_page'].toString()),
        totalVideos: int.parse(inner['total_videos'].toString()),
      );
    } on Exception catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e as dynamic));
    }
  }
}

class CareerRecordVideoPageResult {
  final List<CareerRecordVideoModel> videos;
  final int currentPage;
  final int lastPage;
  final int totalVideos;

  bool get hasNextPage => currentPage < lastPage;

  const CareerRecordVideoPageResult({
    required this.videos,
    required this.currentPage,
    required this.lastPage,
    required this.totalVideos,
  });
}