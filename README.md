# E-Commerce App — Huma-volve Flutter Bootcamp

A Flutter e-commerce app built task by task during the Huma-volve bootcamp.
It talks to the [Platzi Fake Store API](https://fakeapi.platzi.com/) for
authentication, categories and products.

## Demo

| Feature | Video |
| --- | --- |
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
- **Product details** — image, description, color and size selection.
- **Cart** and **Profile** — UI screens backed by dummy data.

## Architecture

The Auth and Home features follow Clean Architecture. Each one is split into
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
    ├── cart/
    ├── profile/
    ├── main_navigation/
    └── splash/
```

### Error handling

Data sources throw `ServerException` / `CacheException`. Repositories catch
them and return `Either<Failure, T>`, so cubits never deal with `DioException`
and only emit a state with the failure message.

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

Unit tests cover the auth repository and the login, sign up and home cubits,
using hand-made fakes instead of a mocking package.

## Bootcamp tasks

| Task | Branch |
| --- | --- |
| Home feature with API and state management | `home-feature-use-API+stateManagement` |
| Day Three — Clean Architecture for Auth and Home | `Day-Three-Task-Clean-Architecture-to-the-Auth-&-Home-Features` |
