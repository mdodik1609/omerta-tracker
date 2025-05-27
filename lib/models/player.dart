class Player {
  final String id;
  final String name;
  int score;
  List<int> roundScores;
  int wonGames;

  Player({
    required this.id,
    required this.name,
    this.score = 0,
    List<int>? roundScores,
    this.wonGames = 0,
  }) : roundScores = roundScores ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'roundScores': roundScores,
      'wonGames': wonGames,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      score: json['score'],
      roundScores: List<int>.from(json['roundScores']),
      wonGames: json['wonGames'] ?? 0,
    );
  }
} 