import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:reversed_minesweeper/features/auth/repository/auth_repository.dart';
import '../models/user_profile.dart';

class AuthState extends Equatable {
  final bool loading;
  final UserProfile? user;
  final String? error;

  const AuthState({this.loading = false, this.user, this.error});

  AuthState copyWith({bool? loading, UserProfile? user, String? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, user, error];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  AuthCubit(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    emit(const AuthState(loading: true));
    try {
      // Keep listening for changes
      _repo.onUserChanged.listen(
        (u) => emit(AuthState(loading: false, user: u)),
      );
      final u = await _repo.signInSilently();
      emit(AuthState(loading: false, user: u));
    } catch (e) {
      emit(AuthState(loading: false, user: null, error: e.toString()));
    }
  }

  Future<void> signInAsGuest() async {
    // Emit a simple guest profile (no backend, no Google)
    emit(
      const AuthState(
        loading: false,
        user: UserProfile(name: 'Guest', email: null, avatarUrl: null),
      ),
    );
  }

  Future<void> signIn() async {
    emit(state.copyWith(loading: true));
    try {
      final u = await _repo.signIn();
      emit(AuthState(loading: false, user: u));
    } catch (e) {
      emit(AuthState(loading: false, user: null, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState(loading: false, user: null));
  }
}
