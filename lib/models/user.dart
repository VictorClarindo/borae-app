import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String userType; // 'participant' ou 'organizer'
  final DateTime createdAt;
  final List<String> favoriteEvents;
  final List<String> purchasedTickets;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.userType,
    required this.createdAt,
    this.favoriteEvents = const [],
    this.purchasedTickets = const [],
  });

  // Converter de JSON para User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      userType: json['userType'] ?? 'participant',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteEvents: List<String>.from(json['favoriteEvents'] ?? []),
      purchasedTickets: List<String>.from(json['purchasedTickets'] ?? []),
    );
  }

  // Converter de Firestore Document para User
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      userType: data['userType'] ?? 'participant',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteEvents: List<String>.from(data['favoriteEvents'] ?? []),
      purchasedTickets: List<String>.from(data['purchasedTickets'] ?? []),
    );
  }

  // Converter de User para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
      'favoriteEvents': favoriteEvents,
      'purchasedTickets': purchasedTickets,
    };
  }

  // Criar cópia com alterações
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? userType,
    DateTime? createdAt,
    List<String>? favoriteEvents,
    List<String>? purchasedTickets,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      purchasedTickets: purchasedTickets ?? this.purchasedTickets,
    );
  }
}
