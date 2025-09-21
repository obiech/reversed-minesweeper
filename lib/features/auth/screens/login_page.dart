import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign-in failed: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.videogame_asset,
                    size: 72,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reversed Minesweeper',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: state.loading
                        ? null
                        : () => context.read<AuthCubit>().signIn(),
                    icon: Image.asset(
                      'assets/google.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, size: 18),
                    ),
                    label: Text(
                      state.loading ? 'Signing in...' : 'Continue with Google',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.loading
                        ? null
                        : () => context.read<AuthCubit>().signInAsGuest(),
                    icon: const Icon(Icons.person),
                    label: const Text('Play as Guest'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
