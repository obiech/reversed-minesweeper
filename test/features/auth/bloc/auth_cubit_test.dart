import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reversed_minesweeper/features/auth/bloc/auth_cubit.dart';
import 'package:reversed_minesweeper/features/auth/models/user_profile.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  const user = UserProfile(
    name: 'Test User',
    email: 'test@example.com',
    avatarUrl: 'https://example.com/a.png',
  );

  setUp(() {
    repo = MockAuthRepository();
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits user after silent sign-in succeeds on init',
      build: () {
        when(
          () => repo.onUserChanged,
        ).thenAnswer((_) => const Stream<UserProfile?>.empty());
        when(() => repo.signInSilently()).thenAnswer((_) async => user);
        return AuthCubit(repo);
      },
      wait: const Duration(milliseconds: 20),
      verify: (cubit) {
        expect(cubit.state.loading, false);
        expect(cubit.state.user, equals(user));
        expect(cubit.state.error, isNull);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signIn() sets loading then emits user on success',
      build: () {
        when(
          () => repo.onUserChanged,
        ).thenAnswer((_) => const Stream<UserProfile?>.empty());
        when(() => repo.signInSilently()).thenAnswer((_) async => null);
        when(() => repo.signIn()).thenAnswer((_) async => user);
        return AuthCubit(repo);
      },
      act: (cubit) async {
        await cubit.signIn();
      },
      verify: (cubit) {
        expect(cubit.state.loading, false);
        expect(cubit.state.user, equals(user));
        expect(cubit.state.error, isNull);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signIn() emits error on failure',
      build: () {
        when(
          () => repo.onUserChanged,
        ).thenAnswer((_) => const Stream<UserProfile?>.empty());
        when(() => repo.signInSilently()).thenAnswer((_) async => null);
        when(() => repo.signIn()).thenThrow(Exception('oops'));
        return AuthCubit(repo);
      },
      act: (cubit) async {
        // Allow _init to complete first to avoid race overwriting the error state
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await cubit.signIn();
      },
      verify: (cubit) {
        expect(cubit.state.loading, false);
        expect(cubit.state.user, isNull);
        expect(cubit.state.error, isNotNull);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signOut() clears user',
      build: () {
        when(
          () => repo.onUserChanged,
        ).thenAnswer((_) => const Stream<UserProfile?>.empty());
        when(() => repo.signInSilently()).thenAnswer((_) async => user);
        when(() => repo.signOut()).thenAnswer((_) async {});
        return AuthCubit(repo);
      },
      act: (cubit) async {
        // Ensure initial user is present
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await cubit.signOut();
      },
      verify: (cubit) {
        expect(cubit.state.loading, false);
        expect(cubit.state.user, isNull);
        expect(cubit.state.error, isNull);
      },
    );
  });
}
