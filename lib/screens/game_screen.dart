import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../services/game_service.dart';
import '../omerta_background.dart';
import '../omerta_card.dart';
import '../initials_avatar.dart';
import 'package:uuid/uuid.dart';

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
    // No need to call loadGames; Hive auto-loads.
  }

  void _updateGame(Game updatedGame) {
    setState(() {
      _game = updatedGame;
    });
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

    String? selectedWinner;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFFD2B48C),
          title: const Text(
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
                DropdownButtonFormField<String>(
                  value: selectedWinner,
                  decoration: InputDecoration(
                    labelText: 'Winner',
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
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        'No Winner',
                        style: TextStyle(
                          fontFamily: 'OmertaFont',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ..._game.players.map((player) {
                      return DropdownMenuItem(
                        value: player.id,
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            fontFamily: 'OmertaFont',
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedWinner = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                                player.name
                                    .split(' ')
                                    .map((e) => e[0])
                                    .join(''),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate all score fields
                bool allFieldsValid = true;
                for (var player in _game.players) {
                  final controller = _scoreControllers[player.id];
                  if (controller == null || controller.text.isEmpty) {
                    allFieldsValid = false;
                    break;
                  }
                  final score = int.tryParse(controller.text);
                  if (score == null) {
                    allFieldsValid = false;
                    break;
                  }
                }

                if (!allFieldsValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid number for all players',
                        style: TextStyle(
                          fontFamily: 'OmertaFont',
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final gameService =
                    Provider.of<GameService>(context, listen: false);
                final round = Round(
                  scores: {},
                  winner: selectedWinner,
                );

                for (var player in _game.players) {
                  final controller = _scoreControllers[player.id];
                  if (controller != null && controller.text.isNotEmpty) {
                    final score = int.tryParse(controller.text) ?? 0;
                    round.scores[player.id] = score;
                  }
                }

                _game.addRound(round);
                if (!mounted) return;
                Navigator.pop(context);
                this.setState(() {}); // Reload the parent widget
              },
              child: const Text('Done'),
            ),
          ],
        ),
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
            onPressed: () async {
              final gameService =
                  Provider.of<GameService>(context, listen: false);
              await gameService.deleteGame(_game.id);
              if (!mounted) return;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;
    final cardRadius = screenWidth * 0.03;
    final titleFontSize = screenWidth * 0.055;
    final subtitleFontSize = screenWidth * 0.04;
    final buttonFontSize = screenWidth * 0.045;
    final chipFontSize = screenWidth * 0.04;
    final inputFontSize = screenWidth * 0.042;
    final verticalSpace = screenHeight * 0.015;
    final horizontalSpace = screenWidth * 0.02;
    final iconSize = screenWidth * 0.07;

    final gameService = Provider.of<GameService>(context);

    if (!gameService.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFD2B48C),
          ),
        ),
      );
    }

    return OmertaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2B48C),
          title: Text(
            _game.name.isEmpty ? 'Game' : _game.name,
            style: TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.black,
              fontSize: titleFontSize,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              iconSize: iconSize,
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
                                  createdAt: _game.createdAt,
                                  players: _game.players,
                                );
                              });
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
                                  player.name
                                      .split(' ')
                                      .map((e) => e[0])
                                      .join(''),
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
                                  'Score: ${_game.getPlayerTotalScores()[player.id]}',
                                  style: const TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor:
                                            const Color(0xFFD2B48C),
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                                              Navigator.pop(
                                                  context); // Close confirmation dialog
                                              Navigator.pop(
                                                  context); // Close edit dialog
                                              setState(() {});
                                            },
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.red),
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
              iconSize: iconSize,
              onPressed: _showDeleteGameDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'Started: ${_dateFormat.format(_game.createdAt)}',
                style: TextStyle(
                  fontFamily: 'OmertaFont',
                  color: Colors.white,
                  fontSize: inputFontSize,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  _buildLeaderboard(
                    titleFontSize: titleFontSize,
                    subtitleFontSize: subtitleFontSize,
                    cardRadius: cardRadius,
                    padding: padding,
                  ),
                  SizedBox(height: verticalSpace * 2),
                  _buildRoundScores(
                    titleFontSize: titleFontSize,
                    subtitleFontSize: subtitleFontSize,
                    cardRadius: cardRadius,
                    padding: padding,
                    inputFontSize: inputFontSize,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFD2B48C),
          onPressed: _showNewRoundDialog,
          child: Icon(Icons.add, color: Colors.black, size: iconSize),
        ),
      ),
    );
  }

  Widget _buildLeaderboard({
    required double titleFontSize,
    required double subtitleFontSize,
    required double cardRadius,
    required double padding,
  }) {
    final sortedPlayers = _game.getSortedPlayers();
    final totalScores = _game.getPlayerTotalScores();
    final wins = _game.getPlayerWins();

    return Card(
      color: const Color(0xFFD2B48C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontFamily: 'OmertaFont',
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: padding),
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final columnWidth =
                    totalWidth / 4; // Divide into 4 equal columns

                return DataTable(
                  headingTextStyle: const TextStyle(
                    fontFamily: 'OmertaFont',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  dataTextStyle: const TextStyle(
                    fontFamily: 'OmertaFont',
                    color: Colors.black,
                  ),
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          '#',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Player',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Total',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: columnWidth,
                        child: const Text(
                          'Wins',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  rows: sortedPlayers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              player.name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              (totalScores[player.id] ?? 0).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: columnWidth,
                            child: Text(
                              (wins[player.id] ?? 0).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundScores({
    required double titleFontSize,
    required double subtitleFontSize,
    required double cardRadius,
    required double padding,
    required double inputFontSize,
  }) {
    final roundScores = _game.getPlayerRoundScores();

    return Card(
      color: const Color(0xFFD2B48C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Round Scores',
                  style: TextStyle(
                    fontFamily: 'OmertaFont',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Total Rounds: ${_game.rounds.length}',
                  style: TextStyle(
                    fontFamily: 'OmertaFont',
                    fontSize: inputFontSize,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: padding),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final playerColumnWidth = 100.0;
                final scoresColumnWidth = availableWidth -
                    playerColumnWidth -
                    8; // 8 for column spacing

                return DataTable(
                  headingTextStyle: const TextStyle(
                    fontFamily: 'OmertaFont',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  dataTextStyle: const TextStyle(
                    fontFamily: 'OmertaFont',
                    color: Colors.black,
                  ),
                  horizontalMargin: 0,
                  columnSpacing: 8,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: playerColumnWidth,
                        child: const Text(
                          'Player',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: scoresColumnWidth,
                        child: const Text(
                          'Scores',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                  rows: _game.players.map((player) {
                    final playerScores = roundScores[player.id] ?? [];
                    final scoresText = playerScores
                        .map((score) => score.toString().padLeft(3, ' '))
                        .join(' - ');

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: playerColumnWidth,
                            child: Text(
                              player.name,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: scoresColumnWidth,
                            child: Text(
                              scoresText,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
