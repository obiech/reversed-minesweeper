part of '../widgets/board_grid.dart';

class _Cell extends StatelessWidget {
  final Position pos;
  final double size;
  final bool revealBombs;
  const _Cell({
    required this.pos,
    required this.size,
    required this.revealBombs,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (p, n) {
        final occChanged = p.isOccupied(pos) != n.isOccupied(pos);
        final hiddenChanged =
            p.hiddenBombs.contains(pos) != n.hiddenBombs.contains(pos);
        final explodedChanged =
            p.explodedBombs.contains(pos) != n.explodedBombs.contains(pos);
        final discoveryChanged =
            p.lastDiscovered != n.lastDiscovered &&
            (n.lastDiscovered == pos || p.lastDiscovered == pos);
        final explosionChanged =
            p.lastExploded != n.lastExploded &&
            (n.lastExploded == pos || p.lastExploded == pos);
        return occChanged ||
            hiddenChanged ||
            explodedChanged ||
            discoveryChanged ||
            explosionChanged;
      },
      builder: (context, state) {
        final occupied = state.isOccupied(pos);
        final hiddenBomb = state.hiddenBombs.contains(pos);
        final explodedBomb = state.explodedBombs.contains(pos);
        final justDiscoveredHere = state.lastDiscovered == pos;
        final justExplodedHere = state.lastExploded == pos;

        return DragTarget<PieceDragData>(
          key: ValueKey('cell_${pos.row}_${pos.col}'),
          onWillAccept: (data) {
            if (data == null) return false;
            if (occupied && state.pieceAt(pos) != data.pieceId) return false;
            return true;
          },
          onAccept: (data) {
            if (data.from != pos) {
              context.read<GameBloc>().add(
                PieceDropped(pieceId: data.pieceId, to: pos),
              );
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                color: candidateData.isNotEmpty
                    ? Colors.lightBlue.withOpacity(0.2)
                    : Colors.white,
              ),
              child: Stack(
                children: [
                  // Show hidden bombs when reveal is on (or keep old debug marker if you want)
                  if (revealBombs && hiddenBomb)
                    Center(
                      child: Container(
                        width: size * 0.22,
                        height: size * 0.22,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (explodedBomb)
                    Center(
                      child: Icon(
                        Icons.close,
                        size: size * 0.35,
                        color: Colors.orange.withOpacity(0.5),
                      ),
                    ),
                  if (justDiscoveredHere)
                    IgnorePointer(
                      child: _ExplosionPulse(
                        key: ValueKey(
                          'expl_${state.discoveryTick}_${pos.row}_${pos.col}',
                        ),
                        size: size,
                      ),
                    ),
                  if (justExplodedHere)
                    IgnorePointer(
                      child: _AutoExplosionBurst(
                        key: ValueKey(
                          'auto_${state.explosionTick}_${pos.row}_${pos.col}',
                        ),
                        size: size,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
