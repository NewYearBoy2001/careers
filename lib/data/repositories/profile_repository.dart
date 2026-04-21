import '../api/profile_api_service.dart';
import '../models/profile_model.dart';
import '../../utils/prefs/auth_local_storage.dart'; // ADD

class ProfileRepository {
  final ProfileApiService _apiService;
  final AuthLocalStorage _localStorage; // ADD

  ProfileRepository(this._apiService, this._localStorage); // ADD

  Future<ProfileModel> getProfile() async {
    return await _apiService.getProfile();
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    final updatedProfile = await _apiService.updateProfile(profileData);

    // ADD: sync updated fields to SharedPreferences
    await _localStorage.updateUserProfile(
      name: updatedProfile.name,
      email: updatedProfile.email,
    );

    return updatedProfile;
  }
}