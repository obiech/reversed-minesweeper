part of '../widgets/board_grid.dart';

class _ExplosionPulse extends StatelessWidget {
  final double size;
  const _ExplosionPulse({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          final scale = 0.7 + 0.6 * t;
          final opacity = 1.0 - t;
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.yellow.shade300,
                      Colors.orange.shade600,
                      Colors.red.shade700,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.orangeAccent, blurRadius: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
