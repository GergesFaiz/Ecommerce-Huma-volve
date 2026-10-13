import 'package:ecommerce_app_huma_volve/core/errors/exceptions.dart';
import 'package:ecommerce_app_huma_volve/core/errors/failures.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  late FakeAuthRemoteDataSource remote;
  late FakeTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = FakeAuthRemoteDataSource();
    storage = FakeTokenStorage();
    repository = AuthRepositoryImpl(remote, storage);
  });

  test('login caches the tokens and returns them', () async {
    final result = await repository.login('a@b.com', '123456');

    expect(result.isRight(), true);
    expect(storage.accessToken, 'access');
    expect(storage.refreshToken, 'refresh');
    expect(await repository.isLoggedIn(), true);
  });

  test('login maps ServerException to ServerFailure', () async {
    remote.error = const ServerException('Wrong email or password');

    final result = await repository.login('a@b.com', 'wrong');

    result.fold((failure) {
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Wrong email or password');
    }, (_) => fail('expected a failure'));
    expect(storage.accessToken, isNull);
  });

  test('login maps CacheException to CacheFailure', () async {
    storage.shouldFail = true;

    final result = await repository.login('a@b.com', '123456');

    result.fold(
      (failure) => expect(failure, isA<CacheFailure>()),
      (_) => fail('expected a failure'),
    );
  });

  test('register maps ServerException to ServerFailure', () async {
    remote.error = const ServerException('This email is already registered');

    final result = await repository.register('A', 'a@b.com', '123456');

    result.fold(
      (failure) => expect(failure.message, 'This email is already registered'),
      (_) => fail('expected a failure'),
    );
  });

  test('logout clears the cached tokens', () async {
    await repository.login('a@b.com', '123456');

    final result = await repository.logout();

    expect(result.isRight(), true);
    expect(storage.accessToken, isNull);
    expect(await repository.isLoggedIn(), false);
  });

  test('isLoggedIn is false when storage fails', () async {
    storage.accessToken = 'access';
    storage.shouldFail = true;

    expect(await repository.isLoggedIn(), false);
  });
}
