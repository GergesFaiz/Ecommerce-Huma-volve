import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';

abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class SecureTokenStorage implements TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage(this._storage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) => _guard(() async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  });

  @override
  Future<String?> getAccessToken() =>
      _guard(() => _storage.read(key: _accessTokenKey));

  @override
  Future<String?> getRefreshToken() =>
      _guard(() => _storage.read(key: _refreshTokenKey));

  @override
  Future<void> clearTokens() => _guard(() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      throw const CacheException('Failed to access secure storage');
    }
  }
}
