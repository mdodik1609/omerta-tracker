import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/game_service.dart';
import '../omerta_background.dart';
import '../omerta_card.dart';
import '../initials_avatar.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({Key? key, required this.game}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game _game;
  final _dateFormat = DateFormat('MMM d, y HH:mm');
  final Map<String, TextEditingController> _scoreControllers = {};

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showNewRoundDialog() {
    // Clear previous controllers
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    _scoreControllers.clear();

    // Track selected winner
    String? selectedWinnerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFFD2B48C),
          title: Text(
            'New Round',
            style: TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Winner dropdown at the top
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6D5C3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedWinnerId,
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text(
                      'Select Winner (Optional)',
                      style: TextStyle(
                        fontFamily: 'OmertaFont',
                        color: Colors.black54,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'No Winner',
                          style: TextStyle(
                            fontFamily: 'OmertaFont',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ..._game.players.map((player) => DropdownMenuItem<String>(
                        value: player.id,
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            fontFamily: 'OmertaFont',
                            color: Colors.black,
                          ),
                        ),
                      )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedWinnerId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Score inputs
                ..._game.players.map((player) {
                  final controller = TextEditingController();
                  _scoreControllers[player.id] = controller;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              InitialsAvatar(
                                player.name.split(' ').map((e) => e[0]).join(''),
                                radius: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontFamily: 'OmertaFont',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Score',
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
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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
              onPressed: () {
                for (var player in _game.players) {
                  final controller = _scoreControllers[player.id];
                  if (controller != null && controller.text.isNotEmpty) {
                    final score = int.tryParse(controller.text) ?? 0;
                    Provider.of<GameService>(context, listen: false)
                        .updatePlayerScore(_game, player.id, score);
                  }
                }
                
                // Update won games for the selected winner
                if (selectedWinnerId != null) {
                  Provider.of<GameService>(context, listen: false)
                      .incrementWonGames(_game, selectedWinnerId!);
                }
                
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'OmertaFont',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemovePlayerDialog(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD2B48C),
        title: Text(
          'Remove Player',
          style: TextStyle(
            fontFamily: 'OmertaFont',
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${player.name}?',
          style: const TextStyle(
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
            onPressed: () {
              Provider.of<GameService>(context, listen: false)
                  .removePlayer(_game, player.id);
              Navigator.pop(context);
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Remove',
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

  void _showDeleteGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFD2B48C),
        title: Text(
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
            onPressed: () {
              Provider.of<GameService>(context, listen: false)
                  .deleteGame(_game.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to home screen
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
    // Sort players by score (ascending) and won games (descending)
    final sortedPlayers = List<Player>.from(_game.players)
      ..sort((a, b) {
        if (a.score != b.score) {
          return a.score.compareTo(b.score);
        }
        return b.wonGames.compareTo(a.wonGames);
      });

    return OmertaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: const Color(0xFFD2B48C),
          title: Text(
            _game.name.isEmpty ? 'Game' : _game.name,
            style: const TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.black,
            ),
          ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFFD2B48C),
                    title: const Text(
                      'Edit Game',
                      style: TextStyle(
                        fontFamily: 'OmertaFont',
                        color: Colors.black,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Game Name',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            style: const TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Game Name',
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
                            controller: TextEditingController(text: _game.name),
                    onSubmitted: (value) {
                      setState(() {
                        _game = Game(
                          id: _game.id,
                          name: value,
                          startTime: _game.startTime,
                          players: _game.players,
                          currentRound: _game.currentRound,
                          isActive: _game.isActive,
                          endTime: _game.endTime,
                        );
                      });
                      Provider.of<GameService>(context, listen: false)
                          .saveGame(_game);
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Players',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._game.players.map((player) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6D5C3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: InitialsAvatar(
                                  player.name.split(' ').map((e) => e[0]).join(''),
                                  radius: 16,
                                ),
                                title: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Score: ${player.score} | Won: ${player.wonGames}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFFD2B48C),
                                        title: const Text(
                                          'Remove Player',
                                          style: TextStyle(
                                            fontFamily: 'OmertaFont',
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to remove ${player.name}? This action cannot be undone.',
                                          style: const TextStyle(
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
                                            onPressed: () {
                                              Provider.of<GameService>(context, listen: false)
                                                  .removePlayer(_game, player.id);
                                              Navigator.pop(context); // Close confirmation dialog
                                              Navigator.pop(context); // Close edit dialog
                                              setState(() {});
                                            },
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            child: const Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontFamily: 'OmertaFont',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'OmertaFont',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                ),
              );
            },
          ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: _showDeleteGameDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Started: ${_dateFormat.format(_game.startTime)}',
                style: const TextStyle(
                  fontFamily: 'OmertaFont',
                  color: Colors.white,
                ),
              ),
          ),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFFD2B48C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...sortedPlayers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final player = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6D5C3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD2B48C),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontFamily: 'OmertaFont',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InitialsAvatar(
                                      player.name.split(' ').map((e) => e[0]).join(''),
                                      radius: 16,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Won: ${player.wonGames}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: Text(
                                  '${player.score}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                    );
                  }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFFD2B48C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Round Scores',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                      ...sortedPlayers.map((player) {
                        return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                                  InitialsAvatar(
                                    player.name.split(' ').map((e) => e[0]).join(''),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                              Expanded(
                                    child: Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontFamily: 'OmertaFont',
                                        color: Colors.black,
                                      ),
                                    ),
                              ),
                              Expanded(
                                child: Text(
                                  player.roundScores.join(' - '),
                                      style: const TextStyle(
                                        fontFamily: 'OmertaFont',
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFD2B48C),
        onPressed: _showNewRoundDialog,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
} 