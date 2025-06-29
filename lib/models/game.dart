import 'package:hive/hive.dart';
import 'player.dart';
import 'round.dart';

part 'game.g.dart';

@HiveType(typeId: 0)
class Game extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<Player> players;

  @HiveField(4)
  List<Round> rounds;

  Game({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.players,
    List<Round>? rounds,
  }) : rounds = rounds ?? [];

  void addRound(Round round) {
    rounds.add(round);
    save();
  }

  void removePlayer(String playerId) {
    // Remove player from players list
    players.removeWhere((player) => player.id == playerId);

    // Remove player's scores from all rounds
    for (var round in rounds) {
      round.scores.remove(playerId);
      // If this player was the winner of this round, clear the winner
      if (round.winner == playerId) {
        round.winner = null;
      }
    }

    save();
  }

  void updatePlayerScore(String playerId, int roundIndex, int score) {
    if (roundIndex >= rounds.length) {
      rounds.add(Round(scores: {}));
    }
    rounds[roundIndex].scores[playerId] = score;
    save();
  }

  void updateLastRound(Round updatedRound) {
    if (rounds.isNotEmpty) {
      rounds[rounds.length - 1] = updatedRound;
      save();
    }
  }

  Map<String, int> getPlayerTotalScores() {
    Map<String, int> totals = {};
    for (var player in players) {
      totals[player.id] = 0;
    }
    for (var round in rounds) {
      for (var player in players) {
        totals[player.id] =
            (totals[player.id] ?? 0) + round.getScore(player.id).toInt();
      }
    }
    return totals;
  }

  Map<String, int> getPlayerWins() {
    Map<String, int> wins = {};
    for (var player in players) {
      wins[player.id] = 0;
    }

    for (var round in rounds) {
      final winnerId = round.winner;
      if (winnerId != null && winnerId.isNotEmpty) {
        wins[winnerId] = (wins[winnerId] ?? 0) + 1;
      }
    }
    return wins;
  }

  List<Player> getSortedPlayers() {
    final totalScores = getPlayerTotalScores();
    final wins = getPlayerWins();

    return List<Player>.from(players)
      ..sort((a, b) {
        final scoreA = totalScores[a.id] ?? 0;
        final scoreB = totalScores[b.id] ?? 0;

        if (scoreA != scoreB) {
          return scoreA.compareTo(scoreB); // Lower score is better
        }

        // If scores are equal, compare wins (more wins is better)
        final winsA = wins[a.id] ?? 0;
        final winsB = wins[b.id] ?? 0;
        return winsB.compareTo(winsA); // Higher wins is better
      });
  }

  Map<String, List<int>> getPlayerRoundScores() {
    Map<String, List<int>> roundScores = {};
    for (var player in players) {
      roundScores[player.id] = List.filled(rounds.length, 0);
    }

    for (var i = 0; i < rounds.length; i++) {
      rounds[i].scores.forEach((playerId, score) {
        roundScores[playerId]?[i] = score;
      });
    }
    return roundScores;
  }
}
