import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../constants/app_theme.dart';
import 'orb_widget.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to GameProvider for state changes
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final isPresenting = game.gameStatus == GameStatus.presenting;
        final isAwaitingInput = game.gameStatus == GameStatus.awaitingInput ||
            game.gameStatus == GameStatus.feedback;

        return AspectRatio(
          aspectRatio: 1.0, // Make the board square
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: GameConfig.gridSize,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: GameConfig.maxGridSize,
              itemBuilder: (context, index) {
                final orbId = index;

                final bool isActivePresentation =
                    isPresenting && game.activeOrbId == orbId;
                final bool showFeedback = game.feedbackOrbId == orbId;

                return OrbWidget(
                  id: orbId,
                  isActive: isActivePresentation,
                  isClickable: isAwaitingInput,
                  showFeedback: showFeedback,
                  isCorrect: game.isLastInputCorrect,
                  onTap: () => game.handlePlayerInput(orbId),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
