import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/core/utils.dart';
import 'package:reddit_clone_provider/features/auth/repositories/auth_repository.dart';
import 'package:reddit_clone_provider/models/user_model.dart';

// user state provider
final userProvider = StateProvider<UserModel?>((ref) => null);

// auth controller provider
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

// create auth state change stream provider
final authStateChangeProvider = StreamProvider((ref) {
  final authStateChange = ref.watch(authControllerProvider.notifier);
  return authStateChange.authStateChange;
});

final getUserProvider = StreamProvider.family((ref, String uid) {
  final getUser = ref.watch(authControllerProvider.notifier);
  return getUser.getUser(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // isLoading

  // authentication state change stream
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  // google signin controller
  void signInGoogle(BuildContext context) async {
    state = true; // isLoading = true

    final user = await _authRepository.googleSignIn();

    state = false; // isLoading = false

    // throw error/success
    user.fold(
      (l) => showSnackBar(context, l.failureMessage),
      (userModel) =>
          _ref.read(userProvider.notifier).update((state) => userModel),
    );
  }

  // get user stream
  Stream<UserModel> getUser(String uid) {
    return _authRepository.getUser(uid);
  }

// sign out
  void signOut() async {
    return _authRepository.signOut();
  }
}
