import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:lumina_trail/models/game_models.dart';
import '../constants/app_theme.dart'; // For GameConfig

class GameProvider with ChangeNotifier {
  // --- Private State ---
  int _level = 1;
  int _score = 0;
  List<OrbData> _sequence = [];
  List<int> _playerInput = [];
  GameStatus _gameStatus = GameStatus.idle;
  int? _activeOrbIndex; // Index in the _sequence being presented
  int? _feedbackInputIndex; // Index in the _playerInput receiving feedback
  bool? _isLastInputCorrect;
  Timer? _presentationTimer;
  Timer? _feedbackTimer;
  Timer? _levelTransitionTimer;

  // --- Public Getters ---
  int get level => _level;
  int get score => _score;
  List<OrbData> get sequence => List.unmodifiable(_sequence); // Read-only view
  GameStatus get gameStatus => _gameStatus;
  int? get activeOrbId => (_gameStatus == GameStatus.presenting &&
          _activeOrbIndex != null &&
          _activeOrbIndex! < _sequence.length)
      ? _sequence[_activeOrbIndex!].id
      : null;
  int? get feedbackOrbId => (_gameStatus == GameStatus.feedback &&
          _feedbackInputIndex != null &&
          _feedbackInputIndex! < _playerInput.length)
      ? _playerInput[_feedbackInputIndex!]
      : null;
  bool? get isLastInputCorrect => _isLastInputCorrect;

  // --- Core Logic Methods ---

  void _generateSequence() {
    final length = GameConfig.initialSequenceLength + _level - 1;
    final List<int> availableIds =
        List.generate(GameConfig.maxGridSize, (index) => index);
    final Random random = Random();
    _sequence = [];

    for (int i = 0; i < length; i++) {
      if (availableIds.isEmpty)
        break; // Should not happen if length <= maxGridSize
      final randomIndex = random.nextInt(availableIds.length);
      final selectedId = availableIds.removeAt(randomIndex);
      _sequence.add(OrbData(id: selectedId));
    }
    if (kDebugMode) {
      print(
          "Generated Sequence (Level $_level): ${_sequence.map((o) => o.id).toList()}");
    }
  }

  void startGame() {
    if (kDebugMode) {
      print("Starting Level $_level");
    }
    _resetForNewLevel();
    _generateSequence();
    _gameStatus = GameStatus.presenting;
    _activeOrbIndex = 0;
    notifyListeners();
    _startPresentationCycle();
  }

  void _startPresentationCycle() {
    _presentationTimer?.cancel(); // Cancel any existing timer

    if (_gameStatus == GameStatus.presenting &&
        _activeOrbIndex != null &&
        _activeOrbIndex! < _sequence.length) {
      // Schedule the next step in the presentation
      _presentationTimer = Timer(GameConfig.presentationSpeed, () {
        _activeOrbIndex = _activeOrbIndex! + 1; // Move to next orb (or end)
        if (_activeOrbIndex! < _sequence.length) {
          notifyListeners(); // Show the next orb
          _startPresentationCycle(); // Continue the cycle
        } else {
          // Sequence presentation finished
          _activeOrbIndex = null;
          _gameStatus = GameStatus.awaitingInput;
          if (kDebugMode) {
            print("Awaiting player input...");
          }
          notifyListeners(); // Update UI to reflect awaiting input state
        }
      });
      // Initial notification for the *first* orb in the sequence or subsequent orbs
      if (_activeOrbIndex! >= 0) {
        notifyListeners();
      }
    } else if (_gameStatus == GameStatus.presenting &&
        _activeOrbIndex == _sequence.length) {
      // This case handles when the sequence finishes presenting immediately after the last orb timer fires
      _activeOrbIndex = null;
      _gameStatus = GameStatus.awaitingInput;
      if (kDebugMode) {
        print("Awaiting player input...");
      }
      notifyListeners();
    }
  }

  void handlePlayerInput(int orbId) {
    if (_gameStatus != GameStatus.awaitingInput) return;

    final currentInputIndex = _playerInput.length;
    if (currentInputIndex >= _sequence.length) return; // Should not happen

    final correctOrbId = _sequence[currentInputIndex].id;
    final bool correct = orbId == correctOrbId;

    if (kDebugMode) {
      print("Input: $orbId, Expected: $correctOrbId, Correct: $correct");
    }

    _playerInput.add(orbId);
    _isLastInputCorrect = correct;
    _feedbackInputIndex = currentInputIndex;
    _gameStatus = GameStatus.feedback;
    notifyListeners(); // Show feedback immediately

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(GameConfig.feedbackDelay, () {
      _feedbackInputIndex = null; // Clear feedback state

      if (!correct) {
        _gameStatus = GameStatus.gameOver;
        if (kDebugMode) {
          print("Incorrect sequence. Game Over.");
        }
        // Optional: Save high score here (e.g., using shared_preferences)
      } else {
        _score += GameConfig.scoreIncrement;
        if (_playerInput.length == _sequence.length) {
          // Sequence complete! Advance level.
          if (kDebugMode) {
            print("Sequence complete! Advancing level.");
          }
          _level++;
          // Start next level after a short delay
          _levelTransitionTimer?.cancel();
          _levelTransitionTimer =
              Timer(GameConfig.levelTransitionDelay, startGame);
          // Keep status as feedback briefly until next level starts
        } else {
          // Correct, but sequence not yet complete
          _gameStatus = GameStatus.awaitingInput; // Ready for next input
        }
      }
      notifyListeners(); // Update UI after feedback delay
    });
  }

  void resetGame() {
    if (kDebugMode) {
      print("Resetting game...");
    }
    _cancelTimers();
    _level = 1;
    _score = 0;
    _sequence = [];
    _playerInput = [];
    _gameStatus = GameStatus.idle;
    _activeOrbIndex = null;
    _feedbackInputIndex = null;
    _isLastInputCorrect = null;
    notifyListeners();
  }

  void _resetForNewLevel() {
    _cancelTimers();
    _playerInput = [];
    _activeOrbIndex = null;
    _feedbackInputIndex = null;
    _isLastInputCorrect = null;
    // Don't notify here, startGame will notify
  }

  void _cancelTimers() {
    _presentationTimer?.cancel();
    _feedbackTimer?.cancel();
    _levelTransitionTimer?.cancel();
    _presentationTimer = null;
    _feedbackTimer = null;
    _levelTransitionTimer = null;
  }

  // Cleanup timers when the provider is disposed
  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
