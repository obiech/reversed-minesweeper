part of '../widgets/board_grid.dart';

class _PieceWidget extends StatelessWidget {
  final double size;
  final String label;
  final bool elevated;
  const _PieceWidget({
    required this.size,
    required this.label,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.indigo.shade400,
        shape: BoxShape.circle,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
