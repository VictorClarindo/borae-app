import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final String type; // 'Show', 'Festival', 'Teatro', 'Esporte', 'Outro'
  final int totalTickets;
  final int availableTickets;
  final double price;
  final String organizerId;
  final String organizerName;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isActive;
  final List<String> categories;
  final String? faculty; // Faculdade/Universidade

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.type,
    required this.totalTickets,
    required this.availableTickets,
    required this.price,
    required this.organizerId,
    required this.organizerName,
    this.imageUrl,
    required this.createdAt,
    this.isActive = true,
    this.categories = const [],
    this.faculty,
  });

  // Converter de JSON para Event
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: json['location'] ?? '',
      type: json['type'] ?? 'Outro',
      totalTickets: json['totalTickets'] ?? 0,
      availableTickets: json['availableTickets'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      categories: List<String>.from(json['categories'] ?? []),
      faculty: json['faculty'],
    );
  }

  // Converter de Firestore Document para Event
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      type: data['type'] ?? 'Outro',
      totalTickets: data['totalTickets'] ?? 0,
      availableTickets: data['availableTickets'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      categories: List<String>.from(data['categories'] ?? []),
      faculty: data['faculty'],
    );
  }

  // Converter de Event para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'type': type,
      'totalTickets': totalTickets,
      'availableTickets': availableTickets,
      'price': price,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'categories': categories,
      'faculty': faculty,
    };
  }

  // Criar cópia com alterações
  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? location,
    String? type,
    int? totalTickets,
    int? availableTickets,
    double? price,
    String? organizerId,
    String? organizerName,
    String? imageUrl,
    DateTime? createdAt,
    bool? isActive,
    List<String>? categories,
    String? faculty,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      type: type ?? this.type,
      totalTickets: totalTickets ?? this.totalTickets,
      availableTickets: availableTickets ?? this.availableTickets,
      price: price ?? this.price,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      categories: categories ?? this.categories,
      faculty: faculty ?? this.faculty,
    );
  }

  // Verificar se há ingressos disponíveis
  bool get hasAvailableTickets => availableTickets > 0;

  // Calcular porcentagem vendida
  double get soldPercentage {
    if (totalTickets == 0) return 0;
    return ((totalTickets - availableTickets) / totalTickets) * 100;
  }
}
