import 'package:hive/hive.dart';
part 'round.g.dart';

@HiveType(typeId: 2)
class Round extends HiveObject {
  @HiveField(0)
  Map<String, int> scores;

  @HiveField(1)
  String? winner;

  Round({
    Map<String, int>? scores,
    this.winner,
  }) : scores = scores ?? {};

  int getScore(String playerId) {
    return scores[playerId] ?? 0;
  }

  void setScore(String playerId, int score) {
    scores[playerId] = score;
  }
}
