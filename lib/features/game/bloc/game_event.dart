import 'package:equatable/equatable.dart';
import '../models/position.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class InitializeGame extends GameEvent {
  final int rows;
  final int cols;
  final int initialBombs;
  final int maxBombs;
  final int initialPieces;
  const InitializeGame({
    required this.rows,
    required this.cols,
    required this.initialBombs,
    required this.maxBombs,
    required this.initialPieces,
  });
}

class PieceDropped extends GameEvent {
  final int pieceId;
  final Position to;
  const PieceDropped({required this.pieceId, required this.to});

  @override
  List<Object?> get props => [pieceId, to];
}

class TimerTick extends GameEvent {
  const TimerTick();
}

class PriceUpdateInt extends GameEvent {
  // integer part of BTC price (floor)
  final int priceInt;
  const PriceUpdateInt(this.priceInt);
  @override
  List<Object?> get props => [priceInt];
}

class ResetGame extends GameEvent {
  const ResetGame();
}
