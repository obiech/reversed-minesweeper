part of '../screens/game_page.dart';

class _Header extends StatelessWidget {
  final double progress;
  final int secondsLeft;
  const _Header({required this.progress, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 4,
              runSpacing: 0,

              children: [
                _chip('Total', state.totalBombs, Colors.blueGrey),
                _chip('Discovered', state.discoveredCount, Colors.green),
                _chip('Exploded', state.explodedBombs.length, Colors.orange),
                _chip('Hidden', state.hiddenBombs.length, Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: state.isOver ? 0 : progress.clamp(0.0, 1.0),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(state.isOver ? '-' : '${secondsLeft}s'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, int value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }
}
