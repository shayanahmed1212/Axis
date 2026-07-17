import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/features/auth/domain/app_user.dart';
import 'package:axis/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Future<AppUser> signIn(String email, String password) {
    return _repository.signInWithEmailAndPassword(email, password);
  }

  Future<AppUser> register(String email, String password, {String? displayName}) {
    return _repository.registerWithEmailAndPassword(email, password, displayName: displayName);
  }

  Future<void> signOut() {
    return _repository.signOut();
  }

  Future<void> resetPassword(String email) {
    return _repository.resetPassword(email);
  }

  Future<void> updateDisplayName(String displayName) {
    return _repository.updateDisplayName(displayName);
  }

  Future<void> changePassword(String currentPassword, String newPassword) {
    return _repository.changePassword(currentPassword, newPassword);
  }

  Future<void> updatePhotoURL(String url) {
    return _repository.updatePhotoURL(url);
  }
}
