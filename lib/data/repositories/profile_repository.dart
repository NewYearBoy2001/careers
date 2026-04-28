import '../api/profile_api_service.dart';
import '../models/profile_model.dart';
import '../../utils/prefs/auth_local_storage.dart';

class ProfileRepository {
  final ProfileApiService _apiService;
  final AuthLocalStorage _localStorage;

  ProfileRepository(this._apiService, this._localStorage);

  Future<ProfileModel> getProfile() async {
    return await _apiService.getProfile();
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    final updatedProfile = await _apiService.updateProfile(profileData);

    await _localStorage.updateUserProfile(
      name: updatedProfile.name,
      email: updatedProfile.email, // will be null if cleared — that's fine
      phone: updatedProfile.phone,
    );

    if (updatedProfile.userId.isNotEmpty) {
      await _localStorage.saveUser(
        userId: updatedProfile.userId,
        name: updatedProfile.name,
        email: updatedProfile.email,
        phone: updatedProfile.phone,
      );
    }

    return updatedProfile;
  }
}