import '../api/course_fee_api_service.dart';
import '../models/course_fee_model.dart';

class CourseFeeRepository {
  final CourseFeeApiService _apiService;

  CourseFeeRepository(this._apiService);

  Future<CourseFeeModel> fetchCourseFeeStructure(String courseId) async {
    final response = await _apiService.fetchCourseFeeStructure(courseId);
    final data = response['data'] as Map<String, dynamic>;
    return CourseFeeModel.fromJson(data);
  }
}