import 'package:dartz/dartz.dart';
import 'package:ecommerce_app_huma_volve/core/errors/exceptions.dart';
import 'package:ecommerce_app_huma_volve/core/errors/failures.dart';
import 'package:ecommerce_app_huma_volve/core/storage/token_storage.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/auth_tokens_model.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/entities/auth_tokens.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';

const tTokens = AuthTokensModel(accessToken: 'access', refreshToken: 'refresh');

const tCategories = [
  CategoryEntity(id: 1, name: 'Clothes'),
  CategoryEntity(id: 2, name: 'Shoes'),
];

Product tProduct(String id) => Product(
  id: id,
  name: 'Product $id',
  description: 'Description $id',
  price: 10,
  imageUrl: '',
  colors: const [],
  sizes: const [],
);

class FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  bool shouldFail = false;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _check();
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    _check();
    return accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    _check();
    return refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _check();
    accessToken = null;
    refreshToken = null;
  }

  void _check() {
    if (shouldFail) throw const CacheException('storage failed');
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  ServerException? error;

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    if (error != null) throw error!;
    return tTokens;
  }

  @override
  Future<void> register(String name, String email, String password) async {
    if (error != null) throw error!;
  }
}

class FakeAuthRepository implements AuthRepository {
  Failure? failure;
  bool loggedIn = false;

  @override
  Future<Either<Failure, AuthTokens>> login(
    String email,
    String password,
  ) async => failure != null ? Left(failure!) : const Right(tTokens);

  @override
  Future<Either<Failure, Unit>> register(
    String name,
    String email,
    String password,
  ) async => failure != null ? Left(failure!) : const Right(unit);

  @override
  Future<Either<Failure, Unit>> logout() async =>
      failure != null ? Left(failure!) : const Right(unit);

  @override
  Future<bool> isLoggedIn() async => loggedIn;
}

class FakeHomeRepository implements HomeRepository {
  Failure? categoriesFailure;
  Failure? productsFailure;
  final List<int?> requestedCategoryIds = [];

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async =>
      categoriesFailure != null
      ? Left(categoriesFailure!)
      : const Right(tCategories);

  @override
  Future<Either<Failure, List<Product>>> getProducts({int? categoryId}) async {
    requestedCategoryIds.add(categoryId);
    if (productsFailure != null) return Left(productsFailure!);
    return Right([tProduct('${categoryId ?? 'all'}')]);
  }
}
