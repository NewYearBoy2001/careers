import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';
import 'package:careers/utils/network/base_dio_client.dart';

class CareerRecordVideoApiService extends BaseDioClient {
  CareerRecordVideoApiService(AuthLocalStorage authStorage)
      : super(authStorage: authStorage);

  /// Fetches the short home list (no pagination).
  /// GET /career-record-videos/home
  Future<Response> fetchHomeVideos() {
    return dio.get(ApiConstants.careerRecordVideosHome);
  }

  /// Fetches the full paginated list.
  /// GET /career-record-videos?page=<page>&per_page=<perPage>
  Future<Response> fetchVideos({int page = 1, int perPage = 8}) {
    return dio.get(
      ApiConstants.careerRecordVideos,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
  }
}