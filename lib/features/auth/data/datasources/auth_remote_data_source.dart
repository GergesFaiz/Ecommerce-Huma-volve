import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login(String email, String password);
  Future<void> register(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthTokensModel.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ServerException('Wrong email or password');
      }
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    try {
      // The API doesn't reject duplicate emails and users/is-available
      // always returns false, so check the users list.
      final users = await _dio.get(ApiConstants.register);
      final exists = (users.data as List).any(
        (u) => u['email'].toString().toLowerCase() == email.toLowerCase(),
      );
      if (exists) {
        throw const ServerException('This email is already registered');
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
      throw ServerException.fromDioException(e);
    }
  }
}
