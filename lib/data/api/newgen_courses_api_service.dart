import 'package:careers/utils/network/base_dio_client.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import 'package:careers/constants/api_constants.dart';
import '../models/newgen_course_model.dart';

class NewgenCoursesApiService extends BaseDioClient {
  NewgenCoursesApiService(AuthLocalStorage authStorage)
      : super(authStorage: authStorage);

  Future<NewgenCoursesResponse> fetchNewgenCourses({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await dio.get(
      '${ApiConstants.newgenCourses}?page=$page&per_page=$perPage',
    );

    if (response.statusCode == 200 && response.data['status'] == '1') {
      return NewgenCoursesResponse.fromJson(response.data);
    } else {
      throw Exception(
          response.data['message'] ?? 'Failed to fetch NewGen courses');
    }
  }
}