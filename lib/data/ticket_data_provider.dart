import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

import '../models/event.dart';
import '../models/ticket.dart';
import '../models/user.dart';

/// DATA PROVIDER - Camada de acesso aos dados de ingressos
/// Responsável por toda comunicação com Firestore para ingressos
class TicketDataProvider {
  final FirebaseFirestore _firestore;

  TicketDataProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Criar novo ingresso (comprar)
  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      await _firestore.collection('tickets').doc(ticket.id).set(ticket.toJson());

      // Atualizar lista de ingressos do usuário
      await _firestore.collection('users').doc(ticket.userId).update({
        'purchasedTickets': FieldValue.arrayUnion([ticket.id]),
      });

      return ticket;
    } catch (e) {
      throw Exception('Erro ao criar ingresso: $e');
    }
  }

  /// Comprar ingressos com transação segura
  Future<List<Ticket>> purchaseTickets({
    required Event event,
    required User user,
    int quantity = 1,
  }) async {
    if (quantity < 1) {
      throw Exception('Quantidade inválida');
    }
    print('[purchaseTickets] START event=${event.id} user=${user.id} qty=$quantity');
    // Primeiro passo: transação apenas para decrementar disponibilidade
    await _firestore.runTransaction((transaction) async {
      final eventRef = _firestore.collection('events').doc(event.id);
      final snap = await transaction.get(eventRef);
      if (!snap.exists) throw Exception('Evento não encontrado');
      final data = snap.data() as Map<String, dynamic>;
      final available = data['availableTickets'] as int? ?? 0;
      print('[purchaseTickets][transaction] availableBefore=$available requested=$quantity');
      if (available < quantity) throw Exception('Ingressos indisponíveis');
      transaction.update(eventRef, {
        'availableTickets': available - quantity,
      });
      print('[purchaseTickets][transaction] decremented -> newAvailable=${available - quantity}');
    });

    // Segundo passo: criar ingressos e atualizar usuário em lote
    final batch = _firestore.batch();
    final tickets = <Ticket>[];
    final now = DateTime.now();
  final random = Random();

    for (int i = 0; i < quantity; i++) {
      final ticketId = _firestore.collection('tickets').doc().id;
  final qrRandom = random.nextInt(1000000000); // < 1e9 evita RangeError em web
  final qrSource = '${ticketId}_${user.id}_${event.id}_${now.millisecondsSinceEpoch}_$qrRandom';
      final qrCode = sha256.convert(utf8.encode(qrSource)).toString().substring(0, 16);
  print('[purchaseTickets] Generating ticket $i id=$ticketId qrRand=$qrRandom');

      final ticket = Ticket(
        id: ticketId,
        userId: user.id,
        userName: user.name,
        eventId: event.id,
        eventName: event.name,
        eventDate: event.date,
        eventLocation: event.location,
        eventImageUrl: event.imageUrl,
        price: event.price,
        purchaseDate: now,
        qrCode: qrCode,
        status: 'active',
      );
      tickets.add(ticket);
      final ticketRef = _firestore.collection('tickets').doc(ticketId);
      batch.set(ticketRef, ticket.toJson());
    }

    // Update do usuário (merge) fora de transação
    final userRef = _firestore.collection('users').doc(user.id);
    batch.set(userRef, {
      'purchasedTickets': FieldValue.arrayUnion(tickets.map((t) => t.id).toList()),
    }, SetOptions(merge: true));

    await batch.commit();
    print('[purchaseTickets] COMMIT OK created=${tickets.length}');
    return tickets;
  }

  /// Buscar ingressos do usuário
  Future<List<Ticket>> getUserTickets(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();

      // Ordenar manualmente no código para evitar necessidade de índice
      final tickets = querySnapshot.docs
          .map((doc) => Ticket.fromFirestore(doc))
          .toList();
      
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      
      return tickets;
    } catch (e) {
      throw Exception('Erro ao buscar ingressos do usuário: $e');
    }
  }

  /// Buscar ingressos de um evento
  Future<List<Ticket>> getEventTickets(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Ordenar manualmente no código para evitar necessidade de índice
      final tickets = querySnapshot.docs
          .map((doc) => Ticket.fromFirestore(doc))
          .toList();
      
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      
      return tickets;
    } catch (e) {
      throw Exception('Erro ao buscar ingressos do evento: $e');
    }
  }

  /// Buscar ingresso por ID
  Future<Ticket> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection('tickets').doc(ticketId).get();

      if (!doc.exists) {
        throw Exception('Ingresso não encontrado');
      }

      return Ticket.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar ingresso: $e');
    }
  }

  /// Atualizar status do ingresso
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar status do ingresso: $e');
    }
  }

  /// Cancelar ingresso
  Future<void> cancelTicket(String ticketId) async {
    try {
      await updateTicketStatus(ticketId, 'cancelled');
    } catch (e) {
      throw Exception('Erro ao cancelar ingresso: $e');
    }
  }

  /// Validar ingresso (marcar como usado)
  Future<void> validateTicket(String ticketId, String qrCode) async {
    try {
      final ticket = await getTicketById(ticketId);

      if (ticket.qrCode != qrCode) {
        throw Exception('QR Code inválido');
      }

      if (ticket.status != 'active') {
        throw Exception('Ingresso já foi usado ou cancelado');
      }

      await updateTicketStatus(ticketId, 'used');
    } catch (e) {
      throw Exception('Erro ao validar ingresso: $e');
    }
  }

  /// Buscar ingressos ativos do usuário
  Future<List<Ticket>> getActiveUserTickets(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('eventDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Ticket.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar ingressos ativos: $e');
    }
  }

  /// Stream de ingressos do usuário (tempo real)
  Stream<List<Ticket>> userTicketsStream(String userId) {
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList());
  }

  /// Contar total de ingressos vendidos de um evento
  Future<int> countEventTickets(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('eventId', isEqualTo: eventId)
          .where('status', whereIn: ['active', 'used']).get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Erro ao contar ingressos: $e');
    }
  }
}
