import 'package:equatable/equatable.dart';

import '../../models/ticket.dart';

/// EVENTOS DO TICKET BLOC
/// Define todas as ações relacionadas a ingressos
abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Comprar ingresso
class TicketPurchase extends TicketEvent {
  final Ticket ticket;

  const TicketPurchase({required this.ticket});

  @override
  List<Object?> get props => [ticket];
}

/// Evento: Carregar ingressos do usuário
class TicketLoadUserTickets extends TicketEvent {
  final String userId;

  const TicketLoadUserTickets({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento: Cancelar ingresso
class TicketCancel extends TicketEvent {
  final String ticketId;

  const TicketCancel({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

/// Evento: Validar ingresso
class TicketValidate extends TicketEvent {
  final String ticketId;
  final String qrCode;

  const TicketValidate({
    required this.ticketId,
    required this.qrCode,
  });

  @override
  List<Object?> get props => [ticketId, qrCode];
}

/// Evento: Carregar ingressos ativos
class TicketLoadActive extends TicketEvent {
  final String userId;

  const TicketLoadActive({required this.userId});

  @override
  List<Object?> get props => [userId];
}
