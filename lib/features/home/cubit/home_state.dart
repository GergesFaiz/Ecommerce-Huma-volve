import '../models/category_model.dart';
import '../models/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<Product> products;
  final int? selectedCategoryId;
  final bool isLoadingProducts;

  HomeLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    this.isLoadingProducts = false,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
