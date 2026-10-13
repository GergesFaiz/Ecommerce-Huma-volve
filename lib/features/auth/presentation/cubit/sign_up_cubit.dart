import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/register_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._registerUseCase) : super(SignUpInitial());

  final RegisterUseCase _registerUseCase;

  Future<void> signUp(String name, String email, String password) async {
    if (state is SignUpLoading) return;
    emit(SignUpLoading());
    final result = await _registerUseCase(name, email, password);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SignUpError(failure.message)),
      (_) => emit(SignUpSuccess()),
    );
  }
}
