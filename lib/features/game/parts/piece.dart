part of '../widgets/board_grid.dart';

class _Piece extends StatelessWidget {
  final int pieceId;
  final Position pos;
  final double cellSize;
  final int label;
  const _Piece({
    required this.pieceId,
    required this.pos,
    required this.cellSize,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final offsetLeft = pos.col * cellSize;
    final offsetTop = pos.row * cellSize;
    final piece = _PieceWidget(size: cellSize * 0.8, label: '$label');

    return Positioned(
      left: offsetLeft + cellSize * 0.1,
      top: offsetTop + cellSize * 0.1,
      child: Draggable<PieceDragData>(
        data: PieceDragData(pieceId: pieceId, from: pos),
        feedback: Material(
          color: Colors.transparent,
          child: _PieceWidget(
            size: cellSize * 0.9,
            label: '$label',
            elevated: true,
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: piece,
      ),
    );
  }
}
