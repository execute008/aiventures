import 'package:aiventures/core/models/game_state.dart';

class Adventure {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final GameState gameState;
  
  Adventure({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.gameState,
  });
  
  Adventure copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    GameState? gameState,
  }) {
    return Adventure(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      gameState: gameState ?? this.gameState,
    );
  }
  
  Map<String, dynamic> toJson() {
    // Implementation for serialization
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      // GameState serialization would go here
    };
  }
  
  factory Adventure.fromJson(Map<String, dynamic> json) {
    // Implementation for deserialization
    return Adventure(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPlayedAt: DateTime.parse(json['lastPlayedAt'] as String),
      gameState: GameState(), // GameState deserialization would go here
    );
  }
}