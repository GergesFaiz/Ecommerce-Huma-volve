import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../errors/exceptions.dart';
import '../storage/token_storage.dart';
import 'api_constants.dart';

class DioClient {
  final TokenStorage _tokenStorage;

  DioClient(this._tokenStorage);

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
    PrettyDioLogger(requestBody: true),
  ]);

  Future<String?> _readToken() async {
    try {
      return await _tokenStorage.getAccessToken();
    } on CacheException {
      return null;
    }
  }
}
