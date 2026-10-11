import 'package:dio/dio.dart';

import '../../../core/api/api_constants.dart';
import '../../../core/api/dio_client.dart';
import '../models/auth_response.dart';

class AuthService {
  final Dio _dio = DioClient.instance.dio;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(res.data);
      DioClient.instance.token = auth.accessToken;
      return auth;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      // The API doesn't reject duplicate emails, so check first.
      final check = await _dio.post(
        ApiConstants.isEmailAvailable,
        data: {'email': email},
      );
      if (check.data['isAvailable'] != true) {
        throw 'This email is already registered';
      }
      await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'avatar': 'https://i.pravatar.cc/150?u=$email',
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  void logout() => DioClient.instance.token = null;

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out, please try again';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) return 'Wrong email or password';
        final message = (e.response?.data as Map?)?['message'];
        if (message is List) return message.join('\n');
        return message?.toString() ?? 'Error (${e.response?.statusCode})';
      default:
        return 'Something went wrong';
    }
  }
}
