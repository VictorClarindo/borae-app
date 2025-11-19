import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_data_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AUTH BLOC - Gerenciador de Estado de Autenticação
/// Camada de lógica de negócio que conecta a UI com o Data Provider
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthDataProvider _authDataProvider;

  AuthBloc({required AuthDataProvider authDataProvider})
      : _authDataProvider = authDataProvider,
        super(const AuthInitial()) {
    // Registrar handlers para cada evento
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  /// Handler: Login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authDataProvider.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handler: Criar conta
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authDataProvider.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        userType: event.userType,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handler: Logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authDataProvider.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handler: Verificar autenticação
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authDataProvider.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handler: Resetar senha
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authDataProvider.resetPassword(event.email);
      emit(const AuthPasswordResetSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
