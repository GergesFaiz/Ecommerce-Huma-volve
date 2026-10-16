import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/product.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../datasources/product_details_remote_data_source.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final ProductDetailsRemoteDataSource _remoteDataSource;

  ProductDetailsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      return Right(await _remoteDataSource.getProductById(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
