import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../home/data/models/product_model.dart';

abstract class ProductDetailsRemoteDataSource {
  Future<ProductModel> getProductById(String id);
}

class ProductDetailsRemoteDataSourceImpl
    implements ProductDetailsRemoteDataSource {
  final Dio _dio;

  ProductDetailsRemoteDataSourceImpl(this._dio);

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final res = await _dio.get(ApiConstants.productById(id));
      return ProductModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
