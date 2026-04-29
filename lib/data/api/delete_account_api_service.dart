// import 'package:dio/dio.dart';
// import 'package:careers/utils/network/base_dio_client.dart';
// import 'package:careers/constants/api_constants.dart';
// import 'package:careers/utils/prefs/auth_local_storage.dart';
// import 'package:careers/utils/network/api_error_handler.dart';
//
// class DeleteAccountApiService {
//   late final Dio _dio;
//
//   DeleteAccountApiService(AuthLocalStorage authStorage)
//       : _dio = BaseDioClient(authStorage: authStorage).dio;
//
//   Future<String> deleteAccount({
//     required String reason,
//     required String confirmation,
//   }) async {
//     try {
//       final response = await _dio.delete(
//         ApiConstants.deleteAccount,
//         data: {
//           'reason': reason,
//           'confirmation': confirmation,
//         },
//       );
//       return response.data['message'] ?? 'Account deleted successfully';
//     } on DioException catch (e) {
//       throw Exception(ApiErrorHandler.handleDioError(e));
//     }
//   }
// }