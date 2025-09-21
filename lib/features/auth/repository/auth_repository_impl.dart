import 'package:google_sign_in/google_sign_in.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository.dart';
import '../models/user_profile.dart';

class AuthRepositoryImpl extends AuthRepository {
  final GoogleSignIn _google;
  AuthRepositoryImpl({GoogleSignIn? google})
    : _google = google ?? GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Stream<UserProfile?> get onUserChanged =>
      _google.onCurrentUserChanged.map(_toProfile);

  @override
  Future<UserProfile?> signInSilently() async {
    final acc = await _google.signInSilently();
    return _toProfile(acc);
  }

  @override
  Future<UserProfile?> signIn() async {
    final acc = await _google.signIn();
    return _toProfile(acc);
  }

  @override
  Future<void> signOut() => _google.signOut();

  UserProfile? _toProfile(GoogleSignInAccount? acc) {
    if (acc == null) return null;
    return UserProfile(
      name: acc.displayName,
      email: acc.email,
      avatarUrl: acc.photoUrl,
    );
  }
}
