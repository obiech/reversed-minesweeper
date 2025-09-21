import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reversed_minesweeper/features/auth/bloc/auth_cubit.dart';
import 'package:reversed_minesweeper/features/game/repository/binance_ticker_repository.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/board_grid.dart';

part '../parts/header.dart';
part '../parts/gameoverlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  Timer? _bombTimer;
  late final BinanceTickerRepository _ticker;
  StreamSubscription<int>? _priceSub;
  bool _revealBombs = false;

  // Haptics trackers
  int _lastDiscoveryTick = 0;
  int _lastExplosionTick = 0;

  // countdown animation controller
  late final AnimationController _countdown;

  @override
  void initState() {
    super.initState();

    _countdown =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(() {
            if (mounted) setState(() {});
          });

    // Initialize game
    context.read<GameBloc>().add(
      const InitializeGame(
        rows: 10,
        cols: 10,
        initialBombs: 20,
        maxBombs: 30,
        initialPieces: 40,
      ),
    );

    // Start timers
    _startOrRestartTimer();

    // Binance
    _ticker = context.read<BinanceTickerRepository>()..connect();
    _priceSub = _ticker.priceIntStream.listen(
      (priceInt) => context.read<GameBloc>().add(PriceUpdateInt(priceInt)),
    );
  }

  void _startNewGame(int rows, int cols) {
    final cells = rows * cols;
    final initialBombs = (cells * 0.2).floor().clamp(1, cells - 1);
    final maxBombs = (cells * 0.3).floor().clamp(initialBombs, cells - 1);
    final initialPieces = (cells * 0.4).floor().clamp(0, cells - initialBombs);

    context.read<GameBloc>().add(
      InitializeGame(
        rows: rows,
        cols: cols,
        initialBombs: initialBombs,
        maxBombs: maxBombs,
        initialPieces: initialPieces,
      ),
    );
    _startOrRestartTimer(); // keeps countdown in sync
  }

  double get _progress => _countdown.value.clamp(0.0, 1.0);
  int get _secondsLeft {
    if (_progress <= 0 || _progress >= 1) return 0;
    final remaining = 10 - (_progress * 10);
    return remaining.ceil().clamp(0, 10);
  }

  @override
  void dispose() {
    _bombTimer?.cancel();
    _priceSub?.cancel();
    _ticker.close();
    _countdown.dispose(); // NEW
    super.dispose();
  }

  void _startOrRestartTimer() {
    _bombTimer?.cancel();
    // Restart smooth UI countdown
    _countdown.stop();
    _countdown.value = 0;
    _countdown.forward();

    _bombTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<GameBloc>().add(const TimerTick());
      // Reset the UI countdown in sync with the logic tick
      _countdown.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) async {
        if (state.discoveryTick > _lastDiscoveryTick) {
          _lastDiscoveryTick = state.discoveryTick;
          await HapticFeedback.vibrate();
        }
        if (state.explosionTick > _lastExplosionTick) {
          _lastExplosionTick = state.explosionTick;
          await HapticFeedback.vibrate();
        }

        if (state.isOver) {
          _bombTimer?.cancel();
          _countdown.stop();
        } else {
          if (_bombTimer == null || !_bombTimer!.isActive) {
            _startOrRestartTimer();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reversed Minesweeper'),
            actions: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, aState) {
                  final user = aState.user;
                  if (user == null) return const SizedBox.shrink();
                  final name = user.name?.trim() ?? 'G';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
                  return Row(
                    children: [
                      IconButton(
                        tooltip: _revealBombs ? 'Hide bombs' : 'Reveal bombs',
                        icon: Icon(
                          _revealBombs
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _revealBombs = !_revealBombs),
                      ),
                      if (user.avatarUrl == null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.indigo.shade200,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(user.avatarUrl!),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Sign out',
                        icon: const Icon(Icons.logout),
                        onPressed: () => context.read<AuthCubit>().signOut(),
                      ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case '8x8':
                      _startNewGame(8, 8);
                      break;
                    case '10x10':
                      _startNewGame(10, 10);
                      break;
                    case '12x12':
                      _startNewGame(12, 12);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: '8x8', child: Text('Board: 8 x 8')),
                  PopupMenuItem(value: '10x10', child: Text('Board: 10 x 10')),
                  PopupMenuItem(value: '12x12', child: Text('Board: 12 x 12')),
                ],
                icon: const Icon(Icons.grid_4x4),
                tooltip: 'Change board size',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _startNewGame(10, 10); // default reset
                },
              ),
            ],
          ),
          body: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _Header(
                          progress: _progress,
                          secondsLeft: _secondsLeft,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: BoardGrid(
                              revealBombs: _revealBombs,
                            ), // pass it here
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  if (state.isOver)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _GameOverOverlay(
                        key: const ValueKey('game_over_overlay'),
                        discovered: state.discoveredCount,
                        onPlayAgain: () =>
                            _startNewGame(state.rows, state.cols),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
