import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/position.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/piece_drag_data.dart';

part '../parts/auto_explosion_burst.dart';
part '../parts/cell.dart';
part '../parts/explosion_pulse.dart';
part '../parts/piece.dart';
part '../parts/piece_widget.dart';

class BoardGrid extends StatelessWidget {
  final bool revealBombs;
  const BoardGrid({super.key, this.revealBombs = false});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          return BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              final cellSize = size / state.cols;
              return Container(
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    for (int r = 0; r < state.rows; r++)
                      for (int c = 0; c < state.cols; c++)
                        Positioned(
                          left: c * cellSize,
                          top: r * cellSize,
                          width: cellSize,
                          height: cellSize,
                          child: _Cell(
                            pos: Position(r, c),
                            size: cellSize,
                            revealBombs: revealBombs,
                          ),
                        ),
                    for (final entry in state.pieces.entries)
                      _Piece(
                        pieceId: entry.key,
                        pos: entry.value,
                        cellSize: cellSize,
                        label: context
                            .watch<GameBloc>()
                            .state
                            .freeNeighborCount(entry.value),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
