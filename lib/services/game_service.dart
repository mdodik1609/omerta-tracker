import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';

class GameService {
  static const String _gamesKey = 'games';
  final _uuid = Uuid();

  Future<List<Game>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getStringList(_gamesKey) ?? [];
    return gamesJson
        .map((json) => Game.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getGames();
    
    final gameIndex = games.indexWhere((g) => g.id == game.id);
    if (gameIndex >= 0) {
      games[gameIndex] = game;
    } else {
      games.add(game);
    }

    final gamesJson = games
        .map((game) => jsonEncode(game.toJson()))
        .toList();
    
    await prefs.setStringList(_gamesKey, gamesJson);
  }

  Future<Game> createNewGame(List<String> playerNames, {String name = ''}) async {
    final players = playerNames
        .map((name) => Player(
              id: _uuid.v4(),
              name: name,
            ))
        .toList();

    final game = Game(
      id: _uuid.v4(),
      name: name,
      startTime: DateTime.now(),
      players: players,
    );

    await saveGame(game);
    return game;
  }

  Future<void> updatePlayerScore(Game game, String playerId, int roundScore) async {
    final player = game.players.firstWhere((p) => p.id == playerId);
    player.roundScores.add(roundScore);
    player.score += roundScore;
    
    // If score is 0, increment won games
    if (roundScore == 0) {
      player.wonGames++;
    }
    
    await saveGame(game);
  }

  Future<void> incrementWonGames(Game game, String playerId) async {
    final player = game.players.firstWhere((p) => p.id == playerId);
    player.wonGames++;
    await saveGame(game);
  }

  Future<void> removePlayer(Game game, String playerId) async {
    game.players.removeWhere((p) => p.id == playerId);
    await saveGame(game);
  }

  Future<void> endGame(Game game) async {
    game.isActive = false;
    game.endTime = DateTime.now();
    await saveGame(game);
  }

  Future<void> deleteGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getGames();
    games.removeWhere((game) => game.id == gameId);
    
    final gamesJson = games
        .map((game) => jsonEncode(game.toJson()))
        .toList();
    
    await prefs.setStringList(_gamesKey, gamesJson);
  }
} 