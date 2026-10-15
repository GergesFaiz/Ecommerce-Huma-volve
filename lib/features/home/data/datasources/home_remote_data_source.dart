import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    required int offset,
    required int limit,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      return (res.data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    required int offset,
    required int limit,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.products,
        queryParameters: {
          'offset': offset,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return (res.data as List).map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
