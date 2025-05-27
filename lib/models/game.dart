import 'player.dart';

class Game {
  final String id;
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  List<Player> players;
  int currentRound;
  bool isActive;

  Game({
    required this.id,
    required this.startTime,
    required this.players,
    this.name = '',
    this.currentRound = 1,
    this.isActive = true,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'players': players.map((p) => p.toJson()).toList(),
      'currentRound': currentRound,
      'isActive': isActive,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      currentRound: json['currentRound'],
      isActive: json['isActive'],
    );
  }
} 