part of '../widgets/board_grid.dart';

class _AutoExplosionBurst extends StatelessWidget {
  final double size;
  const _AutoExplosionBurst({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final ringSize = size * (0.4 + 0.5 * t);
          final opacity = 1.0 - t;
          return Opacity(
            opacity: opacity,
            child: Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepOrange.shade400,
                  width: 3.0 * (1 - 0.6 * t),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.orangeAccent, blurRadius: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
