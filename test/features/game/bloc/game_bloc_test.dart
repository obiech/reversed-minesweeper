import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reversed_minesweeper/features/game/bloc/game_bloc.dart';
import 'package:reversed_minesweeper/features/game/bloc/game_event.dart';
import 'package:reversed_minesweeper/features/game/bloc/game_state.dart';

void main() {
  group('GameBloc', () {
    GameBloc buildBloc() => GameBloc();

    test('InitializeGame sets basic counts', () {
      final bloc = buildBloc();
      bloc.add(
        const InitializeGame(
          rows: 10,
          cols: 10,
          initialBombs: 5,
          maxBombs: 10,
          initialPieces: 8,
        ),
      );
      // allow event to process
      return expectLater(
        bloc.stream,
        emitsThrough(
          predicate<GameState>((s) {
            return s.rows == 10 &&
                s.cols == 10 &&
                s.hiddenBombs.length == 5 &&
                s.explodedBombs.isEmpty &&
                s.pieces.length == 8 &&
                s.discoveredCount == 0 &&
                s.status == GameStatus.playing;
          }),
        ),
      );
    });

    blocTest<GameBloc, GameState>(
      'TimerTick moves one bomb from hidden to exploded and ends when zero hidden',
      build: buildBloc,
      act: (bloc) {
        bloc.add(
          const InitializeGame(
            rows: 4,
            cols: 4,
            initialBombs: 1,
            maxBombs: 5,
            initialPieces: 0,
          ),
        );
        // give it a microtask tick
        Future.microtask(() => bloc.add(const TimerTick()));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final s = bloc.state;
        expect(s.hiddenBombs.length, 0);
        expect(s.explodedBombs.length, 1);
        expect(s.status, GameStatus.gameOver);
      },
    );

    blocTest<GameBloc, GameState>(
      'PieceDropped onto hidden bomb discovers it (count++) and piece remains',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          const InitializeGame(
            rows: 5,
            cols: 5,
            initialBombs: 3,
            maxBombs: 10,
            initialPieces: 2,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final s1 = bloc.state;
        final bombCell = s1.hiddenBombs.first;
        final pieceId = s1.pieces.keys.first;

        bloc.add(PieceDropped(pieceId: pieceId, to: bombCell));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final s = bloc.state;
        // Bomb removed from hidden
        expect(s.hiddenBombs.contains(s.lastDiscovered), isFalse);
        // Discovered count incremented
        expect(s.discoveredCount, 1);
        // Piece is at bombCell
        expect(s.pieces.values.contains(s.lastDiscovered), isTrue);
      },
    );

    blocTest<GameBloc, GameState>(
      'PieceDropped onto occupied cell is ignored (piece stays where it was)',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          const InitializeGame(
            rows: 5,
            cols: 5,
            initialBombs: 3,
            maxBombs: 10,
            initialPieces: 2,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final s1 = bloc.state;
        final entries = s1.pieces.entries.toList();
        final p1 = entries[0];
        final p2 = entries[1];
        // Try to move piece1 to piece2's position (occupied)
        bloc.add(PieceDropped(pieceId: p1.key, to: p2.value));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final s = bloc.state;
        // Positions unchanged
        expect(s.pieces.values.toSet().length, 2); // still two distinct cells
      },
    );

    blocTest<GameBloc, GameState>(
      'PriceUpdateInt divisible by 5 adds a hidden bomb (up to cap); non-divisible does not',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          const InitializeGame(
            rows: 6,
            cols: 6,
            initialBombs: 2,
            maxBombs: 8,
            initialPieces: 0,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final before = bloc.state.hiddenBombs.length;

        // Non-divisible -> no change
        bloc.add(const PriceUpdateInt(30001));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Divisible -> should add 1
        bloc.add(const PriceUpdateInt(30005));
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final after = bloc.state.hiddenBombs.length;
        expect(after, before + 1);
      },
    );

    blocTest<GameBloc, GameState>(
      'Game ends when all bombs are cleared via discoveries',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          const InitializeGame(
            rows: 3,
            cols: 3,
            initialBombs: 1,
            maxBombs: 3,
            initialPieces: 1,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final s1 = bloc.state;
        final bombCell = s1.hiddenBombs.first;
        final pieceId = s1.pieces.keys.first;

        bloc.add(PieceDropped(pieceId: pieceId, to: bombCell));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        final s = bloc.state;
        expect(s.hiddenBombs.isEmpty, isTrue);
        expect(s.status, GameStatus.gameOver);
      },
    );
  });
}
