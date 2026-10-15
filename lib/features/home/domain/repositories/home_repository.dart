import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<Product>>> getProducts({
    int? categoryId,
    required int offset,
    required int limit,
  });
}
