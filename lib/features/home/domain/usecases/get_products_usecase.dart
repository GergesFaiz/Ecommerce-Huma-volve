import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductsUseCase {
  final HomeRepository _repository;

  GetProductsUseCase(this._repository);

  // null means "All"
  Future<Either<Failure, List<Product>>> call({int? categoryId}) =>
      _repository.getProducts(categoryId: categoryId);
}
