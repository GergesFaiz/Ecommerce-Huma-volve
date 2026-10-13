import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getCategoriesUseCase, this._getProductsUseCase)
    : super(HomeInitial());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsUseCase _getProductsUseCase;
  List<CategoryEntity> _categories = [];

  Future<void> getHomeData() async {
    emit(HomeLoading());
    final categoriesResult = await _getCategoriesUseCase();
    if (isClosed) return;
    final categories = categoriesResult.fold((failure) {
      emit(HomeError(failure.message));
      return null;
    }, (categories) => categories);
    if (categories == null) return;
    _categories = categories;

    final productsResult = await _getProductsUseCase();
    if (isClosed) return;
    productsResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (products) =>
          emit(HomeLoaded(categories: _categories, products: products)),
    );
  }

  // null means "All"
  Future<void> selectCategory(int? categoryId) async {
    final current = state;
    if (current is! HomeLoaded || current.selectedCategoryId == categoryId) {
      return;
    }
    emit(
      HomeLoaded(
        categories: _categories,
        products: current.products,
        selectedCategoryId: categoryId,
        isLoadingProducts: true,
      ),
    );
    final result = await _getProductsUseCase(categoryId: categoryId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (products) => emit(
        HomeLoaded(
          categories: _categories,
          products: products,
          selectedCategoryId: categoryId,
        ),
      ),
    );
  }
}
