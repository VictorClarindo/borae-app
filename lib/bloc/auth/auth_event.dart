import 'package:equatable/equatable.dart';

/// EVENTOS DO AUTH BLOC
/// Define todas as ações que podem ser executadas relacionadas à autenticação
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Fazer login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento: Criar conta
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String userType;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, name, userType];
}

/// Evento: Fazer logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento: Verificar status de autenticação
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento: Resetar senha
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
