import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokens>> login(String email, String password);
  Future<Either<Failure, Unit>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, Unit>> logout();
  Future<bool> isLoggedIn();
}
