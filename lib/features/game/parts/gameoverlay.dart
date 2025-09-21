part of '../screens/game_page.dart';

class _GameOverOverlay extends StatelessWidget {
  final int discovered;
  final VoidCallback onPlayAgain;

  const _GameOverOverlay({
    super.key,
    required this.discovered,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Opacity(
                opacity: 1.0,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Game Over',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discovered bombs: $discovered',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onPlayAgain,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
