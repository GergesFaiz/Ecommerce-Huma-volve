import 'package:ecommerce_app_huma_volve/core/errors/failures.dart';
import 'package:ecommerce_app_huma_volve/features/details/domain/usecases/get_product_details_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/details/presentation/cubit/product_details_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/details/presentation/cubit/product_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  late FakeProductDetailsRepository repository;
  late ProductDetailsCubit cubit;

  setUp(() {
    repository = FakeProductDetailsRepository();
    cubit = ProductDetailsCubit(GetProductDetailsUseCase(repository));
  });

  tearDown(() => cubit.close());

  Future<List<ProductDetailsState>> collect(
    Future<void> Function() action,
  ) async {
    final states = <ProductDetailsState>[];
    final sub = cubit.stream.listen(states.add);
    await action();
    await pumpEventQueue();
    await sub.cancel();
    return states;
  }

  test('deep link with only an id fetches the product', () async {
    final states = await collect(() => cubit.loadProduct('5'));

    expect(states, [isA<ProductDetailsLoading>(), isA<ProductDetailsLoaded>()]);
    expect((states.last as ProductDetailsLoaded).product.id, '5');
    expect(repository.requestedIds, ['5']);
  });

  test('product passed from the list is shown without a request', () async {
    final states = await collect(
      () => cubit.loadProduct('7', product: tProduct('7')),
    );

    expect(states, [isA<ProductDetailsLoaded>()]);
    expect(repository.requestedIds, isEmpty);
  });

  test('product with a different id than the link is fetched', () async {
    await collect(() => cubit.loadProduct('8', product: tProduct('7')));

    expect(repository.requestedIds, ['8']);
    expect((cubit.state as ProductDetailsLoaded).product.id, '8');
  });

  test('emits error when the request fails', () async {
    repository.failure = const ServerFailure('Not found');

    final states = await collect(() => cubit.loadProduct('999'));

    expect(states, [isA<ProductDetailsLoading>(), isA<ProductDetailsError>()]);
    expect((states.last as ProductDetailsError).message, 'Not found');
  });

  test('does not emit after close', () async {
    final future = cubit.loadProduct('5');
    await cubit.close();
    await expectLater(future, completes);
  });
}
