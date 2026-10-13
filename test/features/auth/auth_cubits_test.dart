import 'package:ecommerce_app_huma_volve/core/errors/failures.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/register_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/login_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/login_state.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/sign_up_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('LoginCubit', () {
    test('emits loading then success', () async {
      final cubit = LoginCubit(LoginUseCase(repository));
      final states = <LoginState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.login('a@b.com', '123456');
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<LoginLoading>(), isA<LoginSuccess>()]);
    });

    test('emits loading then error with the failure message', () async {
      repository.failure = const ServerFailure('Wrong email or password');
      final cubit = LoginCubit(LoginUseCase(repository));
      final states = <LoginState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.login('a@b.com', 'wrong');
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<LoginLoading>(), isA<LoginError>()]);
      expect((states.last as LoginError).message, 'Wrong email or password');
    });
  });

  group('SignUpCubit', () {
    test('emits loading then success', () async {
      final cubit = SignUpCubit(RegisterUseCase(repository));
      final states = <SignUpState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.signUp('A', 'a@b.com', '123456');
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<SignUpLoading>(), isA<SignUpSuccess>()]);
    });

    test('emits loading then error with the failure message', () async {
      repository.failure = const ServerFailure('No internet connection');
      final cubit = SignUpCubit(RegisterUseCase(repository));
      final states = <SignUpState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.signUp('A', 'a@b.com', '123456');
      await pumpEventQueue();
      await sub.cancel();

      expect(states, [isA<SignUpLoading>(), isA<SignUpError>()]);
      expect((states.last as SignUpError).message, 'No internet connection');
    });
  });
}
