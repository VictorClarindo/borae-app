import 'package:equatable/equatable.dart';

// import '../../models/ticket.dart'; // não necessário no novo evento
import '../../models/event.dart';
import '../../models/user.dart';

/// EVENTOS DO TICKET BLOC
/// Define todas as ações relacionadas a ingressos
abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Comprar ingresso
class TicketPurchaseRequest extends TicketEvent {
  final Event event;
  final User user;
  final int quantity;

  const TicketPurchaseRequest({
    required this.event,
    required this.user,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [event, user, quantity];
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
