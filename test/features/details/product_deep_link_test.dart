import 'package:ecommerce_app_huma_volve/core/di/injection_container.dart';
import 'package:ecommerce_app_huma_volve/core/routes/app_router.dart';
import 'package:ecommerce_app_huma_volve/core/routes/app_routes.dart';
import 'package:ecommerce_app_huma_volve/features/details/domain/usecases/get_product_details_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/details/presentation/cubit/product_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  late FakeProductDetailsRepository repository;

  setUp(() {
    repository = FakeProductDetailsRepository();
    sl.registerFactory(
      () => ProductDetailsCubit(GetProductDetailsUseCase(repository)),
    );
  });

  tearDown(() => sl.reset());

  Future<void> openLink(WidgetTester tester, String location) async {
    final router = AppRouter.createRouter(initialLocation: location);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  test('product link uses the app scheme and the details route', () {
    expect(AppLinks.product('5').toString(), 'humavolve://app/products/5');
    expect(AppLinks.product('5').path, AppRoutes.product('5'));
  });

  testWidgets('/products/:id opens the product details', (tester) async {
    await openLink(tester, AppRoutes.product('42'));

    expect(repository.requestedIds, ['42']);
    expect(find.text('Product 42'), findsOneWidget);
    expect(find.text('Description 42'), findsOneWidget);
  });

  testWidgets('unknown link shows the not found page', (tester) async {
    await openLink(tester, '/unknown');

    expect(find.textContaining('Page not found'), findsOneWidget);
  });
}
