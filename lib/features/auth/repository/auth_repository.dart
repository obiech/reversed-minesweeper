import '../models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> get onUserChanged;

  Future<UserProfile?> signInSilently();

  Future<UserProfile?> signIn();

  Future<void> signOut();
}
