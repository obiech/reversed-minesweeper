import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reversed_minesweeper/features/auth/models/user_profile.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository_impl.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late MockGoogleSignIn google;
  late AuthRepository repo;

  setUp(() {
    google = MockGoogleSignIn();
    repo = AuthRepositoryImpl(google: google);
  });

  group('AuthRepository', () {
    test(
      'signInSilently returns UserProfile when GoogleSignInAccount exists',
      () async {
        final acc = MockGoogleSignInAccount();
        when(() => acc.displayName).thenReturn('Test User');
        when(() => acc.email).thenReturn('test@example.com');
        when(() => acc.photoUrl).thenReturn('https://example.com/a.png');

        when(() => google.signInSilently()).thenAnswer((_) async => acc);

        final user = await repo.signInSilently();

        expect(user, isA<UserProfile>());
        expect(user?.name, 'Test User');
        expect(user?.email, 'test@example.com');
        expect(user?.avatarUrl, 'https://example.com/a.png');
      },
    );

    test(
      'signInSilently returns null when GoogleSignInAccount is null',
      () async {
        when(() => google.signInSilently()).thenAnswer((_) async => null);

        final user = await repo.signInSilently();

        expect(user, isNull);
      },
    );

    test('signIn returns UserProfile on success; null on cancel', () async {
      final acc = MockGoogleSignInAccount();
      when(() => acc.displayName).thenReturn('Jane');
      when(() => acc.email).thenReturn('jane@example.com');
      when(() => acc.photoUrl).thenReturn(null);

      when(() => google.signIn()).thenAnswer((_) async => acc);

      final user = await repo.signIn();
      expect(user?.name, 'Jane');
      expect(user?.email, 'jane@example.com');
      expect(user?.avatarUrl, isNull);

      // Cancel flow
      when(() => google.signIn()).thenAnswer((_) async => null);
      final user2 = await repo.signIn();
      expect(user2, isNull);
    });

    test('signOut delegates to GoogleSignIn.signOut', () async {
      when(() => google.signOut()).thenAnswer((_) async {
        return null;
      });

      await repo.signOut();

      verify(() => google.signOut()).called(1);
    });

    test('onUserChanged maps GoogleSignInAccount? to UserProfile?', () async {
      final controller = StreamController<GoogleSignInAccount?>();
      when(
        () => google.onCurrentUserChanged,
      ).thenAnswer((_) => controller.stream);

      final events = <UserProfile?>[];
      final sub = repo.onUserChanged.listen(events.add);

      final acc = MockGoogleSignInAccount();
      when(() => acc.displayName).thenReturn('Stream User');
      when(() => acc.email).thenReturn('stream@example.com');
      when(() => acc.photoUrl).thenReturn('https://example.com/p.png');

      controller.add(acc);
      controller.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await sub.cancel();
      await controller.close();

      expect(events.length, 2);
      expect(events[0]?.name, 'Stream User');
      expect(events[0]?.email, 'stream@example.com');
      expect(events[0]?.avatarUrl, 'https://example.com/p.png');
      expect(events[1], isNull);
    });
  });
}
