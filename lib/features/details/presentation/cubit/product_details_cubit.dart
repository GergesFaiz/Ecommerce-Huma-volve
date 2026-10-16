import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/product.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase _getProductDetails;

  ProductDetailsCubit(this._getProductDetails) : super(ProductDetailsInitial());

  // Opened from the home list we already have the product; opened from a
  // deep link we only have the id, so fetch it.
  Future<void> loadProduct(String id, {Product? product}) async {
    if (product != null && product.id == id) {
      emit(ProductDetailsLoaded(product));
      return;
    }
    emit(ProductDetailsLoading());
    final result = await _getProductDetails(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }
}
