import '../api/newgen_courses_api_service.dart';
import '../models/newgen_course_model.dart';

class NewgenCoursesRepository {
  final NewgenCoursesApiService _apiService;

  NewgenCoursesRepository(this._apiService);

  Future<NewgenCoursesResponse> fetchNewgenCourses({
    int page = 1,
    int perPage = 10,
  }) {
    return _apiService.fetchNewgenCourses(page: page, perPage: perPage);
  }
}