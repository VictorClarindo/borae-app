import 'package:equatable/equatable.dart';

import '../../models/ticket.dart';

/// ESTADOS DO TICKET BLOC
/// Representa todos os possíveis estados de ingressos
abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TicketInitial extends TicketState {
  const TicketInitial();
}

/// Estado de carregamento
class TicketLoading extends TicketState {
  const TicketLoading();
}

/// Estado de sucesso ao carregar ingressos
class TicketLoaded extends TicketState {
  final List<Ticket> tickets;

  const TicketLoaded({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

/// Estado de sucesso em operação
class TicketOperationSuccess extends TicketState {
  final String message;

  const TicketOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de erro
class TicketError extends TicketState {
  final String message;

  const TicketError({required this.message});

  @override
  List<Object?> get props => [message];
}
