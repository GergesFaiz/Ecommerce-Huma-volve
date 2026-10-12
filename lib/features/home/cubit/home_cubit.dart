import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/category_model.dart';
import '../services/home_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final _homeService = HomeService();
  List<CategoryModel> _categories = [];

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      _categories = await _homeService.getCategories();
      final products = await _homeService.getProducts();
      if (isClosed) return;
      emit(HomeLoaded(categories: _categories, products: products));
    } on DioException catch (e) {
      if (isClosed) return;
      emit(HomeError(_errorMessage(e)));
    }
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
    try {
      final products = await _homeService.getProducts(categoryId: categoryId);
      if (isClosed) return;
      emit(
        HomeLoaded(
          categories: _categories,
          products: products,
          selectedCategoryId: categoryId,
        ),
      );
    } on DioException catch (e) {
      if (isClosed) return;
      emit(HomeError(_errorMessage(e)));
    }
  }

  String _errorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection';
    }
    return 'Failed to load products, please try again';
  }
}
