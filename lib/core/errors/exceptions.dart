import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);

  factory ServerException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException('Connection timed out, please try again');
      case DioExceptionType.connectionError:
        return const ServerException('No internet connection');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final message = data is Map ? data['message'] : null;
        if (message is List) return ServerException(message.join('\n'));
        return ServerException(
          message?.toString() ?? 'Error (${e.response?.statusCode})',
        );
      default:
        return const ServerException('Something went wrong');
    }
  }
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}
