import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/event_data_provider.dart';
import 'event_event.dart';
import 'event_state.dart';

/// EVENT BLOC - Gerenciador de Estado de Eventos
/// Camada de lógica de negócio que conecta a UI com o Data Provider
class EventBloc extends Bloc<EventEvent, EventState> {
  final EventDataProvider _eventDataProvider;

  EventBloc({required EventDataProvider eventDataProvider})
      : _eventDataProvider = eventDataProvider,
        super(const EventInitial()) {
    // Registrar handlers para cada evento
    on<EventLoadAll>(_onLoadAll);
    on<EventLoadByOrganizer>(_onLoadByOrganizer);
    on<EventCreate>(_onCreate);
    on<EventUpdate>(_onUpdate);
    on<EventDelete>(_onDelete);
    on<EventLoadByType>(_onLoadByType);
    on<EventLoadByFaculty>(_onLoadByFaculty);
    on<EventLoadById>(_onLoadById);
  }

  /// Handler: Carregar todos os eventos
  Future<void> _onLoadAll(
    EventLoadAll event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      final events = await _eventDataProvider.getAllEvents();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Carregar eventos do organizador
  Future<void> _onLoadByOrganizer(
    EventLoadByOrganizer event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      final events = await _eventDataProvider.getEventsByOrganizer(
        event.organizerId,
      );
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Criar evento
  Future<void> _onCreate(
    EventCreate event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      await _eventDataProvider.createEvent(
        event.event,
        imageFile: event.imageFile,
      );
      emit(const EventOperationSuccess(message: 'Evento criado com sucesso!'));
      
      // Recarregar eventos
      add(const EventLoadAll());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Atualizar evento
  Future<void> _onUpdate(
    EventUpdate event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      await _eventDataProvider.updateEvent(
        event.event,
        imageFile: event.imageFile,
      );
      emit(const EventOperationSuccess(
          message: 'Evento atualizado com sucesso!'));
      
      // Recarregar eventos
      add(const EventLoadAll());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Deletar evento
  Future<void> _onDelete(
    EventDelete event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      await _eventDataProvider.deleteEvent(event.eventId);
      emit(const EventOperationSuccess(message: 'Evento deletado com sucesso!'));
      
      // Recarregar eventos
      add(const EventLoadAll());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Carregar por tipo
  Future<void> _onLoadByType(
    EventLoadByType event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      final events = await _eventDataProvider.getEventsByType(event.type);
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Carregar por faculdade
  Future<void> _onLoadByFaculty(
    EventLoadByFaculty event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      final events = await _eventDataProvider.getEventsByFaculty(
        event.faculty,
      );
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  /// Handler: Carregar evento por ID
  Future<void> _onLoadById(
    EventLoadById event,
    Emitter<EventState> emit,
  ) async {
    emit(const EventLoading());

    try {
      final eventDetail = await _eventDataProvider.getEventById(event.eventId);
      emit(EventDetailLoaded(event: eventDetail));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }
}
