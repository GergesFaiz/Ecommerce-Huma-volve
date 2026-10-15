import 'package:ecommerce_app_huma_volve/core/errors/failures.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late HomeCubit cubit;

  setUp(() {
    repository = FakeHomeRepository();
    cubit = HomeCubit(
      GetCategoriesUseCase(repository),
      GetProductsUseCase(repository),
    );
  });

  test('getHomeData emits loading then loaded', () async {
    final states = <HomeState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getHomeData();
    await pumpEventQueue();
    await sub.cancel();

    expect(states, [isA<HomeLoading>(), isA<HomeLoaded>()]);
    final loaded = states.last as HomeLoaded;
    expect(loaded.categories, tCategories);
    expect(loaded.products.single.id, 'all');
    expect(loaded.selectedCategoryId, isNull);
  });

  test('getHomeData emits error when categories fail', () async {
    repository.categoriesFailure = const ServerFailure(
      'No internet connection',
    );

    await cubit.getHomeData();

    expect((cubit.state as HomeError).message, 'No internet connection');
    expect(repository.requestedCategoryIds, isEmpty);
  });

  test('getHomeData emits error when products fail', () async {
    repository.productsFailure = const ServerFailure('Something went wrong');

    await cubit.getHomeData();

    expect((cubit.state as HomeError).message, 'Something went wrong');
  });

  test('selectCategory reloads the products for that category', () async {
    await cubit.getHomeData();
    final states = <HomeState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.selectCategory(2);
    await pumpEventQueue();
    await sub.cancel();

    expect(states.length, 2);
    expect((states.first as HomeLoaded).isLoadingProducts, true);
    final loaded = states.last as HomeLoaded;
    expect(loaded.isLoadingProducts, false);
    expect(loaded.selectedCategoryId, 2);
    expect(loaded.products.single.id, '2');
    expect(loaded.categories, tCategories);
  });

  test('selectCategory does nothing for the already selected one', () async {
    await cubit.getHomeData();

    await cubit.selectCategory(null);

    expect(repository.requestedCategoryIds, [null]);
  });

  test('selectCategory does nothing before the data is loaded', () async {
    await cubit.selectCategory(1);

    expect(cubit.state, isA<HomeInitial>());
    expect(repository.requestedCategoryIds, isEmpty);
  });

  group('pagination', () {
    setUp(() {
      repository.totalProducts = 25;
      cubit = HomeCubit(
        GetCategoriesUseCase(repository),
        GetProductsUseCase(repository),
        pageSize: 10,
      );
    });

    test('first page is loaded with offset 0', () async {
      await cubit.getHomeData();

      final loaded = cubit.state as HomeLoaded;
      expect(loaded.products.length, 10);
      expect(loaded.page, 0);
      expect(loaded.hasReachedEnd, false);
      expect(repository.requestedOffsets, [0]);
    });

    test('loadMoreProducts appends pages until the end', () async {
      await cubit.getHomeData();

      await cubit.loadMoreProducts();
      var loaded = cubit.state as HomeLoaded;
      expect(loaded.products.length, 20);
      expect(loaded.page, 1);
      expect(loaded.hasReachedEnd, false);

      await cubit.loadMoreProducts();
      loaded = cubit.state as HomeLoaded;
      expect(loaded.products.length, 25);
      expect(loaded.products.last.id, 'all-24');
      expect(loaded.hasReachedEnd, true);

      await cubit.loadMoreProducts();
      expect(repository.requestedOffsets, [0, 10, 20]);
    });

    test('loadMoreProducts emits loading more then loaded', () async {
      await cubit.getHomeData();
      final states = <HomeState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadMoreProducts();
      await pumpEventQueue();
      await sub.cancel();

      expect(states.length, 2);
      expect((states.first as HomeLoaded).isLoadingMore, true);
      expect((states.last as HomeLoaded).isLoadingMore, false);
    });

    test('a second call while loading more is ignored', () async {
      await cubit.getHomeData();

      await Future.wait([cubit.loadMoreProducts(), cubit.loadMoreProducts()]);

      expect(repository.requestedOffsets, [0, 10]);
      expect((cubit.state as HomeLoaded).products.length, 20);
    });

    test('a failed page keeps the products and needs a retry', () async {
      await cubit.getHomeData();
      repository.productsFailure = const ServerFailure('Something went wrong');

      await cubit.loadMoreProducts();
      var loaded = cubit.state as HomeLoaded;
      expect(loaded.products.length, 10);
      expect(loaded.loadMoreError, 'Something went wrong');

      // scrolling again does not spam the API
      await cubit.loadMoreProducts();
      expect(repository.requestedOffsets, [0, 10]);

      repository.productsFailure = null;
      await cubit.loadMoreProducts(retry: true);
      loaded = cubit.state as HomeLoaded;
      expect(loaded.products.length, 20);
      expect(loaded.loadMoreError, isNull);
      expect(repository.requestedOffsets, [0, 10, 10]);
    });

    test('selectCategory resets to the first page of that category', () async {
      await cubit.getHomeData();
      await cubit.loadMoreProducts();

      await cubit.selectCategory(2);

      final loaded = cubit.state as HomeLoaded;
      expect(loaded.page, 0);
      expect(loaded.products.length, 10);
      expect(loaded.products.first.id, '2-0');
      expect(repository.requestedOffsets, [0, 10, 0]);

      await cubit.loadMoreProducts();
      expect(repository.requestedCategoryIds.last, 2);
      expect(repository.requestedOffsets.last, 10);
    });

    test('a page from the old category is dropped after switching', () async {
      await cubit.getHomeData();

      final loadMore = cubit.loadMoreProducts();
      final select = cubit.selectCategory(1);
      await Future.wait([loadMore, select]);

      final loaded = cubit.state as HomeLoaded;
      expect(loaded.selectedCategoryId, 1);
      expect(loaded.products.length, 10);
      expect(loaded.products.every((p) => p.id.startsWith('1-')), true);
    });

    test('loadMoreProducts does nothing before the data is loaded', () async {
      await cubit.loadMoreProducts();

      expect(cubit.state, isA<HomeInitial>());
      expect(repository.requestedOffsets, isEmpty);
    });
  });
}
