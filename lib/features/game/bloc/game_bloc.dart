import 'dart:math';
import 'package:bloc/bloc.dart';
import '../models/position.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final _rng = Random();

  // To dedupe integer prices already processed for magic bombs
  final Set<int> _seenMagicPriceInts = {};

  GameBloc()
    : super(
        GameState(
          rows: 10,
          cols: 10,
          pieces: const {},
          hiddenBombs: const {},
          explodedBombs: const {},
          discoveredCount: 0,
          maxBombs: 30,
          status: GameStatus.playing,
          lastDiscovered: null,
          discoveryTick: 0,
          lastExploded: null,
          explosionTick: 0,
        ),
      ) {
    on<InitializeGame>(_onInitialize);
    on<PieceDropped>(_onPieceDropped);
    on<TimerTick>(_onTimerTick);
    on<PriceUpdateInt>(_onPriceUpdateInt);
    on<ResetGame>(_onReset);
  }

  void _onInitialize(InitializeGame event, Emitter<GameState> emit) {
    final rows = event.rows;
    final cols = event.cols;
    final cells = rows * cols;

    // Cap counts to avoid invalid setups
    final bombsCount = event.initialBombs.clamp(0, cells);
    final piecesCap = cells - bombsCount;
    final piecesCount = event.initialPieces.clamp(0, piecesCap);

    // Build and shuffle all positions once
    final positions = <Position>[
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++) Position(r, c),
    ]..shuffle(_rng);

    // First N -> bombs, next M -> pieces
    final bombCells = positions.take(bombsCount).toSet();
    final remaining = positions.skip(bombsCount).toList();

    final pieces = <int, Position>{};
    for (var i = 0; i < piecesCount; i++) {
      pieces[i] = remaining[i];
    }

    _seenMagicPriceInts.clear();

    emit(
      GameState(
        rows: rows,
        cols: cols,
        pieces: pieces,
        hiddenBombs: bombCells,
        explodedBombs: {},
        discoveredCount: 0,
        maxBombs: event.maxBombs,
        status: GameStatus.playing,
        lastDiscovered: null,
        discoveryTick: 0,
        lastExploded: null,
        explosionTick: 0,
      ),
    );
  }

  void _onPieceDropped(PieceDropped event, Emitter<GameState> emit) {
    if (state.isOver) return;

    final to = event.to;
    if (to.row < 0 ||
        to.col < 0 ||
        to.row >= state.rows ||
        to.col >= state.cols) {
      return;
    }
    if (state.isOccupied(to)) {
      return;
    }
    final pieces = Map<int, Position>.from(state.pieces);
    if (!pieces.containsKey(event.pieceId)) return;

    pieces[event.pieceId] = to;

    var hiddenBombs = Set<Position>.from(state.hiddenBombs);
    var explodedBombs = Set<Position>.from(state.explodedBombs);
    var discoveredCount = state.discoveredCount;

    Position? lastDiscovered = state.lastDiscovered;
    var discoveryTick = state.discoveryTick;

    if (hiddenBombs.contains(to)) {
      hiddenBombs.remove(to);
      discoveredCount += 1;
      lastDiscovered = to;
      discoveryTick += 1;
    }

    var status = state.status;
    if (hiddenBombs.isEmpty) {
      status = GameStatus.gameOver;
    }

    emit(
      state.copyWith(
        pieces: pieces,
        hiddenBombs: hiddenBombs,
        explodedBombs: explodedBombs,
        discoveredCount: discoveredCount,
        status: status,
        lastDiscovered: lastDiscovered,
        discoveryTick: discoveryTick,
      ),
    );
  }

  void _onTimerTick(TimerTick event, Emitter<GameState> emit) {
    if (state.isOver) return;
    if (state.hiddenBombs.isEmpty) {
      emit(state.copyWith(status: GameStatus.gameOver));
      return;
    }

    final hidden = List<Position>.from(state.hiddenBombs);
    if (hidden.isEmpty) return;

    final chosen = hidden[_rng.nextInt(hidden.length)];
    final hiddenBombs = Set<Position>.from(state.hiddenBombs)..remove(chosen);
    final explodedBombs = Set<Position>.from(state.explodedBombs)..add(chosen);

    var status = state.status;
    if (hiddenBombs.isEmpty) {
      status = GameStatus.gameOver;
    }

    emit(
      state.copyWith(
        hiddenBombs: hiddenBombs,
        explodedBombs: explodedBombs,
        status: status,
        lastExploded: chosen,
        explosionTick: state.explosionTick + 1,
      ),
    );
  }

  void _onPriceUpdateInt(PriceUpdateInt event, Emitter<GameState> emit) {
    if (state.isOver) return;

    // Only act on new integer values and if divisible by 5
    if (!_seenMagicPriceInts.add(event.priceInt)) return;
    if (event.priceInt % 5 != 0) return;

    // Cap
    if (state.totalBombs >= state.maxBombs) return;

    // Find empty square (no piece, no bomb/exploded)
    final candidates = <Position>[];
    for (var r = 0; r < state.rows; r++) {
      for (var c = 0; c < state.cols; c++) {
        final p = Position(r, c);
        final occupied = state.isOccupied(p);
        final hasBomb =
            state.hiddenBombs.contains(p) || state.explodedBombs.contains(p);
        if (!occupied && !hasBomb) {
          candidates.add(p);
        }
      }
    }
    if (candidates.isEmpty) return;

    final addAt = candidates[_rng.nextInt(candidates.length)];
    final hidden = Set<Position>.from(state.hiddenBombs)..add(addAt);
    emit(state.copyWith(hiddenBombs: hidden));
  }

  void _onReset(ResetGame event, Emitter<GameState> emit) {
    // Leave actual re-init to UI by dispatching InitializeGame with chosen params
    _seenMagicPriceInts.clear();
    emit(
      state.copyWith(
        pieces: {},
        hiddenBombs: {},
        explodedBombs: {},
        discoveredCount: 0,
        status: GameStatus.playing,
      ),
    );
  }
}
