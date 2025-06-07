import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'services/game_service.dart';
import 'models/game.dart';
import 'models/player.dart';
import 'models/round.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GameAdapter());
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(RoundAdapter());

    // Open boxes
    await Hive.openBox<Game>('games');

    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    // Show error screen
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Error Initializing App',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontFamily: 'OmertaFont',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                e.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'OmertaFont',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameService(),
      child: MaterialApp(
        title: 'Omerta Score Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'OmertaFont',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
