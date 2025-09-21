import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository_impl.dart';
import 'package:reversed_minesweeper/features/game/repository/binance_ticker_repository.dart';
import 'package:reversed_minesweeper/features/game/repository/binance_ticker_repository_impl.dart';
import 'features/game/bloc/game_bloc.dart';
import 'features/game/screens/game_page.dart';
import 'features/auth/screens/login_page.dart';
import 'features/auth/bloc/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReversedMinesweeperApp());
}

class ReversedMinesweeperApp extends StatelessWidget {
  const ReversedMinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<BinanceTickerRepository>(
          create: (context) => BinanceTickerRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(RepositoryProvider.of<AuthRepository>(context)),
          ),
          BlocProvider(create: (context) => GameBloc()),
        ],
        child: MaterialApp(
          title: 'Reversed Minesweeper',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const _HomeSwitcher(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class _HomeSwitcher extends StatelessWidget {
  const _HomeSwitcher();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (p, n) => p.user != n.user || p.loading != n.loading,
      builder: (context, state) {
        if (state.user == null && !state.loading) {
          return const LoginPage();
        }
        if (state.user != null) {
          return const GamePage();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
