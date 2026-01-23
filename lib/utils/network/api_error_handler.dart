import 'dart:io';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        }

        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey][0];
          return firstError.toString();
        }
      }

      return _statusMessage(error.response?.statusCode);
    } else {
      return _handleException(error);
    }
  }

  static String _statusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Not found.';
      case 422:
        return 'Validation error.';
      case 500:
        return 'Server error. Try again later.';
      default:
        return 'Something went wrong.';
    }
  }

  static String _handleException(Object error) {
    if (error is SocketException) {
      return 'No internet connection.';
    } else {
      return 'Unexpected error occurred.';
    }
  }
}
