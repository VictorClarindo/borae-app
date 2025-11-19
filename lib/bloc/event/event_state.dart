import 'package:equatable/equatable.dart';

import '../../models/event.dart';

/// ESTADOS DO EVENT BLOC
/// Representa todos os possíveis estados de eventos
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EventInitial extends EventState {
  const EventInitial();
}

/// Estado de carregamento
class EventLoading extends EventState {
  const EventLoading();
}

/// Estado de sucesso ao carregar eventos
class EventLoaded extends EventState {
  final List<Event> events;

  const EventLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

/// Estado de sucesso ao carregar evento único
class EventDetailLoaded extends EventState {
  final Event event;

  const EventDetailLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Estado de sucesso em operação (criar/atualizar/deletar)
class EventOperationSuccess extends EventState {
  final String message;

  const EventOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de erro
class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}
