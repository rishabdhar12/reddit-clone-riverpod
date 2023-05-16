import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_provider/features/auth/repositories/auth_repository.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    authRepository: ref.read(authRepositoryProvider),
  ),
);

class AuthController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  void signInGoogle() {
    _authRepository.googleSignIn();
  }
}
