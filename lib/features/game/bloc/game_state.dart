import 'package:equatable/equatable.dart';
import '../models/position.dart';

enum GameStatus { playing, gameOver }

class GameState extends Equatable {
  final int rows;
  final int cols;
  final Map<int, Position> pieces;
  final Set<Position> hiddenBombs;
  final Set<Position> explodedBombs;
  final int discoveredCount;
  final int maxBombs;
  final GameStatus status;

  // New: last discovered bomb position and a monotonically increasing tick
  final Position? lastDiscovered;
  final int discoveryTick;

  // New: last exploded position + tick
  final Position? lastExploded;
  final int explosionTick;

  const GameState({
    required this.rows,
    required this.cols,
    required this.pieces,
    required this.hiddenBombs,
    required this.explodedBombs,
    required this.discoveredCount,
    required this.maxBombs,
    required this.status,
    this.lastDiscovered,
    this.discoveryTick = 0,
    this.lastExploded,
    this.explosionTick = 0,
  });

  int get totalBombs =>
      hiddenBombs.length + explodedBombs.length + discoveredCount;

  bool get isOver => status == GameStatus.gameOver;

  bool isOccupied(Position p) {
    return pieces.values.any((pos) => pos == p);
  }

  int? pieceAt(Position p) {
    try {
      return pieces.entries.firstWhere((e) => e.value == p).key;
    } catch (_) {
      return null;
    }
  }

  int freeNeighborCount(Position p) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = p.row + dr;
        final c = p.col + dc;
        if (r < 0 || c < 0 || r >= rows || c >= cols) continue;
        final q = Position(r, c);
        final occupied = isOccupied(q);
        final hasHiddenBomb = hiddenBombs.contains(q);
        if (!occupied && !hasHiddenBomb) count++;
      }
    }
    return count;
  }

  GameState copyWith({
    Map<int, Position>? pieces,
    Set<Position>? hiddenBombs,
    Set<Position>? explodedBombs,
    int? discoveredCount,
    GameStatus? status,
    int? maxBombs,
    Position? lastDiscovered,
    int? discoveryTick,
    Position? lastExploded,
    int? explosionTick,
  }) {
    return GameState(
      rows: rows,
      cols: cols,
      pieces: pieces ?? this.pieces,
      hiddenBombs: hiddenBombs ?? this.hiddenBombs,
      explodedBombs: explodedBombs ?? this.explodedBombs,
      discoveredCount: discoveredCount ?? this.discoveredCount,
      maxBombs: maxBombs ?? this.maxBombs,
      status: status ?? this.status,
      lastDiscovered: lastDiscovered ?? this.lastDiscovered,
      discoveryTick: discoveryTick ?? this.discoveryTick,
      lastExploded: lastExploded ?? this.lastExploded,
      explosionTick: explosionTick ?? this.explosionTick,
    );
  }

  @override
  List<Object?> get props => [
    rows,
    cols,
    pieces,
    hiddenBombs,
    explodedBombs,
    discoveredCount,
    maxBombs,
    status,
    lastDiscovered,
    discoveryTick,
    lastExploded,
    explosionTick,
  ];
}
