import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ticket_data_provider.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';
// Imports removidos - usamos tipos via evento TicketPurchaseRequest

/// TICKET BLOC - Gerenciador de Estado de Ingressos
/// Camada de lógica de negócio que conecta a UI com o Data Provider
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketDataProvider _ticketDataProvider;

  TicketBloc({required TicketDataProvider ticketDataProvider})
      : _ticketDataProvider = ticketDataProvider,
        super(const TicketInitial()) {
    // Registrar handlers para cada evento
  on<TicketPurchaseRequest>(_onPurchaseRequest);
    on<TicketLoadUserTickets>(_onLoadUserTickets);
    on<TicketCancel>(_onCancel);
    on<TicketValidate>(_onValidate);
    on<TicketLoadActive>(_onLoadActive);
  }

  /// Handler: Comprar ingresso(s)
  Future<void> _onPurchaseRequest(
    TicketPurchaseRequest event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      print('[TicketBloc] PurchaseRequest eventId=${event.event.id} userId=${event.user.id} qty=${event.quantity}');
      final tickets = await _ticketDataProvider.purchaseTickets(
        event: event.event,
        user: event.user,
        quantity: event.quantity,
      );
      print('[TicketBloc] PurchaseSuccess created=${tickets.length} firstTicketId=${tickets.isNotEmpty ? tickets.first.id : 'NONE'}');
      emit(TicketOperationSuccess(
          message: 'Compra realizada: ${tickets.length} ingresso(s).'));
      add(TicketLoadUserTickets(userId: event.user.id));
    } catch (e) {
      print('[TicketBloc] PurchaseError ${e.toString()}');
      emit(TicketError(message: e.toString()));
    }
  }

  /// Handler: Carregar ingressos do usuário
  Future<void> _onLoadUserTickets(
    TicketLoadUserTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      final tickets = await _ticketDataProvider.getUserTickets(event.userId);
      emit(TicketLoaded(tickets: tickets));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  /// Handler: Cancelar ingresso
  Future<void> _onCancel(
    TicketCancel event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      await _ticketDataProvider.cancelTicket(event.ticketId);
      emit(const TicketOperationSuccess(
          message: 'Ingresso cancelado com sucesso!'));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  /// Handler: Validar ingresso
  Future<void> _onValidate(
    TicketValidate event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      await _ticketDataProvider.validateTicket(
        event.ticketId,
        event.qrCode,
      );
      emit(const TicketOperationSuccess(
          message: 'Ingresso validado com sucesso!'));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }

  /// Handler: Carregar ingressos ativos
  Future<void> _onLoadActive(
    TicketLoadActive event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      final tickets = await _ticketDataProvider.getActiveUserTickets(
        event.userId,
      );
      emit(TicketLoaded(tickets: tickets));
    } catch (e) {
      emit(TicketError(message: e.toString()));
    }
  }
}
