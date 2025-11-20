import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket.dart';

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
