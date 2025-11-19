import 'package:equatable/equatable.dart';

import '../../models/user.dart';

/// ESTADOS DO AUTH BLOC
/// Representa todos os possíveis estados da autenticação
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carregamento
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado de autenticado (usuário logado)
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado de não autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de erro
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de sucesso ao resetar senha
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}
