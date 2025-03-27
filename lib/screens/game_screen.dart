import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/game_board.dart';
import '../constants/app_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer or context.watch<GameProvider>() to get the state
    final game = context.watch<GameProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 500), // Max width for content
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Title --- (Always visible or conditional)
                Text(
                  'LuminaTrail',
                  style: textTheme.displayLarge ??
                      const TextStyle(
                          fontSize: 48,
                          color: AppColors.orbCyan,
                          fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // --- Game State Views ---
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _buildGameStateView(context, game, textTheme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build view based on game status
  Widget _buildGameStateView(
      BuildContext context, GameProvider game, TextTheme textTheme) {
    switch (game.gameStatus) {
      case GameStatus.idle:
        return _buildIdleView(context, game, textTheme,
            key: const ValueKey('idle'));
      case GameStatus.presenting:
      case GameStatus.awaitingInput:
      case GameStatus.feedback:
        return _buildPlayingView(context, game, textTheme,
            key: const ValueKey('playing'));
      case GameStatus.gameOver:
        return _buildGameOverView(context, game, textTheme,
            key: const ValueKey('gameOver'));
    }
  }

  // --- Idle View ---
  Widget _buildIdleView(
      BuildContext context, GameProvider game, TextTheme textTheme,
      {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Watch the sequence of glowing orbs, then click them in the same order.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.uiSecondary) ??
              AppTypography.bodyText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: game.startGame,
          child: const Text('Start Game'),
        ),
      ],
    );
  }

  // --- Playing View (Presenting, Awaiting, Feedback) ---
  Widget _buildPlayingView(
      BuildContext context, GameProvider game, TextTheme textTheme,
      {Key? key}) {
    String statusMessage = '';
    if (game.gameStatus == GameStatus.presenting) {
      statusMessage = 'Watch carefully...';
    } else if (game.gameStatus == GameStatus.awaitingInput) {
      statusMessage = 'Your turn...';
    } // Feedback state shows no message or brief indicator handled by OrbWidget

    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Score and Level Display
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                    text: 'Level: ',
                    style: AppTypography.scoreLevelText,
                    children: [
                      TextSpan(
                          text: '${game.level}',
                          style: AppTypography.scoreLevelValue),
                    ]),
              ),
              Text.rich(
                TextSpan(
                    text: 'Score: ',
                    style: AppTypography.scoreLevelText,
                    children: [
                      TextSpan(
                          text: '${game.score}',
                          style: AppTypography.scoreLevelValue),
                    ]),
              ),
            ],
          ),
        ),

        // Game Board
        Flexible(
          child: Align(
            alignment: Alignment.center,
            child: const GameBoard(),
          ),
        ),

        // Status Message Area
        SizedBox(
          height: 50, // Reserve space for status text
          child: Center(
            child: Text(statusMessage, style: AppTypography.statusText),
          ),
        ),
      ],
    );
  }

  // --- Game Over View ---
  Widget _buildGameOverView(
      BuildContext context, GameProvider game, TextTheme textTheme,
      {Key? key}) {
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Game Over',
          style: textTheme.headlineMedium
                  ?.copyWith(color: AppColors.feedbackIncorrect) ??
              AppTypography.headline2
                  .copyWith(color: AppColors.feedbackIncorrect),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          'You reached Level ${game.level}',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.uiSecondary) ??
              AppTypography.bodyText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Final Score: ${game.score}',
          style: textTheme.headlineMedium?.copyWith(fontSize: 28) ??
              AppTypography.headline2.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: game.resetGame,
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
