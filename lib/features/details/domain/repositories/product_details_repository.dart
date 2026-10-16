import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/product.dart';

abstract class ProductDetailsRepository {
  Future<Either<Failure, Product>> getProductById(String id);
}
