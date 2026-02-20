import '../api/profile_api_service.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final ProfileApiService _apiService;

  ProfileRepository(this._apiService);

  Future<ProfileModel> getProfile() async {
    return await _apiService.getProfile();
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    return await _apiService.updateProfile(profileData);
  }
}