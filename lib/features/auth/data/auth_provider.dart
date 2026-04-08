import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jalsetu/core/services/firebase_auth_service.dart';
import 'package:jalsetu/features/user/data/user_repository.dart';
import 'package:jalsetu/shared/models/user_model.dart';

// Firebase Auth Service provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// User Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Current app user provider
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return null;

  final userRepo = ref.read(userRepositoryProvider);
  return await userRepo.getUser(user.uid);
});

// Auth Notifier for login/signup/signout actions
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuthService _authService;
  final UserRepository _userRepository;
  final Ref _ref;

  AuthNotifier(this._authService, this._userRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmail(email, password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        state = AsyncValue.error('Password is Incorrect', st);
      } else {
        state = AsyncValue.error(e.message ?? 'Authentication failed', st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? areaId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential =
          await _authService.signUpWithEmail(email, password);
      final role = _userRepository.determineRole(email);
      final appUser = AppUser(
        userId: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        areaId: areaId,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(appUser);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordReset(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      _ref.invalidate(currentUserProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(
    ref.read(firebaseAuthServiceProvider),
    ref.read(userRepositoryProvider),
    ref,
  );
});
