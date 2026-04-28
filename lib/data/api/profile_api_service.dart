import 'package:dio/dio.dart';
import '../models/profile_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/api_error_handler.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/prefs/auth_local_storage.dart';

class ProfileApiService {
  final BaseDioClient _dioClient;
  final AuthLocalStorage _authStorage;

  ProfileApiService(this._authStorage)
      : _dioClient = BaseDioClient();

  Future<ProfileModel> getProfile() async {
    try {
      final phone = await _authStorage.getPhone();

      // If no phone stored yet, return empty profile
      if (phone == null || phone.isEmpty) {
        return ProfileModel(userId: '', name: '', email: null, phone: null);
      }

      final response = await _dioClient.dio.post(
        ApiConstants.profile,
        data: {'phone': phone},
      );

      if (response.statusCode == 200 && response.data['status'] == "1") {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.updateProfile,
        data: profileData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == "1") {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}