import 'package:dio/dio.dart';

import '../../../core/api/api_constants.dart';
import '../../../core/api/dio_client.dart';
import '../models/category_model.dart';
import '../models/product.dart';

class HomeService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    return (res.data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<Product>> getProducts({int? categoryId}) async {
    final res = await _dio.get(
      ApiConstants.products,
      queryParameters: {if (categoryId != null) 'categoryId': categoryId},
    );
    return (res.data as List).map((e) => Product.fromJson(e)).toList();
  }
}
