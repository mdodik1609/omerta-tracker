import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../omerta_background.dart';
import '../initials_avatar.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerController = TextEditingController();
  final _gameNameController = TextEditingController();
  final List<String> _playerNames = [];
  final _dateFormat = DateFormat('MMM d, y HH:mm');

  @override
  void dispose() {
    _playerController.dispose();
    _gameNameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _playerNames.add(_playerController.text);
        _playerController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _playerNames.removeAt(index);
    });
  }

  Future<void> _startNewGame() async {
    if (_playerNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least 2 players',
            style: TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFFD2B48C),
        ),
      );
      return;
    }

    final gameService = Provider.of<GameService>(context, listen: false);
    final game = await gameService.createNewGame(
      _playerNames,
      name: _gameNameController.text,
    );
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(game: game),
      ),
    );
  }

  Future<void> _deleteGame(String gameId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text(
          'Delete Game',
          style: TextStyle(
            fontFamily: 'OmertaFont',
            color: Colors.black,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this game? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'OmertaFont',
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OmertaFont',
                color: Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final gameService = Provider.of<GameService>(context, listen: false);
              await gameService.deleteGame(gameId);
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'OmertaFont',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OmertaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2B48C),
          title: const Text(
            'Omerta Score Tracker',
            style: TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: Provider.of<GameService>(context, listen: false).getGames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD2B48C),
                      ),
                    );
                  }

                  final games = snapshot.data ?? [];
                  if (games.isEmpty) {
                    return Center(
                      child: Text(
                        'No games yet. Start a new game!',
                        style: TextStyle(
                          fontFamily: 'OmertaFont',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return Card(
                        color: const Color(0xFFD2B48C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(game: game),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        game.name.isEmpty ? 'Game ${index + 1}' : game.name,
                                        style: const TextStyle(
                                          fontFamily: 'OmertaFont',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.black),
                                      onPressed: () => _deleteGame(game.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Started: ${_dateFormat.format(game.startTime)}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Players: ${game.players.map((p) => p.name).join(", ")}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rounds: ${game.currentRound}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Card(
              color: const Color(0xFFD2B48C),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _gameNameController,
                      style: const TextStyle(
                        fontFamily: 'OmertaFont',
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Game Name (Optional)',
                        labelStyle: const TextStyle(
                          fontFamily: 'OmertaFont',
                          color: Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFE6D5C3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _playerController,
                              style: const TextStyle(
                                fontFamily: 'OmertaFont',
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Player Name',
                                labelStyle: const TextStyle(
                                  fontFamily: 'OmertaFont',
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFE6D5C3),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.black),
                            onPressed: _addPlayer,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _playerNames.asMap().entries.map((entry) {
                        return Chip(
                          backgroundColor: const Color(0xFFE6D5C3),
                          label: Text(
                            entry.value,
                            style: const TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, color: Colors.black),
                          onDeleted: () => _removePlayer(entry.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startNewGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6D5C3),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Start New Game',
                        style: TextStyle(
                          fontFamily: 'OmertaFont',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 