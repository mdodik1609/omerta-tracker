import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/game_service.dart';
import '../omerta_background.dart';
import 'game_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

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
  void initState() {
    super.initState();
    // Ensure GameService is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameService = Provider.of<GameService>(context, listen: false);
      if (!gameService.isInitialized) {
        gameService.init();
      }
    });
  }

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

  void _startNewGame() async {
    if (_playerNames.isNotEmpty) {
      const uuid = Uuid();
      final players = _playerNames
          .map((name) => Player(id: uuid.v4(), name: name))
          .toList();
      await Provider.of<GameService>(context, listen: false)
          .createGame(_gameNameController.text, players);
      setState(() {
        _playerNames.clear();
        _gameNameController.clear();
      });
    }
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
              final navigatorContext = context;
              final gameService =
                  Provider.of<GameService>(navigatorContext, listen: false);
              await gameService.deleteGame(gameId);
              if (!navigatorContext.mounted) return;
              Navigator.pop(navigatorContext);
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

    return OmertaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2B48C),
          title: Text(
            'Omerta Score Tracker',
            style: TextStyle(
              fontFamily: 'OmertaFont',
              color: Colors.black,
              fontSize: titleFontSize,
            ),
          ),
        ),
        body: Consumer<GameService>(
          builder: (context, gameService, child) {
            if (gameService.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFFD2B48C),
                    ),
                    SizedBox(height: verticalSpace),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontFamily: 'OmertaFont',
                        color: Colors.white,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!gameService.isInitialized || gameService.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gameService.error ?? 'Failed to initialize app',
                      style: TextStyle(
                        fontFamily: 'OmertaFont',
                        color: Colors.red,
                        fontSize: subtitleFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: verticalSpace),
                    ElevatedButton(
                      onPressed: () {
                        gameService.init();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2B48C),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: 'OmertaFont',
                          color: Colors.black,
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final games = gameService.games;

            return Column(
              children: [
                Expanded(
                  child: games.isEmpty
                      ? Center(
                          child: Text(
                            'No games yet. Start a new game!',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.white,
                              fontSize: subtitleFontSize,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(padding),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return Card(
                              color: const Color(0xFFD2B48C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(cardRadius),
                              ),
                              margin: EdgeInsets.only(bottom: padding),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GameScreen(game: game),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(cardRadius),
                                child: Padding(
                                  padding: EdgeInsets.all(padding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              game.name.isEmpty
                                                  ? 'Game ${index + 1}'
                                                  : game.name,
                                              style: TextStyle(
                                                fontFamily: 'OmertaFont',
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.black),
                                            onPressed: () =>
                                                _deleteGame(game.id),
                                            iconSize: screenWidth * 0.07,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: verticalSpace),
                                      Text(
                                        'Started: ${_dateFormat.format(game.createdAt)}',
                                        style: TextStyle(
                                          fontFamily: 'OmertaFont',
                                          color: Colors.black,
                                          fontSize: inputFontSize,
                                        ),
                                      ),
                                      SizedBox(height: verticalSpace * 0.7),
                                      Text(
                                        'Players: ${game.players.map((p) => p.name).join(", ")}',
                                        style: TextStyle(
                                          fontFamily: 'OmertaFont',
                                          color: Colors.black,
                                          fontSize: inputFontSize,
                                        ),
                                      ),
                                      SizedBox(height: verticalSpace * 0.7),
                                      Text(
                                        'Rounds: ${game.rounds.length}',
                                        style: TextStyle(
                                          fontFamily: 'OmertaFont',
                                          color: Colors.black,
                                          fontSize: inputFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Card(
                  color: const Color(0xFFD2B48C),
                  margin: EdgeInsets.all(padding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        TextField(
                          controller: _gameNameController,
                          style: TextStyle(
                            fontFamily: 'OmertaFont',
                            color: Colors.black,
                            fontSize: inputFontSize,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Game Name (Optional)',
                            labelStyle: TextStyle(
                              fontFamily: 'OmertaFont',
                              color: Colors.black54,
                              fontSize: inputFontSize,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE6D5C3),
                          ),
                        ),
                        SizedBox(height: verticalSpace),
                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _playerController,
                                  style: TextStyle(
                                    fontFamily: 'OmertaFont',
                                    color: Colors.black,
                                    fontSize: inputFontSize,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Player Name',
                                    labelStyle: TextStyle(
                                      fontFamily: 'OmertaFont',
                                      color: Colors.black54,
                                      fontSize: inputFontSize,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(cardRadius),
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
                              SizedBox(width: horizontalSpace),
                              IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.black),
                                onPressed: _addPlayer,
                                iconSize: screenWidth * 0.07,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: verticalSpace * 0.7),
                        Wrap(
                          spacing: horizontalSpace,
                          runSpacing: verticalSpace * 0.7,
                          children: _playerNames.asMap().entries.map((entry) {
                            return Chip(
                              backgroundColor: const Color(0xFFE6D5C3),
                              label: Text(
                                entry.value,
                                style: TextStyle(
                                  fontFamily: 'OmertaFont',
                                  color: Colors.black,
                                  fontSize: chipFontSize,
                                ),
                              ),
                              deleteIcon: const Icon(Icons.close,
                                  color: Colors.black, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _playerNames.removeAt(entry.key);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: verticalSpace),
                        ElevatedButton(
                          onPressed: _startNewGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6D5C3),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.02,
                            ),
                          ),
                          child: Text(
                            'Start New Game',
                            style: TextStyle(
                              fontFamily: 'OmertaFont',
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
