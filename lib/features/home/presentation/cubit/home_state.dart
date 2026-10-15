import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<Product> products;
  final int? selectedCategoryId;
  final bool isLoadingProducts;
  // pagination
  final int page;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final String? loadMoreError;

  HomeLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    this.isLoadingProducts = false,
    this.page = 0,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  HomeLoaded copyWith({
    List<Product>? products,
    int? page,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    String? loadMoreError,
  }) => HomeLoaded(
    categories: categories,
    products: products ?? this.products,
    selectedCategoryId: selectedCategoryId,
    isLoadingProducts: isLoadingProducts,
    page: page ?? this.page,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    // cleared unless passed again
    loadMoreError: loadMoreError,
  );
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
