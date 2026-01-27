import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../utils/prefs/auth_local_storage.dart';

class BaseDioClient {
  late final Dio dio;
  final AuthLocalStorage? _authStorage;

  BaseDioClient({AuthLocalStorage? authStorage}) : _authStorage = authStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor if authStorage is provided
    if (_authStorage != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Get token from storage
            final token = await _authStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      );
    }

    // Logs (DEV only)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }
}