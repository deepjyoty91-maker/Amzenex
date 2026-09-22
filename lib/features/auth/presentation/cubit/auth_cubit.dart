import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/features/auth/data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getSavedUser();
        if (user != null) {
          emit(Authenticated(user));
          return;
        }
      }
      emit(const Unauthenticated());
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login(String identifier, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        identifier: identifier,
        password: password,
      );
      emit(Authenticated(user));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated());
  }
}
