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
}
