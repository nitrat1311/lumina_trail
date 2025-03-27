import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';
import 'constants/app_theme.dart';

void main() {
  runApp(const LuminaTrailApp());
}

class LuminaTrailApp extends StatelessWidget {
  const LuminaTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the GameProvider to the widget tree
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'LuminaTrail',
        theme: buildAppTheme(), // Apply the custom theme
        debugShowCheckedModeBanner: false, // Hide debug banner
        home: const GameScreen(), // Set the initial screen
      ),
    );
  }
}
