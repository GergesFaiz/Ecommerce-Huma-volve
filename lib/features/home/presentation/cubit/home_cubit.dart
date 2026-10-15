import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._getCategoriesUseCase,
    this._getProductsUseCase, {
    this.pageSize = GetProductsUseCase.pageSizeDefault,
  }) : super(HomeInitial());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsUseCase _getProductsUseCase;
  final int pageSize;
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

    final productsResult = await _getProductsUseCase(pageSize: pageSize);
    if (isClosed) return;
    productsResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (products) => emit(
        HomeLoaded(
          categories: _categories,
          products: products,
          hasReachedEnd: products.length < pageSize,
        ),
      ),
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
    final result = await _getProductsUseCase(
      categoryId: categoryId,
      pageSize: pageSize,
    );
    if (isClosed || !_isStillSelected(categoryId)) return;
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (products) => emit(
        HomeLoaded(
          categories: _categories,
          products: products,
          selectedCategoryId: categoryId,
          hasReachedEnd: products.length < pageSize,
        ),
      ),
    );
  }

  // Loads the next page and appends it to the current products.
  // After a failure it waits for an explicit retry instead of
  // firing again on every scroll event.
  Future<void> loadMoreProducts({bool retry = false}) async {
    final current = state;
    if (current is! HomeLoaded ||
        current.isLoadingProducts ||
        current.isLoadingMore ||
        current.hasReachedEnd ||
        (current.loadMoreError != null && !retry)) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await _getProductsUseCase(
      categoryId: current.selectedCategoryId,
      page: nextPage,
      pageSize: pageSize,
    );
    if (isClosed) return;
    final latest = state;
    // the category changed (or data reloaded) while this page was loading
    if (latest is! HomeLoaded ||
        !latest.isLoadingMore ||
        latest.selectedCategoryId != current.selectedCategoryId) {
      return;
    }
    result.fold(
      (failure) => emit(
        latest.copyWith(isLoadingMore: false, loadMoreError: failure.message),
      ),
      (products) => emit(
        latest.copyWith(
          products: [...latest.products, ...products],
          page: nextPage,
          isLoadingMore: false,
          hasReachedEnd: products.length < pageSize,
        ),
      ),
    );
  }

  bool _isStillSelected(int? categoryId) {
    final current = state;
    return current is HomeLoaded &&
        current.isLoadingProducts &&
        current.selectedCategoryId == categoryId;
  }
}
