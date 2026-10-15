import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductsUseCase {
  final HomeRepository _repository;

  GetProductsUseCase(this._repository);

  // categoryId null means "All", page starts at 0
  Future<Either<Failure, List<Product>>> call({
    int? categoryId,
    int page = 0,
    int pageSize = pageSizeDefault,
  }) => _repository.getProducts(
    categoryId: categoryId,
    offset: page * pageSize,
    limit: pageSize,
  );

  static const pageSizeDefault = 10;
}
