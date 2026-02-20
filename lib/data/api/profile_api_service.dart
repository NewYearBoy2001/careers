import 'package:dio/dio.dart';
import '../models/profile_model.dart';
import '../../constants/api_constants.dart';
import '../../utils/network/api_error_handler.dart';
import '../../utils/network/base_dio_client.dart';
import '../../utils/prefs/auth_local_storage.dart';

class ProfileApiService {
  final BaseDioClient _dioClient;

  ProfileApiService(AuthLocalStorage authStorage)
      : _dioClient = BaseDioClient(authStorage: authStorage);

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);

      if (response.statusCode == 200 && response.data['status'] == "1") {
        return ProfileModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.updateProfile,
        data: profileData,
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