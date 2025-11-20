// import 'dart:io'; // removido suporte a File

import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_storage/firebase_storage.dart'; // suporte a imagem removido

import '../models/event.dart';

/// DATA PROVIDER - Camada de acesso aos dados de eventos
/// Responsável por toda comunicação com Firestore e Storage para eventos
class EventDataProvider {
  final FirebaseFirestore _firestore;
  // final FirebaseStorage _storage; // não usado após remoção de imagens

  EventDataProvider({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Criar novo evento
  Future<Event> createEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .set(event.toJson());
      return event;
    } catch (e) {
      throw Exception('Erro ao criar evento: $e');
    }
  }

  /// Buscar todos os eventos
  Future<List<Event>> getAllEvents() async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();

      final events = querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      
      // Ordenar por data em memória (evita necessidade de índice composto)
      events.sort((a, b) => a.date.compareTo(b.date));
      
      return events;
    } catch (e) {
      throw Exception('Erro ao buscar eventos: $e');
    }
  }

  /// Buscar eventos por organizador
  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('organizerId', isEqualTo: organizerId)
          .get();

      final events = querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      
      // Ordenar por data em memória
      events.sort((a, b) => b.date.compareTo(a.date));
      
      return events;
    } catch (e) {
      throw Exception('Erro ao buscar eventos do organizador: $e');
    }
  }

  /// Buscar evento por ID
  Future<Event> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) {
        throw Exception('Evento não encontrado');
      }

      return Event.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar evento: $e');
    }
  }

  /// Atualizar evento
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar evento: $e');
    }
  }

  /// Deletar evento
  Future<void> deleteEvent(String eventId) async {
    try {
      // Marcar como inativo ao invés de deletar
      await _firestore.collection('events').doc(eventId).update({
        'isActive': false,
      });

      // Opcional: deletar imagem do storage
      // Imagens removidas - nada a fazer no Storage
    } catch (e) {
      throw Exception('Erro ao deletar evento: $e');
    }
  }

  /// Buscar eventos por tipo
  Future<List<Event>> getEventsByType(String type) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('type', isEqualTo: type)
          .where('isActive', isEqualTo: true)
          .get();

      final events = querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      
      // Ordenar por data em memória
      events.sort((a, b) => a.date.compareTo(b.date));
      
      return events;
    } catch (e) {
      throw Exception('Erro ao buscar eventos por tipo: $e');
    }
  }

  /// Buscar eventos por faculdade
  Future<List<Event>> getEventsByFaculty(String faculty) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('faculty', isEqualTo: faculty)
          .where('isActive', isEqualTo: true)
          .get();

      final events = querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      
      // Ordenar por data em memória
      events.sort((a, b) => a.date.compareTo(b.date));
      
      return events;
    } catch (e) {
      throw Exception('Erro ao buscar eventos por faculdade: $e');
    }
  }

  /// Decrementar ingressos disponíveis
  Future<void> decrementAvailableTickets(String eventId, int quantity) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final eventDoc =
            await transaction.get(_firestore.collection('events').doc(eventId));

        if (!eventDoc.exists) {
          throw Exception('Evento não encontrado');
        }

        final currentAvailable = eventDoc.data()!['availableTickets'] as int;

        if (currentAvailable < quantity) {
          throw Exception('Ingressos insuficientes');
        }

        transaction.update(eventDoc.reference, {
          'availableTickets': currentAvailable - quantity,
        });
      });
    } catch (e) {
      throw Exception('Erro ao atualizar ingressos: $e');
    }
  }

  /// Stream de eventos (tempo real)
  Stream<List<Event>> eventsStream() {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
          // Ordenar por data em memória
          events.sort((a, b) => a.date.compareTo(b.date));
          return events;
        });
  }

  /// Upload de imagem do evento
  // Métodos de upload removidos
}
