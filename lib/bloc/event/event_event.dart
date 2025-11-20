import 'package:equatable/equatable.dart';

import '../../models/event.dart';

/// EVENTOS DO EVENT BLOC
/// Define todas as ações relacionadas a eventos
abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Carregar todos os eventos
class EventLoadAll extends EventEvent {
  const EventLoadAll();
}

/// Evento: Carregar eventos do organizador
class EventLoadByOrganizer extends EventEvent {
  final String organizerId;

  const EventLoadByOrganizer({required this.organizerId});

  @override
  List<Object?> get props => [organizerId];
}

/// Evento: Criar novo evento
class EventCreate extends EventEvent {
  final Event event;

  const EventCreate({
    required this.event,
  });

  @override
  List<Object?> get props => [event];
}

/// Evento: Atualizar evento
class EventUpdate extends EventEvent {
  final Event event;

  const EventUpdate({
    required this.event,
  });

  @override
  List<Object?> get props => [event];
}

/// Evento: Deletar evento
class EventDelete extends EventEvent {
  final String eventId;

  const EventDelete({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Evento: Buscar por tipo
class EventLoadByType extends EventEvent {
  final String type;

  const EventLoadByType({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Evento: Buscar por faculdade
class EventLoadByFaculty extends EventEvent {
  final String faculty;

  const EventLoadByFaculty({required this.faculty});

  @override
  List<Object?> get props => [faculty];
}

/// Evento: Buscar evento específico
class EventLoadById extends EventEvent {
  final String eventId;

  const EventLoadById({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
