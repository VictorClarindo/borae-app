import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/event.dart';

/// DATA PROVIDER - Camada de acesso aos dados de eventos
/// Responsável por toda comunicação com Firestore e Storage para eventos
class EventDataProvider {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EventDataProvider({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Criar novo evento
  Future<Event> createEvent(Event event, {File? imageFile}) async {
    try {
      String? imageUrl;

      // Se houver imagem, fazer upload
      if (imageFile != null) {
        imageUrl = await _uploadEventImage(event.id, imageFile);
      }

      final eventWithImage = event.copyWith(imageUrl: imageUrl);

      await _firestore
          .collection('events')
          .doc(event.id)
          .set(eventWithImage.toJson());

      return eventWithImage;
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
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
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
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
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
  Future<void> updateEvent(Event event, {File? imageFile}) async {
    try {
      String? imageUrl = event.imageUrl;

      // Se houver nova imagem, fazer upload
      if (imageFile != null) {
        imageUrl = await _uploadEventImage(event.id, imageFile);
      }

      final eventWithImage = event.copyWith(imageUrl: imageUrl);

      await _firestore
          .collection('events')
          .doc(event.id)
          .update(eventWithImage.toJson());
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
      try {
        final ref = _storage.ref().child('events/$eventId.jpg');
        await ref.delete();
      } catch (e) {
        // Ignorar erro se imagem não existir
      }
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
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
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
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
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
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  /// Upload de imagem do evento
  Future<String> _uploadEventImage(String eventId, File imageFile) async {
    try {
      final ref = _storage.ref().child('events/$eventId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }
}
