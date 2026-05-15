import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _repo.getMe();
        emit(AuthAuthenticated(user));
      } catch (_) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data = await _repo.login(event.email, event.password);
      emit(AuthAuthenticated(data['user'] as Map<String, dynamic>));
    } on AppFailure catch (f) {
      emit(AuthFailure(f.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignup(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final data = await _repo.signup(event.name, event.email, event.password);
      emit(AuthAuthenticated(data['user'] as Map<String, dynamic>));
    } on AppFailure catch (f) {
      emit(AuthFailure(f.message));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }
}