import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/round.dart';

class GameService extends ChangeNotifier {
  Box<Game>? _gamesBox;
  Game? _currentGame;
  final _uuid = Uuid();
  bool _isInitialized = false;
  String? _error;
  bool _isLoading = true;

  GameService() {
    init();
  }

  Future<void> init() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _gamesBox = await Hive.openBox<Game>('games');
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error initializing GameService: $e';
      _isLoading = false;
      print(_error);
      notifyListeners();
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Game? get currentGame => _currentGame;
  List<Game> get games =>
      _isInitialized && _gamesBox != null ? _gamesBox!.values.toList() : [];

  Future<void> createGame(String name, List<Player> players) async {
    if (!_isInitialized || _gamesBox == null) {
      throw Exception('GameService not initialized');
    }

    try {
      final game = Game(
        id: _uuid.v4(),
        name: name,
        createdAt: DateTime.now(),
        players: players,
      );
      await _gamesBox!.put(game.id, game);
      _currentGame = game;
      notifyListeners();
    } catch (e) {
      _error = 'Error creating game: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updatePlayerScore(
      String playerId, int roundIndex, int score) async {
    if (!_isInitialized || _currentGame == null || _gamesBox == null) {
      throw Exception('GameService not initialized or no current game');
    }

    try {
      _currentGame!.updatePlayerScore(playerId, roundIndex, score);
      await _currentGame!.save();
      notifyListeners();
    } catch (e) {
      _error = 'Error updating score: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> addRound(Round round) async {
    if (!_isInitialized || _currentGame == null || _gamesBox == null) {
      throw Exception('GameService not initialized or no current game');
    }

    try {
      _currentGame!.addRound(round);
      await _currentGame!.save();
      notifyListeners();
    } catch (e) {
      _error = 'Error adding round: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> removePlayer(String playerId) async {
    if (!_isInitialized || _currentGame == null || _gamesBox == null) {
      throw Exception('GameService not initialized or no current game');
    }

    try {
      _currentGame!.removePlayer(playerId);
      await _currentGame!.save();
      notifyListeners();
    } catch (e) {
      _error = 'Error removing player: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> loadGame(String gameId) async {
    if (!_isInitialized || _gamesBox == null) {
      throw Exception('GameService not initialized');
    }

    try {
      final game = _gamesBox!.get(gameId);
      if (game != null) {
        _currentGame = game;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading game: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> deleteGame(String gameId) async {
    if (!_isInitialized || _gamesBox == null) {
      throw Exception('GameService not initialized');
    }

    try {
      await _gamesBox!.delete(gameId);
      if (_currentGame?.id == gameId) {
        _currentGame = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting game: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Map<String, int> getCurrentGameScores() {
    if (!_isInitialized || _currentGame == null) return {};
    return _currentGame!.getPlayerTotalScores();
  }

  void clearCurrentGame() {
    _currentGame = null;
    notifyListeners();
  }
}
