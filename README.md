# E-Commerce App — Huma-volve Flutter Bootcamp

A Flutter e-commerce app built task by task during the Huma-volve bootcamp.
It talks to the [Platzi Fake Store API](https://fakeapi.platzi.com/) for
authentication, categories and products.

## Demo

| Feature | Video |

| Auth (login / sign up) 

https://github.com/user-attachments/assets/56c02236-6052-4bdb-8f1d-635882c91070

| Home (products and categories from the API) 

https://github.com/user-attachments/assets/42c880ef-a7fc-4201-8164-d7c39b761be9

## Features

- **Auth** — login and sign up against the API, with form validation and
  error messages. Tokens are cached in secure storage, so the app opens
  straight on the home screen while a token is stored. Logout clears them.
- **Home** — categories and products loaded from the API, with filtering by
  category, loading and error states and a retry button.
- **Product details** — image, description, color and size selection. Opens
  from a deep link (`humavolve://app/products/<id>`) and fetches the product
  by id; the share button copies the product's link.
- **Cart** and **Profile** — UI screens backed by dummy data.

## Architecture

The Auth, Home and Product details features follow Clean Architecture. Each one is split into
three layers, and dependencies only point inwards:

```
screen -> cubit -> usecase -> repository (interface) <- repository impl -> remote data source
```

```
lib/
├── core/
│   ├── api/        Dio client and endpoints
│   ├── di/         get_it service locator
│   ├── errors/     exceptions and failures
│   ├── routes/     GoRouter config and route paths
│   ├── storage/    token storage (flutter_secure_storage)
│   └── widgets/    shared widgets
└── features/
    ├── auth/
    │   ├── data/          datasources, models, repositories
    │   ├── domain/        entities, repositories, usecases
    │   └── presentation/  cubit, screens
    ├── home/
    │   ├── data/          datasources, models, repositories
    │   ├── domain/        entities, repositories, usecases
    │   └── presentation/  cubit, screens, widgets
    ├── details/
    │   ├── data/          datasources, repositories
    │   ├── domain/        repositories, usecases
    │   └── presentation/  cubit, screens, widgets
    ├── cart/
    ├── profile/
    ├── main_navigation/
    └── splash/
```

### Error handling

Data sources throw `ServerException` / `CacheException`. Repositories catch
them and return `Either<Failure, T>`, so cubits never deal with `DioException`
and only emit a state with the failure message.

### Deep linking

Navigation uses GoRouter (`lib/core/routes/app_router.dart`). The product
details route is `/products/:id`, and Android opens it from links like
`humavolve://app/products/5` (intent filter in `AndroidManifest.xml`).

- Opened from the home list, the product is passed as `extra` and shown
  immediately.
- Opened from a link, only the id is known, so `ProductDetailsCubit` fetches
  `GET products/{id}` and shows loading, error and retry states.
- Back on a deep-linked screen goes to the splash route, which sends the user
  to home or login.

Try it on a running emulator or device:

```bash
adb shell am start -W -a android.intent.action.VIEW -d "humavolve://app/products/5"
```

### Token caching

On login the access and refresh tokens are saved with
`flutter_secure_storage`. A Dio interceptor reads the access token and adds it
as a `Bearer` header to every request.

## Tech stack

| Purpose | Package |
| --- | --- |
| State management | `flutter_bloc` (Cubit) |
| Networking | `dio`, `pretty_dio_logger` |
| Dependency injection | `get_it` |
| Routing and deep links | `go_router` |
| Functional error handling | `dartz` |
| Secure storage | `flutter_secure_storage` |
| Fonts | `google_fonts` |

## Getting started

Requires the Flutter SDK with Dart `^3.12.0`.

```bash
git clone https://github.com/GergesFaiz/Ecommerce-Huma-volve.git
cd Ecommerce-Huma-volve
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Unit tests cover the auth repository, the login, sign up, home and product
details cubits, and opening the details screen from a deep link,
using hand-made fakes instead of a mocking package.

## Bootcamp tasks

| Task | Branch |
| --- | --- |
| Home feature with API and state management | `home-feature-use-API+stateManagement` |
| Day Three — Clean Architecture for Auth and Home | `Day-Three-Task-Clean-Architecture-to-the-Auth-&-Home-Features` |
| Day Four — Pagination in the Home feature | `Day-Four-Task-Implement-Pagination-In-The-Home-Feature` |
| Day Five — Deep linking in Product details | `Day-Five-Task-Implement-Deep-Linking-In-The-Product-Details-Feature` |
