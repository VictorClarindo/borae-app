import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String eventId;
  final String eventName;
  final String userId;
  final String userName;
  final DateTime purchaseDate;
  final double price;
  final String status; // 'active', 'used', 'cancelled'
  final String qrCode;
  final DateTime eventDate;
  final String eventLocation;
  final String? eventImageUrl;

  Ticket({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.userId,
    required this.userName,
    required this.purchaseDate,
    required this.price,
    required this.status,
    required this.qrCode,
    required this.eventDate,
    required this.eventLocation,
    this.eventImageUrl,
  });

  // Converter de JSON para Ticket
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      purchaseDate: (json['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      qrCode: json['qrCode'] ?? '',
      eventDate: (json['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventLocation: json['eventLocation'] ?? '',
      eventImageUrl: json['eventImageUrl'],
    );
  }

  // Converter de Firestore Document para Ticket
  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      qrCode: data['qrCode'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventLocation: data['eventLocation'] ?? '',
      eventImageUrl: data['eventImageUrl'],
    );
  }

  // Converter de Ticket para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'userId': userId,
      'userName': userName,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'price': price,
      'status': status,
      'qrCode': qrCode,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventLocation': eventLocation,
      'eventImageUrl': eventImageUrl,
    };
  }

  // Criar cópia com alterações
  Ticket copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? userId,
    String? userName,
    DateTime? purchaseDate,
    double? price,
    String? status,
    String? qrCode,
    DateTime? eventDate,
    String? eventLocation,
    String? eventImageUrl,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      eventDate: eventDate ?? this.eventDate,
      eventLocation: eventLocation ?? this.eventLocation,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
    );
  }

  // Verificar se o ingresso está ativo
  bool get isActive => status == 'active';

  // Verificar se o evento já passou
  bool get isEventPast => eventDate.isBefore(DateTime.now());
}
