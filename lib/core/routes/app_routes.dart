class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const home = '/home';
  static const productDetails = '/products/:id';

  static String product(String id) => '/products/$id';
}

// Links that open the app from outside, e.g. humavolve://app/products/5.
// The host is fixed to "app" so the path reaching the router is /products/5.
class AppLinks {
  static const scheme = 'humavolve';
  static const host = 'app';

  static Uri product(String id) =>
      Uri(scheme: scheme, host: host, path: AppRoutes.product(id));
}
