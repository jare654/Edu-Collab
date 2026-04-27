import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, {this.statusCode});

  @override
  String toString() => 'ApiError($statusCode): $message';
}

ApiError mapDioError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final message = error.response?.data is Map
        ? (error.response?.data['message']?.toString() ?? error.message ?? 'Network error')
        : (error.message ?? 'Network error');
    return ApiError(message, statusCode: status);
  }
  return ApiError('Unexpected error');
}
