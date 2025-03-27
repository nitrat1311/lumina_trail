// Represents a single position/target on the board
class OrbData {
  final int id; // Unique identifier (e.g., grid index 0-8)

  OrbData({required this.id});

  // Optional: Override equality for comparisons if needed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrbData && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Enum for the different states of the game
enum GameStatus {
  idle,
  presenting,
  awaitingInput,
  feedback,
  gameOver,
}
