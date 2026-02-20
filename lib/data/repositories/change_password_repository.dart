import '../api/change_password_api_service.dart';

class ChangePasswordRepository {
  final ChangePasswordApiService _apiService;

  ChangePasswordRepository(this._apiService);

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}