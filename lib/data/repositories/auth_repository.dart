import '../api/auth_api_service.dart';
import '../models/api_response.dart';
import '../models/login_response_model.dart';
import 'package:careers/utils/prefs/auth_local_storage.dart';
import '../models/signup_response_model.dart';

class AuthRepository {
  final AuthApiService apiService;
  final AuthLocalStorage localStorage;

  AuthRepository(this.apiService, this.localStorage);

  Future<ApiResponse<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.login(
      email: email,
      password: password,
    );

    // SAVE USER IF LOGIN SUCCESS
    if (response.success && response.data != null) {
      await localStorage.saveUser(response.data!.toUser());
    }

    return response;
  }

  Future<ApiResponse<SignupResponseModel>> signup({
    required Map<String, dynamic> body,
  }) async {
    final response = await apiService.signup(body: body);

    // SAVE USER IF SIGNUP SUCCESS
    if (response.success && response.data != null) {
      await localStorage.saveUser(response.data!.toUser());
    }

    return response;
  }
}
