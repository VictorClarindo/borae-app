import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ticket_data_provider.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

/// TICKET BLOC - Gerenciador de Estado de Ingressos
/// Camada de lógica de negócio que conecta a UI com o Data Provider
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketDataProvider _ticketDataProvider;

  TicketBloc({required TicketDataProvider ticketDataProvider})
      : _ticketDataProvider = ticketDataProvider,
        super(const TicketInitial()) {
    // Registrar handlers para cada evento
    on<TicketPurchase>(_onPurchase);
    on<TicketLoadUserTickets>(_onLoadUserTickets);
    on<TicketCancel>(_onCancel);
    on<TicketValidate>(_onValidate);
    on<TicketLoadActive>(_onLoadActive);
  }

  /// Handler: Comprar ingresso
  Future<void> _onPurchase(
    TicketPurchase event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    try {
      await _ticketDataProvider.createTicket(event.ticket);
      emit(const TicketOperationSuccess(
          message: 'Ingresso comprado com sucesso!'));
      
      // Recarregar ingressos do usuário
      add(TicketLoadUserTickets(userId: event.ticket.userId));
    } catch (e) {
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
